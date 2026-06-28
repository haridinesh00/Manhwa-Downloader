import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/download_task.dart';
import '../services/download_service.dart';

class DownloadDialog extends StatefulWidget {
  const DownloadDialog({super.key});

  @override
  State<DownloadDialog> createState() => _DownloadDialogState();
}

class _DownloadDialogState extends State<DownloadDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _urlController = TextEditingController();
  final _startChapterController = TextEditingController(text: '1');
  final _endChapterController = TextEditingController();
  
  bool _isDownloading = false;
  double _progress = 0.0;
  String _status = '';
  String _error = '';

  Future<void> _startDownload() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isDownloading = true;
        _progress = 0.0;
        _status = 'Starting download...';
        _error = '';
      });

      final task = DownloadTask(
        id: const Uuid().v4(),
        manhwaName: _nameController.text.trim(),
        startChapter: int.parse(_startChapterController.text.trim()),
        endChapter: int.parse(_endChapterController.text.trim()),
        batchSize: 1, // Sequential
      );

      try {
        final result = await DownloadService.startSequentialDownload(
          task,
          _urlController.text.trim(),
          (progress, status) {
            if (mounted) {
              setState(() {
                _progress = progress;
                _status = status;
              });
            }
          },
        );

        if (mounted && result != null) {
          Navigator.of(context).pop(true); // Return true to signify success
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${task.manhwaName} downloaded successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isDownloading = false;
            _error = e.toString();
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 
                MediaQuery.of(context).padding.bottom + 16,
        left: 16,
        right: 16,
        top: 24,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'New Download',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                enabled: !_isDownloading,
                decoration: const InputDecoration(
                  labelText: 'Manhwa Name (e.g., Sword Emperor)',
                  border: OutlineInputBorder(),
                ),
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _urlController,
                enabled: !_isDownloading,
                decoration: const InputDecoration(
                  labelText: 'Target Base URL (e.g., https://asurascans.com/...)',
                  border: OutlineInputBorder(),
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Required';
                  if (!val.startsWith('http')) return 'Enter a valid URL';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _startChapterController,
                      enabled: !_isDownloading,
                      decoration: const InputDecoration(
                        labelText: 'Start Chapter',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _endChapterController,
                      enabled: !_isDownloading,
                      decoration: const InputDecoration(
                        labelText: 'End Chapter',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              if (_error.isNotEmpty) ...[
                Text(
                  _error,
                  style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
              ],
              if (_isDownloading) ...[
                LinearProgressIndicator(value: _progress),
                const SizedBox(height: 8),
                Text(
                  _status,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 16),
              ],
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isDownloading ? null : () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _isDownloading ? null : _startDownload,
                    child: _isDownloading 
                        ? const SizedBox(
                            width: 20, 
                            height: 20, 
                            child: CircularProgressIndicator(strokeWidth: 2)
                          )
                        : const Text('Download Now'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
