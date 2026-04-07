import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:share_plus/share_plus.dart';

class DailyReading {
  final String title;
  final String content;
  DailyReading({required this.title, required this.content});

  factory DailyReading.fromJson(Map<String, dynamic> json) {
    return DailyReading(title: json['title'], content: json['content']);
  }
}

class DailyReadings extends StatefulWidget {
  const DailyReadings({super.key});

  @override
  _DailyReadingsState createState() => _DailyReadingsState();
}

class _DailyReadingsState extends State<DailyReadings> {
  Map<DateTime, DailyReading> _dailyReadings = {};
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  static const kPrimary = Color(0xFFF97316);
  static const kPrimaryDark = Color(0xFFEA580C);
  static const kSurface = Color(0xFFFFF7ED);
  static const kBorder = Color(0xFFFED7AA);
  static const kTextPrimary = Color(0xFF431407);
  static const kTextSecondary = Color(0xFF92400E);

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('es_ES', null);
    _selectedDay = _normalizeDate(DateTime.now());
    _focusedDay = _selectedDay!;
    _loadDailyReadings();
  }

  DateTime _normalizeDate(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  Future<void> _loadDailyReadings() async {
    final jsonString = await rootBundle.loadString('assets/daily_readings.json');
    final Map<String, dynamic> jsonMap = json.decode(jsonString);
    final Map<DateTime, DailyReading> loadedReadings = {};
    jsonMap.forEach((key, value) {
      final date = DateTime.parse(key);
      loadedReadings[_normalizeDate(date)] = DailyReading.fromJson(value);
    });
    if (mounted) {
      setState(() {
        _dailyReadings = loadedReadings;
      });
    }
  }

  String _formatDate(DateTime date) {
    final formattedDate =
        DateFormat("EEEE d 'de' MMMM 'de' y", 'es_ES').format(date);
    return formattedDate[0].toUpperCase() + formattedDate.substring(1);
  }

  void _shareReading(DailyReading reading) {
    final String textToShare =
        'Reflexión del día:\n\n*${reading.title}*\n\n${reading.content}';
    Share.share(textToShare);
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final reading = _selectedDay != null
        ? _dailyReadings[_normalizeDate(_selectedDay!)]
        : null;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ── AppBar con gradiente naranja ──
          SliverAppBar(
            expandedHeight: 130,
            pinned: true,
            backgroundColor: kPrimary,
            iconTheme: const IconThemeData(color: Colors.white),
            actions: [
              IconButton(
                icon: const Icon(Icons.calendar_today, color: Colors.white),
                onPressed: () => _showCalendarDialog(context),
                tooltip: 'Seleccionar Fecha',
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
              title: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Reflexiones Diarias',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (_selectedDay != null)
                    Text(
                      _formatDate(_selectedDay!),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 10,
                        fontWeight: FontWeight.normal,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [kPrimaryDark, kPrimary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
          ),

          // ── Contenido ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Tarjeta de lectura
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: isDarkMode ? const Color(0xFF2D1506) : kSurface,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: isDarkMode
                            ? const Color(0xFF92400E)
                            : kBorder,
                        width: 1,
                      ),
                    ),
                    child: reading != null
                        ? _buildReadingContent(reading, isDarkMode)
                        : _buildNoReadingAvailable(isDarkMode),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Del libro Reflexiones diarias\nCopyright © 1991 por Alcoholics Anonymous World Services, Inc.',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDarkMode
                          ? Colors.white.withOpacity(0.35)
                          : Colors.grey[500],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReadingContent(DailyReading reading, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título con botón compartir
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  reading.title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : kTextPrimary,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.share_outlined),
                color: kPrimary,
                onPressed: () => _shareReading(reading),
                tooltip: 'Compartir reflexión',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 6),
          // Línea divisoria naranja
          Container(
            height: 2,
            width: 48,
            decoration: BoxDecoration(
              color: kPrimary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 18),
          // Contenido
          Text(
            reading.content,
            style: TextStyle(
              fontSize: 17,
              height: 1.7,
              color: isDarkMode
                  ? Colors.white.withOpacity(0.85)
                  : kTextPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoReadingAvailable(bool isDarkMode) {
    return SizedBox(
      width: double.infinity,
      height: 200,
      child: Center(
        child: Text(
          'No hay lectura disponible para esta fecha.',
          style: TextStyle(
            fontSize: 16,
            color: isDarkMode ? Colors.white38 : Colors.grey,
          ),
        ),
      ),
    );
  }

  void _showCalendarDialog(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: isDarkMode
              ? const Color(0xFF2D1506)
              : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TableCalendar(
                  locale: 'es_ES',
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (day) =>
                      isSameDay(_selectedDay, day),
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                    Navigator.of(context).pop();
                  },
                  calendarStyle: CalendarStyle(
                    todayDecoration: BoxDecoration(
                      color: kPrimary.withOpacity(0.4),
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration: const BoxDecoration(
                      color: kPrimary,
                      shape: BoxShape.circle,
                    ),
                    defaultTextStyle: TextStyle(
                      color: isDarkMode ? Colors.white70 : Colors.black87,
                    ),
                    weekendTextStyle: TextStyle(
                      color: isDarkMode ? Colors.white70 : Colors.black87,
                    ),
                    outsideTextStyle: TextStyle(
                      color: isDarkMode ? Colors.white24 : Colors.black26,
                    ),
                  ),
                  headerStyle: HeaderStyle(
                    titleTextStyle: TextStyle(
                      color: isDarkMode ? Colors.white : kTextPrimary,
                      fontSize: 18,
                    ),
                    formatButtonVisible: false,
                    leftChevronIcon: Icon(
                      Icons.chevron_left,
                      color: isDarkMode ? Colors.white70 : kPrimary,
                    ),
                    rightChevronIcon: Icon(
                      Icons.chevron_right,
                      color: isDarkMode ? Colors.white70 : kPrimary,
                    ),
                  ),
                  daysOfWeekStyle: DaysOfWeekStyle(
                    weekdayStyle: const TextStyle(color: kPrimary),
                    weekendStyle: TextStyle(
                      color: kPrimary.withOpacity(0.7),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}