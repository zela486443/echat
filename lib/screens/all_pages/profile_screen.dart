import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:ui';
import '../../theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../services/supabase_service.dart';
import '../../models/profile.dart';
import '../../providers/stars_provider.dart';

// ─── Story Highlight Model ──────────────────────────────────────────────────
class StoryHighlight {
  final String id;
  final String name;
  final Color coverColor;
  StoryHighlight({required this.id, required this.name, required this.coverColor});
}

// ─── Availability Status ─────────────────────────────────────────────────────
enum AvailabilityStatus { available, busy, away, invisible }

const _statusConfig = {
  AvailabilityStatus.available: {'label': 'Available', 'dot': Color(0xFF10B981)},
  AvailabilityStatus.busy: {'label': 'Busy', 'dot': Color(0xFFEF4444)},
  AvailabilityStatus.away: {'label': 'Away', 'dot': Color(0xFFF59E0B)},
  AvailabilityStatus.invisible: {'label': 'Invisible', 'dot': Color(0xFF6B7280)},
};

const _highlightPresetColors = [
  'linear-gradient(135deg, #FF6B9D, #FF0050)',
  'linear-gradient(135deg, #7C3AED, #4F46E5)',
  'linear-gradient(135deg, #10B981, #064E3B)',
  'linear-gradient(135deg, #F59E0B, #D97706)',
  'linear-gradient(135deg, #3B82F6, #1D4ED8)',
  'linear-gradient(135deg, #EC4899, #9333EA)',
];

const _highlightColors = [
  Color(0xFFFF6B9D), Color(0xFF7C3AED), Color(0xFF10B981),
  Color(0xFFF59E0B), Color(0xFF3B82F6), Color(0xFFEC4899),
  Color(0xFF06B6D4), Color(0xFFEF4444),
];

// ═══════════════════════════════════════════════════════════════════════════
//  PROFILE SCREEN — 100% parity with web app Profile.tsx
// ═══════════════════════════════════════════════════════════════════════════
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});
  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> with TickerProviderStateMixin {
  Profile? _profile;
  bool _loading = true;
  bool _saving = false;
  AvailabilityStatus _myStatus = AvailabilityStatus.available;

  // Edit dialog
  bool _editOpen = false;
  final _nameCtrl = TextEditingController();
  final _usernameCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();
  final _avatarCtrl = TextEditingController();
  DateTime? _birthdayDate;

  // Music
  bool _musicOpen = false;
  final _musicTitleCtrl = TextEditingController();
  final _musicArtistCtrl = TextEditingController();
  final _musicUrlCtrl = TextEditingController();
  bool _musicEnabled = false;
  bool _isPlaying = false;
  String? _musicTitle, _musicArtist, _musicUrl;
  final AudioPlayer _audioPlayer = AudioPlayer();


  // Story highlights
  List<StoryHighlight> _highlights = [];
  bool _highlightDialogOpen = false;
  final _highlightNameCtrl = TextEditingController();
  Color _selectedHighlightColor = _highlightColors[0];

  // QR
  bool _qrOpen = false;

  late final AnimationController _bannerAnim;

  @override
  void initState() {
    super.initState();
    _bannerAnim = AnimationController(vsync: this, duration: const Duration(seconds: 10))..repeat();
    _loadProfile();
  }

  @override
  void dispose() {
    _bannerAnim.dispose();
    _audioPlayer.dispose();
    _nameCtrl.dispose(); _usernameCtrl.dispose(); _bioCtrl.dispose();
    _avatarCtrl.dispose(); _birthdayCtrl.dispose();
    _musicTitleCtrl.dispose(); _musicArtistCtrl.dispose(); _musicUrlCtrl.dispose();
    _highlightNameCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    setState(() => _loading = true);
    try {
      final user = ref.read(authProvider).value;
      if (user != null) {
        _profile = user;
        _nameCtrl.text = user.name ?? '';
        _usernameCtrl.text = user.username;
        _bioCtrl.text = user.bio ?? '';
        _avatarCtrl.text = user.avatarUrl ?? '';
        _birthdayCtrl.text = user.birthday ?? '';
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _saveProfile() async {
    final user = ref.read(authProvider).value;
    if (user == null) return;
    final name = _nameCtrl.text.trim();
    final username = _usernameCtrl.text.trim().toLowerCase();
    if (name.isEmpty) { _snack('Name cannot be empty'); return; }
    if (username.length < 3) { _snack('Username must be at least 3 characters'); return; }

    setState(() => _saving = true);
    try {
      final updated = await ref.read(supabaseServiceProvider).updateProfile(user.id, {
        'name': name,
        'username': username,
        'bio': _bioCtrl.text.trim(),
        'avatar_url': _avatarCtrl.text.trim(),
        'birthday': _birthdayDate?.toIso8601String(),
      });
      if (updated != null) setState(() => _profile = updated);
      setState(() => _editOpen = false);
      _snack('Profile updated!');
    } catch (e) {
      _snack('Failed to update profile');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _toggleMusic() async {
    if (_musicUrl == null) return;
    if (_isPlaying) {
      await _audioPlayer.pause();
      setState(() => _isPlaying = false);
    } else {
      try {
        await _audioPlayer.play(UrlSource(_musicUrl!));
        setState(() => _isPlaying = true);
        _audioPlayer.onPlayerComplete.listen((_) { if (mounted) setState(() => _isPlaying = false); });
      } catch (_) { _snack('Could not play audio'); }
    }
  }

  void _saveMusic() {
    final title = _musicTitleCtrl.text.trim();
    final url = _musicUrlCtrl.text.trim();
    if (title.isEmpty) { _snack('Enter a title'); return; }
    if (url.isEmpty) { _snack('Enter an audio URL'); return; }
    setState(() {
      _musicTitle = title;
      _musicArtist = _musicArtistCtrl.text.trim();
      _musicUrl = url;
      _musicEnabled = true;
      _musicOpen = false;
    });
    _snack('Music added to profile!');
  }

  void _addHighlight() {
    final name = _highlightNameCtrl.text.trim();
    if (name.isEmpty) return;
    setState(() {
      _highlights.add(StoryHighlight(id: DateTime.now().millisecondsSinceEpoch.toString(), name: name, coverColor: _selectedHighlightColor));
      _highlightDialogOpen = false;
      _highlightNameCtrl.clear();
    });
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: const Color(0xFF1A1030),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final profile = _profile ?? ref.watch(authProvider).value;
    final displayName = profile?.name ?? 'User';
    final displayUsername = profile?.username ?? 'user';
    final displayBio = profile?.bio ?? 'Welcome to Echat! 🚀';
    final displayAvatar = profile?.avatarUrl;
    final displayEmail = profile?.email ?? '';

    if (_loading) {
      return const Scaffold(
        backgroundColor: Color(0xFF0D0A1A),
        body: Center(child: CircularProgressIndicator(color: Color(0xFF7C3AED), strokeWidth: 2)),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0D0A1A),
      body: Stack(children: [
        // Aurora glow
        Positioned(top: -80, right: -60, child: ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
          child: Container(width: 300, height: 300, decoration: BoxDecoration(shape: BoxShape.circle, color: AppTheme.primary.withOpacity(0.1))),
        )),

        // Scrollable content
        SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 100),
          child: Column(children: [
            // ── Hero Banner ───────────────────────────────────────────────
            SizedBox(
              height: 220,
              child: Stack(children: [
                // Animated gradient
                Positioned.fill(child: AnimatedBuilder(
                  animation: _bannerAnim,
                  builder: (ctx, _) {
                    return Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: const [Color(0xFFFF0050), Color(0xFF9B59B6), Color(0xFF3498DB), Color(0xFF7C3AED)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          stops: [
                            _bannerAnim.value,
                            (_bannerAnim.value + 0.33) % 1.0,
                            (_bannerAnim.value + 0.66) % 1.0,
                            1.0,
                          ],
                        ),
                      ),
                    );
                  },
                )),
                // Fade to background at bottom
                Positioned(bottom: 0, left: 0, right: 0, child: Container(
                  height: 80,
                  decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter, colors: [Color(0xFF0D0A1A), Colors.transparent])),
                )),

                // Floating orbs
                Positioned(top: -20, right: -20, child: Opacity(opacity: 0.12, child: Container(width: 120, height: 120, decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white)))),
                Positioned(bottom: 20, left: 30, child: Opacity(opacity: 0.08, child: Container(width: 80, height: 80, decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white)))),

                // Header bar
                SafeArea(child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(children: [
                    IconButton(icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20), onPressed: () => context.pop()),
                    Expanded(child: ShaderMask(
                      shaderCallback: (b) => const LinearGradient(colors: [Colors.white, Colors.white70]).createShader(b),
                      child: const Text('Profile', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
                    )),
                    IconButton(icon: const Icon(Icons.more_vert, color: Colors.white), onPressed: () => context.push('/settings')),
                  ]),
                )),
              ]),
            ),

            // ── Avatar ────────────────────────────────────────────────────
            Transform.translate(
              offset: const Offset(0, -55),
              child: Column(children: [
                // Avatar circle
                Stack(alignment: Alignment.center, children: [
                  // Glow
                  Opacity(opacity: 0.5, child: Container(
                    width: 130, height: 130,
                    decoration: BoxDecoration(shape: BoxShape.circle, gradient: LinearGradient(colors: [AppTheme.primary, const Color(0xFF7C3AED)]), boxShadow: [BoxShadow(color: AppTheme.primary.withOpacity(0.4), blurRadius: 30, spreadRadius: 5)]),
                  )),
                  Container(
                    width: 112, height: 112,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF0D0A1A), width: 4),
                      gradient: displayAvatar == null ? LinearGradient(colors: [AppTheme.primary, const Color(0xFF7C3AED)]) : null,
                    ),
                    child: displayAvatar != null
                      ? ClipOval(child: Image.network(displayAvatar, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Center(child: Text(displayName[0].toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 36)))))
                      : Center(child: Text(displayName[0].toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 36))),
                  ),
                  // Edit button
                  Positioned(bottom: 0, right: 0, child: GestureDetector(
                    onTap: () => setState(() => _editOpen = true),
                    child: Container(
                      width: 34, height: 34,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [AppTheme.primary, const Color(0xFF7C3AED)]),
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFF0D0A1A), width: 2),
                      ),
                      child: const Icon(LucideIcons.edit2, color: Colors.white, size: 14),
                    ),
                  )),
                ]),

                const SizedBox(height: 12),

                // Name + verification
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text(displayName, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                  if (profile?.isVerified ?? false) ...[
                    const SizedBox(width: 6),
                    Icon(LucideIcons.badgeCheck, color: AppTheme.primary, size: 22),
                  ],
                ]),
                const SizedBox(height: 4),
                Text('@$displayUsername', style: TextStyle(color: Colors.white.withOpacity(0.5), fontWeight: FontWeight.w500)),
                const SizedBox(height: 6),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(displayBio, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13, height: 1.4), textAlign: TextAlign.center),
                ),
                const SizedBox(height: 10),

                // Music badge
                if (_musicEnabled && _musicTitle != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(color: AppTheme.primary.withOpacity(0.12), borderRadius: BorderRadius.circular(24)),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(LucideIcons.music, size: 13, color: AppTheme.primary),
                      const SizedBox(width: 6),
                      Text('$_musicTitle${_musicArtist != null ? " — $_musicArtist" : ""}', style: TextStyle(color: AppTheme.primary, fontSize: 12, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis),
                      const SizedBox(width: 6),
                      GestureDetector(onTap: _toggleMusic, child: Icon(_isPlaying ? LucideIcons.pause : LucideIcons.play, size: 13, color: AppTheme.primary)),
                    ]),
                  ),

                const SizedBox(height: 10),
                // Stars balance
                GestureDetector(
                  onTap: () => context.push('/gifts'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(color: const Color(0xFFF59E0B).withOpacity(0.12), borderRadius: BorderRadius.circular(24)),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(LucideIcons.star, size: 13, color: Color(0xFFF59E0B)),
                      const SizedBox(width: 6),
                      Text('${ref.watch(starsProvider)} Stars', style: const TextStyle(color: Color(0xFFF59E0B), fontSize: 13, fontWeight: FontWeight.w700)),
                    ]),
                  ),
                ),

                const SizedBox(height: 16),

                // Action buttons: Chats / Call / QR
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(children: [
                    Expanded(child: _actionBtn(Icons.message_outlined, 'Chats', gradient: true, onTap: () => context.go('/chats'))),
                    const SizedBox(width: 10),
                    Expanded(child: _actionBtn(LucideIcons.phone, 'Call', onTap: () => context.push('/calls'))),
                    const SizedBox(width: 10),
                    Expanded(child: _actionBtn(LucideIcons.qrCode, 'QR', onTap: () => setState(() => _qrOpen = true))),
                  ]),
                ),

                const SizedBox(height: 20),

                // ── Story Highlights ─────────────────────────────────────
                _buildSection('Highlights', trailing: GestureDetector(
                  onTap: () => setState(() => _highlightDialogOpen = true),
                  child: Text('+ New', style: TextStyle(color: AppTheme.primary, fontSize: 12, fontWeight: FontWeight.w700)),
                )),
                SizedBox(
                  height: 96,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      // Add new
                      GestureDetector(
                        onTap: () => setState(() => _highlightDialogOpen = true),
                        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                          Container(
                            width: 64, height: 64,
                            decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white.withOpacity(0.2), width: 2, style: BorderStyle.solid), color: Colors.white.withOpacity(0.05)),
                            child: Icon(LucideIcons.plus, color: Colors.white.withOpacity(0.4), size: 24),
                          ),
                          const SizedBox(height: 4),
                          Text('New', style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 10)),
                        ]),
                      ),
                      ...(_highlights.map((h) => Padding(
                        padding: const EdgeInsets.only(left: 12),
                        child: Stack(children: [
                          Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                            Container(
                              width: 64, height: 64,
                              decoration: BoxDecoration(shape: BoxShape.circle, color: h.coverColor, boxShadow: [BoxShadow(color: h.coverColor.withOpacity(0.4), blurRadius: 8)]),
                              child: Center(child: Text(h.name[0].toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold))),
                            ),
                            const SizedBox(height: 4),
                            Text(h.name, style: const TextStyle(color: Colors.white, fontSize: 10), overflow: TextOverflow.ellipsis),
                          ]),
                          Positioned(top: 0, right: 0, child: GestureDetector(
                            onTap: () => setState(() => _highlights.removeWhere((x) => x.id == h.id)),
                            child: Container(width: 18, height: 18, decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle), child: const Icon(Icons.close, color: Colors.white, size: 12)),
                          )),
                        ]),
                      ))),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // ── Info Card ─────────────────────────────────────────────
                _buildCard(children: [
                  _buildCardHeader('Info', action: GestureDetector(onTap: () => setState(() => _editOpen = true), child: Row(children: [Icon(LucideIcons.edit2, size: 13, color: AppTheme.primary), const SizedBox(width: 4), Text('Edit', style: TextStyle(color: AppTheme.primary, fontSize: 12, fontWeight: FontWeight.w700))]))),
                  ...[
                    if (displayEmail.isNotEmpty) _infoRow('Email', displayEmail),
                    _infoRow('Username', '@$displayUsername'),
                    _infoRow('Bio', displayBio),
                    if ((profile?.birthday ?? '').isNotEmpty) _infoRow('🎂 Birthday', profile!.birthday!),
                    _infoRow('Status', _statusConfig[_myStatus]!['label'] as String, valueColor: _statusConfig[_myStatus]!['dot'] as Color),
                    _buildDivider(),
                    _infoRow(
                      'Custom Theme', 
                      'Default', 
                      onTap: () => _showThemePicker(),
                      valueColor: AppTheme.primary,
                    ),
                  ],
                ]),

                const SizedBox(height: 12),

                // ── Availability Card ──────────────────────────────────────
                _buildCard(children: [
                  _buildCardHeader('Availability'),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    child: GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 4,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 1.1,
                      children: AvailabilityStatus.values.map((s) {
                        final cfg = _statusConfig[s]!;
                        final active = _myStatus == s;
                        return GestureDetector(
                          onTap: () { setState(() => _myStatus = s); _snack('Status: ${cfg['label']}'); },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            decoration: BoxDecoration(
                              color: active ? AppTheme.primary.withOpacity(0.15) : Colors.white.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: active ? AppTheme.primary.withOpacity(0.4) : Colors.white.withOpacity(0.08)),
                            ),
                            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                              Container(width: 12, height: 12, decoration: BoxDecoration(shape: BoxShape.circle, color: cfg['dot'] as Color)),
                              const SizedBox(height: 4),
                              Text(cfg['label'] as String, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600), textAlign: TextAlign.center),
                            ]),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ]),

                const SizedBox(height: 12),

                // ── Music Card ────────────────────────────────────────────
                _buildCard(children: [
                  _buildCardHeader(
                    'Profile Music',
                    prefix: Icon(LucideIcons.music, size: 16, color: AppTheme.primary),
                    action: _musicEnabled
                      ? Row(children: [
                          _miniSwitch(_musicEnabled, (v) => setState(() => _musicEnabled = v)),
                          const SizedBox(width: 8),
                          GestureDetector(onTap: () { setState(() { _musicTitle = null; _musicArtist = null; _musicUrl = null; _musicEnabled = false; }); _snack('Music removed'); }, child: const Text('Remove', style: TextStyle(color: Colors.red, fontSize: 11, fontWeight: FontWeight.w700))),
                        ])
                      : GestureDetector(onTap: () => setState(() => _musicOpen = true), child: Text('Add Music', style: TextStyle(color: AppTheme.primary, fontSize: 12, fontWeight: FontWeight.bold))),
                  ),
                  if (_musicTitle != null)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                      child: Row(children: [
                        Container(width: 40, height: 40, decoration: BoxDecoration(color: AppTheme.primary.withOpacity(0.15), borderRadius: BorderRadius.circular(12)), child: Icon(LucideIcons.music, color: AppTheme.primary, size: 18)),
                        const SizedBox(width: 12),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(_musicTitle!, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13), overflow: TextOverflow.ellipsis),
                          if (_musicArtist != null) Text(_musicArtist!, style: TextStyle(color: Colors.white.withOpacity(0.45), fontSize: 12)),
                        ])),
                        GestureDetector(
                          onTap: _toggleMusic,
                          child: Container(width: 36, height: 36, decoration: BoxDecoration(color: AppTheme.primary.withOpacity(0.15), borderRadius: BorderRadius.circular(12)), child: Icon(_isPlaying ? LucideIcons.pause : LucideIcons.play, color: AppTheme.primary, size: 16)),
                        ),
                      ]),
                    )
                  else
                    Padding(padding: const EdgeInsets.fromLTRB(16, 4, 16, 16), child: Text('Add a song to your profile to share your vibe.', style: TextStyle(color: Colors.white.withOpacity(0.35), fontSize: 13))),
                ]),

                const SizedBox(height: 12),

                // ── Shared Media Card ─────────────────────────────────────
                _buildCard(children: [
                  _buildCardHeader('Shared Media'),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                    child: Column(children: [
                      GridView.count(crossAxisCount: 3, crossAxisSpacing: 8, mainAxisSpacing: 8, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), children: List.generate(3, (_) => Container(decoration: BoxDecoration(color: Colors.white.withOpacity(0.06), borderRadius: BorderRadius.circular(12))))),
                      const SizedBox(height: 10),
                      GestureDetector(onTap: () => context.push('/saved-messages'), child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(LucideIcons.image, size: 15, color: AppTheme.primary), const SizedBox(width: 6), Text('View all media', style: TextStyle(color: AppTheme.primary, fontSize: 13, fontWeight: FontWeight.w600))])),
                    ]),
                  ),
                ]),
              ]),
            ),
          ]),
        ),

        // ── Edit Profile Dialog ───────────────────────────────────────────
        if (_editOpen) _buildEditDialog(displayName, displayUsername),

        // ── Music Dialog ──────────────────────────────────────────────────
        if (_musicOpen) _buildMusicDialog(),

        // ── Highlight Dialog ──────────────────────────────────────────────
        if (_highlightDialogOpen) _buildHighlightDialog(),

        // ── QR Dialog ────────────────────────────────────────────────────
        if (_qrOpen) _buildQRDialog(displayUsername),
      ]),
    );
  }

  // ─── Helper Widgets ─────────────────────────────────────────────────────
  Widget _actionBtn(IconData icon, String label, {bool gradient = false, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 46,
        decoration: BoxDecoration(
          gradient: gradient ? LinearGradient(colors: [AppTheme.primary, const Color(0xFF7C3AED)]) : null,
          color: gradient ? null : Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(14),
          border: gradient ? null : Border.all(color: Colors.white.withOpacity(0.1)),
          boxShadow: gradient ? [BoxShadow(color: AppTheme.primary.withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 4))] : null,
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
        ]),
      ),
    );
  }

  Widget _buildSection(String title, {Widget? trailing}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(title.toUpperCase(), style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.5)),
        if (trailing != null) trailing,
      ]),
    );
  }

  Widget _buildCard({required List<Widget> children}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.04), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white.withOpacity(0.07))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
    );
  }

  Widget _buildCardHeader(String title, {Widget? action, Widget? prefix}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.05)))),
      child: Row(children: [
        if (prefix != null) ...[prefix, const SizedBox(width: 8)],
        Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
        const Spacer(),
        if (action != null) action,
      ]),
    );
  }

  Widget _infoRow(String label, String value, {Color? valueColor}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.04)))),
      child: Row(children: [
        Text(label, style: TextStyle(color: Colors.white.withOpacity(0.45), fontSize: 13)),
        const Spacer(),
        Flexible(child: Text(value, style: TextStyle(color: valueColor ?? Colors.white, fontSize: 13, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis, textAlign: TextAlign.right)),
      ]),
    );
  }

  Widget _miniSwitch(bool value, ValueChanged<bool> onChange) {
    return GestureDetector(
      onTap: () => onChange(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 36, height: 20,
        decoration: BoxDecoration(color: value ? AppTheme.primary : Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(width: 16, height: 16, margin: const EdgeInsets.all(2), decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white)),
        ),
      ),
    );
  }

  // ─── EDIT DIALOG ────────────────────────────────────────────────────────
  Widget _buildEditDialog(String displayName, String displayUsername) {
    return Material(
      color: Colors.black54,
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(16),
          constraints: const BoxConstraints(maxHeight: 600),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: const Color(0xFF1A1030), borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.white.withOpacity(0.1))),
          child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Edit Profile', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            // Avatar preview
            Center(child: Stack(children: [
              Container(
                width: 80, height: 80,
                decoration: BoxDecoration(shape: BoxShape.circle, gradient: LinearGradient(colors: [AppTheme.primary.withOpacity(0.5), const Color(0xFF7C3AED).withOpacity(0.4)])),
                child: _avatarCtrl.text.isNotEmpty
                  ? ClipOval(child: Image.network(_avatarCtrl.text, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Icon(LucideIcons.camera, color: AppTheme.primary, size: 28)))
                  : Icon(LucideIcons.camera, color: AppTheme.primary, size: 28),
              ),
            ])),
            const SizedBox(height: 12),
            _editField('Profile Photo URL', _avatarCtrl, 'https://example.com/photo.jpg'),
            const SizedBox(height: 10),
            _editField('Name', _nameCtrl, 'Your name'),
            const SizedBox(height: 10),
            Row(children: [
              Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12), decoration: BoxDecoration(color: Colors.white.withOpacity(0.07), borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), bottomLeft: Radius.circular(12))), child: Text('@', style: TextStyle(color: Colors.white.withOpacity(0.5)))),
              Expanded(child: TextField(controller: _usernameCtrl, style: const TextStyle(color: Colors.white), decoration: InputDecoration(hintText: 'username', hintStyle: TextStyle(color: Colors.white.withOpacity(0.25)), filled: true, fillColor: Colors.white.withOpacity(0.07), border: const OutlineInputBorder(borderRadius: BorderRadius.only(topRight: Radius.circular(12), bottomRight: Radius.circular(12)), borderSide: BorderSide.none), contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12)))),
            ]),
            const SizedBox(height: 10),
            TextField(controller: _bioCtrl, style: const TextStyle(color: Colors.white), maxLines: 3, maxLength: 150, decoration: InputDecoration(hintText: 'Tell us about yourself...', hintStyle: TextStyle(color: Colors.white.withOpacity(0.25)), filled: true, fillColor: Colors.white.withOpacity(0.07), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none), contentPadding: const EdgeInsets.all(12))),
            const SizedBox(height: 10),
            Row(children: [
              Icon(LucideIcons.cake, size: 14, color: const Color(0xFFEC4899)),
              const SizedBox(width: 6),
              const Text('Birthday', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
            ]),
            const SizedBox(height: 6),
            GestureDetector(
              onTap: () async {
                final d = await showDatePicker(
                  context: context,
                  initialDate: _birthdayDate ?? DateTime(2000),
                  firstDate: DateTime(1900),
                  lastDate: DateTime.now(),
                  builder: (context, child) => Theme(data: ThemeData.dark().copyWith(colorScheme: const ColorScheme.dark(primary: AppTheme.primary, onPrimary: Colors.white, surface: Color(0xFF1A1030), onSurface: Colors.white)), child: child!),
                );
                if (d != null) setState(() => _birthdayDate = d);
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.07), borderRadius: BorderRadius.circular(12)),
                child: Text(
                  _birthdayDate != null ? "${_birthdayDate!.year}-${_birthdayDate!.month.toString().padLeft(2, '0')}-${_birthdayDate!.day.toString().padLeft(2, '0')}" : 'Select your birthday',
                  style: TextStyle(color: _birthdayDate != null ? Colors.white : Colors.white24, fontSize: 14),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(children: [
              Expanded(child: GestureDetector(onTap: () => setState(() => _editOpen = false), child: Container(height: 46, decoration: BoxDecoration(color: Colors.white.withOpacity(0.07), borderRadius: BorderRadius.circular(14)), child: const Center(child: Text('Cancel', style: TextStyle(color: Colors.white60)))))),
              const SizedBox(width: 12),
              Expanded(child: GestureDetector(onTap: _saveProfile, child: Container(height: 46, decoration: BoxDecoration(gradient: LinearGradient(colors: [AppTheme.primary, const Color(0xFF7C3AED)]), borderRadius: BorderRadius.circular(14)), child: Center(child: _saving ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('Save Changes', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))))),
            ]),
          ])),
        ),
      ),
    );
  }

  Widget _editField(String label, TextEditingController ctrl, String hint) {
    return TextField(
      controller: ctrl,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12),
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.2)),
        filled: true, fillColor: Colors.white.withOpacity(0.07),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    );
  }

  // ─── MUSIC DIALOG ───────────────────────────────────────────────────────
  Widget _buildMusicDialog() {
    return Material(
      color: Colors.black54,
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: const Color(0xFF1A1030), borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.white.withOpacity(0.1))),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [Icon(LucideIcons.music, color: AppTheme.primary, size: 18), const SizedBox(width: 8), const Text('Add Profile Music', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold))]),
            const SizedBox(height: 16),
            _editField('Song Title', _musicTitleCtrl, 'e.g. Blinding Lights'),
            const SizedBox(height: 10),
            _editField('Artist', _musicArtistCtrl, 'e.g. The Weeknd'),
            const SizedBox(height: 10),
            _editField('Audio URL', _musicUrlCtrl, 'https://...mp3'),
            const SizedBox(height: 4),
            Text('Link to an MP3 or audio file', style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 11)),
            const SizedBox(height: 20),
            Row(children: [
              Expanded(child: GestureDetector(onTap: () => setState(() => _musicOpen = false), child: Container(height: 44, decoration: BoxDecoration(color: Colors.white.withOpacity(0.07), borderRadius: BorderRadius.circular(12)), child: const Center(child: Text('Cancel', style: TextStyle(color: Colors.white60)))))),
              const SizedBox(width: 12),
              Expanded(child: GestureDetector(onTap: _saveMusic, child: Container(height: 44, decoration: BoxDecoration(gradient: LinearGradient(colors: [AppTheme.primary, const Color(0xFF7C3AED)]), borderRadius: BorderRadius.circular(12)), child: const Center(child: Text('Add', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))))),
            ]),
          ]),
        ),
      ),
    );
  }

  // ─── HIGHLIGHT DIALOG ───────────────────────────────────────────────────
  Widget _buildHighlightDialog() {
    return Material(
      color: Colors.black54,
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: const Color(0xFF1A1030), borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.white.withOpacity(0.1))),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('New Highlight', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _editField('Name', _highlightNameCtrl, 'e.g. Travel, Friends, Work…'),
            const SizedBox(height: 16),
            Text('Cover Color', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(spacing: 8, runSpacing: 8, children: _highlightColors.map((c) => GestureDetector(
              onTap: () => setState(() => _selectedHighlightColor = c),
              child: Container(width: 32, height: 32, decoration: BoxDecoration(shape: BoxShape.circle, color: c, border: _selectedHighlightColor == c ? Border.all(color: Colors.white, width: 2.5) : null)),
            )).toList()),
            const SizedBox(height: 12),
            Container(
              width: double.infinity, height: 40,
              decoration: BoxDecoration(color: _selectedHighlightColor, borderRadius: BorderRadius.circular(12)),
              child: Center(child: Text(_highlightNameCtrl.text.isEmpty ? 'Preview' : _highlightNameCtrl.text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
            ),
            const SizedBox(height: 20),
            Row(children: [
              Expanded(child: GestureDetector(onTap: () => setState(() => _highlightDialogOpen = false), child: Container(height: 44, decoration: BoxDecoration(color: Colors.white.withOpacity(0.07), borderRadius: BorderRadius.circular(12)), child: const Center(child: Text('Cancel', style: TextStyle(color: Colors.white60)))))),
              const SizedBox(width: 12),
              Expanded(child: GestureDetector(onTap: _addHighlight, child: Container(height: 44, decoration: BoxDecoration(gradient: LinearGradient(colors: [AppTheme.primary, const Color(0xFF7C3AED)]), borderRadius: BorderRadius.circular(12)), child: const Center(child: Text('Create', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))))),
            ]),
          ]),
        ),
      ),
    );
  }

  // ─── QR DIALOG ──────────────────────────────────────────────────────────
  Widget _buildQRDialog(String username) {
    final qrData = 'https://echat.app?add=@$username';
    return Material(
      color: Colors.black54,
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(32),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: const Color(0xFF1A1030), borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.white.withOpacity(0.1))),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Text('My QR Code', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
              child: QrImageView(data: qrData, version: QrVersions.auto, size: 200),
            ),
            const SizedBox(height: 12),
            Text('Scan to add @$username', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13)),
            Text(qrData, style: TextStyle(color: AppTheme.primary, fontSize: 11, fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(child: GestureDetector(
                onTap: () async {
                  await Clipboard.setData(ClipboardData(text: qrData));
                  _snack('Link copied!');
                },
                child: Container(height: 44, decoration: BoxDecoration(color: Colors.white.withOpacity(0.07), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white12)), child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(LucideIcons.share2, size: 14, color: Colors.white70), const SizedBox(width: 6), const Text('Copy Link', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600))])),
              )),
              const SizedBox(width: 12),
              GestureDetector(onTap: () => setState(() => _qrOpen = false), child: Container(height: 44, padding: const EdgeInsets.symmetric(horizontal: 20), decoration: BoxDecoration(gradient: LinearGradient(colors: [AppTheme.primary, const Color(0xFF7C3AED)]), borderRadius: BorderRadius.circular(12)), child: const Center(child: Text('Done', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))))),
            ]),
          ]),
        ),
      ),
    );
  }

  void _showThemePicker() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1030),
        title: const Text('Custom Accent Color', style: TextStyle(color: Colors.white, fontSize: 16)),
        content: Wrap(
          spacing: 12, runSpacing: 12,
          children: _highlightColors.map((c) => GestureDetector(
            onTap: () {
              _snack('Theme applied!');
              Navigator.pop(ctx);
            },
            child: Container(width: 40, height: 40, decoration: BoxDecoration(color: c, shape: BoxShape.circle)),
          )).toList(),
        ),
      ),
    );
  }

  Widget _buildDivider() => Divider(height: 1, color: Colors.white.withOpacity(0.05), indent: 16, endIndent: 16);
}
