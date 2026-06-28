import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../providers/library_provider.dart';
import '../widgets/download_dialog.dart';
import 'reader_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _requestPermissions();
    });
  }

  Future<void> _requestPermissions() async {
    await [
      Permission.storage,
      Permission.manageExternalStorage,
      Permission.notification,
    ].request();
  }

  Future<void> _showDownloadDialog(BuildContext context) async {
    final success = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      builder: (_) => const DownloadDialog(),
    );

    if (success == true && context.mounted) {
      context.read<LibraryProvider>().loadLibrary();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Manhwa Library'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<LibraryProvider>().loadLibrary();
            },
          )
        ],
      ),
      body: Consumer<LibraryProvider>(
        builder: (context, libraryProvider, child) {
          if (libraryProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (libraryProvider.library.isEmpty) {
            return const Center(
              child: Text(
                'No downloaded manhwas yet.\nTap + to begin.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.65,
              crossAxisSpacing: 12,
              mainAxisSpacing: 16,
            ),
            itemCount: libraryProvider.library.length,
            itemBuilder: (context, index) {
              final manhwa = libraryProvider.library[index];
              final hasCover = manhwa.coverImagePath.isNotEmpty && File(manhwa.coverImagePath).existsSync();

              return GestureDetector(
                onTap: () {
                  if (Directory(manhwa.directoryPath).existsSync()) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => ReaderScreen(manhwa: manhwa)),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Images not found!')),
                    );
                  }
                },
                child: Card(
                  clipBehavior: Clip.antiAlias,
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Cover Image Background
                      if (hasCover)
                        Image.file(
                          File(manhwa.coverImagePath),
                          fit: BoxFit.cover,
                        )
                      else
                        Container(
                          color: Colors.grey[800],
                          child: const Icon(Icons.book, size: 64, color: Colors.white54),
                        ),
                      
                      // Gradient Overlay for Text Readability
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.black87, Colors.transparent],
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                            ),
                          ),
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                manhwa.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${manhwa.totalChapters} Chapters',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      // Delete Button
                      Positioned(
                        top: 4,
                        right: 4,
                        child: Material(
                          color: Colors.black54,
                          shape: const CircleBorder(),
                          child: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.white, size: 20),
                            onPressed: () {
                              libraryProvider.deleteManhwa(manhwa.id);
                              final dir = Directory(manhwa.directoryPath);
                              if (dir.existsSync()) {
                                dir.deleteSync(recursive: true);
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showDownloadDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
