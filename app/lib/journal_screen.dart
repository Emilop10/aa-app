import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

// Modelo para una entrada del diario personal
class JournalEntry {
  // ¡NUEVO! Añadimos un ID único para cada entrada.
  final String id;
  final String title;
  final String content;
  final DateTime date;

  JournalEntry({required this.id, required this.title, required this.content, required this.date});

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'content': content,
        'date': date.toIso8601String(),
      };

  factory JournalEntry.fromJson(Map<String, dynamic> json) {
    return JournalEntry(
      // Se añade el ID, con un fallback por si las entradas viejas no lo tienen.
      id: json['id'] ?? DateTime.now().toIso8601String(),
      title: json['title'],
      content: json['content'],
      date: DateTime.parse(json['date']),
    );
  }
}

class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  _JournalScreenState createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  List<JournalEntry> _entries = [];
  final String _storageKey = 'journal_entries';

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('es_ES', null);
    _loadEntries();
  }

  // Carga las entradas guardadas
  Future<void> _loadEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final String? entriesString = prefs.getString(_storageKey);
    if (entriesString != null) {
      final List<dynamic> entriesJson = jsonDecode(entriesString);
      setState(() {
        _entries = entriesJson.map((json) => JournalEntry.fromJson(json)).toList();
        _entries.sort((a, b) => b.date.compareTo(a.date));
      });
    }
  }

  // Guarda la lista de entradas
  Future<void> _saveEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final String entriesString = jsonEncode(_entries.map((e) => e.toJson()).toList());
    await prefs.setString(_storageKey, entriesString);
  }

  // ¡MODIFICADO! Muestra el diálogo para añadir O EDITAR una entrada.
  void _showEntryDialog({JournalEntry? entry}) {
    final bool isEditing = entry != null;
    final TextEditingController titleController = TextEditingController(text: entry?.title);
    final TextEditingController contentController = TextEditingController(text: entry?.content);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isEditing ? 'Editar Entrada' : 'Nueva Entrada del Diario'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  autofocus: true,
                  decoration: const InputDecoration(
                    hintText: 'Título',
                    icon: Icon(Icons.title),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: contentController,
                  decoration: const InputDecoration(
                    hintText: 'Escribe tus pensamientos aquí...',
                    icon: Icon(Icons.article_outlined),
                  ),
                  maxLines: 8,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.isNotEmpty && contentController.text.isNotEmpty) {
                  if (isEditing) {
                    // Lógica para editar
                    final updatedEntry = JournalEntry(
                      id: entry.id,
                      title: titleController.text,
                      content: contentController.text,
                      date: entry.date, // Mantenemos la fecha original
                    );
                    final index = _entries.indexWhere((e) => e.id == entry.id);
                    setState(() {
                      _entries[index] = updatedEntry;
                    });
                  } else {
                    // Lógica para crear
                    final newEntry = JournalEntry(
                      id: DateTime.now().toIso8601String(), // ID único
                      title: titleController.text,
                      content: contentController.text,
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
    return DateFormat('EEEE, d \'de\' MMMM \'de\' y', 'es_ES').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Diario'),
      ),
      body: _entries.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: _entries.length,
              itemBuilder: (context, index) {
                final entry = _entries[index];
                // ¡NUEVO! Envolvemos la tarjeta en un Dismissible para el gesto de borrar.
                return Dismissible(
                  key: Key(entry.id), // Clave única para cada elemento
                  direction: DismissDirection.endToStart, // Deslizar de derecha a izquierda
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
                        entry.title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _formatDate(entry.date),
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              entry.content,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                      // ¡NUEVO! Al tocar, se abre el diálogo para editar.
                      onTap: () {
                        _showEntryDialog(entry: entry);
                      },
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showEntryDialog,
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
                    Icon(Icons.edit_note, size: 40, color: theme.primaryColor),
                    const SizedBox(height: 12),
                    Text(
                      "Tu Espacio Personal",
                      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "La escritura es una herramienta fundamental para el autoconocimiento. Usa este espacio para explorar tus pensamientos y sentimientos sin juicio. Anotar tus experiencias diarias te ayuda a procesarlas y a encontrar claridad en tu camino.",
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
            Text(
              'Presiona el botón "+" para escribir tu primera entrada.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}
