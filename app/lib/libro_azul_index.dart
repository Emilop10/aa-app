import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class LibroAzulIndex extends StatelessWidget {
  final PdfViewerController pdfViewerController;

  LibroAzulIndex(this.pdfViewerController);

  final List<Map<String, dynamic>> chapters = [
    {"title": "Capítulo 1: La Historia de Bill", "page": 13},
    {"title": "Capítulo 2: Hay Una Solución", "page": 27},
    {"title": "Capítulo 3: El Alcoholismo", "page": 37},
    {"title": "Capítulo 4: Nosotros, los Agnósticos", "page": 49},
    {"title": "Capítulo 5: Nuestro Programa", "page": 60},
    {"title": "Capítulo 6: A la Acción", "page": 73},
    {"title": "Capítulo 7: Trabajando Con Otros", "page": 87},
    {"title": "Capítulo 8: A las Esposas", "page": 99},
    {"title": "Capítulo 9: La Familia y la Recuperación", "page": 113},
    {"title": "Capítulo 10: A los Empleadores", "page": 125},
    {"title": "Capítulo 11: La Vida que le espera", "page": 137},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Índice del Libro Azul'),
        backgroundColor: Color(0xFF023E8A), // Asegura que el AppBar use el color azul
      ),
      body: Container(
        color: Color(0xFF023E8A),  // Asegura que el fondo sea azul
        child: ListView.builder(
          itemCount: chapters.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(
                chapters[index]['title'],
                style: TextStyle(color: Colors.white),  // Cambia el color del texto a blanco
              ),
              onTap: () {
                Navigator.pop(context);  // Cierra la pantalla de índice
                pdfViewerController.jumpToPage(chapters[index]['page']);
              },
            );
          },
        ),
      ),
    );
  }
}
