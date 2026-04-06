import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

// Modelo para una entrada del diario
class GratitudeEntry {
  // ¡NUEVO! Añadimos un ID único.
  final String id;
  final String text;
  final DateTime date;

  GratitudeEntry({required this.id, required this.text, required this.date});

  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        'date': date.toIso8601String(),
      };

  factory GratitudeEntry.fromJson(Map<String, dynamic> json) {
    return GratitudeEntry(
      id: json['id'] ?? DateTime.now().toIso8601String(),
      text: json['text'],
      date: DateTime.parse(json['date']),
    );
  }
}

class GratitudeJournalScreen extends StatefulWidget {
  const GratitudeJournalScreen({super.key});

  @override
  _GratitudeJournalScreenState createState() => _GratitudeJournalScreenState();
}

class _GratitudeJournalScreenState extends State<GratitudeJournalScreen> {
  List<GratitudeEntry> _entries = [];
  final String _storageKey = 'gratitude_entries';

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('es_ES', null);
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final String? entriesString = prefs.getString(_storageKey);
    if (entriesString != null) {
      final List<dynamic> entriesJson = jsonDecode(entriesString);
      setState(() {
        _entries = entriesJson.map((json) => GratitudeEntry.fromJson(json)).toList();
        _entries.sort((a, b) => b.date.compareTo(a.date));
      });
    }
  }

  Future<void> _saveEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final String entriesString = jsonEncode(_entries.map((e) => e.toJson()).toList());
    await prefs.setString(_storageKey, entriesString);
  }

  // ¡MODIFICADO! Muestra el diálogo para añadir O EDITAR una entrada.
  void _showAddEntryDialog({GratitudeEntry? entry}) {
    final bool isEditing = entry != null;
    final TextEditingController controller = TextEditingController(text: entry?.text);
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isEditing ? 'Editar Gratitud' : 'Nueva Entrada de Gratitud'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(hintText: 'Estoy agradecido/a por...'),
            maxLines: 4,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  if (isEditing) {
                    // Lógica para editar
                    final updatedEntry = GratitudeEntry(
                      id: entry.id,
                      text: controller.text,
                      date: entry.date, // Mantenemos la fecha original
                    );
                    final index = _entries.indexWhere((e) => e.id == entry.id);
                    setState(() {
                      _entries[index] = updatedEntry;
                    });
                  } else {
                    // Lógica para crear
                    final newEntry = GratitudeEntry(
                      id: DateTime.now().toIso8601String(),
                      text: controller.text,
                      date: DateTime.now(),
                    );
                    setState(() {
                      _entries.insert(0, newEntry);
                    });
                  }
                  _saveEntries();
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  // ¡NUEVO! Función para borrar una entrada.
  void _deleteEntry(String id) {
    setState(() {
      _entries.removeWhere((entry) => entry.id == id);
    });
    _saveEntries();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Entrada eliminada.')),
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('d \'de\' MMMM \'de\' y, h:mm a', 'es_ES').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Diario de Gratitud'),
      ),
      body: _entries.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: _entries.length,
              itemBuilder: (context, index) {
                final entry = _entries[index];
                // ¡NUEVO! Envolvemos la tarjeta en un Dismissible.
                return Dismissible(
                  key: Key(entry.id),
                  direction: DismissDirection.endToStart,
                  onDismissed: (direction) {
                    _deleteEntry(entry.id);
                  },
                  background: Container(
                    color: Colors.redAccent,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    alignment: Alignment.centerRight,
                    child: const Icon(Icons.delete_outline, color: Colors.white),
                  ),
                  child: Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16.0),
                      title: Text(
                        entry.text,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.5),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          _formatDate(entry.date),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
                        ),
                      ),
                      // ¡NUEVO! Al tocar, se abre el diálogo para editar.
                      onTap: () {
                        _showAddEntryDialog(entry: entry);
                      },
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddEntryDialog,
        tooltip: 'Añadir entrada',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState() {
    final theme = Theme.of(context);
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Card(
              color: theme.primaryColor.withOpacity(0.05),
              elevation: 0,
              shape: RoundedRectangleBorder(
                side: BorderSide(color: theme.primaryColor.withOpacity(0.2)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Icon(Icons.lightbulb_outline, size: 40, color: theme.primaryColor),
                    const SizedBox(height: 12),
                    Text(
                      "El Poder de la Gratitud",
                      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Practicar la gratitud diariamente puede transformar tu perspectiva. Al enfocarte en lo bueno, por pequeño que sea, entrenas tu mente para ver las oportunidades en lugar de los obstáculos. Este simple diario es una herramienta poderosa para cultivar la serenidad y la alegría en tu camino de recuperación.",
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
            Text(
              'Presiona el botón "+" para añadir tu primera entrada.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}
