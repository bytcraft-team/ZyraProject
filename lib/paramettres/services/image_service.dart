import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

class ImageService {
  static final ImagePicker _picker = ImagePicker();

  // 📷 from gallery
  static Future<String?> pickImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (image == null) return null;

    return _saveFile(image);
  }

  // 📷 from camera
  static Future<String?> takePhoto() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );

    if (image == null) return null;

    return _saveFile(image);
  }

  // 💾 save locally
  static Future<String> _saveFile(XFile image) async {
    final dir = await getApplicationDocumentsDirectory();
    final fileName = basename(image.path);

    final File newImage =
        await File(image.path).copy('${dir.path}/$fileName');

    return newImage.path;
  }

  // 🗑️ delete image
  static Future<void> deleteImage(String? path) async {
    if (path == null) return;

    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }
}