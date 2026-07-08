import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AudioManager {
  static final AudioPlayer _musicPlayer = AudioPlayer();
  static final AudioPlayer _fxPlayer = AudioPlayer();

  // تشغيل موسيقى الخلفية
  static Future<void> playBackgroundMusic() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('music_enabled') ?? true) {
      await _musicPlayer.play(AssetSource('audio/background.mp3'));
      _musicPlayer.setReleaseMode(ReleaseMode.loop); // تجعل الموسيقى تعيد نفسها
    }
  }

  // إيقاف الموسيقى
  static Future<void> stopMusic() async {
    await _musicPlayer.stop();
  }

  // تشغيل صوت الفوز
  static Future<void> playWinSound() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('sound_enabled') ?? true) {
      await _fxPlayer.play(AssetSource('audio/win_sound.mp3'));
    }
  }
}