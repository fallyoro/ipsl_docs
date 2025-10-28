import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class Document {
  final String id;
  final String idUploader;
  final String path;
  final bool isLoding;
  final ValueNotifier<bool> isDownloading = ValueNotifier(false);
  final ValueNotifier<double> progress = ValueNotifier(0.0);
  final DateTime updatedAt;

  Document({
    required this.id,
    required this.path,
    this.isLoding = false,
    required this.idUploader,
    required this.updatedAt,
  });

  factory Document.fromJson(Map<String, dynamic> json) => Document(
    id: json['id'] ?? '',
    path: json['path'],
    idUploader: json['user_id'] ?? '',
    updatedAt: DateTime.parse(json['updated_at'] as String),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': idUploader,
    'path': path,
    'updated_at': updatedAt.toIso8601String(),
  };

  String get name => path.split("/").last;

  String get extension => p.extension(name).replaceFirst('.', '');

  Future<String> get localPath async {
    final baseDir = await getApplicationDocumentsDirectory();
    final docDir = Directory(
      p.join(baseDir.path, "ipsl_docs", p.dirname(path)),
    );
    final savePath = p.join(docDir.path, name);
    return savePath;
  }
}
