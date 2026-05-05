import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Maps exactly to the Supabase Edge Functions residing in `supabase/functions/`
class BackendFunctionsService {
  final SupabaseClient _client = Supabase.instance.client;

  // 1. ai-chat
  Future<String> invokeAiChat(String message, String conversationId) async {
    final response = await _client.functions.invoke('ai-chat', body: {
      'message': message,
      'conversation_id': conversationId,
    });
    return response.data['reply'] as String;
  }

  // 2. ai-image
  Future<String> invokeAiImageGeneration(String prompt) async {
    final response = await _client.functions.invoke('ai-image', body: {
      'prompt': prompt,
    });
    return response.data['image_url'] as String;
  }

  // 3. send-call-notification
  Future<void> notifyIncomingCall(String receiverId, String type, String roomId) async {
    await _client.functions.invoke('send-call-notification', body: {
      'receiver_id': receiverId,
      'call_type': type,
      'room_id': roomId,
    });
  }

  // 4. wallet-activate
  Future<void> activateWallet() async {
    await _client.functions.invoke('wallet-activate');
  }

  // 5. wallet-balance
  Future<double> getWalletBalance() async {
    final response = await _client.functions.invoke('wallet-balance');
    return (response.data['balance'] as num).toDouble();
  }

  // 6. wallet-deposit
  Future<Map<String, dynamic>> initiateDeposit(double amount, String method) async {
    final response = await _client.functions.invoke('wallet-deposit', body: {
      'amount': amount,
      'method': method,
    });
    return response.data as Map<String, dynamic>; // Usually includes a checkout URL or intent
  }

  // 7. wallet-transfer
  Future<bool> transferFunds(String receiverPhoneOrUsername, double amount, String note) async {
    final response = await _client.functions.invoke('wallet-transfer', body: {
      'receiver_identifier': receiverPhoneOrUsername,
      'amount': amount,
      'note': note,
    });
    return response.data['success'] as bool;
  }
}

final backendFunctionsProvider = Provider((ref) => BackendFunctionsService());
