import 'dart:convert';
import 'dart:io';
import 'package:ipsl_docs/core/constant.dart';
import 'package:ipsl_docs/models/document.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';

class DocumentServive {
  Future<List<Document>> fetchDocuments() async {
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
  }

  Future<void> downloadFile(Document doc) async {
    final uri = Uri(
      scheme: 'http',
      host: host,
      port: port,
      path: '/document/download/${doc.id}',
    );
    final response = await http.get(uri);
    final bytes = response.bodyBytes;
    final dir = await getApplicationDocumentsDirectory();

    final docPath = p.join(dir.path, 'ipsl_docs', doc.filePath, doc.filename);
    final docDir = p.join(dir.path, 'ipsl_docs', doc.filePath);
    final directory = Directory(docDir);
              if (!await directory.exists()) {
                await directory.create(recursive: true);
              }
    final file = File(docPath);
    await file.writeAsBytes(bytes);
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

