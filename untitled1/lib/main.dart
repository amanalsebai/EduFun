import 'package:flutter/material.dart';
import 'app.dart';
import 'core/utils/audio_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); //تهيئة Flutter قبل استخدام خدمات النظام
  await AudioManager.playBackgroundMusic(); // تشغيل الموسيقى عند الإقلاع
  runApp(SmartGamesApp()); //تشغيل التطبيق وعرض الواجهة الرئيسية
}


