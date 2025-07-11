class Document {
  final String id;
  final String idUploader;
  final String filename;
  final String categorie;
  final int year;
  final String subject;
  final String classe;
  final bool isLoding;
  bool isDownloading;
  double progress;

  Document({
    required this.id,
    required this.idUploader,
    required this.filename,
    required this.year,
    required this.classe,
    required this.subject,
    required this.categorie,
    this.isLoding = false,
    this.isDownloading = false,
    this.progress = 0,
  });

  factory Document.fromJson(Map<String, dynamic> json) => Document(
    id: json['id'] ?? '',
    idUploader: json['user_id'] ?? '',
    filename: json['filename'] ?? ' ',
    classe: json['classe'] ?? 'pas/de',
    year: json['year'] ?? 'pas/de',
    subject: json['subject'] ?? 'pas/de',
    categorie: json['categorie'] ?? '',

  );

  /*factory Document.fromJsonForDatabase(Map<String, dynamic> json) => Document(
    id: json['id'] ?? '',
    idUploader: json['user_id'] ?? '',
    filename: json['filename'] ?? ' ',
    filePath: json['filePath'] ?? 'pas/de',
    categorie: json['categorie'] ?? '',
    isDownload: json['isDownload'] ?? 0,
  );*/

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': idUploader,
    'filename': filename,
    'classe': classe,
    'year': year,
    'subject': subject,
    'categorie': categorie,
    //'isDownload': isDownload,
  };
}
