import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/aurora_gradient_bg.dart';

class SharedMediaScreen extends StatelessWidget {
  final String title;
  const SharedMediaScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text('Media: $title', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          bottom: TabBar(
            isScrollable: true,
            indicatorColor: AppTheme.primary,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white38,
            tabs: const [
              Tab(text: 'Media'),
              Tab(text: 'Files'),
              Tab(text: 'Voice'),
              Tab(text: 'Links'),
            ],
          ),
        ),
        body: AuroraGradientBg(
          child: TabBarView(
            children: [
              _buildMediaGrid(),
              _buildFileList(),
              _buildVoiceList(),
              _buildLinkList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMediaGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(2),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 2, mainAxisSpacing: 2),
      itemCount: 24,
      itemBuilder: (context, index) => Container(
        decoration: BoxDecoration(
          color: Colors.white10,
          image: DecorationImage(image: NetworkImage('https://picsum.photos/300?random=$index'), fit: BoxFit.cover),
        ),
      ),
    );
  }

  Widget _buildFileList() {
     return ListView.builder(
       padding: const EdgeInsets.all(16),
       itemCount: 10,
       itemBuilder: (context, index) => ListTile(
         leading: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.description, color: Colors.blue)),
         title: Text('Document_$index.pdf', style: const TextStyle(color: Colors.white, fontSize: 14)),
         subtitle: const Text('2.4 MB • Oct 24', style: TextStyle(color: Colors.white38, fontSize: 12)),
         trailing: const Icon(Icons.download, color: Colors.white24),
       ),
     );
  }

  Widget _buildVoiceList() {
     return ListView.builder(
       padding: const EdgeInsets.all(16),
       itemCount: 8,
       itemBuilder: (context, index) => ListTile(
         leading: const Icon(Icons.mic, color: Colors.purpleAccent),
         title: Text('Voice Message 0:42', style: const TextStyle(color: Colors.white, fontSize: 14)),
         subtitle: const Text('Oct 22, 10:45 AM', style: TextStyle(color: Colors.white38, fontSize: 12)),
         trailing: const Icon(Icons.play_arrow, color: Colors.white),
       ),
     );
  }

  Widget _buildLinkList() {
     return ListView.builder(
       padding: const EdgeInsets.all(16),
       itemCount: 12,
       itemBuilder: (context, index) => ListTile(
         leading: const Icon(Icons.link, color: Colors.greenAccent),
         title: const Text('https://github.com/echats/project', style: TextStyle(color: Colors.blue, fontSize: 14)),
         subtitle: const Text('GitHub: Where the world builds software', style: TextStyle(color: Colors.white38, fontSize: 12)),
       ),
     );
  }
}
