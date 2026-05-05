import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:io';

class DeviceSession {
  final String id;
  final String userId;
  final String deviceName;
  final String deviceType;
  final String browser;
  final String os;
  final String ipAddress;
  final String location;
  final DateTime lastActive;
  final DateTime createdAt;
  final bool isCurrent;

  DeviceSession({
    required this.id,
    required this.userId,
    required this.deviceName,
    required this.deviceType,
    required this.browser,
    required this.os,
    required this.ipAddress,
    required this.location,
    required this.lastActive,
    required this.createdAt,
    required this.isCurrent,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'deviceName': deviceName,
    'deviceType': deviceType,
    'browser': browser,
    'os': os,
    'ipAddress': ipAddress,
    'location': location,
    'lastActive': lastActive.toIso8601String(),
    'createdAt': createdAt.toIso8601String(),
    'isCurrent': isCurrent,
  };

  factory DeviceSession.fromJson(Map<String, dynamic> json) => DeviceSession(
    id: json['id'],
    userId: json['userId'],
    deviceName: json['deviceName'],
    deviceType: json['deviceType'],
    browser: json['browser'],
    os: json['os'],
    ipAddress: json['ipAddress'],
    location: json['location'],
    lastActive: DateTime.parse(json['lastActive']),
    createdAt: DateTime.parse(json['createdAt']),
    isCurrent: json['isCurrent'] ?? false,
  );

  DeviceSession copyWith({bool? isCurrent, DateTime? lastActive}) => DeviceSession(
    id: id,
    userId: userId,
    deviceName: deviceName,
    deviceType: deviceType,
    browser: browser,
    os: os,
    ipAddress: ipAddress,
    location: location,
    lastActive: lastActive ?? this.lastActive,
    createdAt: createdAt,
    isCurrent: isCurrent ?? this.isCurrent,
  );
}

class DeviceService {
  static const String _sessionsPrefix = 'echat_device_sessions_';
  static const String _currentSessionIdKey = 'echat_current_session_id';

  Future<List<DeviceSession>> getSessions(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('$_sessionsPrefix$userId');
    if (data == null) {
      await registerDevice(userId);
      return getSessions(userId);
    }
    final List decoded = jsonDecode(data);
    return decoded.map((e) => DeviceSession.fromJson(e)).toList();
  }

  Future<void> registerDevice(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final currentId = prefs.getString(_currentSessionIdKey);
    final sessions = await _loadSessions(userId);

    if (currentId != null) {
      final index = sessions.indexWhere((s) => s.id == currentId);
      if (index != -1) {
        sessions[index] = sessions[index].copyWith(
          isCurrent: true,
          lastActive: DateTime.now(),
        );
        for (int i = 0; i < sessions.length; i++) {
          if (i != index) sessions[i] = sessions[i].copyWith(isCurrent: false);
        }
        await _saveSessions(userId, sessions);
        return;
      }
    }

    // New session
    final String deviceName = Platform.isAndroid ? 'Android Device' : Platform.isIOS ? 'iPhone' : 'Web Browser';
    final String os = Platform.operatingSystem;
    final String deviceType = (Platform.isAndroid || Platform.isIOS) ? 'mobile' : 'desktop';

    final session = DeviceSession(
      id: 'session_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      deviceName: deviceName,
      deviceType: deviceType,
      browser: 'Native App',
      os: os,
      ipAddress: '192.168.x.x',
      location: 'Active Location',
      lastActive: DateTime.now(),
      createdAt: DateTime.now(),
      isCurrent: true,
    );

    for (int i = 0; i < sessions.length; i++) {
      sessions[i] = sessions[i].copyWith(isCurrent: false);
    }
    sessions.insert(0, session);
    
    await _saveSessions(userId, sessions);
    await prefs.setString(_currentSessionIdKey, session.id);
    
    if (sessions.length == 1) {
      await _addMockSessions(userId, sessions);
    }
  }

  Future<void> terminateSession(String userId, String sessionId) async {
    final sessions = await _loadSessions(userId);
    sessions.removeWhere((s) => s.id == sessionId);
    await _saveSessions(userId, sessions);
  }

  Future<void> terminateAllOthers(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final currentId = prefs.getString(_currentSessionIdKey);
    final sessions = await _loadSessions(userId);
    final current = sessions.where((s) => s.id == currentId).toList();
    await _saveSessions(userId, current);
  }

  Future<List<DeviceSession>> _loadSessions(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('$_sessionsPrefix$userId');
    if (data == null) return [];
    final List decoded = jsonDecode(data);
    return decoded.map((e) => DeviceSession.fromJson(e)).toList();
  }

  Future<void> _saveSessions(String userId, List<DeviceSession> sessions) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_sessionsPrefix$userId', jsonEncode(sessions.map((e) => e.toJson()).toList()));
  }

  Future<void> _addMockSessions(String userId, List<DeviceSession> sessions) async {
    sessions.add(DeviceSession(
      id: 'mock_1',
      userId: userId,
      deviceName: 'Chrome on Windows',
      deviceType: 'desktop',
      browser: 'Chrome',
      os: 'Windows 11',
      ipAddress: '82.45.x.x',
      location: 'London, UK',
      lastActive: DateTime.now().subtract(const Duration(hours: 5)),
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      isCurrent: false,
    ));
    await _saveSessions(userId, sessions);
  }
}
