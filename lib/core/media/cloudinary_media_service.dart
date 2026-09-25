import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

enum CloudinaryPurpose {
  avatar,
  contentImage,
  contentVideo,
  eventImage,
  productImage,
}

class MediaUploadException implements Exception {
  const MediaUploadException(this.message);

  final String message;
}

class CloudinaryMediaService {
  CloudinaryMediaService({FirebaseAuth? auth, Dio? dio, ImagePicker? picker})
    : _auth = auth ?? FirebaseAuth.instance,
      _dio = dio ?? Dio(),
      _picker = picker ?? ImagePicker();

  static const cloudName = 'dc1w5stzg';
  static const signerUrl = String.fromEnvironment('CLOUDINARY_SIGNER_URL');
  static const uploadPreset = String.fromEnvironment(
    'CLOUDINARY_UPLOAD_PRESET',
    defaultValue: 'fandom_verse_unsigned',
  );

  static bool get isConfigured {
    final uri = Uri.tryParse(signerUrl);
    return uri != null &&
        uri.scheme == 'https' &&
        uri.host.isNotEmpty &&
        uri.userInfo.isEmpty &&
        !uri.hasQuery &&
        !uri.hasFragment;
  }

  static bool get isSupportedPlatform =>
      kIsWeb ||
      defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS ||
      defaultTargetPlatform == TargetPlatform.windows ||
      defaultTargetPlatform == TargetPlatform.macOS ||
      defaultTargetPlatform == TargetPlatform.linux;

  final FirebaseAuth _auth;
  final Dio _dio;
  final ImagePicker _picker;
  CancelToken? _cancelToken;

  void cancel() => _cancelToken?.cancel();

  Future<String?> pickAndUpload({
    required CloudinaryPurpose purpose,
    required void Function(double progress) onProgress,
  }) async {
    if (!isSupportedPlatform) {
      throw const MediaUploadException('Platform not supported for media picker.');
    }
    final user = _auth.currentUser;
    if (user == null) {
      throw const MediaUploadException('Sign in to upload media.');
    }
    final isVideo = purpose == CloudinaryPurpose.contentVideo;
    final XFile? picked = isVideo
        ? await _picker.pickVideo(source: ImageSource.gallery)
        : await _picker.pickImage(
            source: ImageSource.gallery,
            maxWidth: purpose == CloudinaryPurpose.avatar ? 1024 : 1920,
            maxHeight: purpose == CloudinaryPurpose.avatar ? 1024 : 1920,
            imageQuality: 85,
            requestFullMetadata: false,
          );
    if (picked == null) return null;

    final bytes = await picked.readAsBytes();
    if (bytes.isEmpty) {
      throw const MediaUploadException('Selected file is empty.');
    }
    final maxBytes = purpose == CloudinaryPurpose.avatar
        ? 5 * 1024 * 1024
        : isVideo
        ? 100 * 1024 * 1024
        : 15 * 1024 * 1024;
    if (bytes.length > maxBytes) {
      throw MediaUploadException(
        'Choose a file smaller than ${maxBytes ~/ (1024 * 1024)} MB.',
      );
    }

    final lowerName = picked.name.toLowerCase();
    final isAllowed = isVideo
        ? (lowerName.endsWith('.mp4') ||
            lowerName.endsWith('.mov') ||
            lowerName.endsWith('.webm') ||
            lowerName.endsWith('.mkv') ||
            lowerName.endsWith('.avi'))
        : (lowerName.endsWith('.jpg') ||
            lowerName.endsWith('.jpeg') ||
            lowerName.endsWith('.png') ||
            lowerName.endsWith('.webp') ||
            lowerName.endsWith('.gif'));

    if (!isAllowed) {
      throw MediaUploadException(
        isVideo
            ? 'Choose an MP4, MOV, or WebM video.'
            : 'Choose a JPEG, PNG, or WebP image.',
      );
    }
    final cancelToken = CancelToken();
    _cancelToken = cancelToken;
    try {
      if (isConfigured) {
        final token = await user.getIdToken();
        if (token == null || _auth.currentUser?.uid != user.uid) {
          throw const MediaUploadException('Your session changed. Try again.');
        }
        final backend = signerUrl.replaceFirst(RegExp(r'/$'), '');
        final headers = {'Authorization': 'Bearer $token'};
        final signed = await _dio.post<Map<String, dynamic>>(
          '$backend/media/sign',
          data: {'purpose': purpose.name},
          options: Options(headers: headers),
          cancelToken: cancelToken,
        );
        final ticket = signed.data;
        if (ticket == null ||
            ticket['cloudName'] != cloudName ||
            ticket['resourceType'] != (isVideo ? 'video' : 'image') ||
            ticket['apiKey'] is! String ||
            ticket['signature'] is! String ||
            ticket['parameters'] is! Map) {
          throw const MediaUploadException(
            'The upload service returned an invalid ticket.',
          );
        }
        final parameters = Map<String, dynamic>.from(ticket['parameters'] as Map);
        if (parameters['timestamp'] is! int ||
            parameters['folder'] is! String ||
            parameters['public_id'] is! String ||
            parameters['upload_preset'] is! String) {
          throw const MediaUploadException('The upload ticket is incomplete.');
        }
        final mimeType = isVideo
            ? picked.name.toLowerCase().endsWith('.webm')
                ? 'video/webm'
                : picked.name.toLowerCase().endsWith('.mov')
                ? 'video/quicktime'
                : 'video/mp4'
            : (supportedImageMime(bytes) ?? 'image/jpeg');
        final form = FormData.fromMap({
          ...parameters,
          'api_key': ticket['apiKey'],
          'signature': ticket['signature'],
          'file': MultipartFile.fromBytes(
            bytes,
            filename: picked.name,
            contentType: DioMediaType.parse(mimeType),
          ),
        });
        final uploaded = await _dio.post<Map<String, dynamic>>(
          'https://api.cloudinary.com/v1_1/$cloudName/${ticket['resourceType']}/upload',
          data: form,
          options: Options(sendTimeout: const Duration(minutes: 10)),
          cancelToken: cancelToken,
          onSendProgress: (sent, total) {
            if (total > 0) onProgress(0.9 * sent / total);
          },
        );
        final result = uploaded.data;
        if (result == null ||
            result['public_id'] is! String ||
            result['version'] is! int ||
            result['signature'] is! String) {
          throw const MediaUploadException(
            'Cloudinary did not confirm the upload.',
          );
        }
        if (_auth.currentUser?.uid != user.uid) {
          throw const MediaUploadException('Your account changed. Try again.');
        }
        onProgress(0.95);
        final completed = await _dio.post<Map<String, dynamic>>(
          '$backend/media/complete',
          data: {
            'purpose': purpose.name,
            'publicId': result['public_id'],
            'version': result['version'],
            'signature': result['signature'],
          },
          options: Options(headers: headers),
          cancelToken: cancelToken,
        );
        final url = completed.data?['secureUrl'];
        final uri = url is String ? Uri.tryParse(url) : null;
        if (uri == null ||
            uri.scheme != 'https' ||
            uri.host != 'res.cloudinary.com' ||
            !uri.path.startsWith('/$cloudName/')) {
          throw const MediaUploadException('The uploaded asset URL is invalid.');
        }
        onProgress(1);
        return url as String;
      } else {
        // Direct upload to Cloudinary using Unsigned Preset
        final mimeType = isVideo
            ? picked.name.toLowerCase().endsWith('.webm')
                ? 'video/webm'
                : picked.name.toLowerCase().endsWith('.mov')
                ? 'video/quicktime'
                : 'video/mp4'
            : (supportedImageMime(bytes) ?? 'image/jpeg');
        final folder = isVideo
            ? 'fandom-verse/content/videos'
            : 'fandom-verse/content/images';
        final form = FormData.fromMap({
          'upload_preset': uploadPreset,
          'folder': folder,
          'file': MultipartFile.fromBytes(
            bytes,
            filename: picked.name,
            contentType: DioMediaType.parse(mimeType),
          ),
        });
        final uploaded = await _dio.post<Map<String, dynamic>>(
          'https://api.cloudinary.com/v1_1/$cloudName/${isVideo ? 'video' : 'image'}/upload',
          data: form,
          options: Options(sendTimeout: const Duration(minutes: 10)),
          cancelToken: cancelToken,
          onSendProgress: (sent, total) {
            if (total > 0) onProgress(sent / total);
          },
        );
        final result = uploaded.data;
        final url = result?['secure_url'] as String?;
        if (url != null && url.startsWith('https://')) {
          onProgress(1);
          return url;
        }
        throw const MediaUploadException('Cloudinary did not return a secure URL.');
      }
    } on DioException catch (error) {
      if (CancelToken.isCancel(error)) {
        throw const MediaUploadException('Upload canceled.');
      }
      final data = error.response?.data;
      var message = 'Upload failed. Check your connection or paste Cloudinary URL.';
      if (data is Map) {
        if (data['error'] is Map && data['error']['message'] is String) {
          message = data['error']['message'] as String;
        } else if (data['error'] is String) {
          message = data['error'] as String;
        }
      } else if (error.response?.statusCode == 413) {
        message = 'The file is too large for Cloudinary.';
      }

      if (message.toLowerCase().contains('preset') ||
          message.toLowerCase().contains('unsigned')) {
        message =
            'Cloudinary preset error: Create an unsigned preset named "$uploadPreset" in Cloudinary Console ($cloudName), or upload file directly in console and paste the URL here.';
      }

      throw MediaUploadException(message);
    } finally {
      if (identical(_cancelToken, cancelToken)) _cancelToken = null;
    }
  }
}

String? supportedImageMime(Uint8List bytes) {
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

bool supportedMediaFile(String name, Uint8List bytes, {required bool video}) {
  final lower = name.toLowerCase();
  if (!video) {
    final mime = supportedImageMime(bytes);
    return (lower.endsWith('.jpg') || lower.endsWith('.jpeg'))
        ? mime == 'image/jpeg'
        : lower.endsWith('.png')
        ? mime == 'image/png'
        : lower.endsWith('.webp') && mime == 'image/webp';
  }
  final isIsoVideo =
      bytes.length >= 12 && String.fromCharCodes(bytes.sublist(4, 8)) == 'ftyp';
  final isWebm =
      bytes.length >= 4 &&
      bytes[0] == 0x1a &&
      bytes[1] == 0x45 &&
      bytes[2] == 0xdf &&
      bytes[3] == 0xa3;
  return ((lower.endsWith('.mp4') || lower.endsWith('.mov')) && isIsoVideo) ||
      (lower.endsWith('.webm') && isWebm);
}
