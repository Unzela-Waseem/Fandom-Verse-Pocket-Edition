import 'dart:io';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

final offlineMediaServiceProvider = Provider<OfflineMediaService>((ref) {
  return OfflineMediaService();
});

class OfflineMediaService {
  final Dio _dio = Dio();
  Directory? _cacheDir;

  Future<void> _initDir() async {
    if (_cacheDir != null) return;
    final dir = await getApplicationDocumentsDirectory();
    _cacheDir = Directory('${dir.path}/offline_media');
    if (!await _cacheDir!.exists()) {
      await _cacheDir!.create(recursive: true);
    }
  }

  String _hashUrl(String url) {
    final bytes = utf8.encode(url);
    final digest = sha256.convert(bytes);
    final ext = url.split('.').last.split('?').first;
    return '${digest.toString()}.$ext';
  }

  Future<String?> getLocalPath(String? url) async {
    if (url == null || url.trim().isEmpty) return null;
    await _initDir();
    final filename = _hashUrl(url.trim());
    final file = File('${_cacheDir!.path}/$filename');
    if (await file.exists()) {
      return file.path;
    }
    return null;
  }

  Future<void> downloadMedia(String? url) async {
    if (url == null || url.trim().isEmpty) return;
    final cleanUrl = url.trim();
    if (!cleanUrl.startsWith('http')) return;
    
    await _initDir();
    final filename = _hashUrl(cleanUrl);
    final savePath = '${_cacheDir!.path}/$filename';
    
    final file = File(savePath);
    if (await file.exists()) return; // Already downloaded

    try {
      await _dio.download(cleanUrl, savePath);
    } catch (e) {
      // Clean up partial file if download failed
      if (await file.exists()) {
        await file.delete();
      }
    }
  }

  Future<void> removeMedia(String? url) async {
    if (url == null || url.trim().isEmpty) return;
    await _initDir();
    final filename = _hashUrl(url.trim());
    final file = File('${_cacheDir!.path}/$filename');
    if (await file.exists()) {
      await file.delete();
    }
  }
}
