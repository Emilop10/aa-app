import 'package:flutter/material.dart';
import 'journal_menu.dart';
import 'literature_menu.dart';
import 'daily_readings.dart';
import 'support_screen.dart';
import 'sobriety_counter_screen.dart';
import 'achievements_screen.dart';
import 'settings_screen.dart'; // ¡NUEVO! Importamos la pantalla de ajustes.

class SobrietyCounterApp extends StatefulWidget {
  const SobrietyCounterApp({super.key});

  @override
  _SobrietyCounterAppState createState() => _SobrietyCounterAppState();
}

class _SobrietyCounterAppState extends State<SobrietyCounterApp> {
  int _currentIndex = 0;
  Key _counterKey = UniqueKey();
  Key _achievementsKey = UniqueKey();

  void _refreshCounterScreens() {
    setState(() {
      _counterKey = UniqueKey();
      _achievementsKey = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _screens = [
      SobrietyCounter(key: _counterKey, onDateChanged: _refreshCounterScreens),
      AchievementsScreen(key: _achievementsKey),
      LiteratureMenu(),
      const DailyReadings(),
      JournalMenu(),
      const SupportScreen(),
      const SettingsScreen(), // ¡NUEVO! Añadimos la pantalla de ajustes a la lista.
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.emoji_events_outlined),
            activeIcon: Icon(Icons.emoji_events),
            label: 'Logros',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book_outlined),
            activeIcon: Icon(Icons.menu_book),
            label: 'Literatura',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book_outlined),
            activeIcon: Icon(Icons.book),
            label: 'Reflexiones',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.edit_outlined),
            activeIcon: Icon(Icons.edit),
            label: 'Escritura',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.support_agent_outlined),
            activeIcon: Icon(Icons.support_agent),
            label: 'Soporte',
          ),
          // ¡NUEVO! Añadimos el ícono de ajustes al menú.
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings),
            label: 'Ajustes',
          ),
        ],
      ),
    );
  }
}
