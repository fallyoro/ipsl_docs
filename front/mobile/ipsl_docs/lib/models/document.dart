class Document {
  final int id;
  final String idUploader;
  final String filename;
  final String filePath;
  final String categorie;
  final int isDownload;

  Document({
    required this.id,
    required this.idUploader,
    required this.filename,
    required this.filePath,
    required this.categorie,
    required this.isDownload
  });

  factory Document.fromJson(Map<String, dynamic> json) => Document(
    id: json['id'],
    idUploader: json['id_Uploader'],
    filename: json['filename'],
    filePath: json['filePath'],
    categorie: json['categorie'],
    isDownload: json['isDownload'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'id_Uploader': idUploader,
    'filename': filename,
    'filePath': filePath,
    'categorie': categorie,
    'isDownload': isDownload ,
  };
}
