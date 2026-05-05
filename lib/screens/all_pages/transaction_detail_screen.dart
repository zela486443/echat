import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import '../../theme/app_theme.dart';

const _kBg   = Color(0xFF0D0A1A);
const _kCard = Color(0xFF16102A);
const _kP    = Color(0xFF7C3AED);

String _fmtETB(double n) => NumberFormat('#,##0.00', 'en_US').format(n);

class TransactionDetailScreen extends StatefulWidget {
  final String transactionId;
  const TransactionDetailScreen({super.key, required this.transactionId});

  @override
  State<TransactionDetailScreen> createState() => _TransactionDetailScreenState();
}

class _TransactionDetailScreenState extends State<TransactionDetailScreen> with SingleTickerProviderStateMixin {
  Map<String, dynamic>? _tx;
  bool _loading = true;
  bool _copied = false;
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero)
        .animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));
    _loadTx();
  }

  @override
  void dispose() { _animCtrl.dispose(); super.dispose(); }

  Future<void> _loadTx() async {
    try {
      final data = await Supabase.instance.client
          .from('wallet_transactions')
          .select('*')
          .eq('id', widget.transactionId)
          .maybeSingle();
      if (data == null && mounted) { context.go('/wallet'); return; }
      setState(() { _tx = data; _loading = false; });
      _animCtrl.forward();
    } catch (_) {
      if (mounted) context.go('/transaction-history');
    }
  }

  String get _shortId => 'TXN${widget.transactionId.substring(widget.transactionId.length - 9).toUpperCase()}';
  bool get _isIn => ['transfer_in', 'deposit'].contains(_tx?['type']);
  double get _amount => (_tx?['amount'] as num?)?.toDouble() ?? 0;
  String get _status => _tx?['status'] ?? 'completed';
  Map<String, dynamic> get _meta => Map<String, dynamic>.from(_tx?['metadata'] ?? {});
  String get _fromTo => _isIn
      ? (_meta['sender_name'] ?? _meta['sender_username'] ?? 'Wallet').toString()
      : (_meta['recipient_name'] ?? _meta['recipient_username'] ?? 'Wallet').toString();
  String get _method => (_meta['method'] ?? 'Wallet Balance').toString();
  String get _note => (_meta['note'] ?? _tx?['description'] ?? '').toString();

  Color _statusColor() {
    switch (_status) {
      case 'completed': return const Color(0xFF10b981);
      case 'pending':   return const Color(0xFFf59e0b);
      case 'failed':    return const Color(0xFFef4444);
      case 'reversed':  return const Color(0xFFfb923c);
      default:          return const Color(0xFF10b981);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(backgroundColor: _kBg, body: Center(child: CircularProgressIndicator(color: _kP)));
    }
    if (_tx == null) return const SizedBox.shrink();

    final statusColor = _statusColor();
    final createdAt = DateTime.tryParse(_tx?['created_at'] ?? '') ?? DateTime.now();
    final dateStr = DateFormat('MMM d, yyyy, h:mm a').format(createdAt);

    return Scaffold(
      backgroundColor: _kBg,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: SlideTransition(
            position: _slideAnim,
            child: CustomScrollView(
              slivers: [
                // Header
                SliverToBoxAdapter(child: Padding(
                  padding: const EdgeInsets.fromLTRB(4, 8, 4, 0),
                  child: Row(children: [
                    IconButton(icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20), onPressed: () => context.pop()),
                    const Expanded(child: Center(child: Text('Transaction Detail', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)))),
                    const SizedBox(width: 48),
                  ]),
                )),

                // Hero
                SliverToBoxAdapter(child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 28, 16, 24),
                  child: Column(children: [
                    // Double ring
                    Container(
                      width: 96, height: 96,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: _kP.withOpacity(0.25), width: 2),
                        color: _kP.withOpacity(0.07),
                      ),
                      child: Center(child: Container(
                        width: 64, height: 64,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(colors: [Color(0xFF7C3AED), Color(0xFFa855f7)]),
                          boxShadow: [BoxShadow(color: _kP.withOpacity(0.5), blurRadius: 20)],
                        ),
                        child: const Icon(Icons.check, color: Colors.white, size: 28),
                      )),
                    ),
                    const SizedBox(height: 20),

                    // Amount
                    Text(
                      '${_isIn ? '+' : '-'}${_fmtETB(_amount)} ETB',
                      style: const TextStyle(color: Colors.white, fontSize: 38, fontWeight: FontWeight.w900, letterSpacing: -0.8),
                    ),
                    const SizedBox(height: 10),

                    // Status badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Container(width: 8, height: 8, decoration: BoxDecoration(shape: BoxShape.circle, color: statusColor)),
                        const SizedBox(width: 6),
                        Text(_status.toUpperCase(), style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                      ]),
                    ),
                  ]),
                )),

                // Details card
                SliverToBoxAdapter(child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('Details', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(color: _kCard, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white.withOpacity(0.07))),
                      child: Column(children: [
                        _detailRow('From/To', _fromTo, icon: LucideIcons.user, isFirst: true),
                        _detailRow('Transaction ID', _shortId, isMono: true, canCopy: true),
                        _detailRow('Date & Time', dateStr),
                        _detailRow('Payment Method', _method, icon: LucideIcons.wallet),
                        if (_note.isNotEmpty) _detailRow('Reference Note', '"$_note"', isLast: true, isItalic: true),
                        if (_note.isEmpty) _detailRow('Payment Method', _method, icon: LucideIcons.wallet, isLast: true),
                      ]),
                    ),
                  ]),
                )),

                // Official receipt card
                SliverToBoxAdapter(child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: _kCard, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white.withOpacity(0.07))),
                    child: Row(children: [
                      Container(
                        width: 44, height: 44,
                        decoration: BoxDecoration(color: _kP.withOpacity(0.2), borderRadius: BorderRadius.circular(14)),
                        child: const Icon(LucideIcons.fileText, color: Color(0xFFa78bfa), size: 20),
                      ),
                      const SizedBox(width: 12),
                      const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('Official E-Receipt', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                        SizedBox(height: 2),
                        Text('Validated by Wallet Network', style: TextStyle(color: Colors.white38, fontSize: 12)),
                      ]),
                    ]),
                  ),
                )),

                // Download button
                SliverToBoxAdapter(child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: GestureDetector(
                    onTap: _downloadReceipt,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Color(0xFF7C3AED), Color(0xFF9333EA)]),
                        borderRadius: BorderRadius.circular(50),
                        boxShadow: [BoxShadow(color: _kP.withOpacity(0.45), blurRadius: 24)],
                      ),
                      child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Icon(LucideIcons.download, color: Colors.white, size: 18),
                        SizedBox(width: 8),
                        Text('Download Receipt', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      ]),
                    ),
                  ),
                )),

                // Report issue
                SliverToBoxAdapter(child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  child: GestureDetector(
                    onTap: () => _showSnack('Support team will be contacted'),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(color: Colors.white.withOpacity(0.1)),
                      ),
                      child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Icon(LucideIcons.alertCircle, color: Colors.white60, size: 18),
                        SizedBox(width: 8),
                        Text('Report an Issue', style: TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.bold)),
                      ]),
                    ),
                  ),
                )),

                // Bottom indicator
                const SliverToBoxAdapter(child: Center(child: Padding(
                  padding: EdgeInsets.only(bottom: 32),
                  child: SizedBox(width: 40, height: 4, child: DecoratedBox(decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.all(Radius.circular(2))))),
                ))),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value, {IconData? icon, bool isMono = false, bool canCopy = false, bool isFirst = false, bool isLast = false, bool isItalic = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        border: isLast ? null : Border(bottom: BorderSide(color: Colors.white.withOpacity(0.06))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white38, fontSize: 13)),
          Row(children: [
            if (icon != null) ...[
              Container(width: 28, height: 28, decoration: BoxDecoration(color: _kP.withOpacity(0.2), shape: BoxShape.circle), child: Icon(icon, color: const Color(0xFFa78bfa), size: 13)),
              const SizedBox(width: 6),
            ],
            Text(value, style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold, fontFamily: isMono ? 'monospace' : null, fontStyle: isItalic ? FontStyle.italic : FontStyle.normal)),
            if (canCopy) ...[
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () { Clipboard.setData(ClipboardData(text: value)); setState(() => _copied = true); Future.delayed(const Duration(seconds: 2), () { if (mounted) setState(() => _copied = false); }); _showSnack('Transaction ID copied'); },
                child: Icon(_copied ? Icons.check : LucideIcons.copy, color: _copied ? const Color(0xFF10b981) : Colors.white30, size: 15),
              ),
            ],
          ]),
        ],
      ),
    );
  }

  void _downloadReceipt() {
    // On mobile, copy to clipboard as text
    final lines = [
      '═══════════════════════════════',
      '        ECHAT OFFICIAL E-RECEIPT',
      '  Validated by Wallet Network',
      '═══════════════════════════════',
      'Amount     : ${_isIn ? '+' : '-'}${_fmtETB(_amount)} ETB',
      'From/To    : $_fromTo',
      'Trans. ID  : $_shortId',
      'Date & Time: ${DateFormat('MMM d, yyyy, h:mm a').format(DateTime.tryParse(_tx?['created_at'] ?? '') ?? DateTime.now())}',
      'Method     : $_method',
      if (_note.isNotEmpty) 'Note       : $_note',
      'Status     : ${_status.toUpperCase()}',
      '═══════════════════════════════',
    ].join('\n');
    Clipboard.setData(ClipboardData(text: lines));
    _showSnack('Receipt copied to clipboard');
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating, backgroundColor: _kP));
  }
}
