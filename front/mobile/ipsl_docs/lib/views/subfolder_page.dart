import 'package:flutter/material.dart';
import 'package:ipsl_docs/core/constant.dart';
import 'package:ipsl_docs/models/document.dart';
import 'package:ipsl_docs/views/home.dart';

class SubfoldersPage extends StatelessWidget {
  final String folder;
  const SubfoldersPage({super.key, required this.folder});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
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
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 250,

              crossAxisSpacing: 24,
              mainAxisSpacing: 24,
              childAspectRatio: 1.1,
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
                      Icon(
                        Icons.folder,
                        color: Colors.amber,
                        size: screenWidth < 600 ? 60 : 76,
                      ),
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
