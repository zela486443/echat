import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';

const _kBg   = Color(0xFF0D0A1A);
const _kCard = Color(0xFF141030);
const _kP    = Color(0xFF7C3AED);

String _fmtETB(double n) => NumberFormat('#,##0.00', 'en_US').format(n);

class TransactionData {
  final String type;
  final double amount;
  final String? recipient;
  final String? method;
  final String transactionId;
  final String timestamp;
  final String status;
  final String? note;

  const TransactionData({
    required this.type, required this.amount, this.recipient, this.method,
    required this.transactionId, required this.timestamp, required this.status, this.note,
  });
}

class TransactionReceiptScreen extends StatefulWidget {
  final TransactionData? transaction;
  const TransactionReceiptScreen({super.key, this.transaction});

  @override
  State<TransactionReceiptScreen> createState() => _TransactionReceiptScreenState();
}

class _TransactionReceiptScreenState extends State<TransactionReceiptScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero)
        .animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));
    _animCtrl.forward();
  }

  @override
  void dispose() { _animCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final tx = widget.transaction;
    if (tx == null) { WidgetsBinding.instance.addPostFrameCallback((_) => context.go('/wallet')); return const SizedBox.shrink(); }

    final isSent = tx.type == 'sent';
    final isIn   = tx.type == 'add_money';
    final shortRef = 'TXN${tx.transactionId.substring(tx.transactionId.length >= 10 ? tx.transactionId.length - 10 : 0).toUpperCase()}';
    final maskedWallet = 'Wallet (**** ${tx.transactionId.substring(tx.transactionId.length >= 4 ? tx.transactionId.length - 4 : 0).toUpperCase()})';

    DateTime? dtObj = DateTime.tryParse(tx.timestamp);
    final txDate = dtObj != null ? DateFormat('MMM d, yyyy').format(dtObj) : tx.timestamp;
    final txTime = dtObj != null ? DateFormat('HH:mm a').format(dtObj) : '';

    final qrLabel = '${tx.transactionId}|${tx.amount}|${tx.timestamp}|Echat';

    return Scaffold(
      backgroundColor: _kBg,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: SlideTransition(
            position: _slideAnim,
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(4, 12, 4, 0),
                  child: Row(children: [
                    IconButton(icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20), onPressed: () => context.go('/wallet')),
                    const Expanded(child: Center(child: Text('Transaction Receipt', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)))),
                    IconButton(icon: const Icon(LucideIcons.moreVertical, color: Colors.white38, size: 20), onPressed: () {}),
                  ]),
                ),
                const SizedBox(height: 4),

                // Receipt card with zigzag bottom
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      // Main card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                        decoration: const BoxDecoration(
                          color: _kCard,
                          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                          border: Border(top: BorderSide(color: Colors.white12), left: BorderSide(color: Colors.white12), right: BorderSide(color: Colors.white12)),
                        ),
                        child: Column(children: [
                          // Green check ring
                          Container(
                            width: 64, height: 64,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFF10b981).withOpacity(0.18),
                              border: Border.all(color: const Color(0xFF10b981).withOpacity(0.35), width: 2),
                              boxShadow: [BoxShadow(color: const Color(0xFF10b981).withOpacity(0.18), blurRadius: 28)],
                            ),
                            child: const Icon(Icons.check, color: Color(0xFF10b981), size: 28),
                          ),
                          const SizedBox(height: 14),

                          const Text('PAYMENT SUCCESSFUL', style: TextStyle(color: Color(0xFF10b981), fontWeight: FontWeight.w700, fontSize: 12, letterSpacing: 2.5)),
                          const SizedBox(height: 20),

                          // Branding
                          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                            Container(
                              width: 28, height: 28,
                              decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF7C3AED), Color(0xFFa855f7)]), borderRadius: BorderRadius.circular(8)),
                              child: const Icon(LucideIcons.wallet, color: Colors.white, size: 14),
                            ),
                            const SizedBox(width: 8),
                            const Text('EchatWallet', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
                          ]),
                          const SizedBox(height: 4),
                          const Text('Secure Digital Payments', style: TextStyle(color: Colors.white38, fontSize: 12)),
                          const SizedBox(height: 20),

                          Text(isSent ? 'Amount Sent' : isIn ? 'Amount Added' : 'Amount',
                              style: const TextStyle(color: Colors.white38, fontSize: 12)),
                          const SizedBox(height: 6),
                          Text('${_fmtETB(tx.amount)} ETB',
                              style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.w900, letterSpacing: -0.8, height: 1)),
                          const SizedBox(height: 24),

                          // Dashed divider
                          const Divider(color: Colors.white12, thickness: 1.5, height: 1),
                          const SizedBox(height: 20),

                          // Detail rows
                          if (tx.recipient != null) _receiptRow('Recipient', tx.recipient!),
                          if (isIn) _receiptRow('Method', tx.method ?? 'Bank Transfer'),
                          _receiptRow('Date', txDate),
                          if (txTime.isNotEmpty) _receiptRow('Time', txTime),
                          _receiptRowWidget('Payment Method',
                            Row(children: [
                              const Icon(LucideIcons.wallet, color: Colors.white38, size: 13),
                              const SizedBox(width: 5),
                              Text(maskedWallet, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
                            ]),
                          ),
                          _receiptRow('Reference ID', shortRef, isMono: true),
                          const SizedBox(height: 24),

                          // QR Code (custom drawn)
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: const [BoxShadow(color: Color(0x5A000000), blurRadius: 24)]),
                            child: SizedBox(
                              width: 128, height: 128,
                              child: CustomPaint(painter: _QrPainter(qrLabel)),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text('SCAN TO VERIFY', style: TextStyle(color: Colors.white24, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 3)),
                          const SizedBox(height: 24),
                        ]),
                      ),

                      // Zigzag torn edge
                      ClipPath(
                        clipper: _ZigzagClipper(),
                        child: Container(height: 20, color: _kCard),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Share button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GestureDetector(
                    onTap: () => _shareReceipt(tx, shortRef),
                    child: Container(
                      width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: _kP,
                        borderRadius: BorderRadius.circular(50),
                        boxShadow: [BoxShadow(color: _kP.withOpacity(0.5), blurRadius: 28)],
                      ),
                      child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Icon(LucideIcons.share2, color: Colors.white, size: 18),
                        SizedBox(width: 8),
                        Text('Share Receipt', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      ]),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Done button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GestureDetector(
                    onTap: () => context.go('/wallet'),
                    child: Container(
                      width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.07),
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(color: Colors.white.withOpacity(0.1)),
                      ),
                      child: const Center(child: Text('Done', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold))),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text('A confirmation email has been sent to your registered address.', textAlign: TextAlign.center, style: TextStyle(color: Colors.white24, fontSize: 11)),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _receiptRow(String label, String value, {bool isMono = false}) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: const TextStyle(color: Colors.white38, fontSize: 13)),
      Text(value, style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700, fontFamily: isMono ? 'monospace' : null)),
    ]),
  );

  Widget _receiptRowWidget(String label, Widget value) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: const TextStyle(color: Colors.white38, fontSize: 13)),
      value,
    ]),
  );

  void _shareReceipt(TransactionData tx, String shortRef) {
    final text = 'Payment of ${_fmtETB(tx.amount)} ETB\nRef: $shortRef';
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Copied to clipboard'), behavior: SnackBarBehavior.floating, backgroundColor: _kP));
  }
}

// Zigzag clipper for torn receipt edge
class _ZigzagClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, 0);
    double x = 0;
    const toothW = 20.0;
    while (x < size.width) {
      path.lineTo(x + toothW / 2, size.height);
      path.lineTo(x + toothW, 0);
      x += toothW;
    }
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }
  @override
  bool shouldReclip(_) => false;
}

// Simple QR-like placeholder painter (draws a matrix pattern)
class _QrPainter extends CustomPainter {
  final String data;
  _QrPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFF000000);
    const modules = 21;
    final cellSize = size.width / modules;
    // Draw finder patterns
    _drawFinder(canvas, paint, 0, 0, cellSize);
    _drawFinder(canvas, paint, (modules - 7) * cellSize, 0, cellSize);
    _drawFinder(canvas, paint, 0, (modules - 7) * cellSize, cellSize);
    // Data cells based on hash of data
    final hash = data.hashCode;
    for (int row = 0; row < modules; row++) {
      for (int col = 0; col < modules; col++) {
        if (_isFinderZone(row, col, modules)) continue;
        if ((hash >> ((row * modules + col) % 31)) & 1 == 1) {
          canvas.drawRect(Rect.fromLTWH(col * cellSize + 0.5, row * cellSize + 0.5, cellSize - 1, cellSize - 1), paint);
        }
      }
    }
  }

  void _drawFinder(Canvas canvas, Paint paint, double x, double y, double cell) {
    canvas.drawRect(Rect.fromLTWH(x, y, 7 * cell, 7 * cell), paint);
    canvas.drawRect(Rect.fromLTWH(x + cell, y + cell, 5 * cell, 5 * cell), Paint()..color = Colors.white);
    canvas.drawRect(Rect.fromLTWH(x + 2 * cell, y + 2 * cell, 3 * cell, 3 * cell), paint);
  }

  bool _isFinderZone(int row, int col, int modules) {
    if (row < 8 && col < 8) return true;
    if (row < 8 && col >= modules - 8) return true;
    if (row >= modules - 8 && col < 8) return true;
    return false;
  }

  @override
  bool shouldRepaint(_) => false;
}
