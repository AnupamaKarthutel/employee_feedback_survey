import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'models/app_user.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'services/auth_service.dart';
import 'services/auth_service_provider.dart';
import 'services/firebase_auth_service.dart';
import 'services/firestore_survey_service.dart';
import 'services/in_memory_auth_service.dart';
import 'services/in_memory_survey_service.dart';
import 'services/service_provider.dart';
import 'services/survey_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SurveyService surveyService;
  AuthService authService;
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    surveyService = FirestoreSurveyService();
    authService = FirebaseAuthService();
    log('Firebase initialized; using Firestore and Firebase Auth.');
  } catch (e) {
    surveyService = InMemorySurveyService();
    authService = InMemoryAuthService();
    log('Firebase not available; using in-memory backend: $e');
  }

  runApp(MyApp(surveyService: surveyService, authService: authService));
}

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
    required this.surveyService,
    required this.authService,
  });

  final SurveyService surveyService;
  final AuthService authService;

  @override
  Widget build(BuildContext context) {
    return ServiceProvider(
      service: surveyService,
      child: AuthServiceProvider(
        authService: authService,
        child: MaterialApp(
          title: 'Employee Feedback & Survey',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
            useMaterial3: true,
          ),
          home: const _AuthGate(),
        ),
      ),
    );
  }
}

class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    final authService = AuthServiceProvider.of(context);

    return StreamBuilder<AppUser?>(
      stream: authService.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final user = snapshot.data;
        if (user == null) return const LoginScreen();
        return HomeScreen(user: user);
      },
    );
  }
}
