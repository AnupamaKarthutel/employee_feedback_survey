import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'screens/home_screen.dart';
import 'services/firestore_survey_service.dart';
import 'services/in_memory_survey_service.dart';
import 'services/service_provider.dart';
import 'services/survey_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SurveyService service;
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    service = FirestoreSurveyService();
    log('Firebase initialized; using Firestore backend.');
  } catch (e) {
    service = InMemorySurveyService();
    log('Firebase not available; using in-memory backend: $e');
  }

  runApp(MyApp(service: service));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.service});

  final SurveyService service;

  @override
  Widget build(BuildContext context) {
    return ServiceProvider(
      service: service,
      child: MaterialApp(
        title: 'Employee Feedback & Survey',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
          useMaterial3: true,
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
