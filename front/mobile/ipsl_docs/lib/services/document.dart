import 'dart:io';
import 'package:dio/dio.dart';
import 'package:ipsl_docs/core/constant.dart';
import 'package:ipsl_docs/core/utils.dart';
import 'package:ipsl_docs/models/document.dart';
import 'package:path/path.dart' as p;

import 'package:path_provider/path_provider.dart';

final options = BaseOptions(
  baseUrl: 'http://$host:$port/document',
  connectTimeout: Duration(minutes: 1),
  receiveTimeout: Duration(minutes: 10),
);
final dio = Dio(options);

class DocumentServive {
  Future<List<Document>> fetchDocuments() async {
    try {
      final response = await dio.get('/documents');

      if (response.statusCode == 200) {
        final data = response.data as List;
        return data
            .map((json) => Document.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception("Faild to load documents");
      }
    } on DioException catch (e) {
      throw Exception(" Failed to fetch document. Error: $e");
    } catch (e) {
      throw Exception("Error unexpected: $e");
    }
  }

  Future<void> downloadFile(
    Document doc,
    void Function(int, int)? onProgress,
  ) async {
    final baseDir = await getApplicationDocumentsDirectory();
    final docDir = Directory(
      p.join(
        baseDir.path,
        "ipsl_docs",
        doc.classe,
        doc.year.toString(),
        doc.subject,
        doc.categorie,
      ),
    );
    if (!await docDir.exists()) {
      await docDir.create(recursive: true);
    }
    final savePath = p.join(docDir.path, doc.filename);
    logInfo("Where the do is supposed to be saved $savePath");

    try {
      await dio.download(
        "/download/${doc.id}",
        savePath,
        onReceiveProgress: onProgress,
        options: Options(
          responseType: ResponseType.bytes,
          followRedirects: false,
        ),
      );
    } on DioException catch (e) {
      throw Exception("Failed to download the document: $e");
    } catch (e) {
      throw Exception("Erreur unexpected: $e");
    }
  }

  Future<String?> uploadDocument({
    required File file,
    required String filename,
    required String classe,
    required String subject,
    required int year,
    required String categorie,
    required String userId,
    void Function(int, int)? onProgress,
  }) async {
    final dio = Dio();

    final formData = FormData.fromMap({
      'filename': filename,
      'classe': classe,
      'subject': subject,
      'year': year.toString(),
      'categorie': categorie,
      'user_id': userId,
      'doc': await MultipartFile.fromFile(
        file.path,
        filename: p.basename(file.path),
      ),
    });

    try {
      final response = await dio.post(
        'http://$host:$port/document/upload',
        data: formData,
        onSendProgress: onProgress,
      );

      if (response.statusCode == 200 && response.data is Map) {
        final data = response.data as Map<String, dynamic>;
        logInfo('Success: ${response.data}');
        return data['id']?.toString();
      } else {
        logInfo('Erreur ${response.statusCode}: ${response.data}');
        return null;
      }
    } catch (e) {
      logInfo('Exception: $e');
      return null;
    }
  }
}







