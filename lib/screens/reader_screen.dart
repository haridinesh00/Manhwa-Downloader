import 'dart:io';
import 'package:flutter/material.dart';
import '../models/manhwa_model.dart';

class ReaderScreen extends StatefulWidget {
  final ManhwaModel manhwa;

  const ReaderScreen({super.key, required this.manhwa});

  @override
  State<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends State<ReaderScreen> {
  List<File> _imageFiles = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadImages();
  }

  Future<void> _loadImages() async {
    final dir = Directory(widget.manhwa.directoryPath);
    if (await dir.exists()) {
      final files = dir.listSync().whereType<File>().toList();
      // Sort alphabetically, which works because we zero-padded chapter and image indices
      files.sort((a, b) => a.path.compareTo(b.path));
      setState(() {
        _imageFiles = files;
      });
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(widget.manhwa.name),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _imageFiles.isEmpty
              ? const Center(
                  child: Text(
                    'No images found',
                    style: TextStyle(color: Colors.white),
                  ),
                )
              : ListView.builder(
                  itemCount: _imageFiles.length,
                  itemBuilder: (context, index) {
                    return Image.file(
                      _imageFiles[index],
                      fit: BoxFit.contain,
                      width: double.infinity,
                    );
                  },
                ),
    );
  }
}
