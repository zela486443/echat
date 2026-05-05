import 'package:flutter/material.dart';

class DrawingCanvasWidget extends StatefulWidget {
  const DrawingCanvasWidget({super.key});

  @override
  State<DrawingCanvasWidget> createState() => _DrawingCanvasWidgetState();
}

class _DrawingCanvasWidgetState extends State<DrawingCanvasWidget> {
  final List<Offset?> _points = [];
  Color _selectedColor = Colors.red;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: () => Navigator.pop(context)),
        actions: [
          IconButton(icon: const Icon(Icons.undo, color: Colors.white), onPressed: () => setState(() => _points.clear())),
          IconButton(icon: const Icon(Icons.send, color: Colors.white), onPressed: () => Navigator.pop(context, 'image_data')),
        ],
      ),
      body: Stack(
        children: [
          GestureDetector(
            onPanUpdate: (details) => setState(() => _points.add(details.localPosition)),
            onPanEnd: (details) => setState(() => _points.add(null)),
            child: CustomPaint(
              painter: _DrawingPainter(_points, _selectedColor),
              size: Size.infinite,
            ),
          ),
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [Colors.red, Colors.blue, Colors.green, Colors.yellow, Colors.white].map((color) {
                return GestureDetector(
                  onTap: () => setState(() => _selectedColor = color),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    width: _selectedColor == color ? 36 : 24,
                    height: _selectedColor == color ? 36 : 24,
                    decoration: BoxDecoration(color: color, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
                  ),
                );
              }).toList(),
            ),
          )
        ],
      ),
    );
  }
}

class _DrawingPainter extends CustomPainter {
  final List<Offset?> points;
  final Color color;

  _DrawingPainter(this.points, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 5.0;

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i]!, points[i + 1]!, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
