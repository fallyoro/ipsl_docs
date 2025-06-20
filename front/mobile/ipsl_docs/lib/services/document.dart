import 'dart:convert';

import 'package:ipsl_docs/core/constant.dart';
import 'package:ipsl_docs/models/document.dart';
import 'package:http/http.dart' as http;

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
            .toList(); // ✅ important
      } else {
        throw Exception('Failed to load documents');
      }
    } catch (e) {
      throw Exception('Failed to fetch documents: $e');
    }
  }
}
