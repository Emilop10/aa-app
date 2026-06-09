import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:ui';
import 'package:table_calendar/table_calendar.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_colors.dart';

// ─── Paleta ───────────────────────────────────────────────
const _kCream    = Color(0xFFFFFBF5);
const _kTextPrim = Color(0xFF431407);
const _kTextSec  = Color(0xFF92400E);
const _kDarkBg   = Color(0xFF1A0800);

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

class _DailyReadingsState extends State<DailyReadings>
    with TickerProviderStateMixin {
  Map<DateTime, DailyReading> _dailyReadings = {};
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  int _readingStreak = 0;

  // Respiración de fondo
  late AnimationController _bgBreathController;
  late Animation<double> _bgBreath;

  // Entrada escalonada
  late AnimationController _entryController;
  late Animation<double> _cardFade;
  late Animation<Offset> _cardSlide;
  late Animation<double> _copyrightFade;
  late Animation<Offset> _copyrightSlide;

  @override
  void initState() {
    super.initState();

    // Respiración de fondo
    _bgBreathController = AnimationController(vsync: this, duration: const Duration(seconds: 7))..repeat(reverse: true);
    _bgBreath = Tween<double>(begin: 0.03, end: 0.09).animate(
        CurvedAnimation(parent: _bgBreathController, curve: Curves.easeInOut));

    // Entrada escalonada
    _entryController = AnimationController(vsync: this, duration: const Duration(milliseconds: 950));
    _cardFade      = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _entryController, curve: const Interval(0.0, 0.6, curve: Curves.easeOut)));
    _cardSlide     = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero).animate(CurvedAnimation(parent: _entryController, curve: const Interval(0.0, 0.6, curve: Curves.easeOut)));
    _copyrightFade = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _entryController, curve: const Interval(0.5, 1.0, curve: Curves.easeOut)));
    _copyrightSlide = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(CurvedAnimation(parent: _entryController, curve: const Interval(0.5, 1.0, curve: Curves.easeOut)));

    initializeDateFormatting('es_ES', null);
    _selectedDay = _normalizeDate(DateTime.now());
    _focusedDay  = _selectedDay!;
    _loadStreak();
    _loadDailyReadings();
  }

  @override
  void dispose() {
    _bgBreathController.dispose();
    _entryController.dispose();
    super.dispose();
  }

  DateTime _normalizeDate(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  Future<void> _loadStreak() async {
    final prefs = await SharedPreferences.getInstance();
    final streak = prefs.getInt('reading_streak') ?? 0;
    if (mounted) {
      setState(() => _readingStreak = streak);
    }
  }

  Future<void> _updateStreak() async {
    final prefs = await SharedPreferences.getInstance();
    final lastDateStr = prefs.getString('last_reading_date');
    final streak = prefs.getInt('reading_streak') ?? 0;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    final lastDate = lastDateStr != null ? DateTime.parse(lastDateStr) : null;

    int newStreak;
    if (lastDate == today) {
      return; // already counted today
    } else if (lastDate == yesterday) {
      newStreak = streak + 1;
    } else {
      newStreak = 1;
    }

    await prefs.setString('last_reading_date', today.toIso8601String());
    await prefs.setInt('reading_streak', newStreak);

    if (mounted) {
      setState(() => _readingStreak = newStreak);
    }
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
      setState(() => _dailyReadings = loadedReadings);
      _entryController.forward();
      // Update streak if there is a reading for today
      final today = _normalizeDate(DateTime.now());
      if (_getReadingForDayFromMap(loadedReadings, today) != null) {
        _updateStreak();
      }
    }
  }

  DailyReading? _getReadingForDayFromMap(Map<DateTime, DailyReading> map, DateTime day) {
    for (final entry in map.entries) {
      if (entry.key.month == day.month && entry.key.day == day.day) {
        return entry.value;
      }
    }
    return null;
  }

  DailyReading? _getReadingForDay(DateTime day) {
    for (final entry in _dailyReadings.entries) {
      if (entry.key.month == day.month && entry.key.day == day.day) {
        return entry.value;
      }
    }
    return null;
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

  void _showCalendarModal(BuildContext context, Color primary) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showCupertinoModalPopup(
      context: context,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1C1C1E) : CupertinoColors.systemBackground,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.black12,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: Text('Cerrar',
                        style: TextStyle(
                            color: isDark ? Colors.white60 : Colors.black45)),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                  Text(
                    'Seleccionar Fecha',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.none,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(width: 60),
                ],
              ),
            ),
            Expanded(
              child: TableCalendar(
                  locale: 'es_ES',
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay  = focusedDay;
                    });
                    final today = _normalizeDate(DateTime.now());
                    if (_normalizeDate(selectedDay) == today) {
                      _updateStreak();
                    }
                    Navigator.pop(ctx);
                  },
                  calendarStyle: CalendarStyle(
                    todayDecoration: BoxDecoration(
                      color: primary.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration: BoxDecoration(
                      color: primary,
                      shape: BoxShape.circle,
                    ),
                    defaultTextStyle: TextStyle(
                        fontSize: 14,
                        decoration: TextDecoration.none,
                        color: isDark ? Colors.white70 : Colors.black87),
                    weekendTextStyle: TextStyle(
                        fontSize: 14,
                        decoration: TextDecoration.none,
                        color: isDark ? Colors.white70 : Colors.black87),
                    outsideTextStyle: TextStyle(
                        fontSize: 14,
                        decoration: TextDecoration.none,
                        color: isDark ? Colors.white30 : Colors.black26),
                    todayTextStyle: const TextStyle(
                        fontSize: 14,
                        decoration: TextDecoration.none,
                        color: Colors.white,
                        fontWeight: FontWeight.w600),
                    selectedTextStyle: const TextStyle(
                        fontSize: 14,
                        decoration: TextDecoration.none,
                        color: Colors.white,
                        fontWeight: FontWeight.w600),
                  ),
                  headerStyle: HeaderStyle(
                    titleTextStyle: TextStyle(
                        color: isDark ? Colors.white : Colors.black,
                        fontSize: 17,
                        decoration: TextDecoration.none,
                        fontWeight: FontWeight.w600),
                    formatButtonVisible: false,
                    leftChevronIcon: Icon(CupertinoIcons.chevron_left,
                        color: isDark ? Colors.white70 : Colors.black54, size: 18),
                    rightChevronIcon: Icon(CupertinoIcons.chevron_right,
                        color: isDark ? Colors.white70 : Colors.black54, size: 18),
                  ),
                  daysOfWeekStyle: DaysOfWeekStyle(
                    weekdayStyle: TextStyle(color: primary, fontSize: 12, decoration: TextDecoration.none, fontWeight: FontWeight.w600),
                    weekendStyle: TextStyle(color: primary.withOpacity(0.7), fontSize: 12, decoration: TextDecoration.none, fontWeight: FontWeight.w600),
                  ),
                  calendarBuilders: const CalendarBuilders(
                    markerBuilder: null,
                  ),
                  eventLoader: null,
                ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Color>(
      valueListenable: appPrimaryColor,
      builder: (context, primary, child) {
        final isDark   = Theme.of(context).brightness == Brightness.dark;
        final bgColor  = isDark ? _kDarkBg : _kCream;
        final textPrim = isDark ? Colors.white : _kTextPrim;
        final reading  = _selectedDay != null ? _getReadingForDay(_selectedDay!) : null;

        return Scaffold(
          backgroundColor: bgColor,
          body: AnimatedBuilder(
            animation: _bgBreath,
            builder: (context, child) => Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.topCenter,
                  radius: 1.2,
                  colors: [
                    primary.withOpacity(_bgBreath.value),
                    bgColor,
                  ],
                ),
              ),
              child: child,
            ),
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverAppBar(
                  expandedHeight: 100,
                  floating: false,
                  pinned: true,
                  stretch: true,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  scrolledUnderElevation: 0,
                  flexibleSpace: FlexibleSpaceBar(
                    titlePadding: const EdgeInsets.only(left: 20, bottom: 14),
                    title: Text(
                      'Reflexiones',
                      style: TextStyle(
                        color: textPrim,
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                      ),
                    ),
                    stretchModes: const [StretchMode.fadeTitle],
                  ),
                  actions: [
                    if (_readingStreak >= 1)
                      Padding(
                        padding: const EdgeInsets.only(right: 4),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                          decoration: BoxDecoration(
                            color: primary.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: primary.withOpacity(0.4),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            '🔥 $_readingStreak',
                            style: TextStyle(
                              color: primary,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: CupertinoButton(
                        padding: const EdgeInsets.all(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                          decoration: BoxDecoration(
                            color: primary,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(CupertinoIcons.calendar, color: Colors.white, size: 14),
                              SizedBox(width: 5),
                              Text(
                                'Fecha',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        onPressed: () => _showCalendarModal(context, primary),
                      ),
                    ),
                  ],
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Reading card
                        FadeTransition(
                          opacity: _cardFade,
                          child: SlideTransition(
                            position: _cardSlide,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(24),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                child: Container(
                                  padding: const EdgeInsets.all(24),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? Colors.white.withOpacity(0.06)
                                        : Colors.white.withOpacity(0.75),
                                    borderRadius: BorderRadius.circular(24),
                                    border: Border.all(
                                      color: isDark
                                          ? Colors.white.withOpacity(0.1)
                                          : Colors.white.withOpacity(0.8),
                                      width: 0.8,
                                    ),
                                  ),
                                  child: reading != null
                                      ? _buildReadingContent(reading, isDark, textPrim, primary)
                                      : _buildNoReadingAvailable(isDark, textPrim),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Copyright
                        FadeTransition(
                          opacity: _copyrightFade,
                          child: SlideTransition(
                            position: _copyrightSlide,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              child: Text(
                                'Del libro Reflexiones Diarias © 1990 por Alcoholics Anonymous World Services, Inc. Reimpresos con permiso de A.A.W.S., Inc. El permiso para reimprimir este material no significa que A.A. haya revisado o aprobado el contenido de esta publicación, ni que A.A. esté de acuerdo con los puntos de vista aquí expresados.',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isDark ? Colors.white24 : _kTextSec.withOpacity(0.4),
                                  height: 1.5,
                                  fontStyle: FontStyle.italic,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                      ],
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

  Widget _buildReadingContent(DailyReading reading, bool isDark, Color textPrim, Color primary) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Row with date badge and share button
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: primary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _formatDate(_selectedDay!),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            CupertinoButton(
              padding: EdgeInsets.zero,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: primary.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(CupertinoIcons.share, color: primary, size: 17),
              ),
              onPressed: () => _shareReading(reading),
            ),
          ],
        ),
        const SizedBox(height: 20),
        // Title
        Text(
          reading.title,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: textPrim,
            letterSpacing: -0.3,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          height: 1,
          color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.06),
        ),
        const SizedBox(height: 16),
        // Content
        Text(
          reading.content,
          style: TextStyle(
            fontSize: 17,
            height: 1.7,
            color: isDark ? Colors.white.withOpacity(0.85) : _kTextPrim.withOpacity(0.85),
          ),
          textAlign: TextAlign.left,
        ),
      ],
    );
  }

  Widget _buildNoReadingAvailable(bool isDark, Color textPrim) {
    return SizedBox(
      height: 200,
      child: Center(
        child: Text(
          'No hay lectura disponible para esta fecha.',
          style: TextStyle(
            fontSize: 16,
            color: isDark ? Colors.white38 : _kTextSec,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
