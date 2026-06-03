import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Notifier global — todos los widgets lo escuchan
final ValueNotifier<Color> appPrimaryColor = ValueNotifier<Color>(const Color(0xFFF97316));

// Colores secundarios derivados del primario (para gradientes)
Color appPrimaryDeep(Color c) => HSLColor.fromColor(c).withLightness((HSLColor.fromColor(c).lightness - 0.08).clamp(0.0, 1.0)).toColor();
Color appPrimaryDark(Color c) => HSLColor.fromColor(c).withLightness((HSLColor.fromColor(c).lightness - 0.18).clamp(0.0, 1.0)).toColor();

// Colores disponibles para elegir
class AppColorOption {
  final String name;
  final Color color;
  const AppColorOption({required this.name, required this.color});
}

const List<AppColorOption> kColorOptions = [
  AppColorOption(name: 'Naranja',  color: Color(0xFFF97316)),
  AppColorOption(name: 'Azul',     color: Color(0xFF3B82F6)),
  AppColorOption(name: 'Verde',    color: Color(0xFF10B981)),
  AppColorOption(name: 'Violeta',  color: Color(0xFF7C3AED)),
  AppColorOption(name: 'Rosa',     color: Color(0xFFEC4899)),
  AppColorOption(name: 'Teal',     color: Color(0xFF0891B2)),
  AppColorOption(name: 'Rojo',     color: Color(0xFFEF4444)),
  AppColorOption(name: 'Índigo',   color: Color(0xFF4F46E5)),
];

Future<void> loadSavedColor() async {
  final prefs = await SharedPreferences.getInstance();
  final hex = prefs.getString('app_primary_color');
  if (hex != null) {
    final value = int.tryParse(hex, radix: 16);
    if (value != null) appPrimaryColor.value = Color(value);
  }
}

Future<void> saveColor(Color color) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('app_primary_color', color.value.toRadixString(16));
  appPrimaryColor.value = color;
}
