import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../theme/app_theme.dart';
import '../../providers/wallet_provider.dart';
import '../../models/transaction.dart';
import '../../widgets/glassmorphic_container.dart';
import '../../widgets/aurora_gradient_bg.dart';
import 'wallet_terms_screen.dart';
import '../../components/security/wallet_lock_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WalletScreen extends ConsumerStatefulWidget {
  const WalletScreen({super.key});

  @override
  ConsumerState<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends ConsumerState<WalletScreen> {
  bool _hasAcceptedTerms = false;
  bool _isUnlocked = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkStatus();
  }

  Future<void> _checkStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _hasAcceptedTerms = prefs.getBool('wallet_terms_accepted') ?? false;
      _isLoading = false;
    });
  }

  Future<void> _acceptTerms() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('wallet_terms_accepted', true);
    setState(() => _hasAcceptedTerms = true);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    
    if (!_hasAcceptedTerms) {
      return WalletTermsScreen(onAccept: _acceptTerms);
    }

    if (!_isUnlocked) {
      return WalletLockScreen(onUnlock: () => setState(() => _isUnlocked = true));
    }

    final theme = Theme.of(context);
    final balanceStream = ref.watch(walletBalanceStreamProvider);
    final transactionsFuture = ref.watch(transactionHistoryProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Wallet', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: Colors.white)),
        actions: [
          IconButton(icon: const Icon(Icons.qr_code_scanner, color: Colors.white), onPressed: () => context.push('/wallet-qr')),
          IconButton(
            icon: const Icon(Icons.history, color: Colors.white), 
            onPressed: () => context.push('/transaction-history'),
          ),
        ],
      ),
      body: AuroraGradientBg(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 120, 20, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Balance Card
              GlassmorphicContainer(
                borderRadius: 24,
                isStrong: true,
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total Balance', style: TextStyle(color: Colors.white70, fontSize: 16)),
                        Icon(Icons.contactless, color: AppTheme.primary.withOpacity(0.5)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    balanceStream.when(
                      data: (wallet) => Text(
                        wallet != null ? '\$${NumberFormat('#,##0.00').format(wallet.balance)}' : '\$0.00',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -1,
                        ),
                      ),
                      loading: () => const Text('...', style: TextStyle(color: Colors.white, fontSize: 36)),
                      error: (_, __) => const Text('Error', style: TextStyle(color: Colors.redAccent, fontSize: 24)),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        _buildStatChip(Icons.arrow_upward, '2.5%', Colors.greenAccent),
                        const SizedBox(width: 12),
                        _buildStatChip(Icons.arrow_downward, '0.8%', Colors.redAccent),
                        const Spacer(),
                        const Text('**** 3921', style: TextStyle(color: Colors.white70, letterSpacing: 2, fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Quick Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildActionItem(context, Icons.add, 'Add', Colors.blueAccent, '/add-money'),
                  _buildActionItem(context, Icons.send, 'Send', Colors.purpleAccent, '/send-money'),
                  _buildActionItem(context, Icons.request_page, 'Request', Colors.orangeAccent, '/request-money'),
                  _buildActionItem(context, Icons.apps, 'More', Colors.tealAccent, '/features'),
                ],
              ),
              const SizedBox(height: 40),

              // Recent Transactions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Recent Activity', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                  TextButton(
                    onPressed: () => context.push('/transaction-history'),
                    child: Text('See All', style: TextStyle(color: AppTheme.primary)),
                  )
                ],
              ),
              const SizedBox(height: 16),
              
              transactionsFuture.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Center(child: Text('Error: $err', style: const TextStyle(color: Colors.white))),
                data: (transactions) {
                  if (transactions.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        child: Text('No recent activity', style: TextStyle(color: Colors.white.withOpacity(0.4))),
                      ),
                    );
                  }

                  return Column(
                    children: transactions.take(5).map((tx) {
                      final isCredit = tx.transactionType == TransactionType.deposit || tx.amount > 0;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: GlassmorphicContainer(
                          borderRadius: 16,
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: isCredit ? Colors.green.withOpacity(0.15) : Colors.red.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  isCredit ? Icons.arrow_downward : Icons.arrow_upward,
                                  color: isCredit ? Colors.greenAccent : Colors.redAccent,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(tx.description ?? (isCredit ? 'Received' : 'Sent'), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                                    const SizedBox(height: 2),
                                    Text(DateFormat('MMM d, h:mm a').format(tx.createdAt), style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11)),
                                  ],
                                ),
                              ),
                              Text(
                                '${isCredit ? '+' : '-'}\$${tx.amount.abs().toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isCredit ? Colors.greenAccent : Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 12),
          const SizedBox(width: 4),
          Text(text, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildActionItem(BuildContext context, IconData icon, String label, Color color, String route) {
    return InkWell(
      onTap: () => context.push(route),
      child: Column(
        children: [
          GlassmorphicContainer(
            width: 64, height: 64,
            borderRadius: 20,
            isStrong: true,
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 10),
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
