enum TaskStatus { pending, downloading, stitching, completed, failed }

class DownloadTask {
  final String id;
  final String manhwaName;
  final int startChapter;
  final int endChapter;
  final int batchSize;
  double progress;
  TaskStatus status;

  DownloadTask({
    required this.id,
    required this.manhwaName,
    required this.startChapter,
    required this.endChapter,
    required this.batchSize,
    this.progress = 0.0,
    this.status = TaskStatus.pending,
  });
}
