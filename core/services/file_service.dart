import 'dart:io';
import 'dart:math' as math;

import 'package:image/image.dart' as img;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class FileService {
  /// Compresses [file] as JPEG.
  ///
  /// When [maxBytes] is set, quality is reduced until the file fits (or min quality).
  /// When [maxWidth] is set, the longest side is scaled down before encoding.
  Future<File?> compressImage(
    File file, {
    int quality = 80,
    int? maxBytes,
    int maxWidth = 1920,
  }) async {
    try {
      final bytes = await file.readAsBytes();
      var decodedImage = img.decodeImage(bytes);

      if (decodedImage == null) return null;

      if (decodedImage.width > maxWidth || decodedImage.height > maxWidth) {
        final scale =
            maxWidth / math.max(decodedImage.width, decodedImage.height);
        decodedImage = img.copyResize(
          decodedImage,
          width: (decodedImage.width * scale).round(),
          height: (decodedImage.height * scale).round(),
          interpolation: img.Interpolation.linear,
        );
      }

      var currentQuality = quality.clamp(10, 100);
      List<int> compressedBytes = img.encodeJpg(
        decodedImage,
        quality: currentQuality,
      );

      if (maxBytes != null) {
        while (compressedBytes.length > maxBytes && currentQuality > 20) {
          currentQuality = math.max(20, currentQuality - 15);
          compressedBytes = img.encodeJpg(
            decodedImage,
            quality: currentQuality,
          );
        }
      }

      final tempDir = await getTemporaryDirectory();
      final fileName = path.basenameWithoutExtension(file.path);
      final newPath = path.join(
        tempDir.path,
        '${fileName}_compressed_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );

      final compressedFile = File(newPath);
      await compressedFile.writeAsBytes(compressedBytes);

      return compressedFile;
    } catch (e) {
      return null;
    }
  }
}
