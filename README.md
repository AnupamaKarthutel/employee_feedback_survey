# Employee Feedback & Survey Tool

A Flutter internal survey application for collecting employee feedback and organisational responses. It supports role-based access, dynamic questionnaires, response storage, and structured data management using **Firebase Firestore** and **Firebase Authentication**.

## Features

- **Role-based access**: HR / Admin accounts can create and manage surveys; Employee accounts can take surveys.
- **Dynamic questionnaires**: Create surveys with text, rating, single-choice, and multi-choice questions.
- **Take surveys**: Employees can respond through a simple form.
- **Response storage**: Submissions are stored in Firestore.
- **Organisational responses**: View individual responses and summary aggregates per survey.
- **Offline-friendly demo**: If Firebase is not configured, the app automatically falls back to an in-memory backend for testing.

## Tech Stack

- Flutter 3.x
- Dart
- Firebase Core
- Firebase Authentication
- Cloud Firestore

## Project Structure

```
lib/
├── main.dart                       # App entry point and backend selection
├── firebase_options.dart           # Firebase configuration placeholders
├── models/                         # AppUser, Survey, Question, Response models
├── services/                       # Auth, survey services, Firestore and in-memory implementations
└── screens/                        # Login, home, create, take, and response screens
```

## Firebase Setup

1. Create a Firebase project in the [Firebase Console](https://console.firebase.google.com/).
2. Register Android, iOS, and/or Web apps.
3. Download `google-services.json` (Android) and `GoogleService-Info.plist` (iOS), place them in the appropriate platform folders, and update `lib/firebase_options.dart` with your keys.
4. Enable **Email/Password** authentication in the Firebase Console under Authentication > Sign-in method.
5. Enable Cloud Firestore in the Firebase Console and add these collections:
   - `users` — stores user roles (`{email, role}` where `role` is `admin` or `employee`).
   - `surveys` — stores survey documents.
   - `surveys/{surveyId}/responses` — stores employee responses.
6. Set up security rules. For development only:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /surveys/{surveyId} {
      allow read, write: if true;
      match /responses/{responseId} {
        allow read, write: if true;
      }
    }
  }
}
```

## Run the App

```bash
flutter pub get
flutter run
```

For the web:

```bash
flutter run -d chrome
```

## Run Tests

```bash
flutter test
```
