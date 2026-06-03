import 'package:flutter/material.dart';
import 'sobriety_counter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'notification_service.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:timezone/timezone.dart' as tz;
import 'daily_readings.dart';
import 'app_colors.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _configureLocalTimeZone();
  await NotificationService.instance.init(navigatorKey: navigatorKey);
  await initializeDateFormatting('es_ES', null);
  await loadSavedColor();

  final details = await NotificationService.instance.getAppLaunchDetails();
  final bool abrirReflexion =
      details?.didNotificationLaunchApp == true &&
      details?.notificationResponse?.payload == 'daily_reflection';

  runApp(const MyApp());

  if (abrirReflexion) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      navigatorKey.currentState?.push(
        MaterialPageRoute(builder: (_) => const DailyReadings()),
      );
    });
  }
}

Future<void> _configureLocalTimeZone() async {
  tz.initializeTimeZones();
  final String timeZoneName = await FlutterNativeTimezone.getLocalTimezone();
  tz.setLocalLocation(tz.getLocation(timeZoneName));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Color>(
      valueListenable: appPrimaryColor,
      builder: (context, primary, child) {
        return MaterialApp(
          navigatorKey: navigatorKey,
          debugShowCheckedModeBanner: false,
          title: 'App de Sobriedad',
          themeMode: ThemeMode.system,

          //==================================
          //== TEMA CLARO — Cálido & Humano ==
          //==================================
          theme: ThemeData(
            brightness: Brightness.light,
            scaffoldBackgroundColor: const Color(0xFFFFFBF5),
            primaryColor: primary,
            colorScheme: ColorScheme.light(
              primary: primary,
              secondary: appPrimaryDeep(primary),
              surface: const Color(0xFFFFF7ED),
            ),
            appBarTheme: AppBarTheme(
              backgroundColor: primary,
              elevation: 0,
              titleTextStyle: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              iconTheme: const IconThemeData(color: Colors.white),
            ),
            cardTheme: CardTheme(
              color: const Color(0xFFFFF7ED),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: Color(0xFFFED7AA), width: 0.8),
              ),
            ),
            textTheme: const TextTheme(
              bodyLarge: TextStyle(color: Color(0xFF431407)),
              bodyMedium: TextStyle(color: Color(0xFF92400E)),
              headlineMedium: TextStyle(color: Color(0xFF431407), fontWeight: FontWeight.bold),
              headlineSmall: TextStyle(color: Color(0xFF431407)),
              titleLarge: TextStyle(color: Color(0xFF431407)),
              titleMedium: TextStyle(color: Color(0xFF92400E)),
            ),
            iconTheme: IconThemeData(color: primary),
            dividerColor: const Color(0xFFFED7AA),
            bottomNavigationBarTheme: BottomNavigationBarThemeData(
              backgroundColor: Colors.white,
              selectedItemColor: primary,
              unselectedItemColor: Colors.grey[400],
              elevation: 8.0,
            ),
          ),

          //==================================
          //== TEMA OSCURO — Cálido & Humano ==
          //==================================
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: const Color(0xFF1A0800),
            primaryColor: primary,
            colorScheme: ColorScheme.dark(
              primary: primary,
              secondary: appPrimaryDeep(primary),
              surface: const Color(0xFF2D1506),
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF1A0800),
              elevation: 0,
              titleTextStyle: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              iconTheme: IconThemeData(color: Colors.white),
            ),
            cardTheme: CardTheme(
              color: const Color(0xFF2D1506),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: Color(0xFF92400E), width: 0.8),
              ),
            ),
            textTheme: TextTheme(
              bodyLarge: TextStyle(color: Colors.white.withOpacity(0.9)),
              bodyMedium: TextStyle(color: Colors.white.withOpacity(0.7)),
              headlineMedium: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              headlineSmall: const TextStyle(color: Colors.white),
              titleLarge: const TextStyle(color: Colors.white),
              titleMedium: TextStyle(color: Colors.white.withOpacity(0.7)),
            ),
            iconTheme: IconThemeData(color: primary),
            dividerColor: const Color(0xFF92400E),
            bottomNavigationBarTheme: BottomNavigationBarThemeData(
              backgroundColor: const Color(0xFF1A0800),
              selectedItemColor: primary,
              unselectedItemColor: Colors.grey[600],
              elevation: 8.0,
            ),
          ),

          home: const SobrietyCounterApp(),
        );
      },
    );
  }
}
