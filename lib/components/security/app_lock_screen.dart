import 'package:flutter/material.dart';

class AppLockScreen extends StatefulWidget {
  const AppLockScreen({super.key});

  @override
  State<AppLockScreen> createState() => _AppLockScreenState();
}

class _AppLockScreenState extends State<AppLockScreen> {
  String _pin = '';

  void _addPin(String digit) {
    if (_pin.length < 4) {
      setState(() => _pin += digit);
      if (_pin.length == 4) {
        // Authenticate logic
        Future.delayed(const Duration(milliseconds: 300), () => setState(() => _pin = ''));
        Navigator.pop(context, true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock, color: Colors.blueAccent, size: 64),
            const SizedBox(height: 24),
            const Text('Enter Passcode', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (index) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _pin.length > index ? Colors.blueAccent : Colors.transparent,
                    border: Border.all(color: Colors.blueAccent, width: 2),
                  ),
                );
              }),
            ),
            const SizedBox(height: 64),
            _buildKeypad(),
          ],
        ),
      ),
    );
  }

  Widget _buildKeypad() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Column(
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [_buildBtn('1'), _buildBtn('2'), _buildBtn('3')]),
          const SizedBox(height: 24),
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [_buildBtn('4'), _buildBtn('5'), _buildBtn('6')]),
          const SizedBox(height: 24),
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [_buildBtn('7'), _buildBtn('8'), _buildBtn('9')]),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const SizedBox(width: 70), // empty space
              _buildBtn('0'),
              GestureDetector(
                onTap: () {
                  if (_pin.isNotEmpty) setState(() => _pin = _pin.substring(0, _pin.length - 1));
                },
                child: const SizedBox(
                  width: 70,
                  height: 70,
                  child: Center(child: Icon(Icons.backspace, color: Colors.white)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBtn(String digit) {
    return GestureDetector(
      onTap: () => _addPin(digit),
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), shape: BoxShape.circle),
        child: Center(child: Text(digit, style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold))),
      ),
    );
  }
}
