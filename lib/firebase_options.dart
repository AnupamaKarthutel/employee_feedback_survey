import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  const DefaultFirebaseOptions._();

  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
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

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBxT19WPIUZZnNkzoyOJeSLABiBqAZcCWk',
    appId: '1:316384747623:web:05390e46c4f17558cdf4c2',
    messagingSenderId: '316384747623',
    projectId: 'employee-feedback-survey',
    authDomain: 'employee-feedback-survey.firebaseapp.com',
    storageBucket: 'employee-feedback-survey.firebasestorage.app',
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
