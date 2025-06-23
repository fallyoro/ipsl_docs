import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:ipsl_docs/core/Responsive.dart';
import 'package:ipsl_docs/core/constant.dart';
import 'package:ipsl_docs/core/notifiers.dart';
import 'package:ipsl_docs/models/document.dart';
import 'package:ipsl_docs/view_models/document.dart';
import 'package:ipsl_docs/views/subfolder_page.dart';
import 'package:ipsl_docs/views/widgets/documents_list_view.dart';

final viewModel = GetIt.I<DocumentViewModel>();

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool isLoading = false;
  Responsive responsive = Responsive();

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return ValueListenableBuilder<List<Document>>(
      valueListenable: viewModel.documents,
      builder: (context, docs, _) {
        final folders = viewModel.getRootFolders();
        // Use a responsive crossAxisCount based on screen width

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 250,

            crossAxisSpacing: 24,
            mainAxisSpacing: 24,
            childAspectRatio: 1.1,
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
                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),

                      color:
                          isDark
                              ? AppColors.darkSecondarySystemBackground
                              : AppColors.lightSecondarySystemBackground,
                    ),

                    // elevation: 2,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.folder,
                          size: screenWidth < 600 ? 60 : 76,
                          color: Colors.amber,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          folder,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: screenWidth < 600 ? 14 : 20,
                          ),
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
