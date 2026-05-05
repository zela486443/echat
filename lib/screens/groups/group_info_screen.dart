import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';
import '../../widgets/groups/group_boost_panel.dart';
import '../../widgets/glassmorphic_container.dart';

class GroupInfoScreen extends StatefulWidget {
  final String groupId;
  final String groupName;
  final String groupDescription;
  final List<dynamic> members;
  final bool isAdmin;

  const GroupInfoScreen({
    super.key,
    required this.groupId,
    required this.groupName,
    required this.groupDescription,
    required this.members,
    required this.isAdmin,
  });

  @override
  State<GroupInfoScreen> createState() => _GroupInfoScreenState();
}

class _GroupInfoScreenState extends State<GroupInfoScreen> {
  String _memberSearch = '';

  Color _colorFor(String uid) {
    const senderColors = [
      Color(0xFFe91e63), Color(0xFF9c27b0), Color(0xFF673ab7), Color(0xFF3f51b5),
      Color(0xFF2196f3), Color(0xFF00bcd4), Color(0xFF009688), Color(0xFF4caf50),
      Color(0xFFff9800), Color(0xFFff5722),
    ];
    int h = 0;
    for (final c in uid.runes) h = (c + ((h << 5) - h)) & 0xFFFFFFFF;
    return senderColors[h.abs() % senderColors.length];
  }

  @override
  Widget build(BuildContext context) {
    final filteredMembers = widget.members.where((m) {
      if (_memberSearch.isEmpty) return true;
      final name = m.name as String;
      return name.toLowerCase().contains(_memberSearch.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF0D0A1A),
      body: CustomScrollView(
        slivers: [
          // Premium Header
          SliverAppBar(
            expandedHeight: 240,
            pinned: true,
            backgroundColor: AppTheme.card,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(widget.groupName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [_colorFor(widget.groupName), const Color(0xFF0D0A1A)],
                      ),
                    ),
                  ),
                  Center(
                    child: Hero(
                      tag: 'group_avatar_${widget.groupId}',
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.white.withOpacity(0.1),
                        child: Text(
                          widget.groupName.isEmpty ? 'G' : widget.groupName[0].toUpperCase(),
                          style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.w900),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              if (widget.isAdmin)
                IconButton(
                  icon: const Icon(LucideIcons.edit3),
                  onPressed: () {
                    // Edit group logic
                  },
                ),
            ],
          ),

          // Group Info Sections
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Description
                  if (widget.groupDescription.isNotEmpty) ...[
                    const Text('ABOUT', style: TextStyle(color: Colors.white24, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                    const SizedBox(height: 12),
                    Text(
                      widget.groupDescription,
                      style: const TextStyle(color: Colors.white70, fontSize: 15, height: 1.6),
                    ),
                    const SizedBox(height: 32),
                  ],

                  // Boost Status Card
                  _buildBoostCard(context),
                  const SizedBox(height: 32),

                  // Members Section Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'MEMBERS (${widget.members.length})',
                        style: const TextStyle(color: Colors.white24, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                      ),
                      if (widget.isAdmin)
                        TextButton.icon(
                          onPressed: () => context.push('/group/${widget.groupId}/add-members'),
                          icon: const Icon(Icons.add, size: 16),
                          label: const Text('Add', style: TextStyle(fontSize: 13)),
                          style: TextButton.styleFrom(foregroundColor: AppTheme.primary),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  // Search Members
                  GlassmorphicContainer(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: TextField(
                      onChanged: (v) => setState(() => _memberSearch = v),
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      decoration: const InputDecoration(
                        hintText: 'Search members...',
                        hintStyle: TextStyle(color: Colors.white24),
                        prefixIcon: Icon(Icons.search, color: Colors.white24, size: 20),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Members List
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final m = filteredMembers[index];
                return _buildMemberTile(m);
              },
              childCount: filteredMembers.length,
            ),
          ),

          // Footer Actions
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  _buildActionTile(LucideIcons.bell, 'Notifications', 'On', () {}),
                  _buildActionTile(LucideIcons.image, 'Shared Media', '245 items', () {}),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // Leave group confirmed logic
                      },
                      icon: const Icon(LucideIcons.logOut, size: 18),
                      label: const Text('Leave Group'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.redAccent,
                        side: const BorderSide(color: Colors.redAccent),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBoostCard(BuildContext context) {
    return GlassmorphicContainer(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(LucideIcons.zap, color: Colors.pinkAccent, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Group Boost Status',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const Spacer(),
              Text('Level 1', style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: const LinearProgressIndicator(
              value: 0.4,
              backgroundColor: Colors.white12,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.pinkAccent),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            '4 of 10 boosts to reach Level 2',
            style: TextStyle(color: Colors.white38, fontSize: 12),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => GroupBoostPanel(groupName: widget.groupName),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.05),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), border: const BorderSide(color: Colors.white12)),
              ),
              child: const Text('⚡ Boost This Group'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMemberTile(dynamic m) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: _colorFor(m.userId),
        child: Text(m.name[0].toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      title: Text(m.name, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500)),
      subtitle: Text(m.role, style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12)),
      trailing: widget.isAdmin && m.role != 'admin' 
        ? const Icon(LucideIcons.moreHorizontal, color: Colors.white24)
        : null,
      onTap: () {
        // Member options logic
      },
    );
  }

  Widget _buildActionTile(IconData icon, String title, String value, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassmorphicContainer(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: InkWell(
          onTap: onTap,
          child: Row(
            children: [
              Icon(icon, color: Colors.white60, size: 20),
              const SizedBox(width: 16),
              Expanded(child: Text(title, style: const TextStyle(color: Colors.white, fontSize: 15))),
              Text(value, style: TextStyle(color: AppTheme.primary, fontSize: 14, fontWeight: FontWeight.bold)),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right, color: Colors.white24, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}
