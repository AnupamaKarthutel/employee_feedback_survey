import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;

class DefaultFirebaseOptions {
  const DefaultFirebaseOptions._();

  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.windows:
        throw UnsupportedError(
          'Firestore is not configured for Windows in this project. Use web or mobile.',
        );
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'Firestore is not configured for macOS in this project. Use web or mobile.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'Firestore is not configured for Linux in this project. Use web or mobile.',
        );
      default:
        return web;
    }
  }

  /// Replace these placeholders with your Firebase web project settings.
  ///
  /// Get your config from the Firebase Console:
  /// Project Settings > Your apps > Web app > Config
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'YOUR_WEB_API_KEY',
    appId: 'YOUR_WEB_APP_ID',
    messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
    projectId: 'employee-feedback-survey',
    authDomain: 'employee-feedback-survey.firebaseapp.com',
    storageBucket: 'employee-feedback-survey.appspot.com',
    measurementId: 'YOUR_MEASUREMENT_ID',
  );

  /// Replace these placeholders with your Firebase Android project settings.
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'YOUR_ANDROID_API_KEY',
    appId: 'YOUR_ANDROID_APP_ID',
    messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
    projectId: 'employee-feedback-survey',
    storageBucket: 'employee-feedback-survey.appspot.com',
  );

  /// Replace these placeholders with your Firebase iOS project settings.
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'YOUR_IOS_API_KEY',
    appId: 'YOUR_IOS_APP_ID',
    messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
    projectId: 'employee-feedback-survey',
    storageBucket: 'employee-feedback-survey.appspot.com',
    iosBundleId: 'com.example.employeeFeedbackSurvey',
  );
}
