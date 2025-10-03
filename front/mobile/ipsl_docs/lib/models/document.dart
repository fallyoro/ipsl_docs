import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

class Document {
  final String id;
  final String idUploader;
  final String path;
  final bool isLoding;
  final ValueNotifier<bool> isDownloading = ValueNotifier(false);
  final ValueNotifier<double> progress = ValueNotifier(0.0);

  Document({
    required this.id,
    required this.path,
    this.isLoding = false,
    required this.idUploader,
  });

  factory Document.fromJson(Map<String, dynamic> json) => Document(
    id: json['id'] ?? '',
    path: json['path'],
    idUploader: json['user_id'] ?? '',
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': idUploader,
    'path': path,
  };

  String get name => path.split("/").last;
}
