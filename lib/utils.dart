import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';

class Utils {
  static Map<String, String> configHeader({String token}) {
    if (token != null) {
      return {
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.acceptHeader: 'application/json',
        HttpHeaders.authorizationHeader: 'Token $token',
      };
    } else {
      return {
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.acceptHeader: 'application/json',
      };
    }
  }

  static String capitalizeFirstLetter(String value) {
    return value[0].toUpperCase() + value.substring(1);
  }
}

class SharedPref {
  Future<String> getString(String key) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(key) ?? null;
  }

  Future<bool> setString(String key, String value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(key, value);
  }
}
