import 'dart:convert';

import 'package:wastexchange_mobile/models/user.dart';
import 'package:wastexchange_mobile/utils/cached_secure_storage.dart';
import 'package:wastexchange_mobile/utils/global_utils.dart';

class UserDataStore {
  factory UserDataStore() {
    return _singleton;
  }

  UserDataStore._internal([CachedSecureStorage cachedSecureStorage]) {
    _cachedSecureStorage = cachedSecureStorage ?? CachedSecureStorage();
  }

  CachedSecureStorage _cachedSecureStorage;
  User _thisUser;
  List<User> _allUsers;
  static const THIS_USER_KEY = 'thisUser';

  static final UserDataStore _singleton = UserDataStore._internal();

  void saveProfile(User user) {
    _thisUser = user;
    _cachedSecureStorage.setValue(THIS_USER_KEY, json.encode(user.toJson()));
  }

  void saveUsers(List<User> users) {
    _allUsers = users;
  }

  User getUser({int id}) {
    return _allUsers.firstWhere((user) => user.id == id, orElse: null);
  }

  Future<User> getProfile() async {
    if (isNotNull(_thisUser)) {
      return _thisUser;
    }
    final String jsonStr = await _cachedSecureStorage.getValue(THIS_USER_KEY);
    if (isNotNull(jsonStr)) {
      _thisUser = User.fromJson(json.decode(jsonStr));
    }
    return _thisUser;
  }

  void deleteUser(){
    _thisUser = null;
    _cachedSecureStorage.deleteKey(THIS_USER_KEY);
  }
}
