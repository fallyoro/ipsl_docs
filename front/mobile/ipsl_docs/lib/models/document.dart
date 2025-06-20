class Document {
  final String id;
  final String idUploader;
  final String filename;
  final String filePath;
  final String categorie;
  final int isDownload;
  final bool isLoding;

  Document({
    required this.id,
    required this.idUploader,
    required this.filename,
    required this.filePath,
    required this.categorie,
    this.isDownload = 0,
    this.isLoding = false
  });
 

  factory Document.fromJson(Map<String, dynamic> json) => Document(
  id: json['id'] ?? '',
  idUploader: json['user_id'] ?? '',
  filename: json['filename'] ?? ' ',
  filePath: json['file_path'] ?? 'pas/de',
  categorie: json['categorie'] ?? '',
  isDownload: json['isDownload'] ?? 0
);

factory Document.fromJsonForDatabase(Map<String, dynamic> json) => Document(
  id: json['id'] ?? '',
  idUploader: json['user_id'] ?? '',
  filename: json['filename'] ?? ' ',
  filePath: json['filePath'] ?? 'pas/de',
  categorie: json['categorie'] ?? '',
  isDownload: json['isDownload'] ?? 0
);



  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': idUploader,
    'filename': filename,
    'filePath': filePath,
    'categorie': categorie,
    //'isDownload': isDownload,
  };
}
