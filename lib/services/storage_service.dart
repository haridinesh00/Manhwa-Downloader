import 'package:shared_preferences/shared_preferences.dart';
import '../models/manhwa_model.dart';

class StorageService {
  static const String _libraryKey = 'manhwa_library';

  static Future<void> saveManhwa(ManhwaModel manhwa) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> libraryStr = prefs.getStringList(_libraryKey) ?? [];
    
    // Check if it already exists, update it if so
    int index = libraryStr.indexWhere((element) {
      final m = ManhwaModel.fromJson(element);
      return m.id == manhwa.id;
    });

    if (index != -1) {
      libraryStr[index] = manhwa.toJson();
    } else {
      libraryStr.add(manhwa.toJson());
    }

    await prefs.setStringList(_libraryKey, libraryStr);
  }

  static Future<List<ManhwaModel>> getLibrary() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    List<String> libraryStr = prefs.getStringList(_libraryKey) ?? [];
    
    return libraryStr.map((str) => ManhwaModel.fromJson(str)).toList();
  }

  static Future<void> deleteManhwa(String id) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> libraryStr = prefs.getStringList(_libraryKey) ?? [];
    
    libraryStr.removeWhere((element) {
      final m = ManhwaModel.fromJson(element);
      return m.id == id;
    });

    await prefs.setStringList(_libraryKey, libraryStr);
  }
}
