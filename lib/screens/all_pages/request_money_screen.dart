import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../services/wallet_service.dart';
import '../../theme/app_theme.dart';
import '../../providers/chat_provider.dart';
import '../../models/profile.dart' as p;
import '../../widgets/glassmorphic_container.dart';

class RequestMoneyScreen extends ConsumerStatefulWidget {
  const RequestMoneyScreen({super.key});

  @override
  ConsumerState<RequestMoneyScreen> createState() => _RequestMoneyScreenState();
}

class _RequestMoneyScreenState extends ConsumerState<RequestMoneyScreen> {
  int _step = 0; // 0: Pick, 1: Amount, 2: Done
  p.PublicProfile? _selectedContact;
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _reasonController = TextEditingController();
  Map<String, dynamic>? _lastRequest;
  bool _isLoading = false;

  final List<int> _quickAmounts = [50, 100, 250, 500, 1000, 2000];

  void _handleRequest() async {
    if (_selectedContact == null) return;
    setState(() => _isLoading = true);
    final amount = double.tryParse(_amountController.text) ?? 0;
    
    final result = await WalletService().requestMoney(
      _selectedContact!.id, 
      amount, 
      _reasonController.text.isEmpty ? null : _reasonController.text
    );
    
    if (mounted) {
      setState(() => _isLoading = false);
      if (result['success'] == true) {
        setState(() {
          _lastRequest = result['request'];
          _step = 2;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['error'] ?? 'Failed to request money')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.currency(symbol: "ETB ", decimalDigits: 2);
    final numericAmount = double.tryParse(_amountController.text) ?? 0;

    return Scaffold(
      backgroundColor: const Color(0xFF0D0A1A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (_step == 1) {
              setState(() => _step = 0);
            } else {
              context.pop();
            }
          },
        ),
        title: const Text('Request Money', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildStepContent(fmt, numericAmount),
            ),
          ),
          if (_step == 1)
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: ElevatedButton(
                onPressed: numericAmount > 0 ? _handleRequest : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                  elevation: 8,
                ),
                child: _isLoading 
                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.arrow_downward, color: Colors.white, size: 20),
                        const SizedBox(width: 8),
                        Text('Request ${numericAmount > 0 ? numericAmount.toInt().toString() : 'Money'}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                      ],
                    ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStepContent(NumberFormat fmt, double numericAmount) {
    switch (_step) {
      case 0: return _buildPickStep();
      case 1: return _buildAmountStep(numericAmount);
      case 2: return _buildDoneStep(fmt);
      default: return const SizedBox();
    }
  }

  Widget _buildPickStep() {
    final searchResults = ref.watch(searchProfilesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        const Text('Who are you requesting from?', style: TextStyle(color: Colors.white38, fontSize: 13)),
        const SizedBox(height: 16),
        GlassmorphicContainer(
          height: 56,
          borderRadius: 16,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              const Icon(Icons.search, color: Colors.white38, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'Search by name or @username',
                    border: InputBorder.none,
                    hintStyle: TextStyle(color: Colors.white38),
                  ),
                  onChanged: (val) => ref.read(profileSearchQueryProvider.notifier).state = val,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        searchResults.when(
          loading: () => Center(child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: CircularProgressIndicator(color: AppTheme.primary),
          )),
          error: (err, _) => Text('Error: $err', style: const TextStyle(color: Colors.red)),
          data: (profiles) {
            if (profiles.isEmpty) {
              return const Center(child: Text('Type at least 2 characters to search', style: TextStyle(color: Colors.white24)));
            }
            return Column(
              children: profiles.map((p) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor: AppTheme.primary, 
                  backgroundImage: p.avatarUrl != null ? NetworkImage(p.avatarUrl!) : null,
                  child: p.avatarUrl == null ? Text((p.name ?? '?')[0]) : null,
                ),
                title: Text(p.name ?? p.username, style: const TextStyle(color: Colors.white)),
                subtitle: Text('@${p.username}', style: const TextStyle(color: Colors.white38)),
                trailing: const Icon(Icons.arrow_right_alt, color: Colors.white38),
                onTap: () {
                  setState(() {
                    _selectedContact = p;
                    _step = 1;
                  });
                },
              )).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildAmountStep(double numericAmount) {
    return Column(
      children: [
        if (_selectedContact != null)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: const Color(0xFF1A1030), border: Border.all(color: Colors.white10), borderRadius: BorderRadius.circular(16)),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppTheme.primary, 
                  backgroundImage: _selectedContact?.avatarUrl != null ? NetworkImage(_selectedContact!.avatarUrl!) : null,
                  child: _selectedContact?.avatarUrl == null ? Text((_selectedContact?.name ?? '?')[0]) : null,
                ),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(_selectedContact!.name ?? _selectedContact!.username, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  Text('@${_selectedContact!.username}', style: const TextStyle(color: Colors.white38, fontSize: 12)),
                ])),
                IconButton(icon: const Icon(Icons.close, size: 18, color: Colors.white38), onPressed: () => setState(() => _step = 0)),
              ],
            ),
          ),
        const SizedBox(height: 40),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            IntrinsicWidth(
              child: TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                autofocus: true,
                style: const TextStyle(color: Colors.white, fontSize: 52, fontWeight: FontWeight.w900),
                decoration: const InputDecoration(border: InputBorder.none, hintText: '0', hintStyle: TextStyle(color: Colors.white12)),
                onChanged: (val) => setState(() {}),
              ),
            ),
            const SizedBox(width: 8),
            const Padding(padding: EdgeInsets.only(bottom: 12), child: Text('ETB', style: TextStyle(color: Colors.white38, fontSize: 24, fontWeight: FontWeight.bold))),
          ],
        ),
        const SizedBox(height: 24),
        GridView.count(
          shrinkWrap: true,
          crossAxisCount: 3,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 2.2,
          children: _quickAmounts.map((q) {
            final active = numericAmount == q;
            return GestureDetector(
              onTap: () => setState(() => _amountController.text = q.toString()),
              child: Container(
                decoration: BoxDecoration(
                  color: active ? AppTheme.primary : const Color(0xFF1A1030),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: active ? AppTheme.primary : Colors.white10),
                ),
                child: Center(child: Text('${q.toLocaleString()} ETB', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold))),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(color: const Color(0xFF1A1030), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white10)),
          child: TextField(
            controller: _reasonController,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(hintText: 'Reason for request (optional)', hintStyle: TextStyle(color: Colors.white38), border: InputBorder.none),
          ),
        ),
      ],
    );
  }

  Widget _buildDoneStep(NumberFormat fmt) {
    return Column(
      children: [
        const SizedBox(height: 20),
        Container(
          width: 64, height: 64,
          decoration: BoxDecoration(color: const Color(0xFF10B981).withOpacity(0.15), shape: BoxShape.circle, border: Border.all(color: const Color(0xFF10B981).withOpacity(0.3))),
          child: const Icon(Icons.check, color: const Color(0xFF10B981), size: 32),
        ),
        const SizedBox(height: 16),
        const Text('Request Sent!', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text('${_lastRequest?['recipient_name'] ?? 'The recipient'} will be notified to send you ${fmt.format(_lastRequest?['amount'] ?? 0)}', textAlign: TextAlign.center, style: const TextStyle(color: Colors.white38, fontSize: 14)),
        const SizedBox(height: 32),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: const Color(0xFF1A1030), borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.white10)),
          child: Column(
            children: [
              const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.qr_code, color: Colors.white38, size: 16),
                SizedBox(width: 8),
                Text('Payment Request QR', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
              ]),
              const SizedBox(height: 20),
              Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)), child: const Icon(Icons.qr_code_2, size: 160, color: Colors.black)),
              const SizedBox(height: 20),
              const Text('Share this QR to receive funds', style: TextStyle(color: Colors.white38, fontSize: 12)),
            ],
          ),
        ),
        const SizedBox(height: 32),
        ElevatedButton(
          onPressed: () => context.pop(),
          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, minimumSize: const Size(double.infinity, 56), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28))),
          child: const Text('Done', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}

extension NumberExtension on num {
  String toLocaleString() {
    return NumberFormat('#,###').format(this);
  }
}
