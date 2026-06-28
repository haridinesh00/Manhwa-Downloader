import 'package:dio/dio.dart';
import 'package:html/parser.dart' as html_parser;

class ScraperService {
  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 15),
    headers: {
      'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/115.0.0.0 Safari/537.36',
      'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8',
      'Accept-Language': 'en-US,en;q=0.9',
    },
  ));

  /// Extracts image URLs from the chapter page HTML by looking for `<link rel="preload" as="image">`
  Future<List<String>> getChapterImages(String baseUrl, int chapterNumber) async {
    String url = baseUrl.trim();
    try {
      // Normalize URL: Strip any trailing slashes, /chapter suffixes, or chapter numbers
      url = url.replaceFirst(RegExp(r'/chapter(?:/\d*)?/?$'), '');
      
      // Also handle the -chapter-X case just in case
      url = url.replaceFirst(RegExp(r'-chapter-\d+/?$'), '');
      
      // Ensure no trailing slash remains before appending
      if (url.endsWith('/')) {
        url = url.substring(0, url.length - 1);
      }
      
      // Construct the final standard AsuraScans chapter URL
      url = '$url/chapter/$chapterNumber/';

      final response = await _dio.get(url);

      if (response.statusCode == 200) {
        var document = html_parser.parse(response.data);
        List<String> imageUrls = [];
        
        // AsuraScans and similar sites usually put chapter images inside a reader container
        var readerArea = document.querySelector('#readerarea');
        if (readerArea != null) {
          var imgTags = readerArea.querySelectorAll('img');
          for (var img in imgTags) {
            String? src = img.attributes['src'] ?? img.attributes['data-src'];
            if (src != null && src.trim().isNotEmpty) {
              imageUrls.add(src.trim());
            }
          }
        }

        // Fallback: Check for preload links if readerArea wasn't found
        if (imageUrls.isEmpty) {
          var linkTags = document.getElementsByTagName('link');
          for (var link in linkTags) {
            if (link.attributes['rel'] == 'preload' && link.attributes['as'] == 'image') {
              String? href = link.attributes['href'];
              if (href != null && (href.contains('uploads') || href.contains('chapters'))) {
                imageUrls.add(href.trim());
              }
            }
          }
        }

        if (imageUrls.isEmpty) {
          throw Exception('No images found on $url');
        }

        return imageUrls;
      } else {
        throw Exception('Failed to load page: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Dio error on URL "$url": ${e.response?.statusCode} - ${e.message}');
    } catch (e) {
      throw Exception('Scraping error on URL "$url": $e');
    }
  }

  /// Extracts the cover image URL from the root manhwa page
  Future<String?> getCoverImageUrl(String baseUrl) async {
    String url = baseUrl.trim();
    // Remove /chapter or similar suffixes to get the root page
    if (url.contains(RegExp(r'/chapter/?\d*/?$'))) {
      url = url.replaceAll(RegExp(r'/chapter/?\d*/?$'), '/');
    } else if (url.contains(RegExp(r'-chapter-\d+/?$'))) {
      url = url.replaceAll(RegExp(r'-chapter-\d+/?$'), '/');
    }
    
    try {
      final response = await _dio.get(url);
      if (response.statusCode == 200) {
        var document = html_parser.parse(response.data);
        // First, check OpenGraph meta tags which are statically rendered and reliable
        var ogImage = document.querySelector('meta[property="og:image"]');
        if (ogImage != null) {
          String? content = ogImage.attributes['content'];
          if (content != null && content.isNotEmpty) return content;
        }

        // Fallback: Check the cover viewer image tag (often hydrated by JS)
        var coverImg = document.querySelector('img#cover-viewer-img');
        if (coverImg != null) {
          String? src = coverImg.attributes['data-full-src'];
          if (src != null && src.isNotEmpty) return src;
          return coverImg.attributes['src'] ?? coverImg.attributes['data-src'];
        }
        
        // Final fallback: typical WordPress/Manga theme class
        var img = document.querySelector('.wp-post-image');
        if (img != null) {
          return img.attributes['src'] ?? img.attributes['data-src'];
        }
      }
    } catch (_) {
      // Return null silently if cover fetch fails
    }
    return null;
  }

  /// Downloads a single image and returns its raw bytes
  Future<List<int>> downloadImage(String url) async {
    try {
      final response = await _dio.get(
        url,
        options: Options(responseType: ResponseType.bytes),
      );
      return response.data;
    } catch (e) {
      throw Exception('Failed to download image $url: $e');
    }
  }
}
