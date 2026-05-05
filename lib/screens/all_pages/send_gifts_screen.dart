import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glassmorphic_container.dart';
import '../../widgets/aurora_gradient_bg.dart';

class SendGiftsScreen extends StatefulWidget {
  final String recipientName;
  const SendGiftsScreen({super.key, required this.recipientName});

  @override
  State<SendGiftsScreen> createState() => _SendGiftsScreenState();
}

class _SendGiftsScreenState extends State<SendGiftsScreen> {
  int _selectedAmount = 100;
  final List<int> _amounts = [50, 100, 500, 1000, 5000];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Send Gift', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: AuroraGradientBg(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 40),
              CircleAvatar(radius: 40, backgroundColor: Colors.amber, child: Icon(Icons.star, size: 50, color: Colors.white)),
              const SizedBox(height: 24),
              Text('Send Stars to ${widget.recipientName}', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              const Text('Stars can be used to unlock premium features, boost channels, or withdraw as real balance.', textAlign: TextAlign.center, style: TextStyle(color: Colors.white54, fontSize: 13)),
              const SizedBox(height: 48),
              _buildAmountGrid(),
              const Spacer(),
              _buildBalanceInfo(),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () => _handleSend(),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                  child: Text('Send $_selectedAmount Stars', style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAmountGrid() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      alignment: WrapAlignment.center,
      children: _amounts.map((amount) {
        final isSelected = _selectedAmount == amount;
        return GestureDetector(
          onTap: () => setState(() => _selectedAmount = amount),
          child: GlassmorphicContainer(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            borderRadius: 16,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 16),
                const SizedBox(width: 8),
                Text('$amount', style: TextStyle(color: isSelected ? Colors.amber : Colors.white, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBalanceInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(16)),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Your Balance:', style: TextStyle(color: Colors.white54, fontSize: 12)),
          SizedBox(width: 8),
          Icon(Icons.star, color: Colors.amber, size: 14),
          SizedBox(width: 4),
          Text('12,450', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  void _handleSend() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF222222),
        title: const Text('Confirm', style: TextStyle(color: Colors.white)),
        content: Text('Send $_selectedAmount Stars to ${widget.recipientName}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Stars sent successfully!'), backgroundColor: Colors.amber));
              Navigator.pop(context);
            }, 
            child: const Text('Send', style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold))
          ),
        ],
      ),
    );
  }
}
