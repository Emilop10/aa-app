import 'package:flutter/material.dart';
import 'sobriety_counter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'notification_service.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:timezone/timezone.dart' as tz;

// ¡NUEVO! Creamos una clave global para el navegador.
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _configureLocalTimeZone();
  
  // ¡MODIFICADO! Pasamos la clave de navegación al servicio.
  await NotificationService.instance.init(navigatorKey: navigatorKey);
  
  await initializeDateFormatting('es_ES', null);
  
  runApp(const MyApp());
}

Future<void> _configureLocalTimeZone() async {
  tz.initializeTimeZones();
  final String timeZoneName = await FlutterNativeTimezone.getLocalTimezone();
  tz.setLocalLocation(tz.getLocation(timeZoneName));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // ¡NUEVO! Asignamos la clave al MaterialApp.
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'App de Sobriedad',
      themeMode: ThemeMode.system,

      //==================================
      //==   TEMA PARA MODO CLARO       ==
      //==================================
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFFFF5EE),
        primaryColor: const Color(0xFF546E7A),
        
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF546E7A),
          elevation: 2.0,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: IconThemeData(
            color: Colors.white,
          ),
        ),
        
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Color(0xFF37474F)),
          bodyMedium: TextStyle(color: Color(0xFF455A64)),
        ),
        
        iconTheme: const IconThemeData(
          color: Color(0xFF546E7A),
        ),
        
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF546E7A),
          unselectedItemColor: Colors.grey[500],
          elevation: 4.0,
        ),
      ),

      //==================================
      //==   TEMA PARA MODO OSCURO      ==
      //==================================
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF212121),
        primaryColor: const Color(0xFF546E7A),
        
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF212121),
          elevation: 0,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: IconThemeData(
            color: Colors.white,
          ),
        ),
        
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: Colors.white.withOpacity(0.9)),
          bodyMedium: TextStyle(color: Colors.white.withOpacity(0.7)),
        ),
        
        iconTheme: IconThemeData(
          color: Colors.white.withOpacity(0.8),
        ),

        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: const Color(0xFF212121),
          selectedItemColor: const Color(0xFFB0BEC5),
          unselectedItemColor: Colors.grey[600],
          elevation: 4.0,
        ),
      ),

      home: const SobrietyCounterApp(),
    );
  }
}
