import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../theme/app_theme.dart';
import '../../providers/chat_provider.dart';
import '../../models/profile.dart' as p;
import '../../widgets/glassmorphic_container.dart';
import '../../widgets/aurora_gradient_bg.dart';
import '../../services/wallet_service.dart';

class SendMoneyScreen extends ConsumerStatefulWidget {
  const SendMoneyScreen({super.key});

  @override
  ConsumerState<SendMoneyScreen> createState() => _SendMoneyScreenState();
}

class _SendMoneyScreenState extends ConsumerState<SendMoneyScreen> {
  int _step = 0; // 0: Pick, 1: Amount, 2: Confirm
  p.PublicProfile? _selectedContact;
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  double _balance = 0;
  bool _isLoading = false;

  final List<int> _quickAmounts = [100, 500, 1000, 5000];

  @override
  void initState() {
    super.initState();
    _loadBalance();
  }

  void _loadBalance() async {
    final result = await WalletService().getWalletBalance();
    if (result['wallet'] != null) {
      if (mounted) setState(() => _balance = (result['wallet']['balance'] ?? 0).toDouble());
    }
  }

  void _handleSend() async {
    if (_selectedContact == null) return;
    setState(() => _isLoading = true);
    final amount = double.tryParse(_amountController.text) ?? 0;
    
    final result = await WalletService().transfer(
      _selectedContact!.id, 
      amount, 
      _noteController.text.isEmpty ? null : _noteController.text
    );
    
    if (mounted) {
      setState(() => _isLoading = false);
      if (result['success'] == true) {
        context.push('/transaction-receipt', extra: result['transaction']);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['error'] ?? 'Failed to send money')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final numericAmount = double.tryParse(_amountController.text) ?? 0;

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            if (_step > 0) { setState(() => _step--); } else { context.pop(); }
          },
        ),
        title: const Text('Send Money', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
      ),
      body: AuroraGradientBg(
        child: SafeArea(
          child: Column(
            children: [
              _buildProgressIndicator(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: _buildStepContent(numericAmount),
                ),
              ),
              if (_step > 0) _buildActionButton(numericAmount),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
      child: Row(
        children: [
          _progressDot(true),
          _progressLine(_step >= 1),
          _progressDot(_step >= 1),
          _progressLine(_step >= 2),
          _progressDot(_step >= 2),
        ],
      ),
    );
  }

  Widget _progressDot(bool active) => Container(
    width: 12, height: 12,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: active ? AppTheme.primary : Colors.white12,
      border: active ? Border.all(color: Colors.white24, width: 2) : null,
    ),
  );

  Widget _progressLine(bool active) => Expanded(
    child: Container(height: 2, color: active ? AppTheme.primary : Colors.white12),
  );

  Widget _buildStepContent(double numericAmount) {
    switch (_step) {
      case 0: return _buildPickStep();
      case 1: return _buildAmountStep(numericAmount);
      case 2: return _buildConfirmStep(numericAmount);
      default: return const SizedBox();
    }
  }

  Widget _buildPickStep() {
    final searchResults = ref.watch(searchProfilesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GlassmorphicContainer(
          borderRadius: 16,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextField(
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: 'Search username or name',
              border: InputBorder.none,
              hintStyle: TextStyle(color: Colors.white38),
              icon: Icon(Icons.search, color: Colors.white54),
            ),
            onChanged: (val) => ref.read(profileSearchQueryProvider.notifier).state = val,
          ),
        ),
        const SizedBox(height: 32),
        const Text('Search Results', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
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
              children: profiles.map((p) => _buildContactTile(p)).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildContactTile(p.PublicProfile profile) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassmorphicContainer(
        borderRadius: 16,
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: AppTheme.primary.withOpacity(0.2), 
            backgroundImage: profile.avatarUrl != null ? NetworkImage(profile.avatarUrl!) : null,
            child: profile.avatarUrl == null ? Text((profile.name ?? '?')[0], style: const TextStyle(color: Colors.white)) : null,
          ),
          title: Text(profile.name ?? profile.username, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          subtitle: Text('@${profile.username}', style: const TextStyle(color: Colors.white38)),
          onTap: () => setState(() {
            _selectedContact = profile;
            _step = 1;
          }),
        ),
      ),
    );
  }

  Widget _buildAmountStep(double numericAmount) {
    return Column(
      children: [
        if (_selectedContact != null)
          GlassmorphicContainer(
            borderRadius: 20,
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppTheme.primary, 
                  radius: 20, 
                  backgroundImage: _selectedContact?.avatarUrl != null ? NetworkImage(_selectedContact!.avatarUrl!) : null,
                  child: _selectedContact?.avatarUrl == null ? Text((_selectedContact?.name ?? '?')[0]) : null,
                ),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(_selectedContact!.name ?? _selectedContact!.username, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  Text('@${_selectedContact!.username}', style: const TextStyle(color: Colors.white38, fontSize: 12)),
                ])),
                IconButton(icon: const Icon(Icons.edit, size: 18, color: Colors.white38), onPressed: () => setState(() => _step = 0)),
              ],
            ),
          ),
        const SizedBox(height: 60),
        const Text('ENTER AMOUNT', style: TextStyle(color: Colors.white38, letterSpacing: 2, fontSize: 12, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text('\$', style: TextStyle(color: Colors.white38, fontSize: 32, fontWeight: FontWeight.bold)),
            const SizedBox(width: 8),
            IntrinsicWidth(
              child: TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                autofocus: true,
                style: const TextStyle(color: Colors.white, fontSize: 64, fontWeight: FontWeight.w900, letterSpacing: -2),
                decoration: const InputDecoration(border: InputBorder.none, hintText: '0', hintStyle: TextStyle(color: Colors.white12)),
                onChanged: (val) => setState(() {}),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text('Available: \$${_balance.toStringAsFixed(2)}', style: TextStyle(color: numericAmount > _balance ? Colors.redAccent : Colors.white38, fontSize: 13)),
        const SizedBox(height: 48),
        Wrap(
          spacing: 12,
          children: _quickAmounts.map((q) => ActionChip(
            label: Text('\$$q'),
            backgroundColor: Colors.white.withOpacity(0.05),
            labelStyle: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold),
            onPressed: () => setState(() => _amountController.text = q.toString()),
          )).toList(),
        ),
        const SizedBox(height: 48),
        GlassmorphicContainer(
          borderRadius: 20,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextField(
            controller: _noteController,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(hintText: 'What is this for?', hintStyle: TextStyle(color: Colors.white24), border: InputBorder.none),
          ),
        ),
      ],
    );
  }

  Widget _buildConfirmStep(double numericAmount) {
    return Column(
      children: [
        GlassmorphicContainer(
          borderRadius: 32,
          isStrong: true,
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              CircleAvatar(
                radius: 40, 
                backgroundColor: AppTheme.primary, 
                backgroundImage: _selectedContact?.avatarUrl != null ? NetworkImage(_selectedContact!.avatarUrl!) : null,
                child: _selectedContact?.avatarUrl == null ? Text((_selectedContact?.name ?? ' ')[0], style: const TextStyle(fontSize: 32)) : null,
              ),
              const SizedBox(height: 16),
              Text('\$${numericAmount.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.w900)),
              const SizedBox(height: 8),
              Text('to ${_selectedContact!.name}', style: const TextStyle(color: Colors.white70, fontSize: 16)),
              const SizedBox(height: 40),
              _confirmRow('Transaction Fee', '\$0.00'),
              _confirmRow('Processing Time', 'Instant'),
              if (_noteController.text.isNotEmpty) _confirmRow('Note', _noteController.text),
            ],
          ),
        ),
      ],
    );
  }

  Widget _confirmRow(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 12),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.white38)),
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ],
    ),
  );

  Widget _buildActionButton(double numericAmount) {
    final canContinue = numericAmount > 0 && numericAmount <= _balance;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
      child: Container(
        width: double.infinity,
        height: 64,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          gradient: canContinue ? AppTheme.gradientPrimary(AppTheme.primary) : null,
          color: canContinue ? null : Colors.white10,
        ),
        child: ElevatedButton(
          onPressed: canContinue ? (_step == 2 ? _handleSend : () => setState(() => _step = 2)) : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
          ),
          child: _isLoading 
            ? const CircularProgressIndicator(color: Colors.white)
            : Text(_step == 2 ? 'CONFIRM SEND' : 'CONTINUE', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
        ),
      ),
    );
  }
}
