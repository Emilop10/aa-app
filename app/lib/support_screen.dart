import 'package:flutter/material.dart';
import 'support_contacts_screen.dart'; // ¡NUEVO! Importamos la pantalla de contactos.

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Soporte'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Tarjeta "Mi Historia"
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MyStoryScreen()),
                );
              },
              child: Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 4,
                child: const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Mi Historia',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Tarjeta "Contactos de Apoyo"
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SupportContactsScreen()),
                );
              },
              child: Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 4,
                child: const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Contactos de Apoyo',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Pantalla "Mi Historia"
class MyStoryScreen extends StatelessWidget {
  const MyStoryScreen({super.key});

  // Función auxiliar para crear párrafos con estilo
  Widget _buildParagraph(String text, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(
        text,
        textAlign: TextAlign.justify,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              height: 1.6, // Mejora la legibilidad
              fontSize: 17,
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Historia'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Icon(
                Icons.favorite_border,
                color: theme.primaryColor,
                size: 40,
              ),
            ),
            // El texto "El Origen de un Sueño" ha sido eliminado.
            const Divider(height: 40, thickness: 1),

            // --- ¡CORREGIDO! Aquí está el texto completo ---
            _buildParagraph(
              'Esta app fue desarrollada como una herramienta adicional al programa de 24 horas.',
              context,
            ),
            _buildParagraph(
              'Yo soy un miembro activo de AA desde hace ya algunas 24 horas. No represento a la OSG y esta app nació como un sueño de ayudar a mantener la sobriedad en más personas.',
              context,
            ),
            _buildParagraph(
              'El desarrollo de esta app ha sido gracias al apoyo y soporte de mi hijo Emi, que sin su amor, apoyo y perseverancia esto no hubiera sido posible.',
              context,
            ),
            _buildParagraph(
              'Esta app ha sido desarrollada con mis propios recursos, por lo que el apoyo de sus donaciones y membresías será siempre bienvenido.',
              context,
            ),
            _buildParagraph(
              'Espero de todo corazón que esta app te funcione como una herramienta de apoyo en tu programa de Recuperación, Unidad y Servicio.',
              context,
            ),
            const SizedBox(height: 20),
            
            // Firma
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                'Felices 24 horas con todo mi Amor y Cariño.\n— Beto L.',
                textAlign: TextAlign.right,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
