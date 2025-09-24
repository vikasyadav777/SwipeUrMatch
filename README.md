# SwipeUrMatch - Complete Starter (Flutter + Firebase)

This repository is an assembled starter project for the SwipeUrMatch app with:
- Email, Google, Apple auth (client code)
- Image uploads to Firebase Storage
- Swipe UI (swipable_stack) with Cloud Functions for matchmaking
- Real-time chat using Firestore
- FCM push notifications on matches (Cloud Functions)
- RevenueCat (purchases_flutter) integration stubs for subscriptions
- AdMob placeholders (google_mobile_ads)
- Reporting & Moderation, Admin Panel, role-based access
- Cloud Functions for admin actions and bootstrap initial admins
- Firestore & Storage security rules

## Setup Steps (summary)
1. Install Flutter & Dart (Flutter 3.7+ recommended).
2. Install Firebase CLI: `npm install -g firebase-tools` and login: `firebase login`.
3. Create Firebase project and enable Auth (Email, Google, Apple), Firestore, Storage, FCM.
4. In project root, run `flutter pub get`.
5. Configure Firebase for Flutter: install `flutterfire_cli` and run `flutterfire configure` to generate `lib/firebase_options.dart`.
6. Place `google-services.json` in `android/app/` and `GoogleService-Info.plist` in `ios/Runner/`.
7. Deploy Cloud Functions:
   ```bash
   cd functions
   npm install
   firebase functions:config:set bootstrap.secret="YOUR_SECRET"
   firebase deploy --only functions
   ```
8. Update Firestore rules and Storage rules in Firebase Console using files in `firebase/`.
9. Run the app: `flutter run`.

## Notes
- Replace AdMob and RevenueCat placeholders with your keys and configure native platforms as explained in previous messages.
- The Cloud Functions use an in-memory rate limiter for demo; use Redis for production.
- Security: ensure functions config secret is removed/rotated after initial bootstrap.

