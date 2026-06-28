import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../models/download_task.dart';
import '../models/manhwa_model.dart';
import 'scraper_service.dart';
import 'storage_service.dart';

class DownloadService {
  /// Downloads images for a manhwa sequentially on the main isolate.
  /// Reports progress via [onProgress].
  static Future<ManhwaModel?> startSequentialDownload(
    DownloadTask task,
    String baseUrl,
    void Function(double progress, String status) onProgress,
  ) async {
    final scraper = ScraperService();
    final int totalChapters = task.endChapter - task.startChapter + 1;
    
    final appDir = await getApplicationDocumentsDirectory();
    final manhwaDir = Directory('${appDir.path}/${task.manhwaName}');
    if (!await manhwaDir.exists()) {
      await manhwaDir.create(recursive: true);
    }

    try {
      int processedChapters = 0;

      for (int currentChapter = task.startChapter; currentChapter <= task.endChapter; currentChapter++) {
        // Fetch image URLs for this chapter
        onProgress(
          processedChapters / totalChapters,
          'Fetching chapter $currentChapter links...',
        );
        
        List<String> imageUrls = await scraper.getChapterImages(baseUrl, currentChapter);
        
        if (imageUrls.isEmpty) {
          throw Exception('No images found for chapter $currentChapter');
        }

        // Download images sequentially
        for (int imgIdx = 0; imgIdx < imageUrls.length; imgIdx++) {
          String url = imageUrls[imgIdx];
          onProgress(
            processedChapters / totalChapters,
            'Downloading Ch $currentChapter (Image ${imgIdx + 1}/${imageUrls.length})...',
          );
          
          List<int> bytes = await scraper.downloadImage(url);
          
          // Ensure zero-padded index for correct chronological sorting later
          String paddedChapter = currentChapter.toString().padLeft(4, '0');
          String paddedImage = imgIdx.toString().padLeft(3, '0');
          
          File imgFile = File('${manhwaDir.path}/ch${paddedChapter}_img$paddedImage.jpg');
          await imgFile.writeAsBytes(bytes, flush: true);
        }
        
        processedChapters++;
        onProgress(
          processedChapters / totalChapters,
          'Chapter $currentChapter finished.',
        );
      }
      
      // Fetch cover image
      onProgress(1.0, 'Fetching cover image...');
      String coverImagePath = '';
      try {
        final coverUrl = await scraper.getCoverImageUrl(baseUrl);
        if (coverUrl != null && coverUrl.isNotEmpty) {
          final coverBytes = await scraper.downloadImage(coverUrl);
          final coverFile = File('${manhwaDir.path}/cover.jpg');
          await coverFile.writeAsBytes(coverBytes, flush: true);
          coverImagePath = coverFile.path;
        }
      } catch (e) {
        debugPrint('Failed to fetch cover image: $e');
      }
      
      // Save metadata
      final model = ManhwaModel(
        id: const Uuid().v4(),
        name: task.manhwaName,
        masterUrl: baseUrl,
        totalChapters: totalChapters,
        directoryPath: manhwaDir.path,
        coverImagePath: coverImagePath,
        dateDownloaded: DateTime.now(),
      );
      
      await StorageService.saveManhwa(model);
      
      onProgress(1.0, 'Download Complete!');
      return model;
      
    } catch (e) {
      onProgress(0.0, 'Error: $e');
      // Clean up directory on failure
      try {
        if (await manhwaDir.exists()) {
          await manhwaDir.delete(recursive: true);
        }
      } catch (_) {}
      rethrow;
    }
  }
}
