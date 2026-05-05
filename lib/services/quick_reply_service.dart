class QuickReply {
  final String id;
  final String shortcut;
  final String text;

  QuickReply({required this.id, required this.shortcut, required this.text});
}

class QuickReplyService {
  static final List<QuickReply> _replies = [
    QuickReply(id: '1', shortcut: '/hi', text: 'ሰላም! እንዴት ነህ?'),
    QuickReply(id: '2', shortcut: '/ok', text: 'እሺ፣ ገብቶኛል።'),
    QuickReply(id: '3', shortcut: '/thanks', text: 'በጣም አመሰግናለሁ!'),
    QuickReply(id: '4', shortcut: '/bye', text: 'ደህና ሁን፣ ቆይ እንገናኛለን።'),
    QuickReply(id: '5', shortcut: '/otw', text: 'በመንገድ ላይ ነኝ 🏃‍♂️'),
    QuickReply(id: '6', shortcut: '/busy', text: 'አሁን ማውራት አልችልም፣ በኋላ እደውላለሁ።'),
    QuickReply(id: '7', shortcut: '/loc', text: 'ያለሁበትን ቦታ እልክልሃለሁ...'),
  ];

  static List<QuickReply> search(String query) {
    final q = query.toLowerCase().trim();
    if (q.isEmpty) return [];
    return _replies.where((r) => r.shortcut.contains(q) || r.text.toLowerCase().contains(q)).toList();
  }
}
