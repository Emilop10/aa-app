# Graph Report - aa-app  (2026-10-16)

## Corpus Check
- 60 files · ~376,102 words
- Verdict: corpus is large enough that graph structure adds value.
- Unclassified: 63 file(s) not represented in the graph (top: (none) 11, .plist 8, .xcconfig 8)

## Summary
- 973 nodes · 1306 edges · 50 communities (35 shown, 15 thin omitted)
- Extraction: 98% EXTRACTED · 2% INFERRED · 0% AMBIGUOUS · INFERRED: 21 edges (avg confidence: 0.87)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `5d3129d3`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- sobriety_counter_screen.dart
- FlutterWindow
- libro_azul_screen.dart
- achievements_screen.dart
- main.dart
- support_contacts_screen.dart
- GeneratedPluginRegistrant.swift
- daily_readings.dart
- settings_screen.dart
- gratitude_journal_screen.dart
- journal_screen.dart
- literature_extras_screens.dart
- literature_menu.dart
- Manual de la App de Sobriedad (A.A.)
- State
- my_application.cc
- prayers_screen.dart
- steps_traditions_screen.dart
- onboarding_screen.dart
- SobrietyEntry
- utils.cpp
- app_colors.dart
- journal_menu.dart
- support_screen.dart
- manifest.json
- windows/flutter/generated_plugin_registrant.cc
- notification_service.dart
- win32_window.cpp
- Win32Window
- StatelessWidget
- package:flutter/material.dart
- verificar-herramental.sh
- MainActivity.kt
- app
- LaunchImage.imageset/README.md
- .MessageHandler
- Point
- SceneDelegate
- 23. Desarrollo local
- 11. Literatura
- 22. Graphify y la red neuronal 3D
- 21. Herramental de Claude Code
- 4. Estructura del repositorio

## God Nodes (most connected - your core abstractions)
1. `Manual de la App de Sobriedad (A.A.)` - 30 edges
2. `Win32Window` - 21 edges
3. `FlutterWindow` - 10 edges
4. `SobrietyEntry` - 9 edges
5. `Provider` - 8 edges
6. `SceneDelegate` - 7 edges
7. `WindowClassRegistrar` - 7 edges
8. `23. Desarrollo local` - 7 edges
9. `_MyApplication` - 6 edges
10. `SobrietyWidgetEntryView` - 5 edges

## Surprising Connections (you probably didn't know these)
- `25. Errores conocidos y soluciones` --references--> `SceneDelegate`  [INFERRED]
  MANUAL.md → app/ios/Runner/AppDelegate.swift
- `26. Historia del desarrollo` --references--> `SceneDelegate`  [INFERRED]
  MANUAL.md → app/ios/Runner/AppDelegate.swift
- `26. Historia del desarrollo` --references--> `main()`  [INFERRED]
  MANUAL.md → app/linux/main.cc
- `5. Arranque de la app` --references--> `main()`  [INFERRED]
  MANUAL.md → app/linux/main.cc
- `wWinMain()` --calls--> `CreateAndAttachConsole()`  [INFERRED]
  app/windows/runner/main.cpp → app/windows/runner/utils.cpp

## Import Cycles
- None detected.

## Communities (50 total, 15 thin omitted)

### Community 0 - "sobriety_counter_screen.dart"
Cohesion: 0.03
Nodes (67): _bgBreath, _bgBreathController, build, _buildBody, _buildEmptyState, _calculateYearsMonthsDays, _card1Fade, _card1Slide (+59 more)

### Community 1 - "FlutterWindow"
Cohesion: 0.12
Nodes (4): FlutterWindow, flutter_controller_, FlutterWindow::FlutterWindow(), project_

### Community 2 - "libro_azul_screen.dart"
Cohesion: 0.04
Nodes (54): _addHighlight, _barsAnim, _barsFade, _bg, build, _buildHighlightsPanel, _buildIndexPanel, _buildLoading (+46 more)

### Community 3 - "achievements_screen.dart"
Cohesion: 0.04
Nodes (40): _allMilestones, _bgBreath, _bgBreathController, build, _buildContent, _buildEmptyState, _buildMilestoneCard, _calculateTime (+32 more)

### Community 4 - "main.dart"
Cohesion: 0.10
Nodes (14): abrirReflexion, build, _configureLocalTimeZone, createState, details, initializeDateFormatting, loadSavedColor, loadSavedThemeMode (+6 more)

### Community 5 - "support_contacts_screen.dart"
Cohesion: 0.05
Nodes (39): _actionBtn, _bgBreath, _bgBreathController, build, _buildCard, _buildEmpty, _call, _ContactEditor (+31 more)

### Community 6 - "GeneratedPluginRegistrant.swift"
Cohesion: 0.06
Nodes (21): AppDelegate, RunnerTests, RegisterGeneratedPlugins(), AppDelegate, MainFlutterWindow, RunnerTests, Cocoa, device_info_plus (+13 more)

### Community 7 - "daily_readings.dart"
Cohesion: 0.05
Nodes (33): _bgBreath, _bgBreathController, build, _buildNoReadingAvailable, _buildReadingContent, _cardFade, _cardSlide, content (+25 more)

### Community 8 - "settings_screen.dart"
Cohesion: 0.05
Nodes (39): main, _bgBreath, _bgBreathController, build, _card1Fade, _card1Slide, _card2Fade, _card2Slide (+31 more)

### Community 9 - "gratitude_journal_screen.dart"
Cohesion: 0.06
Nodes (29): _bgBreath, _bgBreathController, build, _buildCard, _buildDailyPrompt, _buildEmpty, createState, _ctrl (+21 more)

### Community 10 - "journal_screen.dart"
Cohesion: 0.06
Nodes (32): _bgBreath, _bgBreathController, build, _buildCard, _buildEmpty, content, _contentCtrl, _contentFocus (+24 more)

### Community 11 - "literature_extras_screens.dart"
Cohesion: 0.07
Nodes (28): _bgBreath, _bgBreathController, _bgColor, body, build, createState, definition, dispose (+20 more)

### Community 12 - "literature_menu.dart"
Cohesion: 0.06
Nodes (27): _bgBreath, _bgBreathController, build, _buildMenuItem, _comoFuncionaBody, _comoFuncionaFooter, _conceptosBody, _conceptosFooter (+19 more)

### Community 13 - "Manual de la App de Sobriedad (A.A.)"
Cohesion: 0.09
Nodes (22): 10. Logros, 12. Reflexiones diarias, 13. Escritura (Diario y Gratitud), 14. Apoyo (Contactos y Mi Historia), 15. Ajustes, 16. Notificaciones, 17. Sistema de diseño, 18. Almacenamiento de datos y privacidad (+14 more)

### Community 14 - "State"
Cohesion: 0.08
Nodes (42): AchievementsScreen, _AchievementsScreenState, DailyReadings, _DailyReadingsState, _GratitudeEditor, _GratitudeEditorState, GratitudeJournalScreen, _GratitudeJournalScreenState (+34 more)

### Community 15 - "my_application.cc"
Cohesion: 0.08
Nodes (15): fl_register_plugins(), main(), my_application_activate(), my_application_class_init(), my_application_dispose(), my_application_init(), my_application_local_command_line(), my_application_new() (+7 more)

### Community 16 - "prayers_screen.dart"
Cohesion: 0.08
Nodes (24): _bgBreath, _bgBreathController, _bgColor, body, build, _buildRow, createState, dispose (+16 more)

### Community 17 - "steps_traditions_screen.dart"
Cohesion: 0.04
Nodes (36): _achievementsKey, build, _counterKey, createState, _currentIndex, _kCream, _kDarkBg, _refreshCounterScreens (+28 more)

### Community 18 - "onboarding_screen.dart"
Cohesion: 0.08
Nodes (21): _bgBreath, _bgBreathController, body, build, _buildPage, createState, _currentPage, dispose (+13 more)

### Community 19 - "SobrietyEntry"
Cohesion: 0.10
Nodes (13): Provider, SobrietyEntry, SobrietyWidget, .body, SobrietyWidgetEntryView, .body, build, imagePath (+5 more)

### Community 20 - "utils.cpp"
Cohesion: 0.19
Nodes (4): wWinMain(), CreateAndAttachConsole(), GetCommandLineArguments(), Utf8FromUtf16()

### Community 21 - "app_colors.dart"
Cohesion: 0.08
Nodes (18): AppColorOption, appPrimaryColor, appPrimaryDark, appPrimaryDeep, appThemeMode, color, hex, kColorOptions (+10 more)

### Community 22 - "journal_menu.dart"
Cohesion: 0.10
Nodes (15): _bgBreath, _bgBreathController, build, _buildCard, _card1Fade, _card1Slide, _card2Fade, _card2Slide (+7 more)

### Community 23 - "support_screen.dart"
Cohesion: 0.10
Nodes (18): _bgBreath, _bgBreathController, _buildParagraph, _buildSupportCard, _card1Fade, _card1Slide, _card2Fade, _card2Slide (+10 more)

### Community 25 - "manifest.json"
Cohesion: 0.18
Nodes (10): background_color, description, display, icons, name, orientation, prefer_related_applications, short_name (+2 more)

### Community 27 - "notification_service.dart"
Cohesion: 0.10
Nodes (12): cancelAllNotifications, cancelGratitudeNotification, _configureLocalTimeZone, _flutterLocalNotificationsPlugin, getAppLaunchDetails, init, instance, _localLocation (+4 more)

### Community 28 - "win32_window.cpp"
Cohesion: 0.18
Nodes (5): Scale(), Win32Window::Win32Window(), WindowClassRegistrar, class_registered_, instance_

### Community 29 - "Win32Window"
Cohesion: 0.16
Nodes (7): Size, height, width, Win32Window, child_content_, quit_on_close_, window_handle_

### Community 30 - "StatelessWidget"
Cohesion: 0.40
Nodes (4): _HeroCard, _MiniStatCard, _QuoteCard, _StartDateCard

### Community 32 - "verificar-herramental.sh"
Cohesion: 0.83
Nodes (3): instalar_de(), marketplace_de(), verificar-herramental.sh script

### Community 43 - "Point"
Cohesion: 0.50
Nodes (3): Point, x, y

### Community 45 - "23. Desarrollo local"
Cohesion: 0.29
Nodes (7): 23.1 Entorno probado (octubre 2026), 23.2 Preparación (solo una vez), 23.3 Ver el simulador, 23.4 Ciclo de trabajo, 23.5 iPhone real, 23.6 Si algo falla, 23. Desarrollo local

### Community 46 - "11. Literatura"
Cohesion: 0.40
Nodes (5): 11.1 Libro Azul, 11.2 12 Pasos y 12 Tradiciones, 11.3 Oraciones, 11.4 Textos breves, 11. Literatura

### Community 47 - "22. Graphify y la red neuronal 3D"
Cohesion: 0.40
Nodes (5): 22.1 Estado del grafo (actualizado el 15 de octubre de 2026, Graphify 0.9.91), 22.2 Archivos, 22.3 Visualización 3D, 22.4 Actualizar el grafo, 22. Graphify y la red neuronal 3D

### Community 48 - "21. Herramental de Claude Code"
Cohesion: 0.50
Nodes (4): 21.1 Plugins (viajan con el repo), 21.2 Lo que NO viaja con el repo, 21.3 Verificar el entorno, 21. Herramental de Claude Code

## Knowledge Gaps
- **568 isolated node(s):** `UserNotifications`, `WidgetKit`, `SwiftUI`, `.body`, `Milestone` (+563 more)
  These have ≤1 connection - possible missing edges or undocumented components. (Counts symbols only; 730 node(s) total have ≤1 connection when file, concept and rationale nodes are included.)
- **15 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `Win32Window` connect `Win32Window` to `FlutterWindow`, `.MessageHandler`, `Point`, `flutter_window.h`, `win32_window.cpp`?**
  _High betweenness centrality (0.048) - this node is a cross-community bridge._
- **What connects `UserNotifications`, `WidgetKit`, `SwiftUI` to the rest of the system?**
  _568 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `sobriety_counter_screen.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.0273972602739726 - nodes in this community are weakly interconnected._
- **Why does `FlutterWindow` connect `FlutterWindow` to `flutter_window.h`, `Win32Window`?**
  _High betweenness centrality (0.015) - this node is a cross-community bridge._
- **Should `FlutterWindow` be split into smaller, more focused modules?**
  _Cohesion score 0.11764705882352941 - nodes in this community are weakly interconnected._
- **Should `libro_azul_screen.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.03508771929824561 - nodes in this community are weakly interconnected._
- **Should `achievements_screen.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.0425531914893617 - nodes in this community are weakly interconnected._