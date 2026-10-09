import 'dart:typed_data';

import '../../../core/media/cloudinary_media_service.dart';

String? supportedAvatarMime(Uint8List bytes) => supportedImageMime(bytes);

class AvatarUploadService {
  AvatarUploadService({CloudinaryMediaService? mediaService})
    : _mediaService = mediaService ?? CloudinaryMediaService();

  final CloudinaryMediaService _mediaService;

  Future<String?> pickAndUpload({
    required void Function(double progress) onProgress,
  }) => _mediaService.pickAndUpload(
    purpose: CloudinaryPurpose.avatar,
    onProgress: onProgress,
  );

  void cancel() => _mediaService.cancel();
}
