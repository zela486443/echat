import 'package:audioplayers/audioplayers.dart';

class CallAudioService {
  static final CallAudioService _instance = CallAudioService._internal();
  factory CallAudioService() => _instance;
  CallAudioService._internal();

  final AudioPlayer _player = AudioPlayer();
  bool _isPlaying = false;

  Future<void> playRingtone() async {
    if (_isPlaying) return;
    try {
      await _player.setReleaseMode(ReleaseMode.loop);
      await _player.play(AssetSource('sounds/ringtone.mp3'));
      _isPlaying = true;
    } catch (e) {
      print('Error playing ringtone: $e');
    }
  }

  Future<void> playCallingSound() async {
    if (_isPlaying) return;
    try {
      await _player.setReleaseMode(ReleaseMode.loop);
      await _player.play(AssetSource('sounds/calling.mp3'));
      _isPlaying = true;
    } catch (e) {
      print('Error playing calling sound: $e');
    }
  }

  Future<void> stopAll() async {
    await _player.stop();
    _isPlaying = false;
  }

  void dispose() {
    _player.dispose();
  }
}
