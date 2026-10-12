import 'package:flutter/material.dart';
import 'package:hawiisaac/features/authentication/model/auth_token_response.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  StorageService._();

  static const String _accessTokenKey = 'auth_access_token';
  static const String _refreshTokenKey = 'auth_refresh_token';
  static const String _tokenTypeKey = 'auth_token_type';
  static const String _themeModeKey = 'theme_mode';
  static const String _hasSelectedUnitsKey = 'has_selected_units';

  static String _accessToken = '';
  static String _refreshToken = '';
  static String _tokenType = 'bearer';
  static ThemeMode _themeMode = ThemeMode.system;
  static bool _hasSelectedUnits = false;

  static String get accessToken => _accessToken;
  static String get refreshToken => _refreshToken;
  static String get tokenType => _tokenType;
  static ThemeMode get themeMode => _themeMode;
  static bool get hasSelectedUnits => _hasSelectedUnits;
  static bool get hasAccessToken => _accessToken.isNotEmpty;
  static bool get hasRefreshToken => _refreshToken.isNotEmpty;
  static bool get hasAuthTokens => hasAccessToken && hasRefreshToken;

  static Future<void> init() async {
    final preferences = await SharedPreferences.getInstance();
    _accessToken = preferences.getString(_accessTokenKey) ?? '';
    _refreshToken = preferences.getString(_refreshTokenKey) ?? '';
    _tokenType = preferences.getString(_tokenTypeKey) ?? 'bearer';
    _themeMode = _themeModeFromValue(preferences.getString(_themeModeKey));
    _hasSelectedUnits = preferences.getBool(_hasSelectedUnitsKey) ?? false;
    debugPrint(
      'Auth storage init: hasTokens=$hasAuthTokens, '
      'hasSelectedUnits=$_hasSelectedUnits, '
      'access=${_tokenPreview(_accessToken)}, '
      'refresh=${_tokenPreview(_refreshToken)}',
    );
  }

  static Future<bool> saveAuthSession(AuthTokenResponse response) async {
    if (response.accessToken.isEmpty || response.refreshToken.isEmpty) {
      debugPrint(
        'Auth session save skipped: empty token received, '
        'access=${_tokenPreview(response.accessToken)}, '
        'refresh=${_tokenPreview(response.refreshToken)}',
      );
      return false;
    }

    _accessToken = response.accessToken;
    _refreshToken = response.refreshToken;
    _tokenType = response.tokenType;

    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_accessTokenKey, _accessToken);
    await preferences.setString(_refreshTokenKey, _refreshToken);
    await preferences.setString(_tokenTypeKey, _tokenType);
    debugPrint(
      'Auth session saved: tokenType=$_tokenType, '
      'access=${_tokenPreview(_accessToken)}, '
      'refresh=${_tokenPreview(_refreshToken)}',
    );
    return true;
  }

  static Future<void> setHasSelectedUnits(bool value) async {
    _hasSelectedUnits = value;
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_hasSelectedUnitsKey, value);
    debugPrint('Auth storage setHasSelectedUnits: $value');
  }

  static Future<void> clearAuthSession() async {
    _accessToken = '';
    _refreshToken = '';
    _tokenType = 'bearer';
    _hasSelectedUnits = false;

    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_accessTokenKey);
    await preferences.remove(_refreshTokenKey);
    await preferences.remove(_tokenTypeKey);
    await preferences.remove(_hasSelectedUnitsKey);
    debugPrint('Auth session cleared');
  }

  static Future<void> saveThemeMode(ThemeMode themeMode) async {
    _themeMode = themeMode;

    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_themeModeKey, themeMode.name);
  }

  static ThemeMode _themeModeFromValue(String? value) {
    return switch (value) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  static String _tokenPreview(String token) {
    if (token.isEmpty) return 'empty';
    if (token.length <= 12) return 'len=${token.length}';

    return '${token.substring(0, 6)}...${token.substring(token.length - 6)} '
        '(len=${token.length})';
  }
}
