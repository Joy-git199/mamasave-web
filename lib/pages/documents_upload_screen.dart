// lib/pages/documents_upload_screen.dart

import 'package:flutter/material.dart';
import 'package:mamasave/utils/app_colors.dart';
import 'package:mamasave/utils/app_styles.dart';
import 'package:mamasave/widgets/custom_snackbar.dart';

// The DocumentsUploadScreen allows users to upload and view health-related documents.
class DocumentsUploadScreen extends StatefulWidget {
  const DocumentsUploadScreen({super.key});

  @override
  State<DocumentsUploadScreen> createState() => _DocumentsUploadScreenState();
}

class _DocumentsUploadScreenState extends State<DocumentsUploadScreen> {
  // Mock list of uploaded documents
  final List<Map<String, String>> _uploadedDocuments = [
    {'name': 'Antenatal Card.pdf', 'date': '2023-01-15'},
    {'name': 'Ultrasound Scan (Week 12).jpg', 'date': '2023-03-01'},
    {'name': 'Blood Test Results.pdf', 'date': '2023-04-10'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('My Documents & Records'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Manage Your Health Documents',
              style: AppStyles.headline2
                  .copyWith(color: Theme.of(context).primaryColor),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Upload and keep track of all your important health records, scans, and reports securely.',
              style: AppStyles.bodyText1.copyWith(
                  color: Theme.of(context).textTheme.bodyLarge?.color),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  CustomSnackBar.showInfo(
                      context, 'Document upload functionality coming soon!');
                  // TODO: Implement actual document upload logic
                },
                icon: Icon(Icons.cloud_upload_outlined,
                    size: 24,
                    color: Theme.of(context)
                        .elevatedButtonTheme
                        .style
                        ?.foregroundColor
                        ?.resolve(MaterialState.values.toSet())),
                label: Text('Upload New Document',
                    style: AppStyles.buttonTextStyle),
                style: AppStyles.primaryButtonStyle.copyWith(
                  padding: MaterialStateProperty.all(
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 15)),
                ),
              ),
            ),
            const SizedBox(height: 32),
            _buildSectionTitle(
                'Uploaded Documents', Icons.folder_open, context),
            const SizedBox(height: 16),
            _uploadedDocuments.isEmpty
                ? Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: AppStyles.cardDecoration(context),
                    child: Center(
                      child: Text(
                        'No documents uploaded yet.',
                        style: AppStyles.bodyText2.copyWith(
                            fontStyle: FontStyle.italic,
                            color:
                                Theme.of(context).textTheme.bodyMedium?.color),
                      ),
                    ),
                  )
                : Container(
                    decoration: AppStyles.cardDecoration(context),
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _uploadedDocuments.length,
                      itemBuilder: (context, index) {
                        final doc = _uploadedDocuments[index];
                        return ListTile(
                          leading: Icon(Icons.insert_drive_file,
                              color: Theme.of(context).listTileTheme.iconColor),
                          title: Text(doc['name']!,
                              style: AppStyles.bodyText1.copyWith(
                                  color: Theme.of(context)
                                      .listTileTheme
                                      .textColor)), // Corrected
                          subtitle: Text('Uploaded: ${doc['date']}',
                              style: Theme.of(context).textTheme.bodyMedium),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.visibility_outlined,
                                    color: Theme.of(context)
                                        .iconTheme
                                        .color
                                        ?.withOpacity(0.7)),
                                onPressed: () {
                                  CustomSnackBar.showInfo(context,
                                      'Viewing document: ${doc['name']} (simulated).');
                                  // TODO: Implement document viewing logic
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.delete_outline,
                                    color: AppColors.dangerColor),
                                onPressed: () {
                                  setState(() {
                                    _uploadedDocuments.removeAt(index);
                                  });
                                  CustomSnackBar.showInfo(context,
                                      'Document deleted: ${doc['name']}.');
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // Builds a section title with an icon.
  Widget _buildSectionTitle(String title, IconData icon, BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Theme.of(context).primaryColor, size: 28),
        const SizedBox(width: 10),
        Text(
          title,
          style: AppStyles.headline3
              .copyWith(color: Theme.of(context).textTheme.displaySmall?.color),
        ),
      ],
    );
  }
}
