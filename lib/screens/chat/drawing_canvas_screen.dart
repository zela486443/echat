import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:path_provider/path_provider.dart';
import '../../theme/app_theme.dart';

class DrawingCanvasScreen extends StatefulWidget {
  final Function(File imageFile) onSend;

  const DrawingCanvasScreen({super.key, required this.onSend});

  @override
  State<DrawingCanvasScreen> createState() => _DrawingCanvasScreenState();
}

class _DrawingCanvasScreenState extends State<DrawingCanvasScreen> {
  final List<_DrawingPath> _paths = [];
  Color _selectedColor = Colors.white;
  double _strokeWidth = 4.0;
  final GlobalKey _canvasKey = GlobalKey();

  final List<Color> _colors = [
    Colors.white,
    const Color(0xFF7C3AED), // Purple
    const Color(0xFFEC4899), // Pink
    const Color(0xFF3B82F6), // Blue
    const Color(0xFF10B981), // Green
    const Color(0xFFF59E0B), // Amber
    const Color(0xFFEF4444), // Red
  ];

  void _undo() {
    if (_paths.isNotEmpty) {
      setState(() => _paths.removeLast());
    }
  }

  void _clear() {
    setState(() => _paths.clear());
  }

  Future<void> _export() async {
    try {
      final boundary = _canvasKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return;

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;

      final bytes = byteData.buffer.asUint8List();
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/sketch_${DateTime.now().millisecondsSinceEpoch}.png');
      await file.writeAsBytes(bytes);

      widget.onSend(file);
    } catch (e) {
      debugPrint('Export error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0A1A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Sketch', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(LucideIcons.x, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(icon: const Icon(LucideIcons.undo2, color: Colors.white), onPressed: _undo),
          IconButton(icon: const Icon(LucideIcons.trash2, color: Colors.redAccent), onPressed: _clear),
          const SizedBox(width: 8),
          TextButton(
            onPressed: _export,
            child: Text('Send', style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold, fontSize: 16)),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Canvas Area
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.03),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white10),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: RepaintBoundary(
                  key: _canvasKey,
                  child: GestureDetector(
                    onPanStart: (details) {
                      setState(() {
                        _paths.add(_DrawingPath(
                          points: [details.localPosition],
                          color: _selectedColor,
                          width: _strokeWidth,
                        ));
                      });
                    },
                    onPanUpdate: (details) {
                      setState(() {
                        _paths.last.points.add(details.localPosition);
                      });
                    },
                    child: CustomPaint(
                      painter: _CanvasPainter(paths: _paths),
                      size: Size.infinite,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Tools
          Container(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
            decoration: BoxDecoration(
              color: const Color(0xFF150D28),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 20, offset: const Offset(0, -5))],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Brush Size
                Row(
                  children: [
                    const Icon(LucideIcons.paintbrush, color: Colors.white38, size: 18),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: AppTheme.primary,
                          inactiveTrackColor: Colors.white10,
                          thumbColor: Colors.white,
                          overlayColor: AppTheme.primary.withOpacity(0.2),
                        ),
                        child: Slider(
                          value: _strokeWidth,
                          min: 1.0,
                          max: 20.0,
                          onChanged: (v) => setState(() => _strokeWidth = v),
                        ),
                      ),
                    ),
                    Text('${_strokeWidth.round()}px', style: const TextStyle(color: Colors.white38, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 16),
                // Color Picker
                SizedBox(
                  height: 44,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _colors.length,
                    itemBuilder: (context, i) {
                      final color = _colors[i];
                      final isSelected = color == _selectedColor;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedColor = color),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 44,
                          height: 44,
                          margin: const EdgeInsets.only(right: 12),
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected ? Colors.white : Colors.transparent,
                              width: 3,
                            ),
                            boxShadow: isSelected ? [BoxShadow(color: color.withOpacity(0.5), blurRadius: 10)] : null,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DrawingPath {
  final List<Offset> points;
  final Color color;
  final double width;

  _DrawingPath({required this.points, required this.color, required this.width});
}

class _CanvasPainter extends CustomPainter {
  final List<_DrawingPath> paths;

  _CanvasPainter({required this.paths});

  @override
  void paint(Canvas canvas, Size size) {
    for (final path in paths) {
      final paint = Paint()
        ..color = path.color
        ..strokeWidth = path.width
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;

      if (path.points.length > 1) {
        for (int i = 0; i < path.points.length - 1; i++) {
          canvas.drawLine(path.points[i], path.points[i + 1], paint);
        }
      } else if (path.points.isNotEmpty) {
        canvas.drawCircle(path.points[0], path.width / 2, paint..style = PaintingStyle.fill);
      }
    }
  }

  @override
  bool shouldRepaint(_CanvasPainter old) => true;
}
