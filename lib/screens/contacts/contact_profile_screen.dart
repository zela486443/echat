import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/profile.dart';
import '../../providers/call_provider.dart';
import '../../services/contact_notes_service.dart';
import '../../theme/app_theme.dart';
import 'package:timeago/timeago.dart' as timeago;

final contactProfileProvider = FutureProvider.family.autoDispose<PublicProfile?, String>((ref, userId) async {
  final client = Supabase.instance.client;
  final res = await client.from('profiles').select().eq('id', userId).single();
  return PublicProfile.fromJson(res);
});

final contactNotesServiceProvider = Provider((ref) => ContactNotesService());

class ContactProfileScreen extends ConsumerStatefulWidget {
  final String userId;
  const ContactProfileScreen({super.key, required this.userId});

  @override
  ConsumerState<ContactProfileScreen> createState() => _ContactProfileScreenState();
}

class _ContactProfileScreenState extends ConsumerState<ContactProfileScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _noteController = TextEditingController();
  bool _isMuted = false;
  bool _isBlocked = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadNote();
  }

  Future<void> _loadNote() async {
    final note = await ref.read(contactNotesServiceProvider).getNote(widget.userId);
    _noteController.text = note;
  }

  @override
  void dispose() {
    _tabController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final profileAsync = ref.watch(contactProfileProvider(widget.userId));

    return Scaffold(
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (profile) {
          if (profile == null) {
            return const Center(child: Text('User not found'));
          }

          return CustomScrollView(
            slivers: [
              // Cover & Avatar Header
              SliverAppBar(
                expandedHeight: 340,
                pinned: true,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                  onPressed: () => context.pop(),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(LucideIcons.moreVertical, color: Colors.white),
                    onPressed: () {},
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    children: [
                      // Gradient Cover
                      Container(
                        height: 200,
                        decoration: BoxDecoration(
                          gradient: AppTheme.gradientAurora,
                        ),
                      ),
                      // Profile Info Overlay
                      Positioned(
                        top: 140,
                        left: 0,
                        right: 0,
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 60,
                              backgroundColor: theme.scaffoldBackgroundColor,
                              child: CircleAvatar(
                                radius: 56,
                                backgroundImage: profile.avatarUrl != null ? NetworkImage(profile.avatarUrl!) : null,
                                child: profile.avatarUrl == null
                                    ? Text(
                                        (profile.name ?? profile.username).substring(0, 1).toUpperCase(),
                                        style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                                      )
                                    : null,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              profile.name ?? 'No Name',
                              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '@${profile.username}',
                              style: TextStyle(
                                fontSize: 16,
                                color: theme.primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              profile.isOnline ? 'Online' : 'Last seen ${timeago.format(profile.lastSeen)}',
                              style: const TextStyle(color: Colors.grey, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Action Buttons
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _ActionButton(
                        icon: LucideIcons.messageSquare,
                        label: 'Message',
                        onTap: () {},
                      ),
                      _ActionButton(
                        icon: _isMuted ? LucideIcons.bell : LucideIcons.bellOff,
                        label: _isMuted ? 'Unmute' : 'Mute',
                        onTap: () => setState(() => _isMuted = !_isMuted),
                      ),
                      _ActionButton(
                        icon: LucideIcons.phone,
                        label: 'Call',
                        onTap: () {
                          ref.read(activeCallProvider.notifier).startCall(
                            peerId: widget.userId,
                            name: profile.name ?? profile.username, 
                            avatar: profile.avatarUrl, 
                            type: CallType.voice
                          );
                        },
                      ),
                      _ActionButton(
                        icon: LucideIcons.video,
                        label: 'Video',
                        onTap: () {
                          ref.read(activeCallProvider.notifier).startCall(
                            peerId: widget.userId,
                            name: profile.name ?? profile.username, 
                            avatar: profile.avatarUrl, 
                            type: CallType.video
                          );
                        },
                      ),
                      _ActionButton(
                        icon: LucideIcons.userX,
                        label: _isBlocked ? 'Unblock' : 'Block',
                        color: Colors.redAccent,
                        onTap: () => setState(() => _isBlocked = !_isBlocked),
                      ),
                    ],
                  ),
                ),
              ),

              // Bio & Details
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (profile.bio != null) ...[
                        Text(profile.bio!, style: const TextStyle(fontSize: 15)),
                        const SizedBox(height: 4),
                        const Text('Bio', style: TextStyle(color: Colors.grey, fontSize: 12)),
                        const SizedBox(height: 20),
                      ],
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('@${profile.username}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                              const Text('Username', style: TextStyle(color: Colors.grey, fontSize: 12)),
                            ],
                          ),
                          const Icon(LucideIcons.qrCode, color: Colors.grey, size: 20),
                        ],
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),

              // Tabs (Media, Files, Notes)
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    TabBar(
                      controller: _tabController,
                      labelColor: theme.primaryColor,
                      unselectedLabelColor: Colors.grey,
                      indicatorColor: theme.primaryColor,
                      indicatorPadding: const EdgeInsets.symmetric(horizontal: 20),
                      tabs: const [
                        Tab(text: 'Media'),
                        Tab(text: 'Files'),
                        Tab(text: 'Notes'),
                      ],
                    ),
                    SizedBox(
                      height: 400,
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildMediaGrid(),
                          _buildFilesList(),
                          _buildNotesTab(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMediaGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(2),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
      ),
      itemCount: 0, // Placeholder
      itemBuilder: (context, index) => Container(color: Colors.grey.withOpacity(0.1)),
    );
  }

  Widget _buildFilesList() {
    return const Center(
      child: Text('No shared files yet', style: TextStyle(color: Colors.grey)),
    );
  }

  Widget _buildNotesTab() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(LucideIcons.stickyNote, color: Colors.amber, size: 16),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Private notes about this user. Only you can see these.',
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _noteController,
            maxLines: 5,
            decoration: InputDecoration(
              hintText: 'Add a private note...',
              filled: true,
              fillColor: Theme.of(context).cardColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.1)),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                await ref.read(contactNotesServiceProvider).saveNote(widget.userId, _noteController.text);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Note saved')));
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('Save Note'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Column(
          children: [
            Icon(icon, color: color ?? Colors.grey, size: 22),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: color ?? Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
