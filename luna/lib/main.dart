import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'core/constants/feature_flags.dart';
import 'data/services/notification_service.dart';
import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  tz.initializeTimeZones();
  await NotificationService.init();

  await Hive.initFlutter();
  await Hive.openBox<dynamic>('settings');
  await Hive.openBox<dynamic>('ai_cache');

  // Firebase — only initialised after google-services.json is added and
  // kFirebaseEnabled is flipped to true in feature_flags.dart.
  if (kFirebaseEnabled) {
    await Firebase.initializeApp();
  }

  runApp(
    const ProviderScope(
      child: LunaApp(),
    ),
  );
}
