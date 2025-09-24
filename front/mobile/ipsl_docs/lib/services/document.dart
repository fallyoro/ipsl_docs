import 'dart:io';
import 'package:dio/dio.dart';
import 'package:ipsl_docs/core/constant.dart';
import 'package:ipsl_docs/core/utils.dart';
import 'package:ipsl_docs/models/document.dart';
import 'package:path/path.dart' as p;

import 'package:path_provider/path_provider.dart';

final options = BaseOptions(
  baseUrl: 'http://$host:$port/document',
  connectTimeout: Duration(seconds: 10),
  receiveTimeout: Duration(minutes: 3),
);
final dio = Dio(options);

class DocumentServive {
  final CancelToken _cancelToken = CancelToken();

  void cancelDownload([String? reason]) => _cancelToken.cancel(reason);

  Future<List<Document>> fetchDocuments() async {
    try {
      final response = await dio.get('/documents', cancelToken: _cancelToken);

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
    CancelToken cancelToken,
    void Function(int, int)? onProgress,
  ) async {
    if (cancelToken.isCancelled) {
      cancelToken = CancelToken();
    }
    final baseDir = await getApplicationDocumentsDirectory();
    final dirPart = p.dirname(doc.path);
    final fileName = p.basename(doc.path);
    final docDir = Directory(p.join(baseDir.path, "ipsl_docs", dirPart));
    if (!await docDir.exists()) {
      await docDir.create(recursive: true);
    }
    final savePath = p.join(docDir.path, fileName);
    // logInfo("Where the do is supposed to be saved $savePath");

    try {
      await dio.download(
        "/download/${doc.id}",
        savePath,
        cancelToken: cancelToken,
        onReceiveProgress: onProgress,
        options: Options(
          responseType: ResponseType.bytes,
          followRedirects: false,
        ),
      );
    } on DioException catch (e) {
      if (CancelToken.isCancel(e)) {
        logInfo("Téléchargement annulé : ${e.message}");
      } else {
        throw Exception('Erreur inattendue : $e');
      }
    }
  }

  Future<Map<String, dynamic>?> uploadDocument({
    required File file,
    required String filename,
    required String classe,
    required String subject,
    required String year,
    required String categorie,
    required String userId,
    void Function(int, int)? onProgress,
  }) async {
    final dio = Dio();

    final formData = FormData.fromMap({
      'filename': filename,
      'classe': classe,
      'subject': subject,
      'year': year,
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
        return {
          'id': data['id']?.toString(),
          'number_contribution': data['number_contribution'],
        };
        // return data['id']?.toString();
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
