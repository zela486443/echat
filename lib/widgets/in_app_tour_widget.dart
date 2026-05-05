import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class InAppTourWidget extends StatefulWidget {
  final Widget child;
  final List<TourStep> steps;
  final VoidCallback onComplete;

  const InAppTourWidget({
    super.key,
    required this.child,
    required this.steps,
    required this.onComplete,
  });

  @override
  State<InAppTourWidget> createState() => _InAppTourWidgetState();
}

class TourStep {
  final String title;
  final String description;
  final Alignment alignment;

  TourStep({required this.title, required this.description, required this.alignment});
}

class _InAppTourWidgetState extends State<InAppTourWidget> {
  int _currentStep = 0;
  bool _isVisible = true;

  void _next() {
    if (_currentStep < widget.steps.length - 1) {
      setState(() => _currentStep++);
    } else {
      setState(() => _isVisible = false);
      widget.onComplete();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isVisible) return widget.child;

    final step = widget.steps[_currentStep];

    return Stack(
      children: [
        widget.child,
        // Dim background
        Positioned.fill(child: Container(color: Colors.black.withOpacity(0.7))),
        // Highlight logic (Simplified for this version)
        Positioned.fill(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _next,
              child: Stack(
                children: [
                  Align(
                    alignment: step.alignment,
                    child: Padding(
                      padding: const EdgeInsets.all(40),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A1030),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppTheme.primary, width: 2),
                          boxShadow: [BoxShadow(color: AppTheme.primary.withOpacity(0.3), blurRadius: 20)],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(step.title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            Text(step.description, style: const TextStyle(color: Colors.white70, fontSize: 14)),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Step ${_currentStep + 1} of ${widget.steps.length}', style: const TextStyle(color: Colors.white38, fontSize: 12)),
                                TextButton(onPressed: _next, child: Text(_currentStep == widget.steps.length - 1 ? 'FINISH' : 'NEXT', style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold))),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
