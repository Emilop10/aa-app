import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

class SobrietyCounter extends StatefulWidget {
  final VoidCallback onDateChanged;
  const SobrietyCounter({super.key, required this.onDateChanged});

  @override
  _SobrietyCounterState createState() => _SobrietyCounterState();
}

class _TimeBreakdown {
  final int years;
  final int months;
  final int days;
  _TimeBreakdown({required this.years, required this.months, required this.days});
}

class _SobrietyCounterState extends State<SobrietyCounter> {
  DateTime? sobrietyDate;
  _TimeBreakdown timeBreakdown = _TimeBreakdown(years: 0, months: 0, days: 0);
  Timer? _timer;

  // Paleta cálida
  static const kPrimary = Color(0xFFF97316);
  static const kPrimaryDark = Color(0xFFEA580C);
  static const kRing2 = Color(0xFFFB923C);
  static const kRing3 = Color(0xFFFED7AA);
  static const kSurface = Color(0xFFFFF7ED);
  static const kBorder = Color(0xFFFED7AA);
  static const kTextPrimary = Color(0xFF431407);
  static const kTextSecondary = Color(0xFF92400E);

  @override
  void initState() {
    super.initState();
    _loadSobrietyDate();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  _TimeBreakdown _calculateYearsMonthsDays(DateTime start, DateTime end) {
    int years = end.year - start.year;
    int months = end.month - start.month;
    int days = end.day - start.day;

    if (months < 0 || (months == 0 && days < 0)) {
      years--;
      months += 12;
    }
    if (days < 0) {
      months--;
      DateTime lastDayOfPreviousMonth = DateTime(end.year, end.month, 0);
      days += lastDayOfPreviousMonth.day;
    }
    return _TimeBreakdown(years: years, months: months, days: days);
  }

  Future<void> _loadSobrietyDate() async {
    final prefs = await SharedPreferences.getInstance();
    final dateString = prefs.getString('sobrietyDate');
    if (dateString != null) {
      if (mounted) {
        setState(() {
          sobrietyDate = DateTime.parse(dateString);
          timeBreakdown = _calculateYearsMonthsDays(sobrietyDate!, DateTime.now());
          _startTimer();
        });
      }
    }
  }

  void _startTimer() {
    _timer?.cancel();
    if (sobrietyDate != null) {
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (mounted) {
          setState(() {
            timeBreakdown = _calculateYearsMonthsDays(sobrietyDate!, DateTime.now());
          });
        }
      });
    }
  }

  Future<void> _setSobrietyDate(BuildContext context) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: sobrietyDate ?? DateTime.now(),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: kPrimary,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('sobrietyDate', pickedDate.toIso8601String());
      setState(() {
        sobrietyDate = pickedDate;
      });
      _startTimer();
      widget.onDateChanged();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final ringBg = isDarkMode
        ? Colors.white.withOpacity(0.1)
        : kRing3.withOpacity(0.4);

    final double yearsProgress =
        (timeBreakdown.months / 12) + (timeBreakdown.days / (12 * 30));
    final double monthsProgress = timeBreakdown.months / 12.0;
    final double daysProgress = timeBreakdown.days / 30.44;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Contador de Sobriedad"),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () => _setSobrietyDate(context),
          ),
        ],
      ),
      body: sobrietyDate == null
          ? _buildEmpty(context, isDarkMode)
          : SingleChildScrollView(
              child: Column(
                children: [
                  // ── Hero con anillos ──
                  Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [kPrimaryDark, kPrimary],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(36),
                        bottomRight: Radius.circular(36),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 48),
                    child: SizedBox(
                      height: 320,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CircularPercentIndicator(
                            radius: 150,
                            lineWidth: 14,
                            percent: yearsProgress.clamp(0.0, 1.0),
                            progressColor: Colors.white,
                            backgroundColor: Colors.white.withOpacity(0.2),
                            circularStrokeCap: CircularStrokeCap.round,
                          ),
                          CircularPercentIndicator(
                            radius: 118,
                            lineWidth: 14,
                            percent: monthsProgress.clamp(0.0, 1.0),
                            progressColor: kRing3,
                            backgroundColor: Colors.white.withOpacity(0.15),
                            circularStrokeCap: CircularStrokeCap.round,
                          ),
                          CircularPercentIndicator(
                            radius: 86,
                            lineWidth: 14,
                            percent: daysProgress.clamp(0.0, 1.0),
                            progressColor: kRing2,
                            backgroundColor: Colors.white.withOpacity(0.1),
                            circularStrokeCap: CircularStrokeCap.round,
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "${timeBreakdown.years} ${timeBreakdown.years == 1 ? 'año' : 'años'}",
                                style: const TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                "${timeBreakdown.months} ${timeBreakdown.months == 1 ? 'mes' : 'meses'}",
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white.withOpacity(0.85),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                "${timeBreakdown.days} ${timeBreakdown.days == 1 ? 'día' : 'días'}",
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white.withOpacity(0.85),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                "sobrio/a y contando",
                                style: TextStyle(
                                  fontSize: 13,
                                  fontStyle: FontStyle.italic,
                                  color: Colors.white.withOpacity(0.65),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ── Tarjetas de estadísticas ──
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                    child: Row(
                      children: [
                        _statCard(
                          context,
                          isDarkMode,
                          label: "Años",
                          value: "${timeBreakdown.years}",
                          icon: Icons.workspace_premium_outlined,
                        ),
                        const SizedBox(width: 12),
                        _statCard(
                          context,
                          isDarkMode,
                          label: "Meses",
                          value: "${timeBreakdown.months}",
                          icon: Icons.calendar_month_outlined,
                        ),
                        const SizedBox(width: 12),
                        _statCard(
                          context,
                          isDarkMode,
                          label: "Días",
                          value: "${timeBreakdown.days}",
                          icon: Icons.today_outlined,
                        ),
                      ],
                    ),
                  ),

                  // ── Frase motivacional ──
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: isDarkMode
                            ? const Color(0xFF2D1506)
                            : kSurface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDarkMode
                              ? const Color(0xFF92400E)
                              : kBorder,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.format_quote_rounded,
                            color: kPrimary,
                            size: 30,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Un día a la vez",
                            style: TextStyle(
                              fontSize: 18,
                              fontStyle: FontStyle.italic,
                              color: isDarkMode
                                  ? Colors.white.withOpacity(0.8)
                                  : kTextSecondary,
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
  }

  Widget _buildEmpty(BuildContext context, bool isDarkMode) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 60,
              color: kPrimary.withOpacity(0.6),
            ),
            const SizedBox(height: 20),
            Text(
              "Toca el calendario para establecer tu fecha de sobriedad.",
              style: TextStyle(
                fontSize: 18,
                color: isDarkMode
                    ? Colors.white.withOpacity(0.7)
                    : kTextSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _statCard(
    BuildContext context,
    bool isDarkMode, {
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF2D1506) : kSurface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDarkMode ? const Color(0xFF92400E) : kBorder,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: kPrimary, size: 22),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : kTextPrimary,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isDarkMode
                    ? Colors.white.withOpacity(0.6)
                    : kTextSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}