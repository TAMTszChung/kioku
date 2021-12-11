/*
# COMP 4521    #  PANG, Kit        20606678          kpangaa@connect.ust.hk
# COMP 4521    #  TAM, Tsz Chung        20606173          tctam@connect.ust.hk
*/

import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class CustomImagePicker {
  static Future<Uint8List?> pickMedia({
    required bool isGallery,
    required bool fixRatio,
  }) async {
    final source = isGallery ? ImageSource.gallery : ImageSource.camera;
    final XFile? pickedFile = await ImagePicker().pickImage(source: source);

    if (pickedFile == null) return null;

    final file = File(pickedFile.path);
    return cropImage(file, fixRatio: fixRatio);
  }

  static Future<Uint8List?> cropImage(File file,
      {required bool fixRatio}) async {
    File? croppedFile;
    if (fixRatio) {
      croppedFile = await ImageCropper.cropImage(
        sourcePath: file.path,
        aspectRatio: const CropAspectRatio(ratioX: 210, ratioY: 297),
        aspectRatioPresets: const [],
        compressQuality: 100,
      );
    } else {
      croppedFile = await ImageCropper.cropImage(
          sourcePath: file.path,
          compressQuality: 100,
          androidUiSettings: const AndroidUiSettings(
              initAspectRatio: CropAspectRatioPreset.original,
              lockAspectRatio: false));
    }
    if (croppedFile == null) return null;

    Uint8List data = await croppedFile.readAsBytes();
    int quality = 100;
    while (true) {
      final compressedData = await FlutterImageCompress.compressWithList(data,
          minWidth: 3840, minHeight: 3840, quality: quality);
      if (compressedData.length <= 1677721) {
        data = compressedData;
        break;
      }
      quality -= 20;
      if (quality < 20) {
        throw Exception('Image too large!');
      }
    }
    return data;
  }
}
