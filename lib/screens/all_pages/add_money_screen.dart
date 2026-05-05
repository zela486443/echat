import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../services/wallet_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glassmorphic_container.dart';
import 'package:intl/intl.dart';

class AddMoneyScreen extends ConsumerStatefulWidget {
  const AddMoneyScreen({super.key});

  @override
  ConsumerState<AddMoneyScreen> createState() => _AddMoneyScreenState();
}

class _AddMoneyScreenState extends ConsumerState<AddMoneyScreen> {
  final TextEditingController _amountController = TextEditingController(text: "2500");
  String _selectedMethod = "telebirr";
  bool _isConfirmStep = false;
  bool _isLoading = false;

  final List<Map<String, dynamic>> _methods = [
    { 'id': "telebirr", 'label': "Telebirr", 'sub': "Instant deposit", 'icon': Icons.account_balance_wallet, 'color': Color(0xFFA78BFA) },
    { 'id': "cbebirr", 'label': "CBEBirr", 'sub': "Commercial Bank of Ethiopia", 'icon': Icons.account_balance, 'color': const Color(0xFF2563EB) },
    { 'id': "awash", 'label': "Awash Bank", 'sub': "Secure bank transfer", 'icon': Icons.payments, 'color': Color(0xFF34D399) },
    { 'id': "card", 'label': "Credit/Debit Card", 'sub': "Visa, Mastercard, Amex", 'icon': Icons.credit_card, 'color': Color(0xFFFBBF24) },
  ];

  final List<int> _quickAmounts = [100, 250, 500, 1000, 2500, 5000];

  void _handleDeposit() async {
    setState(() => _isLoading = true);
    final amount = double.tryParse(_amountController.text) ?? 0;
    final method = _methods.firstWhere((m) => m['id'] == _selectedMethod)['label'];
    
    final result = await WalletService().deposit(amount, method);
    
    if (mounted) {
      setState(() => _isLoading = false);
      if (result['success'] == true) {
        context.push('/transaction-receipt', extra: result['transaction']);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['error'] ?? 'Failed to add money')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: "ETB ", decimalDigits: 2);
    final numericAmount = double.tryParse(_amountController.text) ?? 0;

    return Scaffold(
      backgroundColor: const Color(0xFF0D0A1A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_left, size: 32),
          onPressed: () {
            if (_isConfirmStep) {
              setState(() => _isConfirmStep = false);
            } else {
              context.pop();
            }
          },
        ),
        title: const Text('Add Money', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Dots indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(width: 28, height: 4, decoration: BoxDecoration(color: AppTheme.primary, borderRadius: BorderRadius.circular(2))),
              const SizedBox(width: 8),
              Container(width: 16, height: 4, decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(2))),
              const SizedBox(width: 8),
              Container(width: 16, height: 4, decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(2))),
            ],
          ),
          const SizedBox(height: 24),
          
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _isConfirmStep ? _buildConfirmStep(currencyFormat, numericAmount) : _buildMainStep(numericAmount),
            ),
          ),

          // Bottom Button
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: ElevatedButton(
              onPressed: numericAmount > 0 ? (_isConfirmStep ? _handleDeposit : () => setState(() => _isConfirmStep = true)) : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                elevation: 8,
                shadowColor: AppTheme.primary.withOpacity(0.5),
              ),
              child: _isLoading 
                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_isConfirmStep ? 'Add ${numericAmount.toInt().toString()} ETB' : 'Continue', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                      if (!_isConfirmStep) const SizedBox(width: 8),
                      if (!_isConfirmStep) const Icon(Icons.arrow_right_alt, color: Colors.white),
                    ],
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainStep(double numericAmount) {
    return Column(
      children: [
        const Text('ENTER AMOUNT', style: TextStyle(color: Color(0xFF7C3AED), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 2)),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('ETB', style: TextStyle(color: Colors.white38, fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(width: 8),
            IntrinsicWidth(
              child: TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.w900),
                decoration: const InputDecoration(border: InputBorder.none, hintText: '0', hintStyle: TextStyle(color: Colors.white12)),
                onChanged: (val) => setState(() {}),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          alignment: WrapAlignment.center,
          children: _quickAmounts.map((q) {
            final active = numericAmount == q;
            return GestureDetector(
              onTap: () => setState(() => _amountController.text = q.toString()),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: active ? AppTheme.primary : const Color(0xFF211540),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: active ? AppTheme.primary : Colors.white10),
                ),
                child: Text(q.toString(), style: TextStyle(color: active ? Colors.white : Colors.white70, fontWeight: FontWeight.bold)),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 32),
        const Divider(color: Colors.white12),
        const SizedBox(height: 24),
        const Align(alignment: Alignment.centerLeft, child: Text('Select Payment Method', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold))),
        const SizedBox(height: 16),
        ..._methods.map((m) {
          final active = _selectedMethod == m['id'];
          return GestureDetector(
            onTap: () => setState(() => _selectedMethod = m['id']),
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: active ? const Color(0x267C3AED) : const Color(0xFF1A1030),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: active ? const Color(0x737C3AED) : Colors.white10),
              ),
              child: Row(
                children: [
                   Container(
                     width: 44, height: 44,
                     decoration: BoxDecoration(color: m['color'].withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
                     child: Icon(m['icon'], color: m['color'], size: 20),
                   ),
                   const SizedBox(width: 16),
                   Expanded(
                     child: Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                         Text(m['label'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                         Text(m['sub'], style: const TextStyle(color: Colors.white38, fontSize: 12)),
                       ],
                     ),
                   ),
                   Container(
                     width: 20, height: 20,
                     decoration: BoxDecoration(
                       shape: BoxShape.circle,
                       border: Border.all(color: active ? AppTheme.primary : Colors.white30, width: 2),
                       color: active ? AppTheme.primary : Colors.transparent,
                     ),
                     child: active ? const Icon(Icons.check, size: 12, color: Colors.white) : null,
                   ),
                ],
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildConfirmStep(NumberFormat fmt, double numericAmount) {
    final method = _methods.firstWhere((m) => m['id'] == _selectedMethod);
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1A1030),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white10),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(vertical: 24),
                width: double.infinity,
                color: AppTheme.primary.withOpacity(0.1),
                child: Column(
                  children: [
                    const Text('You\'re adding', style: TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                    const SizedBox(height: 8),
                    Text('${fmt.format(numericAmount)}', style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w900)),
                    Text('≈ \$${(numericAmount / 57.5).toStringAsFixed(2)} USD', style: const TextStyle(color: Colors.white24, fontSize: 12)),
                  ],
                ),
              ),
              _buildDetailRow('Payment Method', method['label']),
              _buildDetailRow('Transaction Fee', 'Free'),
              _buildDetailRow('You Receive', fmt.format(numericAmount)),
              _buildDetailRow('Processing Time', 'Instant', isLast: true),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0x1234D399),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0x2E34D399)),
          ),
          child: Row(
            children: [
              const Icon(Icons.shield_outlined, color: Color(0xFF34D399), size: 18),
              const SizedBox(width: 12),
              const Expanded(child: Text('Secured by 256-bit encryption · No hidden fees', style: TextStyle(color: Colors.white38, fontSize: 12))),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isLast = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        border: isLast ? null : Border(bottom: BorderSide(color: Colors.white.withOpacity(0.05))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white38, fontSize: 13)),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
