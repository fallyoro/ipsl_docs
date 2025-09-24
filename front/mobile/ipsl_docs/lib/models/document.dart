import 'package:flutter/material.dart';

class Document {
  final String id;
  final String idUploader;
  final String path;
  final bool isLoding;
  bool? isDir;
  final ValueNotifier<bool> isDownloading = ValueNotifier(false);
  final ValueNotifier<double> progress = ValueNotifier(0.0);

  Document({
    required this.id,
    required this.path,
    this.isLoding = false,
    this.isDir,
    required this.idUploader,
  });

  factory Document.fromJson(Map<String, dynamic> json) => Document(
    id: json['id'] ?? '',
    isDir: null,
    path: json['path'],
    idUploader: json['user_id'] ?? '',
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': idUploader,
    'path': path,
  };
}
