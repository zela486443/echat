import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'dart:ui';
import '../../theme/app_theme.dart';
import '../../providers/chat_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/profile.dart';
import '../../services/supabase_service.dart';

class NearbyPeopleScreen extends ConsumerStatefulWidget {
  const NearbyPeopleScreen({super.key});

  @override
  ConsumerState<NearbyPeopleScreen> createState() => _NearbyPeopleScreenState();
}

class _NearbyPeopleScreenState extends ConsumerState<NearbyPeopleScreen> {
  bool _isVisible = false;
  final List<String> _sentRequests = [];
  List<Profile> _nearbyPeople = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadNearby();
  }

  Future<void> _loadNearby() async {
    setState(() => _isLoading = true);
    final service = ref.read(supabaseServiceProvider);
    final people = await service.fetchNearbyProfiles();
    if (mounted) {
      setState(() {
        _nearbyPeople = people;
        _isLoading = false;
      });
    }
  }

  void _handleSayHi(Profile profile) async {
    final currentUserId = ref.read(authProvider).value?.id;
    if (currentUserId == null) return;

    final service = ref.read(supabaseServiceProvider);
    final chatId = await service.findOrCreateChat(currentUserId, profile.id);
    if (chatId != null && mounted) {
      setState(() => _sentRequests.add(profile.id));
      context.push('/chat/$chatId');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0A1A),
      body: CustomScrollView(
        slivers: [
          _buildHeader(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildVisibilityToggle(),
                  const SizedBox(height: 24),
                  if (!_isVisible) _buildHiddenState() else ...[
                    _buildConnectionRequests(),
                    _buildNearbyList(),
                  ],
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return SliverAppBar(
      backgroundColor: const Color(0xFF0D0A1A).withOpacity(0.9),
      pinned: true,
      elevation: 0,
      leading: IconButton(icon: const Icon(LucideIcons.arrowLeft, color: Colors.white, size: 22), onPressed: () => context.pop()),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('People Nearby', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
          if (_isVisible) const Text('Visible · Updated just now', style: TextStyle(color: const Color(0xFF10B981), fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
      actions: [
        if (_isVisible) IconButton(icon: const Icon(LucideIcons.navigation, color: Colors.white38, size: 18), onPressed: () {}),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildVisibilityToggle() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFF151122), borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.white.withOpacity(0.05))),
      child: Row(
        children: [
          Container(width: 40, height: 40, decoration: BoxDecoration(color: _isVisible ? const Color(0xFF10B981).withOpacity(0.1) : Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(12)), child: Icon(LucideIcons.radio, color: _isVisible ? const Color(0xFF10B981) : Colors.white24, size: 20)),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Make myself visible', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                Text('Let others nearby see you', style: TextStyle(color: Colors.white38, fontSize: 12)),
              ],
            ),
          ),
          Switch(value: _isVisible, onChanged: (v) => setState(() => _isVisible = v), activeColor: const Color(0xFF10B981)),
        ],
      ),
    );
  }

  Widget _buildHiddenState() {
    return Column(
      children: [
        const SizedBox(height: 60),
        Container(width: 80, height: 80, decoration: BoxDecoration(color: const Color(0xFF7C3AED).withOpacity(0.1), borderRadius: BorderRadius.circular(24)), child: const Icon(LucideIcons.mapPin, color: Color(0xFF7C3AED), size: 40)),
        const SizedBox(height: 24),
        const Text('Discover people nearby', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        const Text('Turn on visibility to find people around you. Only approximate distances are shared.', textAlign: TextAlign.center, style: TextStyle(color: Colors.white24, fontSize: 13)),
      ],
    );
  }

  Widget _buildConnectionRequests() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('CONNECTION REQUESTS', style: TextStyle(color: Colors.white24, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: const Color(0xFF151122), borderRadius: BorderRadius.circular(24), border: Border.all(color: const Color(0xFF7C3AED).withOpacity(0.2))),
          child: Row(
            children: [
              CircleAvatar(radius: 20, backgroundColor: Color(0xFF7C3AED), child: Text('AT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12))),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Abel Tesfaye', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                    Text('Wants to connect', style: TextStyle(color: Colors.white38, fontSize: 11)),
                  ],
                ),
              ),
              IconButton(icon: const Icon(LucideIcons.check, color: const Color(0xFF10B981), size: 18), onPressed: () {}),
              IconButton(icon: const Icon(LucideIcons.x, color: Colors.redAccent, size: 18), onPressed: () {}),
            ],
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildNearbyList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('${_nearbyPeople.length} PEOPLE ONLINE', style: const TextStyle(color: Colors.white24, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
        const SizedBox(height: 12),
        if (_isLoading)
          const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator(color: Color(0xFF7C3AED))))
        else if (_nearbyPeople.isEmpty)
          const Center(child: Padding(padding: EdgeInsets.all(20), child: Text('No one nearby yet', style: TextStyle(color: Colors.white24))))
        else
          Container(
            decoration: BoxDecoration(color: const Color(0xFF151122), borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.white.withOpacity(0.05))),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _nearbyPeople.length,
              separatorBuilder: (context, index) => Divider(height: 1, color: Colors.white.withOpacity(0.03), indent: 70),
              itemBuilder: (context, index) {
                final user = _nearbyPeople[index];
                final isSent = _sentRequests.contains(user.id);
                // Mock distance for aesthetic parity
                final distance = '${(index + 1) * 150}m';
                
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: Stack(
                    children: [
                      CircleAvatar(
                        radius: 24, 
                        backgroundColor: const Color(0xFF7C3AED).withOpacity(0.1),
                        backgroundImage: user.avatarUrl != null ? NetworkImage(user.avatarUrl!) : null,
                        child: user.avatarUrl == null ? Text(user.name?.substring(0, 1) ?? '?', style: const TextStyle(color: Color(0xFF7C3AED), fontWeight: FontWeight.bold)) : null,
                      ),
                      if (user.isOnline == true) Positioned(bottom: 2, right: 2, child: Container(width: 12, height: 12, decoration: BoxDecoration(color: const Color(0xFF10B981), shape: BoxShape.circle, border: Border.all(color: const Color(0xFF151122), width: 2)))),
                    ],
                  ),
                  title: Row(
                    children: [
                      Text(user.name ?? 'User', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                      const SizedBox(width: 8),
                      Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(8)), child: Text(distance, style: const TextStyle(color: Colors.white38, fontSize: 10))),
                    ],
                  ),
                  subtitle: Text(user.bio ?? 'Exploring Echat', style: const TextStyle(color: Colors.white24, fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis),
                  trailing: GestureDetector(
                    onTap: isSent ? null : () => _handleSayHi(user),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(color: isSent ? const Color(0xFF10B981).withOpacity(0.1) : const Color(0xFF7C3AED).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                      child: Text(isSent ? 'Sent' : 'Say Hi', style: TextStyle(color: isSent ? const Color(0xFF10B981) : const Color(0xFF7C3AED), fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}
