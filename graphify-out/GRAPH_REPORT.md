# Graph Report - aa-app  (2026-10-06)

## Corpus Check
- 60 files · ~373,999 words
- Verdict: corpus is large enough that graph structure adds value.
- Unclassified: 63 file(s) not represented in the graph (top: (none) 11, .plist 8, .xcconfig 8)

## Summary
- 951 nodes · 1279 edges · 42 communities (31 shown, 11 thin omitted)
- Extraction: 99% EXTRACTED · 1% INFERRED · 0% AMBIGUOUS · INFERRED: 18 edges (avg confidence: 0.86)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `ffe5167d`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- sobriety_counter_screen.dart
- win32_window.cpp
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
- sobriety_counter.dart
- manifest.json
- windows/flutter/generated_plugin_registrant.cc
- menu_item.dart
- SingleTickerProviderStateMixin
- MaterialPageRoute
- StatelessWidget
- package:flutter/material.dart
- verificar-herramental.sh
- MainActivity.kt
- app
- LaunchImage.imageset/README.md

## God Nodes (most connected - your core abstractions)
1. `Manual de la App de Sobriedad (A.A.)` - 28 edges
2. `Win32Window` - 21 edges
3. `FlutterWindow` - 10 edges
4. `SobrietyEntry` - 9 edges
5. `Provider` - 8 edges
6. `WindowClassRegistrar` - 7 edges
7. `_MyApplication` - 6 edges
8. `SobrietyWidgetEntryView` - 5 edges
9. `SobrietyWidget` - 5 edges
10. `wWinMain()` - 5 edges

## Surprising Connections (you probably didn't know these)
- `5. Arranque de la app` --references--> `main()`  [INFERRED]
  MANUAL.md → app/linux/main.cc
- `wWinMain()` --calls--> `CreateAndAttachConsole()`  [INFERRED]
  app/windows/runner/main.cpp → app/windows/runner/utils.cpp
- `my_application_activate()` --calls--> `fl_register_plugins()`  [INFERRED]
  app/linux/my_application.cc → app/linux/flutter/generated_plugin_registrant.cc
- `main()` --calls--> `my_application_new()`  [INFERRED]
  app/linux/main.cc → app/linux/my_application.cc
- `wWinMain()` --calls--> `GetCommandLineArguments()`  [INFERRED]
  app/windows/runner/main.cpp → app/windows/runner/utils.cpp

## Import Cycles
- None detected.

## Communities (42 total, 11 thin omitted)

### Community 0 - "sobriety_counter_screen.dart"
Cohesion: 0.03
Nodes (67): _bgBreath, _bgBreathController, build, _buildBody, _buildEmptyState, _calculateYearsMonthsDays, _card1Fade, _card1Slide (+59 more)

### Community 1 - "win32_window.cpp"
Cohesion: 0.05
Nodes (20): FlutterWindow, flutter_controller_, FlutterWindow::FlutterWindow(), project_, EnableFullDpiSupportIfAvailable(), Point, x, y (+12 more)

### Community 2 - "libro_azul_screen.dart"
Cohesion: 0.04
Nodes (54): _addHighlight, _barsAnim, _barsFade, _bg, build, _buildHighlightsPanel, _buildIndexPanel, _buildLoading (+46 more)

### Community 3 - "achievements_screen.dart"
Cohesion: 0.04
Nodes (40): _allMilestones, _bgBreath, _bgBreathController, build, _buildContent, _buildEmptyState, _buildMilestoneCard, _calculateTime (+32 more)

### Community 4 - "main.dart"
Cohesion: 0.05
Nodes (28): abrirReflexion, build, _configureLocalTimeZone, createState, details, initializeDateFormatting, loadSavedColor, loadSavedThemeMode (+20 more)

### Community 5 - "support_contacts_screen.dart"
Cohesion: 0.05
Nodes (41): _actionBtn, _bgBreath, _bgBreathController, build, _buildCard, _buildEmpty, _call, _ContactEditor (+33 more)

### Community 6 - "GeneratedPluginRegistrant.swift"
Cohesion: 0.06
Nodes (20): AppDelegate, RunnerTests, RegisterGeneratedPlugins(), AppDelegate, MainFlutterWindow, RunnerTests, Cocoa, device_info_plus (+12 more)

### Community 7 - "daily_readings.dart"
Cohesion: 0.05
Nodes (33): _bgBreath, _bgBreathController, build, _buildNoReadingAvailable, _buildReadingContent, _cardFade, _cardSlide, content (+25 more)

### Community 8 - "settings_screen.dart"
Cohesion: 0.05
Nodes (35): _bgBreath, _bgBreathController, _card1Fade, _card1Slide, _card2Fade, _card2Slide, _colorCardFade, _colorCardSlide (+27 more)

### Community 9 - "gratitude_journal_screen.dart"
Cohesion: 0.06
Nodes (29): _bgBreath, _bgBreathController, build, _buildCard, _buildDailyPrompt, _buildEmpty, createState, _ctrl (+21 more)

### Community 10 - "journal_screen.dart"
Cohesion: 0.06
Nodes (32): _bgBreath, _bgBreathController, build, _buildCard, _buildEmpty, content, _contentCtrl, _contentFocus (+24 more)

### Community 11 - "literature_extras_screens.dart"
Cohesion: 0.06
Nodes (32): _bgBreath, _bgBreathController, _bgColor, body, build, createState, definition, dispose (+24 more)

### Community 12 - "literature_menu.dart"
Cohesion: 0.06
Nodes (27): _bgBreath, _bgBreathController, build, _buildMenuItem, _comoFuncionaBody, _comoFuncionaFooter, _conceptosBody, _conceptosFooter (+19 more)

### Community 13 - "Manual de la App de Sobriedad (A.A.)"
Cohesion: 0.06
Nodes (32): 10. Logros, 11.1 Libro Azul, 11.2 12 Pasos y 12 Tradiciones, 11.3 Oraciones, 11.4 Textos breves, 11. Literatura, 12. Reflexiones diarias, 13. Escritura (Diario y Gratitud) (+24 more)

### Community 14 - "State"
Cohesion: 0.11
Nodes (28): AchievementsScreen, _AchievementsScreenState, DailyReadings, _DailyReadingsState, _GratitudeEditor, _GratitudeEditorState, JournalMenu, _JournalMenuState (+20 more)

### Community 15 - "my_application.cc"
Cohesion: 0.09
Nodes (14): fl_register_plugins(), main(), my_application_activate(), my_application_class_init(), my_application_dispose(), my_application_init(), my_application_local_command_line(), my_application_new() (+6 more)

### Community 16 - "prayers_screen.dart"
Cohesion: 0.07
Nodes (28): _bgBreath, _bgBreathController, _bgColor, body, build, _buildRow, createState, dispose (+20 more)

### Community 17 - "steps_traditions_screen.dart"
Cohesion: 0.07
Nodes (26): _bgBreath, _bgBreathController, _bgColor, build, _buildCard, _buildCreditFooter, _buildList, createState (+18 more)

### Community 18 - "onboarding_screen.dart"
Cohesion: 0.08
Nodes (21): _bgBreath, _bgBreathController, body, build, _buildPage, createState, _currentPage, dispose (+13 more)

### Community 19 - "SobrietyEntry"
Cohesion: 0.13
Nodes (8): Provider, SobrietyEntry, SobrietyWidget, .body, SobrietyWidgetEntryView, .body, SwiftUI, WidgetKit

### Community 20 - "utils.cpp"
Cohesion: 0.12
Nodes (4): wWinMain(), CreateAndAttachConsole(), GetCommandLineArguments(), Utf8FromUtf16()

### Community 21 - "app_colors.dart"
Cohesion: 0.09
Nodes (18): AppColorOption, appPrimaryColor, appPrimaryDark, appPrimaryDeep, appThemeMode, color, hex, kColorOptions (+10 more)

### Community 22 - "journal_menu.dart"
Cohesion: 0.10
Nodes (15): _bgBreath, _bgBreathController, build, _buildCard, _card1Fade, _card1Slide, _card2Fade, _card2Slide (+7 more)

### Community 23 - "support_screen.dart"
Cohesion: 0.10
Nodes (18): _bgBreath, _bgBreathController, _buildParagraph, _buildSupportCard, _card1Fade, _card1Slide, _card2Fade, _card2Slide (+10 more)

### Community 24 - "sobriety_counter.dart"
Cohesion: 0.11
Nodes (8): _achievementsKey, build, _counterKey, createState, _currentIndex, _kCream, _kDarkBg, _refreshCounterScreens

### Community 25 - "manifest.json"
Cohesion: 0.18
Nodes (10): background_color, description, display, icons, name, orientation, prefer_related_applications, short_name (+2 more)

### Community 27 - "menu_item.dart"
Cohesion: 0.33
Nodes (5): build, imagePath, MenuItem, targetScreen, title

### Community 28 - "SingleTickerProviderStateMixin"
Cohesion: 0.40
Nodes (4): GratitudeJournalScreen, _GratitudeJournalScreenState, JournalScreen, _JournalScreenState

### Community 29 - "MaterialPageRoute"
Cohesion: 0.40
Nodes (4): main, build, _openSettings, build

### Community 30 - "StatelessWidget"
Cohesion: 0.40
Nodes (4): _HeroCard, _MiniStatCard, _QuoteCard, _StartDateCard

### Community 32 - "verificar-herramental.sh"
Cohesion: 0.83
Nodes (3): instalar_de(), marketplace_de(), verificar-herramental.sh script

## Knowledge Gaps
- **608 isolated node(s):** `WidgetKit`, `SwiftUI`, `.body`, `Milestone`, `_TimeBreakdown` (+603 more)
  These have ≤1 connection - possible missing edges or undocumented components. (Counts symbols only; 715 node(s) total have ≤1 connection when file, concept and rationale nodes are included.)
- **11 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **What connects `WidgetKit`, `SwiftUI`, `.body` to the rest of the system?**
  _608 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `sobriety_counter_screen.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.0273972602739726 - nodes in this community are weakly interconnected._
- **Should `win32_window.cpp` be split into smaller, more focused modules?**
  _Cohesion score 0.05268065268065268 - nodes in this community are weakly interconnected._
- **Should `libro_azul_screen.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.03508771929824561 - nodes in this community are weakly interconnected._
- **Should `achievements_screen.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.0425531914893617 - nodes in this community are weakly interconnected._
- **Should `main.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.048484848484848485 - nodes in this community are weakly interconnected._
- **Should `support_contacts_screen.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.048726467331118496 - nodes in this community are weakly interconnected._