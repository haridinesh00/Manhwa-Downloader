import 'package:flutter/material.dart';
import '../models/manhwa_model.dart';
import '../services/storage_service.dart';

class LibraryProvider with ChangeNotifier {
  List<ManhwaModel> _library = [];
  bool _isLoading = true;

  List<ManhwaModel> get library => _library;
  bool get isLoading => _isLoading;

  LibraryProvider() {
    loadLibrary();
  }

  Future<void> loadLibrary() async {
    _isLoading = true;
    notifyListeners();

    _library = await StorageService.getLibrary();
    // Sort by date downloaded descending
    _library.sort((a, b) => b.dateDownloaded.compareTo(a.dateDownloaded));

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addManhwa(ManhwaModel manhwa) async {
    await StorageService.saveManhwa(manhwa);
    await loadLibrary();
  }

  Future<void> deleteManhwa(String id) async {
    await StorageService.deleteManhwa(id);
    await loadLibrary();
  }
}
