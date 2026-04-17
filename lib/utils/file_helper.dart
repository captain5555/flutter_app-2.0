import 'dart:io';
import 'package:path_provider/path_provider.dart';

class FileHelper {
  static Future<String> getLocalPath() async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  static Future<File> getLocalFile(String filename) async {
    final path = await getLocalPath();
    return File('$path/$filename');
  }

  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  static String getFileExtension(String filename) {
    return filename.split('.').last.toLowerCase();
  }

  static bool isImageFile(String filename) {
    final ext = getFileExtension(filename);
    return ['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(ext);
  }

  static bool isVideoFile(String filename) {
    final ext = getFileExtension(filename);
    return ['mp4', 'mov', 'avi', 'mkv', 'webm'].contains(ext);
  }
}
