import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glassmorphic_container.dart';
import '../../widgets/aurora_gradient_bg.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios, color: Colors.white), onPressed: () => context.pop()),
        title: const Text('Profile', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: const Icon(LucideIcons.moreVertical, color: Colors.white), onPressed: () => context.push('/settings')),
        ],
      ),
      body: AuroraGradientBg(
        child: profileAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(child: Text('Error: $err')),
          data: (profile) => SingleChildScrollView(
            child: Column(
              children: [
                _buildHeroHeader(profile),
                _buildProfileInfo(profile),
                _buildActionButtons(profile),
                _buildHighlights(),
                _buildStats(),
                _buildProfileTabs(),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroHeader(dynamic profile) {
    return Stack(
      alignment: Alignment.bottomCenter,
      clipBehavior: Clip.none,
      children: [
        Container(
          height: 220,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: AppTheme.gradientAurora,
          ),
          child: Opacity(
            opacity: 0.1,
            child: Icon(Icons.auto_awesome, color: Colors.white, size: 200),
          ),
        ),
        Positioned(
          bottom: -50,
          child: Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.black, width: 4),
                  boxShadow: [BoxShadow(color: AppTheme.primary.withOpacity(0.3), blurRadius: 30, spreadRadius: 10)],
                ),
                child: CircleAvatar(
                  radius: 56,
                  backgroundColor: AppTheme.primary.withOpacity(0.1),
                  backgroundImage: profile?.avatarUrl != null ? NetworkImage(profile!.avatarUrl!) : null,
                  child: profile?.avatarUrl == null ? const Icon(Icons.person, size: 50, color: Colors.white24) : null,
                ),
              ),
              Positioned(
                right: 4,
                bottom: 4,
                child: GestureDetector(
                  onTap: () => context.push('/update-profile'),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: AppTheme.primary, shape: BoxShape.circle, border: Border.all(color: Colors.black, width: 2)),
                    child: const Icon(Icons.edit, color: Colors.white, size: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProfileInfo(dynamic profile) {
    return Padding(
      padding: const EdgeInsets.only(top: 60, left: 24, right: 24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(profile?.name ?? 'User', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)),
              const SizedBox(width: 6),
              const Icon(Icons.verified, color: Colors.blueAccent, size: 20),
            ],
          ),
          const SizedBox(height: 4),
          Text('@${profile?.username ?? 'username'}', style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          Text(
            profile?.bio ?? 'Welcome to Echat! 🚀',
            style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          _buildStatusTag(),
        ],
      ),
    );
  }

  Widget _buildStatusTag() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.green.withOpacity(0.2))),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(radius: 4, backgroundColor: Colors.green),
          SizedBox(width: 8),
          Text('Available', style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildActionButtons(dynamic profile) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        children: [
          Expanded(
            child: _buildActionButton(LucideIcons.messageSquare, 'Message', isPrimary: true, onTap: () {}),
          ),
          const SizedBox(width: 12),
          _buildActionButton(LucideIcons.phone, 'Call', onTap: () {}),
          const SizedBox(width: 12),
          _buildActionButton(LucideIcons.qrCode, 'QR', onTap: () => _showQRDialog(profile)),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, {bool isPrimary = false, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: GlassmorphicContainer(
        height: 50,
        borderRadius: 16,
        padding: EdgeInsets.zero,
        child: Container(
          decoration: isPrimary ? BoxDecoration(gradient: AppTheme.gradientPrimary(AppTheme.primary), borderRadius: BorderRadius.circular(16)) : null,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 18),
              if (isPrimary) ...[
                const SizedBox(width: 8),
                Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ]
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHighlights() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Text('HIGHLIGHTS', style: TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
        ),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: 5,
            itemBuilder: (context, index) {
              if (index == 0) return _buildAddHighlight();
              return _buildHighlightItem('Trip $index', Colors.primaries[index % Colors.primaries.length]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAddHighlight() {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white12, style: BorderStyle.solid), color: Colors.white.withOpacity(0.05)),
            child: const Icon(Icons.add, color: Colors.white38),
          ),
          const SizedBox(height: 6),
          const Text('New', style: TextStyle(color: Colors.white38, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildHighlightItem(String label, Color color) {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: color, width: 2)),
            child: CircleAvatar(radius: 28, backgroundColor: color.withOpacity(0.2), child: Text(label[0], style: const TextStyle(color: Colors.white))),
          ),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildStats() {
    return Container(
      margin: const EdgeInsets.all(24),
      child: GlassmorphicContainer(
        borderRadius: 20,
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem('1.2K', 'Followers'),
            _divider(),
            _buildStatItem('450', 'Following'),
            _divider(),
            _buildStatItem('12.5K', 'Likes'),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
        Text(label, style: const TextStyle(color: Colors.white38, fontSize: 12)),
      ],
    );
  }

  Widget _divider() => Container(height: 30, width: 1, color: Colors.white10);

  Widget _buildProfileTabs() {
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.primary,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white38,
          dividerColor: Colors.transparent,
          tabs: const [
            Tab(icon: Icon(LucideIcons.image)),
            Tab(icon: Icon(LucideIcons.play)),
            Tab(icon: Icon(LucideIcons.bookmark)),
          ],
        ),
        SizedBox(
          height: 400,
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildMediaGrid(),
              _buildMediaGrid(isVideos: true),
              _buildMediaGrid(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMediaGrid({bool isVideos = false}) {
    return GridView.builder(
      padding: const EdgeInsets.all(4),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 4, mainAxisSpacing: 4),
      itemCount: 12,
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(4)),
          child: isVideos ? const Center(child: Icon(Icons.play_circle_outline, color: Colors.white24)) : null,
        );
      },
    );
  }

  void _showQRDialog(dynamic profile) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: GlassmorphicContainer(
          borderRadius: 24,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('My QR Code', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                child: QrImageView(
                  data: 'https://echats.app/add/@${profile?.username}',
                  version: QrVersions.auto,
                  size: 200.0,
                ),
              ),
              const SizedBox(height: 24),
              Text('@${profile?.username}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('Scan this to add me on Echat', style: TextStyle(color: Colors.white54, fontSize: 12)),
              const SizedBox(height: 24),
              _buildActionButton(Icons.share, 'Share Profile Link', isPrimary: true, onTap: () => Navigator.pop(context)),
            ],
          ),
        ),
      ),
    );
  }
}
