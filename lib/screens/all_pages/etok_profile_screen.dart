import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'dart:ui';
import '../../theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/etok_provider.dart';
import '../../models/etok_video.dart';
import '../../services/etok_service.dart';
import '../../models/profile.dart';
import '../../services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EtokProfileScreen extends ConsumerStatefulWidget {
  final String? userId;
  const EtokProfileScreen({super.key, this.userId});

  @override
  ConsumerState<EtokProfileScreen> createState() => _EtokProfileScreenState();
}

class _EtokProfileScreenState extends ConsumerState<EtokProfileScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _loading = true;
  bool _isFollowing = false;
  Map<String, dynamic> _stats = {'likes': 0, 'followers': 0, 'following': 0};
  List<EtokVideo> _videos = [];
  Profile? _viewedProfile;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final service = ref.read(etokServiceProvider);
    final currentUserId = ref.read(authProvider).value?.id;
    final targetUserId = widget.userId ?? currentUserId;

    if (targetUserId == null) return;

    final results = await Future.wait([
      service.fetchProfileStats(targetUserId),
      service.fetchUserVideos(targetUserId),
      if (currentUserId != null && targetUserId != currentUserId) 
        service.isFollowing(currentUserId, targetUserId)
      else 
        Future.value(false),
      // Also fetch profile info if not own
      if (targetUserId != currentUserId)
        _fetchTargetProfile(targetUserId)
      else
        Future.value(null),
    ]);

    if (mounted) {
      setState(() {
        _stats = results[0] as Map<String, dynamic>;
        _videos = results[1] as List<EtokVideo>;
        _isFollowing = results[2] as bool;
        _loading = false;
      });
    }
  }

  Future<void> _fetchTargetProfile(String userId) async {
    final res = await Supabase.instance.client.from('profiles').select().eq('id', userId).maybeSingle();
    if (res != null) {
      _viewedProfile = Profile.fromJson(res);
    }
  }

  void _handleFollow() async {
    final currentUserId = ref.read(authProvider).value?.id;
    final targetUserId = widget.userId;
    if (currentUserId == null || targetUserId == null) return;

    final service = ref.read(etokServiceProvider);
    if (_isFollowing) {
      await service.unfollowUser(currentUserId, targetUserId);
    } else {
      await service.followUser(currentUserId, targetUserId);
    }
    setState(() => _isFollowing = !_isFollowing);
    // Refresh stats
    final newStats = await service.fetchProfileStats(targetUserId);
    setState(() => _stats = newStats);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(backgroundColor: Colors.black, body: Center(child: CircularProgressIndicator(color: Colors.white)));
    }

    final currentUser = ref.watch(authProvider).value;
    final isOwn = widget.userId == null || widget.userId == currentUser?.id;
    final profile = isOwn ? currentUser : _viewedProfile;
    final username = profile?.username ?? (isOwn ? currentUser?.email?.split('@')[0] : 'user') ?? 'user';

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: _buildAppBar(username, isOwn),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildProfileHeader(profile, isOwn),
                  _buildTabSection(),
                  _buildVideoGrid(),
                ],
              ),
            ),
          ),
          _buildEtokBottomNav(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(String username, bool isOwn) {
    return AppBar(
      backgroundColor: Colors.black,
      elevation: 0,
      leading: IconButton(icon: const Icon(LucideIcons.arrowLeft, color: Colors.white), onPressed: () => context.pop()),
      centerTitle: true,
      title: Text('@$username', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
      actions: [
        if (isOwn) IconButton(icon: const Icon(LucideIcons.barChart2, color: Colors.white70, size: 20), onPressed: () {}),
        IconButton(icon: const Icon(LucideIcons.moreHorizontal, color: Colors.white), onPressed: () => _showMoreOptions(isOwn)),
      ],
    );
  }

  Widget _buildProfileHeader(dynamic user, bool isOwn) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          if (user?.avatarUrl != null)
            CircleAvatar(radius: 48, backgroundImage: NetworkImage(user!.avatarUrl!))
          else
            Container(
              width: 96, height: 96,
              decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white24, width: 2), color: Colors.white10),
              child: const Center(child: Text('👤', style: TextStyle(fontSize: 40))),
            ),
          const SizedBox(height: 12),
          Text(user?.name ?? 'Display Name', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text('@${user?.username ?? 'username'}', style: const TextStyle(color: Colors.white60, fontSize: 13)),
          const SizedBox(height: 20),
          _buildStatsRow(),
          const SizedBox(height: 20),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text('Digital Creator | Tech Enthusiast | Addis Ababa 🇪🇹', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 13)),
          ),
          const SizedBox(height: 20),
          _buildActionButtons(isOwn),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildStatItem(_formatStat(_stats['following']), 'Following'),
        _buildStatDivider(),
        _buildStatItem(_formatStat(_stats['followers']), 'Followers'),
        _buildStatDivider(),
        _buildStatItem(_formatStat(_stats['likes']), 'Likes'),
      ],
    );
  }

  String _formatStat(int count) {
    if (count >= 1000000) return '${(count / 1000000).toStringAsFixed(1)}M';
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}K';
    return count.toString();
  }

  Widget _buildStatItem(String value, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildStatDivider() {
    return Container(width: 1, height: 12, color: Colors.white12);
  }

  Widget _buildActionButtons(bool isOwn) {
    if (isOwn) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () => _showEditProfile(),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, side: const BorderSide(color: Colors.white24), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                child: const Text('Edit profile', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(border: Border.all(color: Colors.white24), borderRadius: BorderRadius.circular(8)),
              child: const Icon(LucideIcons.settings, color: Colors.white, size: 18),
            ),
          ],
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: _handleFollow,
              style: ElevatedButton.styleFrom(backgroundColor: _isFollowing ? Colors.transparent : const Color(0xFFFF0050), side: _isFollowing ? const BorderSide(color: Colors.white24) : null, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
              child: Text(_isFollowing ? 'Following' : 'Follow', style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, side: const BorderSide(color: Colors.white24), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
              child: const Text('Message', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(border: Border.all(color: Colors.white24), borderRadius: BorderRadius.circular(8)),
            child: const Icon(LucideIcons.share2, color: Colors.white, size: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildTabSection() {
    return Container(
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.white10))),
      child: TabBar(
        controller: _tabController,
        indicatorColor: Colors.white,
        indicatorWeight: 2,
        tabs: const [
          Tab(icon: Icon(Icons.grid_view, size: 20)),
          Tab(icon: Icon(LucideIcons.heart, size: 20)),
        ],
      ),
    );
  }

  Widget _buildVideoGrid() {
    if (_videos.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(top: 60),
        child: Column(
          children: [
            Icon(Icons.movie_creation_outlined, color: Colors.white10, size: 48),
            SizedBox(height: 12),
            Text('No videos posted yet', style: TextStyle(color: Colors.white38, fontSize: 13)),
          ],
        ),
      );
    }
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _videos.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 1.5, mainAxisSpacing: 1.5, childAspectRatio: 9/16),
      itemBuilder: (context, index) {
        final v = _videos[index];
        return Container(
          decoration: BoxDecoration(
            color: Colors.grey[900],
            image: v.thumbnailUrl != null ? DecorationImage(image: NetworkImage(v.thumbnailUrl!), fit: BoxFit.cover) : null,
          ),
          child: Stack(
            children: [
              Positioned(
                bottom: 4, left: 4,
                child: Row(
                  children: [
                    const Icon(Icons.play_arrow_outlined, color: Colors.white, size: 14),
                    Text(_formatStat(v.views), style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEtokBottomNav() {
    return Container(
      height: 60,
      padding: const EdgeInsets.only(bottom: 5),
      decoration: BoxDecoration(color: Colors.black, border: Border(top: BorderSide(color: Colors.white10))),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Icon(LucideIcons.home, color: Colors.white54, size: 24),
          Icon(LucideIcons.users, color: Colors.white54, size: 24),
          CircleAvatar(backgroundColor: Colors.white, radius: 14, child: Icon(Icons.add, color: Colors.black, size: 20)),
          Icon(LucideIcons.messageSquare, color: Colors.white54, size: 24),
          Icon(LucideIcons.user, color: Colors.white, size: 24),
        ],
      ),
    );
  }

  void _showMoreOptions(bool isOwn) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isOwn) ...[
              _buildMoreItem(LucideIcons.edit3, 'Edit profile', () { context.pop(); _showEditProfile(); }),
              _buildMoreItem(LucideIcons.settings, 'Privacy settings', () {}),
            ] else ...[
              _buildMoreItem(LucideIcons.ban, 'Block user', () {}, color: Colors.redAccent),
              _buildMoreItem(LucideIcons.flag, 'Report', () {}, color: Colors.redAccent),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMoreItem(IconData icon, String label, VoidCallback onTap, {Color color = Colors.white}) {
    return ListTile(
      leading: Icon(icon, color: color.withOpacity(0.7), size: 20),
      title: Text(label, style: TextStyle(color: color, fontSize: 15)),
      onTap: onTap,
    );
  }

  void _showEditProfile() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF111111),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(onPressed: () => context.pop(), child: const Text('Cancel', style: TextStyle(color: Colors.white60))),
                  const Text('Edit profile', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  TextButton(onPressed: () => context.pop(), child: const Text('Save', style: TextStyle(color: Color(0xFFFF0050), fontWeight: FontWeight.bold))),
                ],
              ),
            ),
            const Divider(color: Colors.white10, height: 1),
            Expanded(
              child: ListView(
                controller: scrollController,
                children: [
                  const SizedBox(height: 32),
                  Center(
                    child: Stack(
                      children: [
                        Container(
                          width: 80, height: 80,
                          decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white10),
                          child: const Center(child: Text('👤', style: TextStyle(fontSize: 32))),
                        ),
                        Positioned(
                          bottom: 0, left: 10, right: 10,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            decoration: BoxDecoration(color: const Color(0xFFFF0050), borderRadius: BorderRadius.circular(10)),
                            child: const Text('Change', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  _buildEditField('Name', 'Add name'),
                  _buildEditField('Username', 'Add username'),
                  _buildEditField('Bio', 'Add bio'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditField(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.white10))),
      child: Row(
        children: [
          SizedBox(width: 100, child: Text(label, style: const TextStyle(color: Colors.white54, fontSize: 14))),
          Expanded(child: Text(value, style: const TextStyle(color: Colors.white, fontSize: 14))),
        ],
      ),
    );
  }
}
