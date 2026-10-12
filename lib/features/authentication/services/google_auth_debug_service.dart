import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hawiisaac/core/apiendpoint/apiendpoint.dart';
import 'package:hawiisaac/core/utils/logging/logger.dart';
import 'package:hawiisaac/features/authentication/model/auth_token_response.dart';
import 'package:hawiisaac/features/authentication/services/auth_api_client.dart';
import 'package:hawiisaac/features/authentication/services/auth_exception.dart';

class GoogleAuthDebugResult {
  const GoogleAuthDebugResult({
    required this.googleIdToken,
    required this.firebaseIdToken,
    required this.authSession,
    required this.email,
    required this.uid,
  });

  final String googleIdToken;
  final String firebaseIdToken;
  final AuthTokenResponse authSession;
  final String email;
  final String uid;
}

class GoogleAuthDebugService {
  GoogleAuthDebugService({
    FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
    AuthApiClient? apiClient,
  }) : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
       _googleSignIn = googleSignIn ?? GoogleSignIn.instance,
       _apiClient = apiClient ?? const AuthApiClient();

  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;
  final AuthApiClient _apiClient;

  bool _isInitialized = false;

  Future<GoogleAuthDebugResult> signInAndLoginToBackend() async {
    await _ensureInitialized();

    final GoogleSignInAccount googleUser = await _googleSignIn.authenticate();
    final GoogleSignInAuthentication googleAuth = googleUser.authentication;
    final String googleIdToken = googleAuth.idToken ?? '';

    String firebaseIdToken = '';
    User? user;

    try {
      if (googleIdToken.isNotEmpty) {
        final AuthCredential credential = GoogleAuthProvider.credential(
          idToken: googleIdToken,
        );
        final UserCredential userCredential = await _firebaseAuth
            .signInWithCredential(credential);
        user = userCredential.user;
        firebaseIdToken = await user?.getIdToken(true) ?? '';
      }
    } catch (error) {
      debugPrint('Firebase Auth sign in skipped/failed: $error');
    }

    final tokenToSend = firebaseIdToken.isNotEmpty
        ? firebaseIdToken
        : googleIdToken;

    if (tokenToSend.isEmpty) {
      throw const AuthException(
        message: 'Google sign-in did not return a valid ID token.',
        statusCode: 0,
      );
    }

    final tokenPreview = _tokenPreview(tokenToSend);
    AppLoggerHelper.debug(
      'Google login request token preview: $tokenPreview',
    );

    Map<String, dynamic> data;
    try {
      data = await _apiClient.postJson(
        url: ApiEndpoint.googleAuth,
        body: <String, dynamic>{
          'id_token': tokenToSend,
          'idToken': tokenToSend,
          'token': tokenToSend,
        },
        logLabel: 'Google Auth',
        showDebugLog: true,
      );
    } catch (error) {
      debugPrint(
        'Google Auth endpoint failed ($error), attempting Firebase Auth fallback...',
      );
      data = await _apiClient.postJson(
        url: ApiEndpoint.firebaseAuth,
        body: <String, dynamic>{
          'id_token': tokenToSend,
          'token': tokenToSend,
        },
        logLabel: 'Firebase Auth Fallback',
        showDebugLog: true,
      );
    }

    final authSession = AuthTokenResponse.fromJson(data);
    if (authSession.accessToken.isEmpty || authSession.refreshToken.isEmpty) {
      throw const AuthException(
        message: 'Google login response did not include valid tokens.',
        statusCode: 0,
      );
    }

    debugPrint('Google auth success:');
    debugPrint('Google email: ${googleUser.email}');
    debugPrint('Firebase uid: ${user?.uid ?? 'unknown'}');
    debugPrint('Google ID token: $googleIdToken');
    debugPrint('Firebase ID token: $firebaseIdToken');
    debugPrint(
      'Backend auth success: tokenType=${authSession.tokenType}, '
      'access=${_tokenPreview(authSession.accessToken)}, '
      'refresh=${_tokenPreview(authSession.refreshToken)}',
    );

    return GoogleAuthDebugResult(
      googleIdToken: googleIdToken,
      firebaseIdToken: firebaseIdToken,
      authSession: authSession,
      email: googleUser.email,
      uid: user?.uid ?? '',
    );
  }

  Future<void> _ensureInitialized() async {
    if (_isInitialized) return;

    await _googleSignIn.initialize();
    _isInitialized = true;
  }

  String _tokenPreview(String token) {
    if (token.isEmpty) return 'empty';
    if (token.length <= 12) return 'len=${token.length}';

    return '${token.substring(0, 6)}...${token.substring(token.length - 6)} '
        '(len=${token.length})';
  }
}
