import 'package:flutter/material.dart';
import 'package:ipsl_docs/core/constant.dart';
import 'package:ipsl_docs/core/notifiers.dart';
import 'package:ipsl_docs/models/document.dart';
import 'package:ipsl_docs/view_models/document.dart';
import 'package:ipsl_docs/views/widgets/documents_list_view.dart';

late final DocumentViewModel viewModel;

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return ValueListenableBuilder<List<Document>>(
      valueListenable: viewModel.documents,
      builder: (context, docs, _) {
        final folders = viewModel.getRootFolders();
        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.2,
          ),
          itemCount: folders.length,
          itemBuilder: (context, index) {
            final folder = folders[index];
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SubfoldersPage(folder: folder),
                  ),
                );
              },
              child: ValueListenableBuilder(
                valueListenable: ThemeController.isDarkModeNotifier,
                builder: (context, isDark, child) {
                  return Card(
                    color:
                        isDark
                            ? AppColors.darkSecondarySystemBackground
                            : AppColors.lightSecondarySystemBackground,
                    elevation: 2,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.folder, size: 48, color: Colors.amber),
                        const SizedBox(height: 12),
                        Text(
                          folder,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}

class SubfoldersPage extends StatelessWidget {
  final String folder;
  const SubfoldersPage({super.key, required this.folder});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(folder)),
      body: ValueListenableBuilder<List<Document>>(
        valueListenable: viewModel.documents,
        builder: (context, docs, _) {
          final subfolders =
              docs
                  .where((doc) => doc.filePath.startsWith('$folder/'))
                  .map((doc) => doc.filePath.split('/')[1])
                  .toSet()
                  .toList();

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.2,
            ),
            itemCount: subfolders.length,
            itemBuilder: (context, index) {
              final subfolder = subfolders[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) => DocumentsPage(
                            folder: folder,
                            subfolder: subfolder,
                          ),
                    ),
                  );
                },
                child: Card(
                  color:
                      Theme.of(context).brightness == Brightness.dark
                          ? AppColors.darkSecondarySystemBackground
                          : AppColors.lightSecondarySystemBackground,
                  elevation: 2,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.folder, size: 48, color: Colors.amber),
                      const SizedBox(height: 12),
                      Text(
                        subfolder,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class DocumentsPage extends StatelessWidget {
  final String folder;
  final String subfolder;
  const DocumentsPage({
    super.key,
    required this.folder,
    required this.subfolder,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //appBar: AppBar(title: Text('$folder/$subfolder')),
      body: ValueListenableBuilder<List<Document>>(
        valueListenable: viewModel.documents,
        builder: (context, docs, _) {
          final docsInSubfolder =
              docs.where((doc) {
                final parts = doc.filePath.split('/');
                return parts.length > 1 &&
                    parts[0] == folder &&
                    parts[1] == subfolder;
              }).toList();

          return DocumentListView(
            folderPath: '$folder/$subfolder',
            documents: docsInSubfolder,
          );
        },
      ),
    );
  }
}
