import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/firebase_options.dart';
import 'package:instagram_clone/root/root_app.dart';

void main() async {
  
  
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
);
  await EasyLocalization.ensureInitialized();
  runApp(EasyLocalization(supportedLocales: [
    Locale('en'),
    Locale('ar'),
    
  ],
  path: 'assets/translations',
  fallbackLocale: Locale('ar'),
  child: MyApp()));
}

