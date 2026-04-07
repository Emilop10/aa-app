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
    return DailyReading(
      title: json['title'],
      content: json['content'],
    );
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

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('es_ES', null);
    _selectedDay = _normalizeDate(DateTime.now());
    _focusedDay = _selectedDay!;
    _loadDailyReadings();
  }

  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

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

  // ✅ FIX: busca por mes y día, ignorando el año
  DailyReading? _getReadingForDay(DateTime day) {
    final key = _dailyReadings.keys.firstWhere(
      (date) => date.month == day.month && date.day == day.day,
      orElse: () => DateTime(0),
    );
    return key.year == 0 ? null : _dailyReadings[key];
  }

  String _formatDate(DateTime date) {
    final formattedDate =
        DateFormat('EEEE d \'de\' MMMM \'de\' y', 'es_ES').format(date);
    return formattedDate[0].toUpperCase() + formattedDate.substring(1);
  }

  void _shareReading(DailyReading reading) {
    final String textToShare =
        'Reflexión del día:\n\n*${reading.title}*\n\n${reading.content}';
    Share.share(textToShare);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // ✅ FIX: usa _getReadingForDay en lugar de buscar por clave directa
    final reading =
        _selectedDay != null ? _getReadingForDay(_selectedDay!) : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reflexiones Diarias'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () => _showCalendarDialog(context),
            tooltip: 'Seleccionar Fecha',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              elevation: 4.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: reading != null
                    ? _buildReadingContent(reading, theme)
                    : _buildNoReadingAvailable(theme),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Del libro Reflexiones diarias\nCopyright © 1991 por Alcoholics Anonymous World Services, Inc. Todos los derechos reservados.',
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReadingContent(DailyReading reading, ThemeData theme) {
    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _formatDate(_selectedDay!),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              reading.title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(height: 30, thickness: 1),
            Text(
              reading.content,
              style: theme.textTheme.bodyLarge?.copyWith(
                height: 1.6,
                fontSize: 17,
              ),
              textAlign: TextAlign.left,
            ),
          ],
        ),
        Positioned(
          top: -8,
          right: -8,
          child: IconButton(
            icon: Icon(Icons.share, color: theme.primaryColor),
            onPressed: () => _shareReading(reading),
            tooltip: 'Compartir reflexión',
          ),
        ),
      ],
    );
  }

  Widget _buildNoReadingAvailable(ThemeData theme) {
    return SizedBox(
      width: double.infinity,
      height: 200,
      child: Center(
        child: Text(
          'No hay lectura disponible para esta fecha.',
          style: theme.textTheme.titleMedium
              ?.copyWith(color: Colors.grey),
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
          backgroundColor: theme.cardColor,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
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
                      color: theme.primaryColor.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration: BoxDecoration(
                      color: theme.primaryColor,
                      shape: BoxShape.circle,
                    ),
                    defaultTextStyle: TextStyle(
                        color: isDarkMode
                            ? Colors.white70
                            : Colors.black87),
                    weekendTextStyle: TextStyle(
                        color: isDarkMode
                            ? Colors.white70
                            : Colors.black87),
                    outsideTextStyle: TextStyle(
                        color: isDarkMode
                            ? Colors.white30
                            : Colors.black26),
                  ),
                  headerStyle: HeaderStyle(
                    titleTextStyle: TextStyle(
                        color: theme.textTheme.bodyLarge!.color,
                        fontSize: 18),
                    formatButtonVisible: false,
                    leftChevronIcon: Icon(Icons.chevron_left,
                        color: theme.iconTheme.color),
                    rightChevronIcon: Icon(Icons.chevron_right,
                        color: theme.iconTheme.color),
                  ),
                  daysOfWeekStyle: DaysOfWeekStyle(
                    weekdayStyle:
                        TextStyle(color: theme.primaryColor),
                    weekendStyle: TextStyle(
                        color: theme.primaryColor.withOpacity(0.7)),
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