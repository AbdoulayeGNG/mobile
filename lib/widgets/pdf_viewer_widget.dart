import 'dart:io';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
//import 'package:path/path.dart' as path;

class PDFViewerWidget extends StatefulWidget {
  final String filePath;
  final int initialPage;
  final Function(int page) onPageChanged;

  const PDFViewerWidget({
    Key? key,
    required this.filePath,
    required this.initialPage,
    required this.onPageChanged,
  }) : super(key: key);

  @override
  State<PDFViewerWidget> createState() => _PDFViewerWidgetState();
}

class _PDFViewerWidgetState extends State<PDFViewerWidget> {
  late PdfViewerController _pdfViewerController;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _pdfViewerController = PdfViewerController();
  }

  @override
  void dispose() {
    _pdfViewerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.7,
      child: Stack(
        children: [
          SfPdfViewer.file(
            File(widget.filePath),
            controller: _pdfViewerController,
            onDocumentLoaded: (details) {
              if (!_isInitialized && widget.initialPage > 1) {
                _pdfViewerController.jumpToPage(widget.initialPage);
                _isInitialized = true;
              }
            },
            onPageChanged: (details) {
              widget.onPageChanged(details.newPageNumber);
            },
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(8),
              color: Colors.black54,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left, color: Colors.white),
                    onPressed: () {
                      _pdfViewerController.previousPage();
                    },
                  ),
                  Text(
                    'Page ${_pdfViewerController.pageNumber}',
                    style: const TextStyle(color: Colors.white),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right, color: Colors.white),
                    onPressed: () {
                      _pdfViewerController.nextPage();
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
