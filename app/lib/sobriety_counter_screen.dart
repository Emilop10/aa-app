import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

// ─── Paleta "Cálido & Humano" ───────────────────────────
const _kOrange   = Color(0xFFF97316);
const _kCream    = Color(0xFFFFFBF5);
const _kSurface  = Color(0xFFFFF7ED);
const _kBorder   = Color(0xFFFED7AA);
const _kTextPrim = Color(0xFF431407);
const _kTextSec  = Color(0xFF92400E);
const _kDarkBg   = Color(0xFF1A0800);
const _kDarkSurf = Color(0xFF2D1506);

class SobrietyCounter extends StatefulWidget {
  final VoidCallback onDateChanged;
  const SobrietyCounter({super.key, required this.onDateChanged});
  @override
  _SobrietyCounterState createState() => _SobrietyCounterState();
}

class _TimeBreakdown {
  final int years, months, days;
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
    int years  = end.year  - start.year;
    int months = end.month - start.month;
    int days   = end.day   - start.day;
    if (months < 0 || (months == 0 && days < 0)) { years--; months += 12; }
    if (days < 0) {
      months--;
      days += DateTime(end.year, end.month, 0).day;
    }
    return _TimeBreakdown(years: years, months: months, days: days);
  }

  Future<void> _loadSobrietyDate() async {
    final prefs      = await SharedPreferences.getInstance();
    final dateString = prefs.getString('sobrietyDate');
    if (dateString != null && mounted) {
      setState(() {
        sobrietyDate  = DateTime.parse(dateString);
        timeBreakdown = _calculateYearsMonthsDays(sobrietyDate!, DateTime.now());
        _startTimer();
      });
    }
  }

  void _startTimer() {
    _timer?.cancel();
    if (sobrietyDate != null) {
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) setState(() => timeBreakdown =
            _calculateYearsMonthsDays(sobrietyDate!, DateTime.now()));
      });
    }
  }

  Future<void> _setSobrietyDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: sobrietyDate ?? DateTime.now(),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: Theme.of(ctx).colorScheme.copyWith(
            primary: _kOrange, onPrimary: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('sobrietyDate', picked.toIso8601String());
      setState(() => sobrietyDate = picked);
      _startTimer();
      widget.onDateChanged();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark      = Theme.of(context).brightness == Brightness.dark;
    final bgColor     = isDark ? _kDarkBg   : _kCream;
    final surfColor   = isDark ? _kDarkSurf : _kSurface;
    final borderColor = isDark ? Colors.white.withOpacity(0.1) : _kBorder;
    final textPrim    = isDark ? Colors.white : _kTextPrim;

    return Scaffold(
      backgroundColor: bgColor,
      // ── AppBar: crema/oscuro (NO naranja) para separarse del hero ──
      appBar: AppBar(
        title: Text(
          "Contador de Sobriedad",
          style: TextStyle(
            color: textPrim,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: surfColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today, color: _kOrange),
            onPressed: () => _setSobrietyDate(context),
          ),
        ],
      ),
      body: sobrietyDate == null
          ? _buildEmptyState(isDark)
          : _buildBody(isDark, textPrim, surfColor, borderColor),
    );
  }

  // ── Estado vacío (sin fecha) ──────────────────────────────────────
  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_today,
                size: 64, color: _kOrange.withOpacity(0.5)),
            const SizedBox(height: 20),
            Text(
              "Toca el calendario para establecer\ntu fecha de sobriedad.",
              style: TextStyle(
                fontSize: 18,
                color: isDark ? Colors.white70 : _kTextSec,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // ── Cuerpo principal ─────────────────────────────────────────────
  Widget _buildBody(
    bool isDark, Color textPrim, Color surfColor, Color borderColor) {

    final yr  = (timeBreakdown.months / 12 + timeBreakdown.days / 360).clamp(0.0, 1.0);
    final mo  = (timeBreakdown.months / 12.0).clamp(0.0, 1.0);
    final day = (timeBreakdown.days   / 30.44).clamp(0.0, 1.0);

    return SingleChildScrollView(
      child: Column(
        children: [
          // ── Hero naranja con rings blancos ────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 40),
            decoration: const BoxDecoration(
              color: _kOrange,
              borderRadius: BorderRadius.only(
                bottomLeft:  Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularPercentIndicator(
                  radius: 140, lineWidth: 14,
                  percent: yr,
                  progressColor: Colors.white.withOpacity(0.9),
                  backgroundColor: Colors.white.withOpacity(0.2),
                  circularStrokeCap: CircularStrokeCap.round,
                ),
                CircularPercentIndicator(
                  radius: 110, lineWidth: 14,
                  percent: mo,
                  progressColor: Colors.white.withOpacity(0.7),
                  backgroundColor: Colors.white.withOpacity(0.15),
                  circularStrokeCap: CircularStrokeCap.round,
                ),
                CircularPercentIndicator(
                  radius: 80, lineWidth: 14,
                  percent: day,
                  progressColor: Colors.white.withOpacity(0.5),
                  backgroundColor: Colors.white.withOpacity(0.1),
                  circularStrokeCap: CircularStrokeCap.round,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "${timeBreakdown.years} "
                      "${timeBreakdown.years == 1 ? 'año' : 'años'}",
                      style: const TextStyle(
                        fontSize: 28, fontWeight: FontWeight.bold,
                        color: Colors.white),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "${timeBreakdown.months} "
                      "${timeBreakdown.months == 1 ? 'mes' : 'meses'}",
                      style: TextStyle(fontSize: 18,
                          color: Colors.white.withOpacity(0.9)),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "${timeBreakdown.days} "
                      "${timeBreakdown.days == 1 ? 'día' : 'días'}",
                      style: TextStyle(fontSize: 18,
                          color: Colors.white.withOpacity(0.9)),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "sobrio/a y contando",
                      style: TextStyle(
                        fontSize: 14, fontStyle: FontStyle.italic,
                        color: Colors.white.withOpacity(0.85)),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── Tarjetas de estadísticas ──────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
            child: Row(
              children: [
                _StatCard(
                  icon: Icons.emoji_events_outlined,
                  value: timeBreakdown.years,
                  label: "Años",
                  surfColor: surfColor,
                  borderColor: borderColor,
                  textPrim: textPrim,
                ),
                const SizedBox(width: 10),
                _StatCard(
                  icon: Icons.calendar_month_outlined,
                  value: timeBreakdown.months,
                  label: "Meses",
                  surfColor: surfColor,
                  borderColor: borderColor,
                  textPrim: textPrim,
                ),
                const SizedBox(width: 10),
                _StatCard(
                  icon: Icons.today_outlined,
                  value: timeBreakdown.days,
                  label: "Días",
                  surfColor: surfColor,
                  borderColor: borderColor,
                  textPrim: textPrim,
                ),
              ],
            ),
          ),

          // ── Tarjeta de frase ──────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: surfColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderColor),
              ),
              child: Column(
                children: [
                  const Text(
                    '\u201C\u201C',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: _kOrange,
                      height: 0.8,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Un día a la vez',
                    style: TextStyle(
                      fontSize: 18,
                      fontStyle: FontStyle.italic,
                      color: textPrim,
                      fontWeight: FontWeight.w500,
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
}

// ─────────────────────────────────────────────────────────────────
// Widget auxiliar: tarjeta de estadística
// ─────────────────────────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final IconData icon;
  final int value;
  final String label;
  final Color surfColor, borderColor, textPrim;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.surfColor,
    required this.borderColor,
    required this.textPrim,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: surfColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor),
        ),
        child: Column(
          children: [
            Icon(icon, color: _kOrange, size: 26),
            const SizedBox(height: 8),
            Text(
              '$value',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: textPrim,
              ),
            ),
            const SizedBox(height: 2),
            const Text(
              '',
              // el label se pasa abajo
            ),
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: _kTextSec),
            ),
          ],
        ),
      ),
    );
  }
}