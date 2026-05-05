import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class PrivacySettings {
  final String lastSeenVisibility;
  final bool readReceipts;
  final bool onlineStatus;
  final String profilePhotoVisibility;
  final bool forwardedMessages;
  final String phoneNumberVisibility;
  final String groupsAddPermission;
  final String callsPrivacy;

  PrivacySettings({
    this.lastSeenVisibility = 'everyone',
    this.readReceipts = true,
    this.onlineStatus = true,
    this.profilePhotoVisibility = 'everyone',
    this.forwardedMessages = true,
    this.phoneNumberVisibility = 'contacts',
    this.groupsAddPermission = 'everyone',
    this.callsPrivacy = 'everyone',
  });

  Map<String, dynamic> toJson() => {
    'lastSeenVisibility': lastSeenVisibility,
    'readReceipts': readReceipts,
    'onlineStatus': onlineStatus,
    'profilePhotoVisibility': profilePhotoVisibility,
    'forwardedMessages': forwardedMessages,
    'phoneNumberVisibility': phoneNumberVisibility,
    'groupsAddPermission': groupsAddPermission,
    'callsPrivacy': callsPrivacy,
  };

  factory PrivacySettings.fromJson(Map<String, dynamic> json) => PrivacySettings(
    lastSeenVisibility: json['lastSeenVisibility'] ?? 'everyone',
    readReceipts: json['readReceipts'] ?? true,
    onlineStatus: json['onlineStatus'] ?? true,
    profilePhotoVisibility: json['profilePhotoVisibility'] ?? 'everyone',
    forwardedMessages: json['forwardedMessages'] ?? true,
    phoneNumberVisibility: json['phoneNumberVisibility'] ?? 'contacts',
    groupsAddPermission: json['groupsAddPermission'] ?? 'everyone',
    callsPrivacy: json['callsPrivacy'] ?? 'everyone',
  );

  PrivacySettings copyWith({
    String? lastSeenVisibility,
    bool? readReceipts,
    bool? onlineStatus,
    String? profilePhotoVisibility,
    bool? forwardedMessages,
    String? phoneNumberVisibility,
    String? groupsAddPermission,
    String? callsPrivacy,
  }) => PrivacySettings(
    lastSeenVisibility: lastSeenVisibility ?? this.lastSeenVisibility,
    readReceipts: readReceipts ?? this.readReceipts,
    onlineStatus: onlineStatus ?? this.onlineStatus,
    profilePhotoVisibility: profilePhotoVisibility ?? this.profilePhotoVisibility,
    forwardedMessages: forwardedMessages ?? this.forwardedMessages,
    phoneNumberVisibility: phoneNumberVisibility ?? this.phoneNumberVisibility,
    groupsAddPermission: groupsAddPermission ?? this.groupsAddPermission,
    callsPrivacy: callsPrivacy ?? this.callsPrivacy,
  );
}

class PrivacyService {
  static const String _key = 'echat_privacy_settings';

  Future<PrivacySettings> getSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_key);
    if (data == null) return PrivacySettings();
    return PrivacySettings.fromJson(jsonDecode(data));
  }

  Future<void> updateSettings(PrivacySettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(settings.toJson()));
  }
}
