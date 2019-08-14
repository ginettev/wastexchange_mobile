import 'package:wastexchange_mobile/util/cached_secure_storage.dart';

/// TokenRepository class specifically designed to handle JWT Token by validating JWT Token, Checking token expired, etc...
/// This uses a singleton pattern to ensure only one instance is available.
class TokenRepository {

  factory TokenRepository() {
    return _instance ??= TokenRepository._internal();
  }

  TokenRepository._internal();

  static TokenRepository _instance;

  static const _tokenKey = 'token';

  Future<bool> isAuthorized() async {
    return await getToken() != null;
  }

  Future<void> setToken(token) async {
    await CachedSecureStorage().setValue(_tokenKey, token);
  }

  Future<void> deleteToken() async {
    await CachedSecureStorage().setValue(_tokenKey, null);
  }

  Future<String> getToken() async {
    return CachedSecureStorage().getValue(_tokenKey);
  }
}