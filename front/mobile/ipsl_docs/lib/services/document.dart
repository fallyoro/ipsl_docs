import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:ipsl_docs/core/constant.dart';
import 'package:ipsl_docs/core/utils.dart';
import 'package:ipsl_docs/models/document.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;

import 'package:path_provider/path_provider.dart';

final options = BaseOptions(
  baseUrl: 'http://$host:$port/document',
  connectTimeout: Duration(minutes: 1),
  receiveTimeout: Duration(minutes: 1),
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

  /*Future<List<Document>> fetchDocuments() async {
    try {
      final uri = Uri(
        scheme: 'http',
        host: host,
        port: port,
        path: '/document/documents',
      );

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List<dynamic>;

        return data
            .map((json) => Document.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Failed to load documents');
      }
    } catch (e) {
      throw Exception('Failed to fetch documents: $e');
    }
  }*/
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
  }) async {
    final uri = Uri(
      scheme: 'http',
      host: host,
      port: port,
      path: '/document/upload',
    );
    var request = http.MultipartRequest('POST', uri);

    // Champs du formulaire
    request.fields['filename'] = filename;
    request.fields['classe'] = classe;
    request.fields['subject'] = subject;
    request.fields['year'] = year.toString();
    request.fields['categorie'] = categorie;
    request.fields['user_id'] = userId;

    // Fichier à uploader
    request.files.add(
      await http.MultipartFile.fromPath(
        'doc', // DOIT correspondre au paramètre `doc: UploadFile = File(...)`
        file.path,
        filename: p.basename(file.path),
      ),
    );

    var response = await request.send();
    final respStr = await http.Response.fromStream(response);

    if (response.statusCode == 200) {
      logInfo('Success: ${respStr.body}');
      final Map<String, dynamic> jsonResp = jsonDecode(respStr.body);
      return jsonResp['id']?.toString();
    } else {
      logInfo('Error ${response.statusCode}: ${respStr.body}');
      return null;
    }
  }
}








/*Future<File?> downloadPdf(String docId, {Function(double)? onProgress}) async {
  try {
    final uri = Uri(
      scheme: 'http',
      host: host,
      port: port,
      path: '/document/download/$docId', 
    );

    final client = http.Client();
    final request = http.Request('GET', uri);
    final streamed = await client.send(request);

    if (streamed.statusCode != 200) {
      return null;
    }

    final contentLength = streamed.contentLength ?? 0;
    int received = 0;

    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/$docId.pdf');
    final sink = file.openWrite();

    await for (var chunk in streamed.stream) {
      received += chunk.length;
      sink.add(chunk);
      if (onProgress != null && contentLength > 0) {
        onProgress(received / contentLength);
      }
    }

    await sink.close();
    client.close();
    return file;
  } catch (e) {
    return null;
  }
}
*/




/*
Future<File?> downloadPdf(String docId, {Function(double)? onProgress}) async {
  // ... le code que tu as partagé ...
}

// Dans un StatefulWidget :
double progress = 0.0;

void startDownload() async {
  final file = await downloadPdf(docId,
    onProgress: (p) {
      setState(() {
        progress = p; // p est entre 0.0 et 1.0
      });
    }
  );
  if (file != null) {
    // téléchargement terminé
  }
}

@override
Widget build(BuildContext context) {
  return Column(
    children: [
      ElevatedButton(onPressed: startDownload, child: Text("Télécharger PDF")),
      LinearProgressIndicator(value: progress),
      Text('${(progress * 100).toStringAsFixed(0)} %'),
    ],
  );
}
*/

