import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:menu_dart_api/by_feature/auth/social_login/data/usecase/social_login_usecase.dart';
import 'package:menu_dart_api/by_feature/auth/social_login/model/social_login_response.dart';
import 'package:menu_dart_api/core/api.dart';
import '../firebase_config.dart';
import '../config.dart';
import '../analytics_service.dart';

class GoogleAuthService {
  static final GoogleAuthService _instance = GoogleAuthService._internal();
  factory GoogleAuthService() => _instance;
  GoogleAuthService._internal();

  final GoogleSignIn _googleSignIn = GoogleSignIn(clientId: FirebaseConfig.googleSignInClientId);

  Future<SocialLoginResponse?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        return null;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Autenticar con Firebase para obtener el token correcto
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      final String? firebaseToken = await userCredential.user?.getIdToken();

      if (firebaseToken == null || firebaseToken.isEmpty) {
        throw Exception('Failed to get Firebase ID token');
      }

      final socialLoginUseCase = SocialLoginUseCase();
      final response = await socialLoginUseCase.executeWithGoogle(
        firebaseIdToken: firebaseToken,
        userInfo: {'email': googleUser.email, 'displayName': googleUser.displayName, 'photoURL': googleUser.photoUrl},
      );

      _updateGlobalAuthState(response, googleUser.displayName);

      AnalyticsService().logLogin(method: 'google');
      AnalyticsService().setUserId(response.user?.id.toString());

      return response;
    } catch (e) {
      print('Google Sign-In Error: $e');
      rethrow;
    }
  }

  /// Intenta restaurar la sesión de forma silenciosa sin mostrar diálogos
  Future<SocialLoginResponse?> signInSilently() async {
    try {
      // 1. Intentar con Google silent sign in
      final GoogleSignInAccount? googleUser = await _googleSignIn.signInSilently();

      // 2. Revisar si hay usuario de Firebase persistido
      User? firebaseUser = FirebaseAuth.instance.currentUser;

      if (googleUser == null && firebaseUser == null) {
        return null;
      }

      // 3. Obtener el token de Firebase
      String? firebaseToken;
      if (firebaseUser != null) {
        firebaseToken = await firebaseUser.getIdToken();
      } else if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
        firebaseToken = await userCredential.user?.getIdToken();
      }

      if (firebaseToken == null || firebaseToken.isEmpty) return null;

      // 4. Llamar al backend para obtener el ACCESS_TOKEN
      final socialLoginUseCase = SocialLoginUseCase();
      final response = await socialLoginUseCase.executeWithGoogle(
        firebaseIdToken: firebaseToken,
        userInfo: {
          'email': firebaseUser?.email ?? googleUser?.email,
          'displayName': firebaseUser?.displayName ?? googleUser?.displayName,
          'photoURL': firebaseUser?.photoURL ?? googleUser?.photoUrl,
        },
      );

      _updateGlobalAuthState(response, googleUser?.displayName ?? firebaseUser?.displayName);

      AnalyticsService().logLogin(method: 'google_silent');
      AnalyticsService().setUserId(response.user?.id.toString());

      return response;
    } catch (e) {
      debugPrint('Silent Sign-In Error: $e');
      return null;
    }
  }

  /// Actualiza las variables globales de autenticación
  void _updateGlobalAuthState(SocialLoginResponse response, String? fallbackName) {
    ACCESS_TOKEN = response.accessToken;
    API.setAccessToken(ACCESS_TOKEN);

    final user = response.user;
    NAME_USER = user?.name ?? fallbackName ?? '';

    if (NAME_USER.contains(' ')) {
      final parts = NAME_USER.split(' ');
      NAME_USER = parts.first;
      USER_LAST_NAME = parts.sublist(1).join(' ');
    }

    USER_EMAIL = user?.email ?? '';
    debugPrint('[AUTH] Sesión actualizada para: $USER_EMAIL');
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      AnalyticsService().logLogout();
      AnalyticsService().setUserId(null);
      ACCESS_TOKEN = '';
      API.setAccessToken('');
      NAME_USER = '';
      USER_LAST_NAME = '';
      USER_EMAIL = '';
    } catch (e) {
      debugPrint('Sign Out Error: $e');
    }
  }

  bool get isAuthenticated => ACCESS_TOKEN.isNotEmpty;
}
