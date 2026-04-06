import 'package:flutter/material.dart';
import 'journal_screen.dart';
import 'gratitude_journal_screen.dart'; // ¡NUEVO! Importamos la pantalla del diario de gratitud.

class JournalMenu extends StatelessWidget {
  const JournalMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Escritura"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildMenuItem(
            context,
            'Mi Diario',
            'assets/images/journal_bg.png', 
            JournalScreen(),
          ),
          // ¡NUEVO! Añadimos el botón para el Diario de Gratitud.
          _buildMenuItem(
            context,
            'Diario de Gratitud',
            'assets/images/daily_reflections_bg.png', // Puedes usar otra imagen si quieres
            const GratitudeJournalScreen(),
          ),
        ],
      ),
    );
  }

  // Widget de menú con estilo consistente
  Widget _buildMenuItem(
      BuildContext context, String title, String imagePath, Widget targetScreen) {
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
