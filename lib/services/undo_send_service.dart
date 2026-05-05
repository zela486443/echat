import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Manages a 5-second undo window for sent messages.
/// Call [scheduleUndo] immediately after sending; call [cancelUndo] if the
/// user taps "Undo", otherwise the message is committed permanently.
class UndoSendService {
  final _client = Supabase.instance.client;

  // messageId → (timer, pendingRow)
  final Map<String, _PendingUndo> _pending = {};

  /// Schedule a 5-second window to undo a sent message.
  /// [onCountdown] fires every second with the remaining seconds.
  /// [onExpired]  fires when the window closes (message finalised).
  void scheduleUndo({
    required String messageId,
    required String chatId,
    required Map<String, dynamic> messageRow,
    void Function(int remaining)? onCountdown,
    void Function()? onExpired,
  }) {
    // Cancel any existing window for this message.
    cancelUndo(messageId, commit: false);

    int remaining = 5;

    final timer = Timer.periodic(const Duration(seconds: 1), (t) async {
      remaining--;
      onCountdown?.call(remaining);

      if (remaining <= 0) {
        t.cancel();
        _pending.remove(messageId);
        // Persist message to Supabase now that the window has closed.
        await _commitMessage(messageRow);
        onExpired?.call();
      }
    });

    _pending[messageId] = _PendingUndo(
      timer: timer,
      chatId: chatId,
      messageRow: messageRow,
    );
  }

  /// Cancel the undo window.
  /// If [commit] is true the message is still saved (default = true).
  Future<void> cancelUndo(String messageId, {bool commit = true}) async {
    final pending = _pending.remove(messageId);
    if (pending == null) return;
    pending.timer.cancel();
    if (commit) {
      await _commitMessage(pending.messageRow);
    }
  }

  /// Undo (delete) a message within its 5-second window.
  /// Returns true if the undo was successful, false if the window had already
  /// closed.
  Future<bool> undoSend(String messageId) async {
    final pending = _pending.remove(messageId);
    if (pending == null) return false; // window already closed
    pending.timer.cancel();
    // Do NOT commit — the message never reaches the DB.
    return true;
  }

  bool hasPendingUndo(String messageId) => _pending.containsKey(messageId);

  Future<void> _commitMessage(Map<String, dynamic> row) async {
    try {
      await _client.from('messages').insert(row);
    } catch (e) {
      // Log but don't crash — the user already saw the optimistic UI.
      // ignore: avoid_print
      print('[UndoSendService] commit failed: $e');
    }
  }

  void dispose() {
    for (final p in _pending.values) {
      p.timer.cancel();
    }
    _pending.clear();
  }
}

class _PendingUndo {
  final Timer timer;
  final String chatId;
  final Map<String, dynamic> messageRow;
  _PendingUndo({required this.timer, required this.chatId, required this.messageRow});
}

// ─── Riverpod Provider ────────────────────────────────────────────────────────
final undoSendServiceProvider = Provider<UndoSendService>((ref) {
  final svc = UndoSendService();
  ref.onDispose(svc.dispose);
  return svc;
});
