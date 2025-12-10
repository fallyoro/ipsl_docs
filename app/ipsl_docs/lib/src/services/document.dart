import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dartz/dartz.dart';
import 'package:ipsl_docs/src/core/failure.dart';
import '../core/network_exception.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../core/utils.dart';
import '../models/document.dart';

final dio = Dio(options);
final options = BaseOptions(
  baseUrl: '$baseUrl/document',
  connectTimeout: Duration(seconds: 3),
  receiveTimeout: Duration(minutes: 3),
  sendTimeout: Duration(minutes: 5),
);
final String baseUrl = dotenv.env['API_BASE_URL'] as String;

class DocumentService {
  final CancelToken _cancelToken = CancelToken();

  void cancelDownload([String? reason]) => _cancelToken.cancel(reason);

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

  Future<List<Map<String, dynamic>>> fetchRawDocuments() async {
    try {
      final response = await dio.get('/documents', cancelToken: _cancelToken);

      if (response.statusCode == 200) {
        final data = response.data as List;
        return data.map((json) => json as Map<String, dynamic>).toList();
      } else {
        throw Exception("Faild to load documents");
      }
    } on DioException catch (e) {
      throw Exception(" Failed to fetch document. Error: $e");
    } catch (e) {
      throw Exception("Error unexpected: $e");
    }
  }

  Future<Either<NetworkFailure, Map<String, dynamic>>> uploadDocument({
    required File file,
    required String path,

    required String userId,
    void Function(int, int)? onProgress,
  }) async {
    final formData = FormData.fromMap({
      'path': path,
      'user_id': userId,
      'doc': await MultipartFile.fromFile(
        file.path,
        filename: p.basename(file.path),
      ),
    });

    try {
      final response = await dio.post(
        '$baseUrl/document/upload',
        data: formData,
        onSendProgress: onProgress,
      );

      final data = response.data as Map<String, dynamic>;
      logInfo('Success: ${response.data}');
      return Right({
        'id': data['id']?.toString(),
        'number_contribution': data['number_contribution'],
        'updated_at': data['updated_at']?.toString(),
      });
    } on DioException catch (e) {
      final error = NetworkException.fromDioError(e);
      return Left(NetworkFailure(error.message));
    } catch (e) {
      return Left(NetworkFailure("Erreur réseau ou inconnue : $e"));
    }
  }
}
