import 'package:flutter/material.dart';

class StarsPackage {
  final String id;
  final String name;
  final int stars;
  final int bonus;
  final double price;
  final bool popular;

  const StarsPackage({
    required this.id,
    required this.name,
    required this.stars,
    required this.bonus,
    required this.price,
    this.popular = false,
  });
}

class Gift {
  final String id;
  final String emoji;
  final String name;
  final int stars;
  final GiftRarity rarity;

  const Gift({
    required this.id,
    required this.emoji,
    required this.name,
    required this.stars,
    required this.rarity,
  });
}

enum GiftRarity { common, rare, epic, legendary }

const List<Gift> AVAILABLE_GIFTS = [
  Gift(id: "rose", emoji: "🌹", name: "Red Rose", stars: 10, rarity: GiftRarity.common),
  Gift(id: "butterfly", emoji: "🦋", name: "Butterfly", stars: 15, rarity: GiftRarity.common),
  Gift(id: "cherry", emoji: "🍒", name: "Lucky Cherries", stars: 5, rarity: GiftRarity.common),
  Gift(id: "fire", emoji: "🔥", name: "Fire Spirit", stars: 30, rarity: GiftRarity.common),
  Gift(id: "star", emoji: "⭐", name: "Shooting Star", stars: 25, rarity: GiftRarity.common),
  Gift(id: "cake", emoji: "🎂", name: "Birthday Cake", stars: 25, rarity: GiftRarity.common),
  Gift(id: "moon", emoji: "🌙", name: "Silver Moon", stars: 45, rarity: GiftRarity.rare),
  Gift(id: "heart", emoji: "💖", name: "Diamond Heart", stars: 50, rarity: GiftRarity.rare),
  Gift(id: "rocket", emoji: "🚀", name: "Space Rocket", stars: 75, rarity: GiftRarity.rare),
  Gift(id: "lightning", emoji: "⚡", name: "Thunder", stars: 80, rarity: GiftRarity.rare),
  Gift(id: "trophy", emoji: "🏆", name: "Golden Trophy", stars: 100, rarity: GiftRarity.rare),
  Gift(id: "rainbow", emoji: "🌈", name: "Rainbow", stars: 150, rarity: GiftRarity.epic),
  Gift(id: "gem", emoji: "💎", name: "Precious Gem", stars: 200, rarity: GiftRarity.epic),
  Gift(id: "unicorn", emoji: "🦄", name: "Magic Unicorn", stars: 250, rarity: GiftRarity.epic),
  Gift(id: "crystal", emoji: "🔮", name: "Crystal Ball", stars: 300, rarity: GiftRarity.legendary),
  Gift(id: "dragon", emoji: "🐉", name: "Lucky Dragon", stars: 500, rarity: GiftRarity.epic),
  Gift(id: "planet", emoji: "🪐", name: "Mystery Planet", stars: 750, rarity: GiftRarity.legendary),
  Gift(id: "crown", emoji: "👑", name: "Royal Crown", stars: 1000, rarity: GiftRarity.legendary),
];

Color getRarityColor(GiftRarity rarity) {
  switch (rarity) {
    case GiftRarity.common: return const Color(0xFF94A3B8); // slate-400
    case GiftRarity.rare: return const Color(0xFF60A5FA); // blue-400
    case GiftRarity.epic: return const Color(0xFFC084FC); // purple-400
    case GiftRarity.legendary: return const Color(0xFFFACC15); // yellow-400
  }
}

const List<StarsPackage> buyStarsPackages = [
  StarsPackage(id: 'pkg1', name: 'Lite Pack', stars: 100, bonus: 0, price: 50, popular: false),
  StarsPackage(id: 'pkg2', name: 'Starter Pack', stars: 500, bonus: 50, price: 200, popular: true),
  StarsPackage(id: 'pkg3', name: 'Pro Pack', stars: 2000, bonus: 300, price: 750, popular: false),
  StarsPackage(id: 'pkg4', name: 'Creator Pack', stars: 5000, bonus: 1000, price: 1500, popular: false),
];
