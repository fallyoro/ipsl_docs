import 'package:flutter/material.dart';
import 'package:ipsl_docs/database/database.dart';
import 'package:ipsl_docs/models/document.dart';
import 'package:ipsl_docs/view_models/document.dart';
import 'package:ipsl_docs/views/widgets/documents_list_view.dart';

//final viewModel = DocumentViewModel(sqlite);
late final DocumentViewModel viewModel;
//final bool isLoding;

class Home extends StatefulWidget {
  //final DocumentViewModel viewModel;

  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool isLoading = true;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    //_setup();
  }

  Future<void> _setup() async {
    final sqlite = await SQLiteService.init(); // 🔄 instance prête
    viewModel = DocumentViewModel(sqlite);
    await viewModel.loadDocuments();

    setState(() {
      isLoading = false;
    });
  }

  /* Future<void> _setup() async {
    final sqlite = SQLiteService();
    await sqlite.init();
    final dir = await getApplicationDocumentsDirectory();

    logInfo('📁 DB path: ${dir.path}/ipsl_docs.db');

    print("===========================================================");
    sqlite.insertMockData();
    await viewModel.loadDocuments();
  }*/

  Widget build(BuildContext context) {
    /*if (isLoading) {
      // ✅ Affichage d’un loader pendant l’init
      return const Center(child: CircularProgressIndicator());
    }*/

    return ValueListenableBuilder<List<Document>>(
      valueListenable: viewModel.documents,
      builder: (context, docs, _) {
        final folders = viewModel.getRootFolders();
        return ListView.builder(
          itemCount: folders.length,
          itemBuilder: (context, index) {
            final folder = folders[index];
            return ListTile(
              leading: const Icon(Icons.folder),
              title: Text(folder),
              onTap: () {
                final docsInFolder =
                    docs
                        .where((doc) => doc.filePath.split('/').first == folder)
                        .toList();

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => DocumentListView(
                          folderPath: folder,
                          documents: docsInFolder,
                        ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
