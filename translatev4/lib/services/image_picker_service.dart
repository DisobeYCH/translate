import 'dart:io';
import 'package:image_picker/image_picker.dart';

class ImagePickerService {
  static Future<File?> pickImageFromGallery() async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (image == null) return null;
      final imageFile = File(image.path);
      return imageFile;
    } catch (e) {
      print('Failed to pick image from gallery: $e');
      return null;
    }
  }

  static Future<File?> pickImageFromCamera() async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.camera);
      if (image == null) return null;
      final imageFile = File(image.path);
      return imageFile;
    } catch (e) {
      print('Failed to pick image from camera: $e');
      return null;
    }
  }
}
