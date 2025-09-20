import 'package:flutter/material.dart';
import 'package:touchhealth/core/cache/cache.dart';
import 'package:touchhealth/core/utils/helper/error_screen.dart';
import 'package:touchhealth/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'app.dart';
import 'data/source/local/chat_message_model.dart';
import 'data/source/firebase/firebase_service.dart';

Future<void> main() async {
  // Custom error handler
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return CustomErrorScreen(
      errorMessage: details.exception.toString(),
      stackTrace: details.stack.toString(),
    );
  };

  WidgetsFlutterBinding.ensureInitialized();

  // Load .env variables
  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    print('Warning: .env file not found or could not be loaded: $e');
  }

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Configure Firebase services
  FirebaseService.configureFirebase();

  // Initialize cache
  await CacheData.cacheDataInit();

  // Initialize Hive for local storage
  await Hive.initFlutter();
  Hive.registerAdapter(ChatMessageModelAdapter());

  runApp(const MyApp()); // MyApp is in app.dart
  
 }
