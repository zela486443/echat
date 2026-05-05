import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glassmorphic_container.dart';
import '../../widgets/aurora_gradient_bg.dart';

class CreateBotScreen extends StatefulWidget {
  const CreateBotScreen({super.key});

  @override
  State<CreateBotScreen> createState() => _CreateBotScreenState();
}

class _CreateBotScreenState extends State<CreateBotScreen> {
  int _step = 1;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Create New Bot', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: AuroraGradientBg(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
               _buildProgressHeader(),
               const SizedBox(height: 48),
               Expanded(
                 child: _step == 1 ? _buildStep1() : _step == 2 ? _buildStep2() : _buildStep3(),
               ),
               _buildNavigationButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildCircle(1, 'Info'),
        _buildLine(),
        _buildCircle(2, 'Logic'),
        _buildLine(),
        _buildCircle(3, 'Finalize'),
      ],
    );
  }

  Widget _buildCircle(int step, String label) {
    bool active = _step >= step;
    return Column(
      children: [
        Container(
          width: 32, height: 32,
          decoration: BoxDecoration(shape: BoxShape.circle, color: active ? AppTheme.primary : Colors.white10, border: Border.all(color: active ? AppTheme.primary : Colors.white24)),
          child: Center(child: Text('$step', style: TextStyle(color: active ? Colors.white : Colors.white24, fontWeight: FontWeight.bold))),
        ),
        const SizedBox(height: 8),
        Text(label, style: TextStyle(color: active ? Colors.white : Colors.white24, fontSize: 10)),
      ],
    );
  }

  Widget _buildLine() {
    return Container(width: 40, height: 1, color: Colors.white10, margin: const EdgeInsets.only(left: 10, right: 10, bottom: 18));
  }

  Widget _buildStep1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Bot Details', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 24),
        _buildTextField('Bot Name', _nameController, 'e.g. My Helper Bot'),
        const SizedBox(height: 20),
        _buildTextField('Username', _usernameController, 'e.g. my_helper_bot'),
        const SizedBox(height: 8),
        const Text('Users will find your bot with this @username', style: TextStyle(color: Colors.white24, fontSize: 11)),
      ],
    );
  }

  Widget _buildStep2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Response Logic', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 24),
        const Text('Choose how your bot should respond:', style: TextStyle(color: Colors.white70, fontSize: 14)),
        const SizedBox(height: 16),
        _buildLogicOption('Auto-Reply', 'Matches keywords to predefined answers', true),
        _buildLogicOption('AI-Powered', 'Uses GPT-4 to generate conversational replies', false),
        _buildLogicOption('Webhook', 'Points to your external server/API', false),
      ],
    );
  }

  Widget _buildStep3() {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.check_circle_outline, color: Colors.greenAccent, size: 80),
        SizedBox(height: 24),
        Text('Ready to Launch!', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
        SizedBox(height: 12),
        Text('Your bot will be listed in the marketplace once approved by moderators.', textAlign: TextAlign.center, style: TextStyle(color: Colors.white54, fontSize: 14)),
      ],
    );
  }

  Widget _buildTextField(String label, TextEditingController ctrl, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextField(controller: ctrl, style: const TextStyle(color: Colors.white), decoration: InputDecoration(hintText: hint, hintStyle: const TextStyle(color: Colors.white24), filled: true, fillColor: Colors.white.withOpacity(0.05), border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none))),
      ],
    );
  }

  Widget _buildLogicOption(String title, String desc, bool selected) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: GlassmorphicContainer(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                Text(desc, style: const TextStyle(color: Colors.white38, fontSize: 11)),
              ]),
            ),
            Radio(value: selected, groupValue: true, onChanged: (v) {}, activeColor: AppTheme.primary),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (_step > 1) TextButton(onPressed: () => setState(() => _step--), child: const Text('Back', style: TextStyle(color: Colors.white38)))
        else const SizedBox(),
        ElevatedButton(
          onPressed: () {
            if (_step < 3) setState(() => _step++);
            else Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16)),
          child: Text(_step == 3 ? 'Finish' : 'Next', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}
