import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class SendMoneyScreen extends StatefulWidget {
  const SendMoneyScreen({super.key});

  @override
  State<SendMoneyScreen> createState() => _SendMoneyScreenState();
}

class _SendMoneyScreenState extends State<SendMoneyScreen> {
  String amount = '0';

  void _onKeypadTap(String value) {
    setState(() {
      if (amount == '0') {
        amount = value;
      } else {
        amount += value;
      }
    });
  }

  void _onBackspace() {
    setState(() {
      if (amount.length > 1) {
        amount = amount.substring(0, amount.length - 1);
      } else {
        amount = '0';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Send Money', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          const SizedBox(height: 32),
          // User Selection
          ListTile(
            leading: CircleAvatar(
              backgroundColor: theme.colorScheme.surface,
              child: const Icon(Icons.person_outline),
            ),
            title: const Text('Alex Smith', style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('@alex_smith', style: TextStyle(color: theme.colorScheme.onBackground.withOpacity(0.6))),
            trailing: IconButton(
              icon: const Icon(Icons.keyboard_arrow_down),
              onPressed: () {},
            ),
          ),
          
          Expanded(
            child: Center(
              child: Text(
                '\$$amount',
                style: const TextStyle(
                  fontSize: 64,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -2,
                ),
              ),
            ),
          ),

          // Custom Keypad
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(32),
                topRight: Radius.circular(32),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 20,
                  offset: const Offset(0, -10),
                )
              ],
            ),
            child: Column(
              children: [
                for (int i = 0; i < 3; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        for (int j = 1; j <= 3; j++)
                          _KeypadButton(
                            value: '${i * 3 + j}',
                            onTap: () => _onKeypadTap('${i * 3 + j}'),
                          ),
                      ],
                    ),
                  ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _KeypadButton(
                      value: '.',
                      onTap: () => _onKeypadTap('.'),
                    ),
                    _KeypadButton(
                      value: '0',
                      onTap: () => _onKeypadTap('0'),
                    ),
                    _KeypadButton(
                      icon: Icons.backspace_outlined,
                      onTap: _onBackspace,
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: AppTheme.gradientAurora,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                    ),
                    child: const Text('Send Money', style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
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

class _KeypadButton extends StatelessWidget {
  final String? value;
  final IconData? icon;
  final VoidCallback onTap;

  const _KeypadButton({this.value, this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(32),
      child: Container(
        width: 80,
        height: 60,
        alignment: Alignment.center,
        child: value != null
            ? Text(
                value!,
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              )
            : Icon(icon, size: 28),
      ),
    );
  }
}
