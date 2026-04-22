import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'dart:io' show Platform;

class FirebaseConfig {
  static const String _apiKey = String.fromEnvironment(
    'FIREBASE_API_KEY',
    defaultValue: 'AIzaSyCIetD2sqddB9a0PyXP32BjWQEZ7fEp-Rw',
  );

  static const String _authDomain = String.fromEnvironment(
    'FIREBASE_AUTH_DOMAIN',
    defaultValue: 'menucom-ff087.firebaseapp.com',
  );

  static const String _projectId = String.fromEnvironment(
    'FIREBASE_PROJECT_ID',
    defaultValue: 'menucom-ff087',
  );

  static const String _storageBucket = String.fromEnvironment(
    'FIREBASE_STORAGE_BUCKET',
    defaultValue: 'menucom-ff087.firebasestorage.app',
  );

  static const String _messagingSenderId = String.fromEnvironment(
    'FIREBASE_MESSAGING_SENDER_ID',
    defaultValue: '1053737382833',
  );

  static const String _appIdWeb = String.fromEnvironment(
    'FIREBASE_APP_ID_WEB',
    defaultValue: '1:1053737382833:web:fe025ed8ecad532f900390',
  );

  static const String _measurementId = String.fromEnvironment(
    'FIREBASE_MEASUREMENT_ID',
    defaultValue: 'G-JVFCM6XLWV',
  );

  static const String _googleWebClientId = String.fromEnvironment(
    'GOOGLE_SIGN_IN_WEB_CLIENT_ID',
    defaultValue: '1053737382833-49iodle61i3kmdte9uocoij5hdg263nk.apps.googleusercontent.com',
  );

  static const String _googleIosClientId = String.fromEnvironment(
    'GOOGLE_SIGN_IN_IOS_CLIENT_ID',
    defaultValue: '1053737382833-49iodle61i3kmdte9uocoij5hdg263nk.apps.googleusercontent.com',
  );

  static FirebaseOptions get web => const FirebaseOptions(
        apiKey: _apiKey,
        authDomain: _authDomain,
        projectId: _projectId,
        storageBucket: _storageBucket,
        messagingSenderId: _messagingSenderId,
        appId: _appIdWeb,
        measurementId: _measurementId,
      );

  static FirebaseOptions get android => const FirebaseOptions(
        apiKey: _apiKey,
        appId: _appIdWeb,
        messagingSenderId: _messagingSenderId,
        projectId: _projectId,
        storageBucket: _storageBucket,
      );

  static FirebaseOptions get ios => const FirebaseOptions(
        apiKey: _apiKey,
        appId: _appIdWeb,
        messagingSenderId: _messagingSenderId,
        projectId: _projectId,
        storageBucket: _storageBucket,
        iosBundleId: 'com.menucom.catalog',
      );

  static FirebaseOptions get macos => const FirebaseOptions(
        apiKey: _apiKey,
        appId: _appIdWeb,
        messagingSenderId: _messagingSenderId,
        projectId: _projectId,
        storageBucket: _storageBucket,
        iosBundleId: 'com.menucom.catalog',
      );

  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }

    switch (Platform.operatingSystem) {
      case 'android':
        return android;
      case 'ios':
        return ios;
      case 'macos':
        return macos;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for ${Platform.operatingSystem}',
        );
    }
  }

  static String? get googleSignInClientId {
    if (kIsWeb) {
      return _googleWebClientId.isNotEmpty ? _googleWebClientId : null;
    }

    switch (Platform.operatingSystem) {
      case 'android':
        return null;
      case 'ios':
        return _googleIosClientId.isNotEmpty ? _googleIosClientId : null;
      case 'macos':
        return _googleIosClientId.isNotEmpty ? _googleIosClientId : null;
      default:
        return null;
    }
  }
}
