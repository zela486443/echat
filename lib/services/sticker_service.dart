import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class Sticker {
  final String id;
  final String emoji;
  final String label;
  final String pack;

  Sticker({required this.id, required this.emoji, required this.label, required this.pack});

  Map<String, dynamic> toJson() => {'id': id, 'emoji': emoji, 'label': label, 'pack': pack};
  factory Sticker.fromJson(Map<String, dynamic> json) => Sticker(
    id: json['id'],
    emoji: json['emoji'],
    label: json['label'],
    pack: json['pack'],
  );
}

class StickerPack {
  final String id;
  final String name;
  final String icon;
  final List<Sticker> stickers;

  StickerPack({required this.id, required this.name, required this.icon, required this.stickers});
}

class StickerService {
  static const String _recentKey = 'echat_recent_stickers';
  static const String _favoritesKey = 'echat_favorite_stickers';

  static final List<StickerPack> stickerPacks = [
    StickerPack(
      id: "smileys",
      name: "Smileys",
      icon: "☺",
      stickers: [
        Sticker(id: "s1", emoji: "☺", label: "Smile", pack: "smileys"),
        Sticker(id: "s2", emoji: "☻", label: "Happy", pack: "smileys"),
        Sticker(id: "s3", emoji: "♡", label: "Love", pack: "smileys"),
        Sticker(id: "s4", emoji: "☼", label: "Sunny Face", pack: "smileys"),
        Sticker(id: "s5", emoji: "✿", label: "Flower Face", pack: "smileys"),
        Sticker(id: "s6", emoji: "◕‿◕", label: "Cute Face", pack: "smileys"),
        Sticker(id: "s7", emoji: "╰(*°▽°*)╯", label: "Excited", pack: "smileys"),
        Sticker(id: "s8", emoji: "(◠‿◠)", label: "Cheerful", pack: "smileys"),
        Sticker(id: "s9", emoji: "ᕙ(⇀‸↼)ᕗ", label: "Strong", pack: "smileys"),
        Sticker(id: "s10", emoji: "♥‿♥", label: "Heart Eyes", pack: "smileys"),
        Sticker(id: "s11", emoji: "(╥﹏╥)", label: "Crying", pack: "smileys"),
        Sticker(id: "s12", emoji: "¯\\_(ツ)_/¯", label: "Shrug", pack: "smileys"),
        Sticker(id: "s13", emoji: "(ᵔᴥᵔ)", label: "Bear Face", pack: "smileys"),
        Sticker(id: "s14", emoji: "(*^▽^*)", label: "Joy", pack: "smileys"),
      ],
    ),
    StickerPack(
      id: "animals",
      name: "Animals",
      icon: "♞",
      stickers: [
        Sticker(id: "a1", emoji: "♞", label: "Horse", pack: "animals"),
        Sticker(id: "a2", emoji: "☙", label: "Bird", pack: "animals"),
        Sticker(id: "a3", emoji: "⚘", label: "Butterfly", pack: "animals"),
        Sticker(id: "a4", emoji: "◈", label: "Fish", pack: "animals"),
        Sticker(id: "a5", emoji: "❀", label: "Bee", pack: "animals"),
        Sticker(id: "a6", emoji: "⊛", label: "Spider", pack: "animals"),
        Sticker(id: "a7", emoji: "ʕ•ᴥ•ʔ", label: "Bear", pack: "animals"),
        Sticker(id: "a8", emoji: "▼・ᴥ・▼", label: "Dog", pack: "animals"),
        Sticker(id: "a9", emoji: "(=^・ω・^=)", label: "Cat", pack: "animals"),
        Sticker(id: "a10", emoji: "◎⃝", label: "Owl", pack: "animals"),
        Sticker(id: "a11", emoji: "⋆⁺₊⋆", label: "Firefly", pack: "animals"),
        Sticker(id: "a12", emoji: "≋≋≋", label: "Snake", pack: "animals"),
        Sticker(id: "a13", emoji: "◉‿◉", label: "Frog", pack: "animals"),
        Sticker(id: "a14", emoji: "⊹⊹⊹", label: "Ladybug", pack: "animals"),
      ],
    ),
    StickerPack(
      id: "food",
      name: "Food",
      icon: "♨",
      stickers: [
        Sticker(id: "f1", emoji: "♨", label: "Hot Food", pack: "food"),
        Sticker(id: "f2", emoji: "◉", label: "Donut", pack: "food"),
        Sticker(id: "f3", emoji: "▽", label: "Ice Cream", pack: "food"),
        Sticker(id: "f4", emoji: "◐", label: "Cookie", pack: "food"),
        Sticker(id: "f5", emoji: "☕", label: "Coffee", pack: "food"),
        Sticker(id: "f6", emoji: "✦", label: "Star Fruit", pack: "food"),
        Sticker(id: "f7", emoji: "◆", label: "Chocolate", pack: "food"),
        Sticker(id: "f8", emoji: "◇", label: "Rice Ball", pack: "food"),
        Sticker(id: "f9", emoji: "▣", label: "Waffle", pack: "food"),
        Sticker(id: "f10", emoji: "⊕", label: "Pizza", pack: "food"),
        Sticker(id: "f11", emoji: "◎", label: "Sushi", pack: "food"),
        Sticker(id: "f12", emoji: "❁", label: "Cake", pack: "food"),
        Sticker(id: "f13", emoji: "⊗", label: "Pie", pack: "food"),
        Sticker(id: "f14", emoji: "◯", label: "Egg", pack: "food"),
        Sticker(id: "f15", emoji: "☘", label: "Salad", pack: "food"),
        Sticker(id: "f16", emoji: "◬", label: "Sandwich", pack: "food"),
      ],
    ),
    StickerPack(
      id: "symbols",
      name: "Symbols",
      icon: "♪",
      stickers: [
        Sticker(id: "sy1", emoji: "♥", label: "Heart", pack: "symbols"),
        Sticker(id: "sy2", emoji: "★", label: "Star", pack: "symbols"),
        Sticker(id: "sy3", emoji: "♪", label: "Music", pack: "symbols"),
        Sticker(id: "sy4", emoji: "♦", label: "Diamond", pack: "symbols"),
        Sticker(id: "sy5", emoji: "▲", label: "Triangle", pack: "symbols"),
        Sticker(id: "sy6", emoji: "●", label: "Circle", pack: "symbols"),
        Sticker(id: "sy7", emoji: "✦", label: "Sparkle", pack: "symbols"),
        Sticker(id: "sy8", emoji: "⚡", label: "Lightning", pack: "symbols"),
        Sticker(id: "sy9", emoji: "✧", label: "Twinkle", pack: "symbols"),
        Sticker(id: "sy10", emoji: "♣", label: "Club", pack: "symbols"),
        Sticker(id: "sy11", emoji: "♠", label: "Spade", pack: "symbols"),
        Sticker(id: "sy12", emoji: "⊛", label: "Asterisk", pack: "symbols"),
        Sticker(id: "sy13", emoji: "◆", label: "Filled Diamond", pack: "symbols"),
        Sticker(id: "sy14", emoji: "✶", label: "Six Star", pack: "symbols"),
        Sticker(id: "sy15", emoji: "❖", label: "Four Diamond", pack: "symbols"),
        Sticker(id: "sy16", emoji: "✿", label: "Flower", pack: "symbols"),
      ],
    ),
  ];

  static Future<List<Sticker>> getRecent() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_recentKey);
    if (data == null) return [];
    final List<dynamic> list = jsonDecode(data);
    return list.map((e) => Sticker.fromJson(e)).toList();
  }

  static Future<void> addRecent(Sticker sticker) async {
    final recent = await getRecent();
    recent.removeWhere((s) => s.id == sticker.id);
    recent.insert(0, sticker);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_recentKey, jsonEncode(recent.take(20).toList()));
  }

  static Future<List<Sticker>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_favoritesKey);
    if (data == null) return [];
    final List<dynamic> list = jsonDecode(data);
    return list.map((e) => Sticker.fromJson(e)).toList();
  }

  static Future<bool> toggleFavorite(Sticker sticker) async {
    final favorites = await getFavorites();
    final index = favorites.indexWhere((s) => s.id == sticker.id);
    final isFav = index >= 0;
    if (isFav) {
      favorites.removeAt(index);
    } else {
      favorites.add(sticker);
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_favoritesKey, jsonEncode(favorites));
    return !isFav;
  }

  static List<Sticker> search(String query) {
    final q = query.toLowerCase().trim();
    if (q.isEmpty) return [];
    return stickerPacks
        .expand((p) => p.stickers)
        .where((s) => s.label.toLowerCase().contains(q) || s.pack.toLowerCase().contains(q))
        .toList();
  }
}
