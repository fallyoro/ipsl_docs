import '../models/document.dart';

class DirectoryNode {
  final String name;
  final List<DirectoryNode> subDirectories;
  final List<Document> documents;

  DirectoryNode({
    required this.name,
    this.subDirectories = const [],
    this.documents = const [],
  });

  DirectoryNode copyWith({
    String? name,
    List<DirectoryNode>? subdirectories,
    List<Document>? documents,
  }) {
    return DirectoryNode(
      subDirectories: subdirectories ?? subDirectories,
      name: name ?? this.name,
      documents: documents ?? this.documents,
    );
  }

  bool get hasSubdirectories {
    return subDirectories.isNotEmpty;
  }

  bool get hasDocuments => documents.isNotEmpty;
}
