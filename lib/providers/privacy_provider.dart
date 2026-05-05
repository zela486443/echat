import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/privacy_service.dart';

final privacyServiceProvider = Provider<PrivacyService>((ref) => PrivacyService());

final privacySettingsProvider = StateNotifierProvider<PrivacySettingsNotifier, PrivacySettings>((ref) {
  final service = ref.watch(privacyServiceProvider);
  return PrivacySettingsNotifier(service);
});

class PrivacySettingsNotifier extends StateNotifier<PrivacySettings> {
  final PrivacyService _service;

  PrivacySettingsNotifier(this._service) : super(PrivacySettings()) {
    _load();
  }

  Future<void> _load() async {
    state = await _service.getSettings();
  }

  Future<void> update(PrivacySettings updates) async {
    state = updates;
    await _service.updateSettings(state);
  }

  Future<void> patch(PrivacySettings Function(PrivacySettings) mapper) async {
    state = mapper(state);
    await _service.updateSettings(state);
  }
}
