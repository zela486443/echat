import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'dart:ui';
import '../../theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/channel_provider.dart';
import '../../models/channel.dart';

class ChannelsScreen extends ConsumerStatefulWidget {
  const ChannelsScreen({super.key});

  @override
  ConsumerState<ChannelsScreen> createState() => _ChannelsScreenState();
}

class _ChannelsScreenState extends ConsumerState<ChannelsScreen> {
  String _searchQuery = "";

  @override
  Widget build(BuildContext context) {
    final myChannelsAsync = ref.watch(myChannelsProvider);
    final subChannelsAsync = ref.watch(subscribedChannelsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF03001C),
      body: Stack(
        children: [
          // Aurora Background
          Positioned(top: -100, right: -50, child: ImageFiltered(imageFilter: ImageFilter.blur(sigmaX: 80, sigmaY: 80), child: Container(width: 300, height: 300, decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFF7C3AED).withOpacity(0.12))))),
          Positioned(bottom: 100, left: -50, child: ImageFiltered(imageFilter: ImageFilter.blur(sigmaX: 60, sigmaY: 60), child: Container(width: 250, height: 250, decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFFFF0050).withOpacity(0.06))))),
          
          CustomScrollView(
            slivers: [
              _buildHeader(),
              _buildSearchBarSliver(),
              
              // My Channels
              myChannelsAsync.when(
                data: (channels) => channels.isEmpty 
                  ? const SliverToBoxAdapter(child: SizedBox()) 
                  : SliverMainAxisGroup(slivers: [
                      _buildSectionHeaderSliver('MY CHANNELS'),
                      _buildChannelListSliver(channels),
                    ]),
                loading: () => const SliverToBoxAdapter(child: Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator(color: Color(0xFF7C3AED), strokeWidth: 2)))),
                error: (err, _) => SliverToBoxAdapter(child: Center(child: Text('Error: $err', style: const TextStyle(color: Colors.white24)))),
              ),

              // Subscribed Channels
              subChannelsAsync.when(
                data: (channels) => channels.isEmpty 
                  ? _buildEmptyStateSliver() 
                  : SliverMainAxisGroup(slivers: [
                      _buildSectionHeaderSliver('SUBSCRIBED'),
                      _buildChannelListSliver(channels),
                    ]),
                loading: () => const SliverToBoxAdapter(child: SizedBox()),
                error: (err, _) => const SliverToBoxAdapter(child: SizedBox()),
              ),
              
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
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
      title: const Text('Channels', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
      actions: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          child: GestureDetector(
            onTap: () {},
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF6D28D9), Color(0xFF9333EA)]), borderRadius: BorderRadius.circular(16)),
              child: const Row(
                children: [
                  Icon(LucideIcons.plus, color: Colors.white, size: 14),
                  SizedBox(width: 8),
                  Text('Create', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBarSliver() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.06), borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.white.withOpacity(0.05))),
          child: Row(
            children: [
              const Icon(LucideIcons.search, color: Colors.white38, size: 18),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  onChanged: (val) => setState(() => _searchQuery = val),
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: const InputDecoration(hintText: 'Search channels...', hintStyle: TextStyle(color: Colors.white24, fontSize: 13), border: InputBorder.none),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyStateSliver() {
    return SliverFillRemaining(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(width: 90, height: 90, padding: const EdgeInsets.all(24), decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(24)), child: const Icon(LucideIcons.megaphone, color: Colors.white24, size: 40)),
          const SizedBox(height: 24),
          const Text('No channels yet', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Create a channel to broadcast messages', style: TextStyle(color: Colors.white24, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildSectionHeaderSliver(String label) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
        child: Text(label, style: const TextStyle(color: Colors.white24, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
      ),
    );
  }

  Widget _buildChannelListSliver(List<Channel> channels) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final c = channels[index];
            final avatarColor = c.avatarColor != null ? Color(int.parse(c.avatarColor!.replaceFirst('#', '0xFF'))) : const Color(0xFF7C3AED);
            
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.04),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                  child: ListTile(
                    onTap: () => context.push('/channel/${c.id}'),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: Container(
                      width: 48, height: 48, 
                      decoration: BoxDecoration(color: avatarColor.withOpacity(0.2), borderRadius: BorderRadius.circular(16)), 
                      child: Center(child: Text(c.name[0].toUpperCase(), style: TextStyle(color: avatarColor, fontWeight: FontWeight.bold, fontSize: 18))),
                    ),
                    title: Text(c.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(c.description ?? 'No description', style: const TextStyle(color: Colors.white38, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                    ),
                    trailing: const Icon(LucideIcons.chevronRight, color: Colors.white12, size: 18),
                  ),
                ),
              ),
            );
          },
          childCount: channels.length,
        ),
      ),
    );
  }
}
