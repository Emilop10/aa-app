import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'libro_azul_index.dart';

class LibroAzulScreen extends StatefulWidget {
  const LibroAzulScreen({Key? key}) : super(key: key);

  @override
  _LibroAzulScreenState createState() => _LibroAzulScreenState();
}

class _LibroAzulScreenState extends State<LibroAzulScreen> {
  final PdfViewerController _pdfViewerController = PdfViewerController();
  int _lastPage = 1; // Página predeterminada si no hay una página guardada.

  @override
  void initState() {
    super.initState();
    _initializeLastPage(); // Inicializa la última página guardada.
  }

  Future<void> _initializeLastPage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int savedPage = prefs.getInt('lastPageLibroAzul') ?? 1; // Predeterminado a la página 1.
    setState(() {
      _lastPage = savedPage;
    });

    // Mueve el visor a la última página después de cargar.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _pdfViewerController.jumpToPage(savedPage);
    });
  }

  Future<void> _saveLastPage(int page) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('lastPageLibroAzul', page);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Libro Azul'),
        actions: [
          IconButton(
            icon: const Icon(Icons.list),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LibroAzulIndex(_pdfViewerController),
                ),
              );
            },
            tooltip: 'Ver Índice',
          ),
        ],
      ),
      body: SfPdfViewer.asset(
        'assets/libro_azul.pdf',
        controller: _pdfViewerController,
        onPageChanged: (PdfPageChangedDetails details) {
          _saveLastPage(details.newPageNumber); // Guarda la página actual.
        },
        onDocumentLoadFailed: (details) {
          _showErrorDialog(context, 'Error al cargar el PDF: ${details.description}');
        },
      ),
    );
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Error',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
