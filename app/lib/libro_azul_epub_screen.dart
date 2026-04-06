import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show ByteData, rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:vocsy_epub_viewer/epub_viewer.dart';

// Ya no necesitamos SharedPreferences porque el lector lo maneja todo.

class LibroAzulEpubScreen extends StatefulWidget {
  const LibroAzulEpubScreen({super.key});

  @override
  State<LibroAzulEpubScreen> createState() => _LibroAzulEpubScreenState();
}

class _LibroAzulEpubScreenState extends State<LibroAzulEpubScreen> {

  // ¡CAMBIO CLAVE! Hemos eliminado el 'StreamSubscription' y toda la lógica
  // de 'initState' y 'dispose' que escuchaba la ubicación.

  @override
  void initState() {
    super.initState();
    // Abrimos el libro tan pronto como la pantalla se carga.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _openBookFromTempDir(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    // La pantalla ahora solo muestra un indicador de carga mientras abre el libro.
    return Scaffold(
      appBar: AppBar(
        title: const Text("Abriendo Libro..."),
      ),
      body: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Future<void> _openBookFromTempDir(BuildContext context) async {
    try {
      final Directory tempDir = await getTemporaryDirectory();
      final String tempPath = '${tempDir.path}/libro_azul.epub';
      final File tempFile = File(tempPath);

      if (!await tempFile.exists()) {
        final ByteData data = await rootBundle.load('assets/libro_azul.epub');
        await tempFile.writeAsBytes(
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
        );
      }
      
      // Ya no necesitamos leer la última ubicación, el lector lo hará solo.

      VocsyEpub.setConfig(
        themeColor: Theme.of(context).primaryColor,
        identifier: "libroAzul", // El lector usa esto para recordar la posición.
        scrollDirection: EpubScrollDirection.ALLDIRECTIONS,
        allowSharing: true,
        enableTts: true,
      );

      // ¡CAMBIO CLAVE! Llamamos a 'open' sin el parámetro 'lastLocation'.
      VocsyEpub.open(tempPath);
      
      if (mounted) {
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted) {
            Navigator.of(context).pop();
          }
        });
      }

    } catch (e) {
      print('Error al abrir el libro: $e');
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo abrir el libro.')),
        );
      }
    }
  }
}
