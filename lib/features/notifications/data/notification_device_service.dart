import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationDeviceService {
  static const _deviceIdKey = 'fandom_verse_device_id';

  static Future<String> _deviceId() async {
    final preferences = await SharedPreferences.getInstance();
    final existing = preferences.getString(_deviceIdKey);
    if (existing != null) return existing;
    final random = Random.secure();
    final bytes = List<int>.generate(24, (_) => random.nextInt(256));
    final id = base64UrlEncode(bytes).replaceAll('=', '');
    await preferences.setString(_deviceIdKey, id);
    return id;
  }

  static Future<void> saveCurrentToken(String uid) async {
    final token = await FirebaseMessaging.instance.getToken();
    if (token == null || token.isEmpty) return;
    await saveToken(uid, token);
  }

  static Future<void> saveToken(String uid, String token) async {
    final deviceId = await _deviceId();
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('devices')
        .doc(deviceId)
        .set({
          'token': token,
          'enabled': true,
          'platform': defaultTargetPlatform.name,
          'updatedAt': FieldValue.serverTimestamp(),
        });
  }

  static Future<bool> enable(String uid) async {
    final settings = await FirebaseMessaging.instance.requestPermission();
    if (settings.authorizationStatus == AuthorizationStatus.denied ||
        settings.authorizationStatus == AuthorizationStatus.notDetermined) {
      return false;
    }
    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'priceDropNotifications': true,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    try {
      await saveCurrentToken(uid);
    } catch (_) {
      // In-app notifications remain enabled when device push is unavailable.
    }
    return true;
  }

  static Future<void> disable(String uid) async {
    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'priceDropNotifications': false,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    final deviceId = await _deviceId();
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('devices')
        .doc(deviceId)
        .delete();
  }
}
