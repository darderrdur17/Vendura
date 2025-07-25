import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class ImageService {
  /// Saves the given [image] file to the app's documents directory under an
  /// `images/` sub-folder and returns the new file path.
  static Future<String> saveImage(File image) async {
    final appDir = await getApplicationDocumentsDirectory();
    final imagesDir = Directory(p.join(appDir.path, 'images'));
    if (!await imagesDir.exists()) {
      await imagesDir.create(recursive: true);
    }

    final ext = p.extension(image.path);
    final fileName = '${const Uuid().v4()}$ext';
    final newPath = p.join(imagesDir.path, fileName);

    final newFile = await image.copy(newPath);
    return newFile.path;
  }

  /// Deletes the image at the provided [path] if it exists.
  static Future<void> deleteImage(String path) async {
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }
} 