import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class BusinessHours {
  final String day;
  bool closed;
  String open;
  String close;

  BusinessHours({required this.day, this.closed = false, this.open = '09:00', this.close = '18:00'});

  Map<String, dynamic> toJson() => {'day': day, 'closed': closed, 'open': open, 'close': close};
  factory BusinessHours.fromJson(Map<String, dynamic> json) => BusinessHours(
    day: json['day'],
    closed: json['closed'] ?? false,
    open: json['open'] ?? '09:00',
    close: json['close'] ?? '18:00',
  );
}

class BusinessProfile {
  bool isEnabled;
  String businessName;
  String address;
  String phone;
  String website;
  String welcomeMessage;
  bool awayEnabled;
  String awayMessage;
  String awayStartTime;
  String awayEndTime;
  List<BusinessHours> hours;

  BusinessProfile({
    this.isEnabled = false,
    this.businessName = '',
    this.address = '',
    this.phone = '',
    this.website = '',
    this.welcomeMessage = 'Hello! Thanks for reaching out. How can we help you today?',
    this.awayEnabled = false,
    this.awayMessage = "We're currently away but will get back to you soon!",
    this.awayStartTime = '18:00',
    this.awayEndTime = '09:00',
    List<BusinessHours>? hours,
  }) : hours = hours ?? [
    BusinessHours(day: 'Monday'),
    BusinessHours(day: 'Tuesday'),
    BusinessHours(day: 'Wednesday'),
    BusinessHours(day: 'Thursday'),
    BusinessHours(day: 'Friday'),
    BusinessHours(day: 'Saturday', closed: true),
    BusinessHours(day: 'Sunday', closed: true),
  ];

  Map<String, dynamic> toJson() => {
    'isEnabled': isEnabled,
    'businessName': businessName,
    'address': address,
    'phone': phone,
    'website': website,
    'welcomeMessage': welcomeMessage,
    'awayEnabled': awayEnabled,
    'awayMessage': awayMessage,
    'awayStartTime': awayStartTime,
    'awayEndTime': awayEndTime,
    'hours': hours.map((h) => h.toJson()).toList(),
  };

  factory BusinessProfile.fromJson(Map<String, dynamic> json) => BusinessProfile(
    isEnabled: json['isEnabled'] ?? false,
    businessName: json['businessName'] ?? '',
    address: json['address'] ?? '',
    phone: json['phone'] ?? '',
    website: json['website'] ?? '',
    welcomeMessage: json['welcomeMessage'] ?? '',
    awayEnabled: json['awayEnabled'] ?? false,
    awayMessage: json['awayMessage'] ?? '',
    awayStartTime: json['awayStartTime'] ?? '18:00',
    awayEndTime: json['awayEndTime'] ?? '09:00',
    hours: (json['hours'] as List?)?.map((h) => BusinessHours.fromJson(h)).toList(),
  );
}

class BusinessProfileService {
  static const String _keyPrefix = 'business_profile_';

  Future<void> saveProfile(String userId, BusinessProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('${_keyPrefix}$userId', jsonEncode(profile.toJson()));
  }

  Future<BusinessProfile> getProfile(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('${_keyPrefix}$userId');
    if (data == null) return BusinessProfile();
    try {
      return BusinessProfile.fromJson(jsonDecode(data));
    } catch (_) {
      return BusinessProfile();
    }
  }
}
