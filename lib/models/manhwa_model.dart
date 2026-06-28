import 'dart:convert';

class ManhwaModel {
  final String id;
  final String name;
  final String masterUrl;
  final int totalChapters;
  final String directoryPath;
  final String coverImagePath;
  final DateTime dateDownloaded;

  ManhwaModel({
    required this.id,
    required this.name,
    required this.masterUrl,
    required this.totalChapters,
    required this.directoryPath,
    this.coverImagePath = '',
    required this.dateDownloaded,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'masterUrl': masterUrl,
      'totalChapters': totalChapters,
      'directoryPath': directoryPath,
      'coverImagePath': coverImagePath,
      'dateDownloaded': dateDownloaded.millisecondsSinceEpoch,
    };
  }

  factory ManhwaModel.fromMap(Map<String, dynamic> map) {
    return ManhwaModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      masterUrl: map['masterUrl'] ?? '',
      totalChapters: map['totalChapters']?.toInt() ?? 0,
      directoryPath: map['directoryPath'] ?? map['pdfPath'] ?? '',
      coverImagePath: map['coverImagePath'] ?? '',
      dateDownloaded: DateTime.fromMillisecondsSinceEpoch(map['dateDownloaded'] ?? 0),
    );
  }

  String toJson() => json.encode(toMap());

  factory ManhwaModel.fromJson(String source) => ManhwaModel.fromMap(json.decode(source));
}
