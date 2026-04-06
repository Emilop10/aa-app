import 'package:flutter/material.dart';
// IMPORTAMOS LA NUEVA PANTALLA DEL LECTOR EPUB
import 'libro_azul_epub_screen.dart'; 
import 'steps_traditions_screen.dart';

// El archivo 'libro_azul.dart' (el del PDF) ya no es necesario aquí.

class LiteratureMenu extends StatelessWidget {
  const LiteratureMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Literatura"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildMenuItem(
            context: context,
            title: 'Libro Azul',
            imagePath: 'assets/images/big_book_bg.png',
            // ¡CAMBIO CLAVE! Ahora apunta a la nueva pantalla del lector ePub.
            targetScreen: const LibroAzulEpubScreen(), 
          ),
          _buildMenuItem(
            context: context,
            title: '12 Pasos / 12 Tradiciones',
            imagePath: 'assets/images/steps_traditions_bg.png',
            targetScreen: StepsTraditionsScreen(), // Este se mantiene igual
          ),
        ],
      ),
    );
  }

  // El widget _buildMenuItem no necesita cambios, se mantiene igual.
  Widget _buildMenuItem({
    required BuildContext context,
    required String title,
    required String imagePath,
    required Widget targetScreen,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => targetScreen),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        height: 150,
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withOpacity(0.1),
          image: DecorationImage(
            image: AssetImage(imagePath),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.4),
              BlendMode.darken,
            ),
          ),
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Center(
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(
                  offset: Offset(1, 1),
                  blurRadius: 3,
                  color: Colors.black87,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
