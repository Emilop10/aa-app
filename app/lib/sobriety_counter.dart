import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:ui';
import 'journal_menu.dart';
import 'literature_menu.dart';
import 'daily_readings.dart';
import 'support_screen.dart';
import 'sobriety_counter_screen.dart';
import 'achievements_screen.dart';
import 'settings_screen.dart';
import 'app_colors.dart';

const _kCream   = Color(0xFFFFFBF5);
const _kDarkBg  = Color(0xFF1A0800);

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
      _counterKey      = UniqueKey();
      _achievementsKey = UniqueKey();
    });
  }

  void _openSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SettingsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Color>(
      valueListenable: appPrimaryColor,
      builder: (context, primary, child) {
        final isDark   = Theme.of(context).brightness == Brightness.dark;
        final bgColor  = isDark ? _kDarkBg : _kCream;

        final List<Widget> screens = [
          SobrietyCounter(key: _counterKey, onDateChanged: _refreshCounterScreens),
          AchievementsScreen(key: _achievementsKey),
          const LiteratureMenu(),
          const DailyReadings(),
          const JournalMenu(),
          const SupportScreen(),
        ];

        final List<IconData> tabIcons = [
          CupertinoIcons.house,
          CupertinoIcons.star,
          CupertinoIcons.book,
          CupertinoIcons.sun_max,
          CupertinoIcons.pencil,
          CupertinoIcons.person_2,
        ];
        final List<IconData> tabIconsFilled = [
          CupertinoIcons.house_fill,
          CupertinoIcons.star_fill,
          CupertinoIcons.book_fill,
          CupertinoIcons.sun_max_fill,
          CupertinoIcons.pencil,
          CupertinoIcons.person_2_fill,
        ];
        final List<String> tabLabels = [
          'Inicio', 'Logros', 'Literatura', 'Reflexiones', 'Escritura', 'Apoyo',
        ];

        return Scaffold(
          backgroundColor: bgColor,
          extendBody: true,
          body: Stack(
            children: [
              IndexedStack(
                index: _currentIndex,
                children: screens,
              ),
              // Settings button overlay (top-left, only visible on index 0)
              if (_currentIndex == 0)
                Positioned(
                  top: MediaQuery.of(context).padding.top + 8,
                  left: 16,
                  child: CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: _openSettings,
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withOpacity(0.12)
                            : Colors.white.withOpacity(0.8),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDark
                              ? Colors.white.withOpacity(0.1)
                              : Colors.white.withOpacity(0.8),
                          width: 0.8,
                        ),
                      ),
                      child: Icon(
                        CupertinoIcons.settings,
                        size: 18,
                        color: isDark ? Colors.white70 : const Color(0xFF431407),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  height: 64,
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.black.withOpacity(0.55)
                        : Colors.white.withOpacity(0.75),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withOpacity(0.1)
                          : Colors.white.withOpacity(0.9),
                      width: 0.8,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: List.generate(tabLabels.length, (i) {
                      final isActive  = _currentIndex == i;
                      return Expanded(
                        child: CupertinoButton(
                          padding: EdgeInsets.zero,
                          onPressed: () => setState(() => _currentIndex = i),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                isActive ? tabIconsFilled[i] : tabIcons[i],
                                size: 22,
                                color: isActive
                                    ? primary
                                    : (isDark
                                        ? Colors.white38
                                        : const Color(0xFF92400E).withOpacity(0.5)),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                tabLabels[i],
                                style: TextStyle(
                                  fontSize: 9.5,
                                  fontWeight: isActive
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                  color: isActive
                                      ? primary
                                      : (isDark
                                          ? Colors.white38
                                          : const Color(0xFF92400E).withOpacity(0.5)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
