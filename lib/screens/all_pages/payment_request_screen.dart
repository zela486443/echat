import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class PaymentRequestScreen extends ConsumerStatefulWidget {
  const PaymentRequestScreen({super.key});

  @override
  ConsumerState<PaymentRequestScreen> createState() => _PaymentRequestScreenState();
}

class _PaymentRequestScreenState extends ConsumerState<PaymentRequestScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  String? _generatedLink;

  void _handleGenerate() {
    if (_amountController.text.isEmpty) return;
    setState(() {
      _generatedLink = 'https://echats.et/pay/zola/${_amountController.text}';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => context.pop()),
        title: const Text('Payment Request Link', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildInputCard(),
            if (_generatedLink != null) ...[
              const SizedBox(height: 24),
              _buildQRCard(),
              const SizedBox(height: 24),
              _buildActionButtons(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInputCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.white12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Amount (ETB)', style: TextStyle(color: Colors.white38, fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextField(controller: _amountController, keyboardType: TextInputType.number, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold), decoration: InputDecoration(hintText: '0.00', hintStyle: const TextStyle(color: Colors.white24), filled: true, fillColor: Colors.white.withOpacity(0.05), border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none), contentPadding: const EdgeInsets.all(16))),
          const SizedBox(height: 20),
          const Text('Note (optional)', style: TextStyle(color: Colors.white38, fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextField(controller: _noteController, style: const TextStyle(color: Colors.white), decoration: InputDecoration(hintText: "What's it for?", hintStyle: const TextStyle(color: Colors.white24), filled: true, fillColor: Colors.white.withOpacity(0.05), border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none), contentPadding: const EdgeInsets.all(16))),
          const SizedBox(height: 24),
          SizedBox(width: double.infinity, height: 56, child: ElevatedButton.icon(onPressed: _handleGenerate, icon: const Icon(Icons.link, color: Colors.white), label: const Text('Generate Link', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF0050), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))))),
        ],
      ),
    );
  }

  Widget _buildQRCard() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.white12)),
      child: Column(
        children: [
          Container(width: 200, height: 200, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)), child: const Icon(Icons.qr_code_2, size: 160, color: Colors.black)),
          const SizedBox(height: 16),
          Text('Scan to pay ${_amountController.text} ETB', style: const TextStyle(color: Colors.white54, fontSize: 14)),
          if (_noteController.text.isNotEmpty) Text(_noteController.text, style: const TextStyle(color: Colors.white24, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(16)), child: Text(_generatedLink!, style: const TextStyle(color: Colors.white38, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis)),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: SizedBox(height: 56, child: OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.copy, color: Colors.white), label: const Text('Copy Link', style: TextStyle(color: Colors.white)), style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.white12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)))))),
            const SizedBox(width: 16),
            Expanded(child: SizedBox(height: 56, child: ElevatedButton.icon(onPressed: () {}, icon: const Icon(Icons.share, color: Colors.white), label: const Text('Share', style: TextStyle(color: Colors.white)), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF0050), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)))))),
          ],
        ),
      ],
    );
  }
}
