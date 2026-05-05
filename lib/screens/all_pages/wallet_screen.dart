import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/wallet_provider.dart';

// ─── Design Tokens ────────────────────────────────────────────────────
const _kBg      = Color(0xFF0D0A1A);
const _kCard    = Color(0xFF150D28);
const _kCard2   = Color(0xFF1C1130);
const _kPrimary = Color(0xFF7C3AED);

// ─── TXN Config ───────────────────────────────────────────────────────
final _txnCfg = <String, Map<String, dynamic>>{
  'transfer_in':  {'label': 'Received',    'color': const Color(0xFF4ADE80), 'isIn': true},
  'deposit':      {'label': 'Added Money', 'color': const Color(0xFF4ADE80), 'isIn': true},
  'transfer_out': {'label': 'Sent',        'color': const Color(0xFFF87171), 'isIn': false},
  'withdrawal':   {'label': 'Withdrawal',  'color': const Color(0xFFFB923C), 'isIn': false},
  'adjustment':   {'label': 'Adjustment',  'color': const Color(0xFF60A5FA), 'isIn': true},
};

String _formatETB(double n) => n.toStringAsFixed(2).replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => ',');

String _shortDate(String s) {
  final d = DateTime.parse(s);
  final diff = DateTime.now().difference(d).inDays;
  final time = '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  if (diff == 0) return 'Today, $time';
  if (diff == 1) return 'Yesterday, $time';
  return '${d.day}/${d.month}/${d.year}';
}

// ─── Mini Area Chart (no external package) ───────────────────────────
class _MiniAreaChart extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  const _MiniAreaChart({required this.data});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: CustomPaint(
        size: Size.infinite,
        painter: _AreaChartPainter(data: data),
      ),
    );
  }
}

class _AreaChartPainter extends CustomPainter {
  final List<Map<String, dynamic>> data;
  _AreaChartPainter({required this.data});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;
    final maxVal = data.fold<double>(0, (p, d) => (d['income'] as num).toDouble() > p ? (d['income'] as num).toDouble() : p);
    if (maxVal == 0) return;

    final paintLine = Paint()
      ..color = _kPrimary
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    final paintFill = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [_kPrimary.withOpacity(0.5), _kPrimary.withOpacity(0)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final n = data.length;
    final dx = size.width / (n - 1);

    Path pathLine = Path();
    Path pathFill = Path();

    for (int i = 0; i < n; i++) {
      final x = i * dx;
      final y = size.height - ((data[i]['income'] as num).toDouble() / maxVal * size.height * 0.85);
      if (i == 0) { pathLine.moveTo(x, y); pathFill.moveTo(x, y); }
      else { pathLine.lineTo(x, y); pathFill.lineTo(x, y); }
    }

    pathFill.lineTo(size.width, size.height);
    pathFill.lineTo(0, size.height);
    pathFill.close();

    canvas.drawPath(pathFill, paintFill);
    canvas.drawPath(pathLine, paintLine);

    // Day labels
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    for (int i = 0; i < n; i++) {
      final day = data[i]['day'] as String;
      textPainter.text = TextSpan(text: day, style: const TextStyle(color: Color(0x66FFFFFF), fontSize: 9, fontWeight: FontWeight.w600));
      textPainter.layout();
      textPainter.paint(canvas, Offset(i * dx - textPainter.width / 2, size.height - textPainter.height));
    }
  }

  @override
  bool shouldRepaint(_AreaChartPainter old) => old.data != data;
}

// ─── Wallet Screen ────────────────────────────────────────────────────
class WalletScreen extends ConsumerStatefulWidget {
  const WalletScreen({super.key});

  @override
  ConsumerState<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends ConsumerState<WalletScreen> with SingleTickerProviderStateMixin {
  bool _showBal = true;
  bool _copied = false;
  bool _refreshing = false;
  bool _needsActivation = false;
  bool _showTerms = false;

  // Quick contacts from txn history
  // List<Map<String, dynamic>> _quickContacts = []; // Removed: computed in build


  Future<void> _refresh() async {
    setState(() => _refreshing = true);
    ref.invalidate(walletDataProvider);
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) setState(() => _refreshing = false);
  }

  void _copyWalletId(String id) {
    Clipboard.setData(ClipboardData(text: id));
    setState(() => _copied = true);
    Future.delayed(const Duration(seconds: 2), () { if (mounted) setState(() => _copied = false); });
    _showSnack('Wallet ID copied');
  }

  void _showSnack(String msg) => ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating, backgroundColor: _kPrimary));

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).value;
    final walletAsync = ref.watch(walletDataProvider);
    final firstName = user?.name?.split(' ').first ?? user?.email?.split('@').first ?? 'there';

    if (_showTerms) return _buildTermsScreen();

    return Scaffold(
      backgroundColor: _kBg,
      body: walletAsync.when(
        loading: () => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(width: 64, height: 64, decoration: BoxDecoration(color: _kPrimary.withOpacity(0.15), shape: BoxShape.circle, border: Border.all(color: _kPrimary.withOpacity(0.3))),
                  child: const Icon(LucideIcons.loader, color: _kPrimary, size: 28)),
              const SizedBox(height: 16),
              const Text('Loading wallet…', style: TextStyle(color: Color(0x66FFFFFF), fontSize: 13)),
            ],
          ),
        ),
        error: (e, _) => Center(child: Text('Error: $e', style: const TextStyle(color: Colors.red))),
        data: (data) {
          final balance = (data['balance'] as num?)?.toDouble() ?? 0.0;
          final currency = data['currency'] as String? ?? 'ETB';
          final stars = (data['stars'] as num?)?.toInt() ?? 0;
          final txns = (data['recent_transactions'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [];
          final last4 = '1234'; // derived from wallet id hash
          final _chartData = [
            {'day': 'Mon', 'income': 120.0, 'expense': 80.0},
            {'day': 'Tue', 'income': 200.0, 'expense': 150.0},
            {'day': 'Wed', 'income': 150.0, 'expense': 100.0},
            {'day': 'Thu', 'income': 300.0, 'expense': 250.0},
            {'day': 'Fri', 'income': 250.0, 'expense': 180.0},
            {'day': 'Sat', 'income': 400.0, 'expense': 300.0},
            {'day': 'Sun', 'income': 350.0, 'expense': 280.0},
          ];
          final weekIncome = _chartData.fold<double>(0, (s, d) => s + (d['income'] as num).toDouble());
          final weekExpense = _chartData.fold<double>(0, (s, d) => s + (d['expense'] as num).toDouble());

          return Stack(
            children: [
              // Background orbs
              Positioned(top: -100, right: -60, child: _orb(240, _kPrimary.withOpacity(0.12))),
              Positioned(bottom: 200, left: -60, child: _orb(200, const Color(0xFFFF0050).withOpacity(0.07))),

              CustomScrollView(
                slivers: [
                  // Header
                  _buildHeader(user, firstName),

                  SliverToBoxAdapter(child: Column(
                    children: [
                      // Activation banner
                      if (_needsActivation) _buildActivationBanner(),

                      // Balance card
                      _buildBalanceCard(balance, currency, last4),

                      // Quick actions
                      _buildQuickActions(),

                      // Stars & Gifts
                      _buildStarsCard(stars),

                      // Quick Send
                      _buildQuickSend(txns),

                      // Activity Chart
                      _buildActivityChart(txns),

                      // Recent Transactions
                      _buildRecentTxns(txns),

                      // Monthly Stats
                      _buildMonthlyStats(data),

                      const SizedBox(height: 120),
                    ],
                  )),
                ],
              ),

              // Wallet-specific bottom nav
              _buildWalletNav(context),
            ],
          );
        },
      ),
    );
  }

  Widget _orb(double size, Color color) => ImageFiltered(
    imageFilter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
    child: Container(width: size, height: size, decoration: BoxDecoration(shape: BoxShape.circle, color: color)),
  );

  SliverAppBar _buildHeader(dynamic user, String firstName) {
    return SliverAppBar(
      pinned: true,
      backgroundColor: _kBg.withOpacity(0.92),
      flexibleSpace: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(color: Colors.transparent),
        ),
      ),
      elevation: 0,
      leadingWidth: 200,
      leading: Padding(
        padding: const EdgeInsets.only(left: 16),
        child: Row(
          children: [
            Container(
              width: 40, height: 40,
              decoration: const BoxDecoration(shape: BoxShape.circle, gradient: LinearGradient(colors: [_kPrimary, Color(0xFFa855f7)])),
              child: Center(child: Text(firstName[0].toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900))),
            ),
            const SizedBox(width: 10),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Welcome back,', style: TextStyle(color: Color(0x66FFFFFF), fontSize: 11)),
                Text(firstName, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
              ],
            ),
          ],
        ),
      ),
      actions: [
        GestureDetector(
          onTap: _refresh,
          child: SizedBox(width: 36, height: 36, child: AnimatedRotation(
            turns: _refreshing ? 1 : 0,
            duration: const Duration(milliseconds: 700),
            child: Container(
              decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.06), border: Border.all(color: Colors.white.withOpacity(0.08))),
              child: const Icon(LucideIcons.refreshCw, color: Color(0x80FFFFFF), size: 15),
            ),
          )),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () => _showSnack('Wallet notifications'),
          child: Container(
            width: 36, height: 36,
            decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.06), border: Border.all(color: Colors.white.withOpacity(0.08))),
            child: const Icon(LucideIcons.bell, color: Color(0x80FFFFFF), size: 15),
          ),
        ),
        const SizedBox(width: 16),
      ],
    );
  }

  Widget _buildActivationBanner() {
    return GestureDetector(
      onTap: () => setState(() => _showTerms = true),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(color: Colors.amber.withOpacity(0.07), border: Border(bottom: BorderSide(color: Colors.amber.withOpacity(0.18)))),
        child: Row(
          children: [
            Container(width: 32, height: 32, decoration: BoxDecoration(color: Colors.amber.withOpacity(0.18), shape: BoxShape.circle), child: const Icon(LucideIcons.zap, color: Color(0xFFFBBF24), size: 16)),
            const SizedBox(width: 12),
            const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Activate your wallet', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
              Text('Accept terms to unlock all features', style: TextStyle(color: Color(0x66FFFFFF), fontSize: 11)),
            ])),
            const Icon(LucideIcons.chevronRight, color: Color(0xFFFBBF24), size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceCard(double balance, String currency, String last4) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(
            begin: Alignment.topLeft, end: Alignment.bottomRight,
            colors: [Color(0xFF2D0A8A), Color(0xFF6B1FD4), Color(0xFF9B35EA), Color(0xFF5B10C4)],
          ),
          boxShadow: [BoxShadow(color: const Color(0xFF6B1FD4).withOpacity(0.55), blurRadius: 30, offset: const Offset(0, 10))],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              // Top-right orb
              Positioned(top: -40, right: -40, child: Container(width: 160, height: 160, decoration: BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(colors: [const Color(0xFFC864FF).withOpacity(0.45), Colors.transparent])))),
              // Bottom-left orb
              Positioned(bottom: -50, left: -30, child: Container(width: 140, height: 140, decoration: BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(colors: [const Color(0xFF5014B4).withOpacity(0.35), Colors.transparent])))),
              // Dot grid
              Positioned.fill(child: CustomPaint(painter: _DotGridPainter())),

              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () => setState(() => _showBal = !_showBal),
                          child: Row(
                            children: [
                              const Text('MAIN BALANCE', style: TextStyle(color: Color(0x8CFFFFFF), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.8)),
                              const SizedBox(width: 6),
                              Icon(_showBal ? LucideIcons.eye : LucideIcons.eyeOff, color: const Color(0x80FFFFFF), size: 14),
                            ],
                          ),
                        ),
                        // Credit card icon
                        Container(
                          width: 36, height: 24,
                          decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(6), border: Border.all(color: Colors.white.withOpacity(0.2))),
                          alignment: Alignment.bottomRight,
                          padding: const EdgeInsets.all(4),
                          child: Container(height: 6, width: 16, decoration: BoxDecoration(color: Colors.white.withOpacity(0.5), borderRadius: BorderRadius.circular(2))),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Balance
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: _showBal
                          ? Column(
                              key: const ValueKey('show'),
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.baseline,
                                  textBaseline: TextBaseline.alphabetic,
                                  children: [
                                    Text(_formatETB(balance), style: const TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
                                    const SizedBox(width: 8),
                                    const Text('ETB', style: TextStyle(color: Color(0xA6FFFFFF), fontSize: 20, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                                if (balance > 0)
                                  Text('≈ \$${(balance / 57.5).toStringAsFixed(2)} USD', style: const TextStyle(color: Color(0x66FFFFFF), fontSize: 12)),
                              ],
                            )
                          : Column(
                              key: const ValueKey('hide'),
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text('••••••••', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: 3)),
                                Text('Balance hidden', style: TextStyle(color: Color(0x4DFFFFFF), fontSize: 12)),
                              ],
                            ),
                    ),

                    const SizedBox(height: 12),

                    // Card row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _showBal ? '**** **** **** $last4' : '•••• •••• •••• ••••',
                          style: const TextStyle(color: Color(0x8CFFFFFF), fontSize: 14, fontFamily: 'monospace', letterSpacing: 2),
                        ),
                        Row(children: [
                          GestureDetector(
                            onTap: () => _copyWalletId(last4),
                            child: Container(
                              width: 28, height: 28,
                              decoration: BoxDecoration(color: Colors.white.withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
                              child: Icon(_copied ? LucideIcons.check : LucideIcons.copy, color: _copied ? const Color(0xFF4ADE80) : const Color(0x8CFFFFFF), size: 13),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Mastercard
                          SizedBox(width: 46, child: Stack(children: [
                            Container(width: 28, height: 28, decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xD9EB001B))),
                            Positioned(left: 18, child: Container(width: 28, height: 28, decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xD9F79E1B)))),
                          ])),
                        ]),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    final actions = [
      {'icon': LucideIcons.plus,         'label': 'Add',       'route': '/add-money'},
      {'icon': LucideIcons.send,         'label': 'Send',      'route': '/send-money'},
      {'icon': LucideIcons.arrowDownLeft,'label': 'Request',   'route': '/request-money'},
      {'icon': LucideIcons.qrCode,       'label': 'QR Pay',    'route': '/wallet/qr'},
      {'icon': LucideIcons.history,      'label': 'History',    'route': '/transaction-history'},
      {'icon': LucideIcons.clock,        'label': 'Scheduled',  'route': '/scheduled-payments'},
      {'icon': LucideIcons.target,       'label': 'Goals',      'route': '/savings-goals'},
      {'icon': LucideIcons.link,         'label': 'Pay Link',   'route': '/payment-request'},
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, childAspectRatio: 0.78, mainAxisSpacing: 16, crossAxisSpacing: 4),
        itemCount: actions.length,
        itemBuilder: (_, i) {
          final a = actions[i];
          return GestureDetector(
            onTap: () => context.push(a['route'] as String),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 56, height: 56,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.07), border: Border.all(color: Colors.white.withOpacity(0.09))),
                  child: Icon(a['icon'] as IconData, color: const Color(0xBFFFFFFF), size: 22),
                ),
                const SizedBox(height: 6),
                Text(a['label'] as String, style: const TextStyle(color: Color(0x73FFFFFF), fontSize: 10.5, fontWeight: FontWeight.w600), textAlign: TextAlign.center),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStarsCard(int stars) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: _kCard2,
          border: Border.all(color: _kPrimary.withOpacity(0.22)),
        ),
        child: Row(
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(shape: BoxShape.circle, color: _kPrimary.withOpacity(0.25), border: Border.all(color: _kPrimary.withOpacity(0.35))),
              child: const Icon(LucideIcons.star, color: Color(0xFFA78BFA), size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Stars & Gifts', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                  Text('${stars.toLocaleString()} Stars available', style: const TextStyle(color: Color(0x66FFFFFF), fontSize: 12)),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => context.push('/buy-stars'),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: _kPrimary,
                  boxShadow: [BoxShadow(color: _kPrimary.withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 4))],
                ),
                child: const Text('Redeem', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickSend(List<Map<String, dynamic>> txns) {
    // Extract unique recent recipients from transactions (transfer_out)
    final Map<String, Map<String, dynamic>> seen = {};
    for (final t in txns) {
      if (t['type'] == 'transfer_out') {
        final meta = t['metadata'] as Map<String, dynamic>? ?? {};
        final id = meta['recipient_id']?.toString() ?? '';
        final name = meta['recipient_name']?.toString() ?? meta['recipient_username']?.toString() ?? 'User';
        if (id.isNotEmpty && !seen.containsKey(id)) {
          seen[id] = {'id': id, 'name': name};
        }
      }
      if (seen.length >= 5) break;
    }
    final contacts = seen.values.toList();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Quick Send', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
              GestureDetector(
                onTap: () => context.push('/send-money'),
                child: const Text('View All', style: TextStyle(color: _kPrimary, fontSize: 13, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 80,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                // New button
                GestureDetector(
                  onTap: () => context.push('/send-money'),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 56, height: 56,
                        decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.04), border: Border.all(color: Colors.white.withOpacity(0.18), style: BorderStyle.solid, width: 2)),
                        child: const Icon(LucideIcons.plus, color: Color(0x59FFFFFF), size: 20),
                      ),
                      const SizedBox(height: 6),
                      const Text('New', style: TextStyle(color: Color(0x59FFFFFF), fontSize: 11)),
                    ],
                  ),
                ),
                if (contacts.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(left: 16, top: 20),
                    child: Text('Send to someone to see them here', style: TextStyle(color: Colors.white.withOpacity(0.25), fontSize: 12)),
                  )
                else
                  ...contacts.map((c) => Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: GestureDetector(
                      onTap: () => context.push('/send-money?to=${c['id']}'),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 56, height: 56,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(colors: [Color(0xFF6D28D9), Color(0xFFa855f7)]),
                              boxShadow: [BoxShadow(color: _kPrimary.withOpacity(0.45), blurRadius: 12)],
                            ),
                            alignment: Alignment.center,
                            child: Text((c['name'] as String)[0].toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)),
                          ),
                          const SizedBox(height: 6),
                          SizedBox(
                            width: 56,
                            child: Text((c['name'] as String).split(' ').first, style: const TextStyle(color: Color(0x80FFFFFF), fontSize: 11), overflow: TextOverflow.ellipsis, textAlign: TextAlign.center),
                          ),
                        ],
                      ),
                    ),
                  )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityChart(List<Map<String, dynamic>> txns) {
    final days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    final today = DateTime.now();
    final List<Map<String, dynamic>> chartData = List.generate(7, (i) {
      final d = DateTime(today.year, today.month, today.day).subtract(Duration(days: 6 - i));
      return {'day': days[d.weekday % 7], 'income': 0.0, 'expense': 0.0, 'date': d};
    });

    for (final t in txns) {
      final td = DateTime.parse(t['created_at'] as String);
      final tDay = DateTime(td.year, td.month, td.day);
      for (final slot in chartData) {
        if ((slot['date'] as DateTime).isAtSameMomentAs(tDay)) {
          final amount = (t['amount'] as num).toDouble();
          if (['transfer_in', 'deposit', 'adjustment'].contains(t['type'])) {
            slot['income'] += amount;
          } else if (['transfer_out', 'withdrawal'].contains(t['type'])) {
            slot['expense'] += amount;
          }
        }
      }
    }

    final weekIncome = chartData.fold<double>(0, (s, d) => s + (d['income'] as double));
    final weekExpense = chartData.fold<double>(0, (s, d) => s + (d['expense'] as double));

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: _kCard2,
          border: Border.all(color: Colors.white.withOpacity(0.07)),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Activity', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                        Text('Last 7 days performance', style: TextStyle(color: Color(0x61FFFFFF), fontSize: 11)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: _kPrimary.withOpacity(0.1), borderRadius: BorderRadius.circular(20), border: Border.all(color: _kPrimary.withOpacity(0.2))),
                    child: const Row(children: [
                      Text('Weekly', style: TextStyle(color: _kPrimary, fontSize: 12, fontWeight: FontWeight.w600)),
                      SizedBox(width: 4),
                      Icon(LucideIcons.chevronDown, color: _kPrimary, size: 13),
                    ]),
                  ),
                ],
              ),
            ),

            // Chart
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: _MiniAreaChart(data: chartData),
            ),

            // Income / Expense bars
            Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: Colors.white.withOpacity(0.06))),
              ),
              child: Row(
                children: [
                  _buildChartStat(true, '+${_formatETB(weekIncome)}', const Color(0xFF4ADE80)),
                  Container(width: 1, height: 20, color: Colors.white.withOpacity(0.08), margin: const EdgeInsets.symmetric(horizontal: 16)),
                  _buildChartStat(false, '-${_formatETB(weekExpense)}', const Color(0xFFF87171)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartStat(bool isIncome, String value, Color color) => Expanded(
    child: Row(
      children: [
        if (isIncome) ...[
          Container(width: 40, height: 6, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
          const SizedBox(width: 8),
          const Text('Income', style: TextStyle(color: Color(0x66FFFFFF), fontSize: 12)),
          const SizedBox(width: 8),
          Text(value, style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.bold)),
        ] else ...[
          Text(value, style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          const Text('Expense', style: TextStyle(color: Color(0x66FFFFFF), fontSize: 12)),
          const SizedBox(width: 8),
          Container(width: 40, height: 6, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
        ],
      ],
    ),
  );

  Widget _buildRecentTxns(List<Map<String, dynamic>> txns) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Recent Transactions', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
              GestureDetector(
                onTap: () => context.push('/transaction-history'),
                child: const Text('See All', style: TextStyle(color: _kPrimary, fontSize: 13, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (txns.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 40),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: _kCard2, border: Border.all(color: Colors.white.withOpacity(0.07))),
              child: Column(
                children: [
                  Icon(LucideIcons.arrowLeftRight, color: Colors.white.withOpacity(0.12), size: 40),
                  const SizedBox(height: 12),
                  const Text('No transactions yet', style: TextStyle(color: Colors.white54, fontSize: 14, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  const Text('Add money or send to get started', style: TextStyle(color: Color(0x4DFFFFFF), fontSize: 12)),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () => context.push('/add-money'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), color: _kPrimary, boxShadow: [BoxShadow(color: _kPrimary.withOpacity(0.4), blurRadius: 12)]),
                      child: const Text('Add Money', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                    ),
                  ),
                ],
              ),
            )
          else
            Column(
              children: txns.take(8).map((t) {
                final type = t['type'] as String? ?? 'transfer_in';
                final cfg = _txnCfg[type] ?? {'label': type, 'color': Colors.white, 'isIn': false};
                final isIn = cfg['isIn'] as bool;
                final amount = (t['amount'] as num?)?.toDouble() ?? 0;
                final meta = t['metadata'] as Map<String, dynamic>? ?? {};
                final counterparty = isIn
                    ? (meta['sender_name'] as String? ?? cfg['label'] as String)
                    : (meta['recipient_name'] as String? ?? cfg['label'] as String);

                return GestureDetector(
                  onTap: () => context.push('/transaction-detail/${t['id']}'),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      color: _kCard2,
                      border: Border.all(color: Colors.white.withOpacity(0.06)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44, height: 44,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            color: (cfg['color'] as Color).withOpacity(0.15),
                          ),
                          child: Icon(isIn ? LucideIcons.arrowDownLeft : LucideIcons.arrowUpRight, color: cfg['color'] as Color, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(counterparty, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                              Text(_shortDate(t['created_at'] as String? ?? DateTime.now().toIso8601String()), style: const TextStyle(color: Color(0x61FFFFFF), fontSize: 12)),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('${isIn ? '+' : '−'}${_formatETB(amount)} ETB', style: TextStyle(color: cfg['color'] as Color, fontSize: 15, fontWeight: FontWeight.bold)),
                            Text(t['status'] as String? ?? 'completed', style: const TextStyle(color: Color(0x66FFFFFF), fontSize: 11)),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildMonthlyStats(Map<String, dynamic> data) {
    final monthlyIn = (data['monthly_received'] as num?)?.toDouble() ?? 0;
    final monthlyOut = (data['monthly_sent'] as num?)?.toDouble() ?? 0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Row(
        children: [
          Expanded(child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: const Color(0xFF4ADE80).withOpacity(0.07),
              border: Border.all(color: const Color(0xFF4ADE80).withOpacity(0.14)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Icon(LucideIcons.trendingUp, color: Color(0xFF4ADE80), size: 16),
                    const Text('This month', style: TextStyle(color: Color(0x4DFFFFFF), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                  ],
                ),
                const SizedBox(height: 8),
                Text('+${_formatETB(monthlyIn)} ETB', style: const TextStyle(color: Color(0xFF4ADE80), fontSize: 18, fontWeight: FontWeight.w900)),
                const Text('Money In', style: TextStyle(color: Color(0x61FFFFFF), fontSize: 11)),
              ],
            ),
          )),
          const SizedBox(width: 12),
          Expanded(child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: const Color(0xFFF87171).withOpacity(0.07),
              border: Border.all(color: const Color(0xFFF87171).withOpacity(0.14)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Icon(LucideIcons.trendingDown, color: Color(0xFFF87171), size: 16),
                    const Text('This month', style: TextStyle(color: Color(0x4DFFFFFF), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                  ],
                ),
                const SizedBox(height: 8),
                Text('-${_formatETB(monthlyOut)} ETB', style: const TextStyle(color: Color(0xFFF87171), fontSize: 18, fontWeight: FontWeight.w900)),
                const Text('Money Out', style: TextStyle(color: Color(0x61FFFFFF), fontSize: 11)),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildWalletNav(BuildContext context) {
    return Positioned(
      bottom: 0, left: 0, right: 0,
      child: Container(
        height: 68 + MediaQuery.of(context).padding.bottom,
        decoration: BoxDecoration(
          color: _kBg,
          border: Border(top: BorderSide(color: Colors.white.withOpacity(0.07))),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.45), blurRadius: 32)],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _navBtn(context, LucideIcons.home, 'HOME', () => context.go('/home'), false),
            _navBtn(context, LucideIcons.wallet, 'WALLET', () {}, true),
            // Center QR button
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: GestureDetector(
                onTap: () => context.push('/wallet/qr'),
                child: Container(
                  width: 56, height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(colors: [Color(0xFF6D28D9), Color(0xFF9333EA)]),
                    boxShadow: [BoxShadow(color: _kPrimary.withOpacity(0.6), blurRadius: 20), const BoxShadow(color: _kBg, blurRadius: 0, spreadRadius: 3)],
                  ),
                  child: const Icon(LucideIcons.qrCode, color: Colors.white, size: 24),
                ),
              ),
            ),
            _navBtn(context, LucideIcons.barChart2, 'INSIGHTS', () => context.push('/transaction-history'), false),
            _navBtn(context, LucideIcons.user, 'PROFILE', () => context.go('/profile'), false),
          ],
        ),
      ),
    );
  }

  Widget _navBtn(BuildContext context, IconData icon, String label, VoidCallback onTap, bool active) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: active ? Colors.white : const Color(0x61FFFFFF), size: 22),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: active ? Colors.white : const Color(0x61FFFFFF), fontSize: 10, fontWeight: active ? FontWeight.bold : FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildTermsScreen() {
    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(backgroundColor: _kBg, title: const Text('Wallet Terms'), leading: IconButton(icon: const Icon(Icons.close), onPressed: () => setState(() => _showTerms = false))),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Expanded(
              child: Text(
                'By activating your Echat Wallet, you agree to:\n\n'
                '• Providing accurate personal information\n'
                '• Complying with Ethiopian financial regulations\n'
                '• Not using the wallet for illegal activities\n'
                '• Maintaining account security\n\n'
                'Your funds are secured by the Echat financial platform.',
                style: TextStyle(color: Colors.white70, height: 1.8, fontSize: 15),
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: _kPrimary, padding: const EdgeInsets.symmetric(vertical: 16)),
                onPressed: () { setState(() { _showTerms = false; _needsActivation = false; }); _showSnack('Wallet activated!'); },
                child: const Text('Accept & Activate', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Dot Grid Painter ────────────────────────────────────────────────
class _DotGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withOpacity(0.07)..strokeWidth = 1;
    const spacing = 18.0;
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 1, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_DotGridPainter _) => false;
}

// Extension for formatting numbers
extension on int {
  String toLocaleString() {
    return toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => ',');
  }
}
