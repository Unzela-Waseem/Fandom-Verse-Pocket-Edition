import 'dart:async';
import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class AvatarUploadException implements Exception {
  const AvatarUploadException(this.message);

  final String message;
}

String? supportedAvatarMime(Uint8List bytes) {
  if (bytes.length >= 3 &&
      bytes[0] == 0xff &&
      bytes[1] == 0xd8 &&
      bytes[2] == 0xff) {
    return 'image/jpeg';
  }
  if (bytes.length >= 8 &&
      bytes[0] == 0x89 &&
      bytes[1] == 0x50 &&
      bytes[2] == 0x4e &&
      bytes[3] == 0x47 &&
      bytes[4] == 0x0d &&
      bytes[5] == 0x0a &&
      bytes[6] == 0x1a &&
      bytes[7] == 0x0a) {
    return 'image/png';
  }
  if (bytes.length >= 12 &&
      String.fromCharCodes(bytes.sublist(0, 4)) == 'RIFF' &&
      String.fromCharCodes(bytes.sublist(8, 12)) == 'WEBP') {
    return 'image/webp';
  }
  return null;
}

class AvatarUploadService {
  AvatarUploadService({FirebaseAuth? auth, FirebaseStorage? storage})
    : _auth = auth ?? FirebaseAuth.instance,
      _storage = storage ?? FirebaseStorage.instance;

  static const maxBytes = 5 * 1024 * 1024;
  final FirebaseAuth _auth;
  final FirebaseStorage _storage;
  UploadTask? _upload;

  Future<String?> pickAndUpload({
    required String uid,
    required void Function(double progress) onProgress,
  }) async {
    if (_auth.currentUser?.uid != uid) {
      throw const AvatarUploadException('Sign in to your own account first.');
    }
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
      requestFullMetadata: false,
    );
    if (picked == null) return null;
    final length = await picked.length();
    if (length == 0 || length > maxBytes) {
      throw const AvatarUploadException('Choose an image smaller than 5 MB.');
    }
    final bytes = await picked.readAsBytes();
    final mime = supportedAvatarMime(bytes);
    if (bytes.length > maxBytes || mime == null) {
      throw const AvatarUploadException(
        'Choose a JPEG, PNG, or WebP image smaller than 5 MB.',
      );
    }
    if (_auth.currentUser?.uid != uid) {
      throw const AvatarUploadException('Your account changed. Try again.');
    }
    final name = DateTime.now().microsecondsSinceEpoch.toString();
    final reference = _storage.ref('users/$uid/avatars/$name');
    final upload = reference.putData(
      bytes,
      SettableMetadata(contentType: mime),
    );
    _upload = upload;
    final subscription = upload.snapshotEvents.listen((snapshot) {
      if (snapshot.totalBytes > 0) {
        onProgress(snapshot.bytesTransferred / snapshot.totalBytes);
      }
    });
    try {
      await upload;
      if (_auth.currentUser?.uid != uid) {
        await reference.delete();
        throw const AvatarUploadException('Your account changed. Try again.');
      }
      return reference.getDownloadURL();
    } finally {
      await subscription.cancel();
      _upload = null;
    }
  }

  Future<void> cancel() async {
    await _upload?.cancel();
  }

  Future<void> deletePrevious({required String uid, String? url}) async {
    if (_auth.currentUser?.uid != uid || url == null || url.isEmpty) return;
    try {
      final previous = _storage.refFromURL(url);
      if (previous.fullPath.startsWith('users/$uid/avatars/')) {
        await previous.delete();
      }
    } on FirebaseException {
      // A failed cleanup does not undo the successfully saved new avatar.
    } on ArgumentError {
      // Social sign-in profile photos are not owned by this Storage bucket.
    }
  }
}
