/*
# COMP 4521    #  PANG, Kit        20606678          kpangaa@connect.ust.hk
# COMP 4521    #  TAM, Tsz Chung        20606173          tctam@connect.ust.hk
*/

import 'dart:io';

import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class CustomImagePicker {
  static Future<File?> pickMedia({
    required bool isGallery,
    required bool fixRatio,
  }) async {
    try {
      final source = isGallery ? ImageSource.gallery : ImageSource.camera;
      final XFile? pickedFile = await ImagePicker().pickImage(source: source);

      if (pickedFile == null) return null;

      final file = File(pickedFile.path);
      return cropImage(file, fixRatio: fixRatio);
    } catch (e) {
      rethrow;
    }
  }

  static Future<File?> cropImage(File file,
      {required bool fixRatio, int maxSize = 2097152}) async {
    final fileSize = await file.length();
    final compressRatio =
        fileSize > maxSize ? ((maxSize / fileSize) * 100).floor() : 100;

    File? croppedFile;
    if (fixRatio) {
      croppedFile = await ImageCropper.cropImage(
        sourcePath: file.path,
        aspectRatio: const CropAspectRatio(ratioX: 210, ratioY: 297),
        aspectRatioPresets: const [],
        compressQuality: compressRatio,
      );
    } else {
      croppedFile = await ImageCropper.cropImage(
          sourcePath: file.path,
          compressQuality: compressRatio,
          androidUiSettings: const AndroidUiSettings(
              initAspectRatio: CropAspectRatioPreset.original,
              lockAspectRatio: false));
    }

    return croppedFile;
  }
}
