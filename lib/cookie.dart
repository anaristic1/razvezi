import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:razvezi/storage.dart';
import 'package:razvezi/custom_logger.dart';

import 'package:flutter/foundation.dart';

final storage = FlutterSecureStorage();
final cookieJar = CookieJar();

Future<String> serverLogin(username, password) async {
  try {
    final response = await http.post(
      Uri.parse('${Connection.adress}login/'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"username": username, "password": password}),
    );

    if (response.statusCode == 200) {
      final rawCookies = response.headers['set-cookie'];

      final data = jsonDecode(response.body);

      storage.write(key: 'user', value: data['user']['username']);
      storage.write(key: 'role', value: data['user']['role']);

      Session.setSession(
        username: data['user']['username'],
        role: data['user']['role'],
      );

      if (rawCookies != null) {
        final sessionMatch =
            RegExp(r'sessionid=([^;]+)').firstMatch(rawCookies);
        final csrfMatch = RegExp(r'csrftoken=([^;]+)').firstMatch(rawCookies);

        if (sessionMatch != null) {
          storage.write(key: 'sessionid', value: sessionMatch.group(1)!);
        }

        if (csrfMatch != null) {
          storage.write(key: 'csrftoken', value: csrfMatch.group(1)!);
        }
      }
      return "";
    }
  } on SocketException {
    return "Server je nedostupan.";
  } on http.ClientException {
    return "Greška u mreži.";
  } catch (e) {
    return "Greška se desila.";
  }
  return "Pogrešno ime ili lozinka.";
}

Future<void> logout() async {
  await http.post(Uri.parse('${Connection.adress}logout/'));
  storage.delete(key: 'sessionid');
  storage.delete(key: 'csrftoken');
  Session.clear();
}

Future getCookieFromStorage() async {
  final sessionid = await storage.read(key: 'sessionid');
  final csrftoken = await storage.read(key: 'csrftoken');

  return "sessionid=$sessionid; csrftoken=$csrftoken";
}

Future getCSRF() async {
  return await storage.read(key: 'csrftoken');
}

class Session {
  static String? _username;
  static String? _role;

  static String? get username => _username;
  static String? get role => _role;

  static void setSession({
    required String username,
    required String role,
  }) {
    _username = username;
    _role = role;
  }

  static void clear() {
    _username = null;
    _role = null;
  }
}
