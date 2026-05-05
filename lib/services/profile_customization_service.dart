import 'package:flutter/material.dart';

class ProfileCustomization {
  final String userId;
  final Color? customAccent;
  final String? customWallpaper;

  ProfileCustomization({required this.userId, this.customAccent, this.customWallpaper});
}

class ProfileCustomizationService {
  final Map<String, ProfileCustomization> _overrides = {};

  void setOverride(String userId, {Color? accent, String? wallpaper}) {
    _overrides[userId] = ProfileCustomization(
      userId: userId,
      customAccent: accent,
      customWallpaper: wallpaper,
    );
  }

  ProfileCustomization? getOverride(String userId) => _overrides[userId];
}
