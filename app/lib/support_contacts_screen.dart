import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

// Modelo para un contacto de apoyo
class SupportContact {
  final String id;
  final String name;
  final String phone;

  SupportContact({required this.id, required this.name, required this.phone});

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'phone': phone};

  factory SupportContact.fromJson(Map<String, dynamic> json) {
    return SupportContact(
      id: json['id'],
      name: json['name'],
      phone: json['phone'],
    );
  }
}

class SupportContactsScreen extends StatefulWidget {
  const SupportContactsScreen({super.key});

  @override
  _SupportContactsScreenState createState() => _SupportContactsScreenState();
}

class _SupportContactsScreenState extends State<SupportContactsScreen> {
  List<SupportContact> _contacts = [];
  final String _storageKey = 'support_contacts';

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  // Carga los contactos guardados
  Future<void> _loadContacts() async {
    final prefs = await SharedPreferences.getInstance();
    final String? contactsString = prefs.getString(_storageKey);
    if (contactsString != null) {
      final List<dynamic> contactsJson = jsonDecode(contactsString);
      setState(() {
        _contacts = contactsJson.map((json) => SupportContact.fromJson(json)).toList();
      });
    }
  }

  // Guarda la lista de contactos
  Future<void> _saveContacts() async {
    final prefs = await SharedPreferences.getInstance();
    final String contactsString = jsonEncode(_contacts.map((c) => c.toJson()).toList());
    await prefs.setString(_storageKey, contactsString);
  }

  // Lanza una llamada telefónica
  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo llamar al número $phoneNumber')),
      );
    }
  }

  // Muestra el diálogo para añadir o editar un contacto
  void _showContactDialog({SupportContact? contact}) {
    final bool isEditing = contact != null;
    final TextEditingController nameController = TextEditingController(text: contact?.name);
    final TextEditingController phoneController = TextEditingController(text: contact?.phone);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isEditing ? 'Editar Contacto' : 'Nuevo Contacto de Apoyo'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Nombre',
                  icon: Icon(Icons.person_outline),
                ),
              ),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(
                  labelText: 'Teléfono',
                  icon: Icon(Icons.phone_outlined),
                ),
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty && phoneController.text.isNotEmpty) {
                  if (isEditing) {
                    final updatedContact = SupportContact(
                      id: contact.id,
                      name: nameController.text,
                      phone: phoneController.text,
                    );
                    final index = _contacts.indexWhere((c) => c.id == contact.id);
                    setState(() {
                      _contacts[index] = updatedContact;
                    });
                  } else {
                    final newContact = SupportContact(
                      id: DateTime.now().toIso8601String(),
                      name: nameController.text,
                      phone: phoneController.text,
                    );
                    setState(() {
                      _contacts.add(newContact);
                    });
                  }
                  _saveContacts();
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

  // Borra un contacto
  void _deleteContact(String id) {
    setState(() {
      _contacts.removeWhere((contact) => contact.id == id);
    });
    _saveContacts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contactos de Apoyo'),
      ),
      body: _contacts.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              itemCount: _contacts.length,
              itemBuilder: (context, index) {
                final contact = _contacts[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 12.0),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context).primaryColor,
                      child: const Icon(Icons.person, color: Colors.white),
                    ),
                    title: Text(contact.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(contact.phone),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.phone, color: Colors.green),
                          onPressed: () => _makePhoneCall(contact.phone),
                          tooltip: 'Llamar',
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, color: Colors.blueGrey),
                          onPressed: () => _showContactDialog(contact: contact),
                          tooltip: 'Editar',
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                          onPressed: () => _deleteContact(contact.id),
                          tooltip: 'Borrar',
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showContactDialog,
        tooltip: 'Añadir contacto',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 20),
            Text(
              'Sin Contactos de Apoyo',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'Presiona el botón "+" para añadir a las personas que te apoyan en tu camino, como tu padrino o amigos cercanos.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}
