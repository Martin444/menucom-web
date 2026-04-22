import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:menu_dart_api/by_feature/auth/social_login/data/usecase/social_login_usecase.dart';
import 'package:menu_dart_api/by_feature/auth/social_login/model/social_login_response.dart';
import 'package:menu_dart_api/core/api.dart';
import '../firebase_config.dart';
import '../config.dart';

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

      ACCESS_TOKEN = response.accessToken;
      API.setAccessToken(ACCESS_TOKEN);
      NAME_USER = response.user?.name ?? googleUser.displayName ?? '';
      if (NAME_USER.contains(' ')) {
        final parts = NAME_USER.split(' ');
        NAME_USER = parts.first;
        USER_LAST_NAME = parts.sublist(1).join(' ');
      }
      USER_EMAIL = response.user?.email ?? googleUser.email;

      return response;
    } catch (e) {
      print('Google Sign-In Error: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      ACCESS_TOKEN = '';
      API.setAccessToken('');
      NAME_USER = '';
      USER_LAST_NAME = '';
      USER_EMAIL = '';
    } catch (e) {
      print('Sign Out Error: $e');
    }
  }

  bool get isAuthenticated => ACCESS_TOKEN.isNotEmpty;
}
