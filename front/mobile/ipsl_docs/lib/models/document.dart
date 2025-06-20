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
  /*    __tablename__ = "documents"
    id: UUID = Field(primary_key=True, default_factory=uuid4)
    filename: str
    file_path: str
    file_type: str
    categorie: str
    upload_at: datetime = Field(default_factory= lambda: datetime.now(timezone.utc))
    user_id: UUID = Field(foreign_key="users.id")
    # user: "User" = Relationship(back_populates="documents")*/

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

  /*{
    "filename": "thermo",
    "file_path": "cpi1/thermo/devoirs",
    "file_type": "string",
    "categorie": "string",
    "user_id": "276909f2-4df1-45f7-8681-2bec01d284ac"
  },*/

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': idUploader,
    'filename': filename,
    'filePath': filePath,
    'categorie': categorie,
    //'isDownload': isDownload,
  };
}
