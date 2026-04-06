import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

class SobrietyCounter extends StatefulWidget {
  // Callback para notificar cambios de fecha.
  final VoidCallback onDateChanged;
  const SobrietyCounter({super.key, required this.onDateChanged});

  @override
  _SobrietyCounterState createState() => _SobrietyCounterState();
}

// Estructura para guardar el resultado del cálculo
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
                  primary: const Color(0xFF546E7A),
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
      // Notificamos al widget padre que la fecha cambió.
      widget.onDateChanged();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final mainTextColor = isDarkMode ? Colors.white.withOpacity(0.9) : const Color(0xFF37474F);
    final secondaryTextColor = isDarkMode ? Colors.white.withOpacity(0.7) : const Color(0xFF455A64);
    final accentColor = isDarkMode ? const Color(0xFFB0BEC5) : const Color(0xFF546E7A);
    final ringBackgroundColor = isDarkMode ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.08);

    final ringColor1 = const Color(0xFF546E7A);
    final ringColor2 = const Color(0xFF78909C);
    final ringColor3 = const Color(0xFFB0BEC5);

    final double yearsProgress = (timeBreakdown.months / 12) + (timeBreakdown.days / (12 * 30));
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
      body: Center(
        child: sobrietyDate == null
            ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Text(
                  "Toca el calendario para establecer tu fecha de sobriedad.",
                  style: TextStyle(fontSize: 18, color: secondaryTextColor),
                  textAlign: TextAlign.center,
                ),
              )
            : Stack(
                alignment: Alignment.center,
                children: [
                  CircularPercentIndicator(
                    radius: 160,
                    lineWidth: 15,
                    percent: yearsProgress.clamp(0.0, 1.0),
                    progressColor: ringColor1,
                    backgroundColor: ringBackgroundColor,
                    circularStrokeCap: CircularStrokeCap.round,
                  ),
                  CircularPercentIndicator(
                    radius: 130,
                    lineWidth: 15,
                    percent: monthsProgress.clamp(0.0, 1.0),
                    progressColor: ringColor2,
                    backgroundColor: ringBackgroundColor,
                    circularStrokeCap: CircularStrokeCap.round,
                  ),
                  CircularPercentIndicator(
                    radius: 100,
                    lineWidth: 15,
                    percent: daysProgress.clamp(0.0, 1.0),
                    progressColor: ringColor3,
                    backgroundColor: ringBackgroundColor,
                    circularStrokeCap: CircularStrokeCap.round,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "${timeBreakdown.years} ${timeBreakdown.years == 1 ? 'año' : 'años'}",
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: mainTextColor),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "${timeBreakdown.months} ${timeBreakdown.months == 1 ? 'mes' : 'meses'}",
                        style: TextStyle(fontSize: 18, color: mainTextColor),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "${timeBreakdown.days} ${timeBreakdown.days == 1 ? 'día' : 'días'}",
                        style: TextStyle(fontSize: 18, color: mainTextColor),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "sobrio/a",
                        style: TextStyle(fontSize: 14, color: secondaryTextColor),
                      ),
                      Text(
                        "y contando",
                        style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic, color: accentColor),
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }
}
