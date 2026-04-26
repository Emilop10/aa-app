import 'package:flutter/material.dart';
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
  final int years, months, days, totalDays;
  _TimeBreakdown({
    required this.years,
    required this.months,
    required this.days,
    required this.totalDays,
  });
}

class _SobrietyCounterState extends State<SobrietyCounter> {
  DateTime? sobrietyDate;
  _TimeBreakdown timeBreakdown =
      _TimeBreakdown(years: 0, months: 0, days: 0, totalDays: 0);
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
    final totalDays = end.difference(start).inDays;
    return _TimeBreakdown(
        years: years, months: months, days: days, totalDays: totalDays);
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

  // Formatea números con coma de miles: 5516 → "5,516"
  String _fmt(int n) => n.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (m) => '${m[1]},',
      );

  @override
  Widget build(BuildContext context) {
    final isDark      = Theme.of(context).brightness == Brightness.dark;
    final bgColor     = isDark ? _kDarkBg   : _kCream;
    final surfColor   = isDark ? _kDarkSurf : _kSurface;
    final borderColor = isDark ? Colors.white.withOpacity(0.1) : _kBorder;
    final textPrim    = isDark ? Colors.white : _kTextPrim;

    return Scaffold(
      backgroundColor: bgColor,
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

  Widget _buildBody(
      bool isDark, Color textPrim, Color surfColor, Color borderColor) {

    final tb = timeBreakdown;

    final String yLabel = '${tb.years} ${tb.years   == 1 ? "año"  : "años"}';
    final String mLabel = '${tb.months} ${tb.months == 1 ? "mes"  : "meses"}';
    final String dLabel = '${tb.days} ${tb.days     == 1 ? "día"  : "días"}';

    return SingleChildScrollView(
      child: Column(
        children: [

          // ── Hero tipo póster ─────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 44, 24, 36),
            decoration: const BoxDecoration(
              color: _kOrange,
              borderRadius: BorderRadius.only(
                bottomLeft:  Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                // Número grande — el protagonista
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    _fmt(tb.totalDays),
                    style: const TextStyle(
                      fontSize: 96,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.0,
                      letterSpacing: -2,
                    ),
                  ),
                ),

                const SizedBox(height: 6),

                // Etiqueta principal
                Text(
                  'días sobrio/a',
                  style: TextStyle(
                    fontSize: 18,
                    fontStyle: FontStyle.italic,
                    color: Colors.white.withOpacity(0.85),
                    letterSpacing: 0.5,
                  ),
                ),

                const SizedBox(height: 20),

                // Línea divisora sutil
                Container(
                  width: 48,
                  height: 1.5,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.45),
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),

                const SizedBox(height: 20),

                // Desglose: años · meses · días
                Text(
                  '$yLabel  ·  $mLabel  ·  $dLabel',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.white.withOpacity(0.75),
                    letterSpacing: 0.3,
                  ),
                  textAlign: TextAlign.center,
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
                  value: tb.years,
                  label: "Años",
                  surfColor: surfColor,
                  borderColor: borderColor,
                  textPrim: textPrim,
                ),
                const SizedBox(width: 10),
                _StatCard(
                  icon: Icons.calendar_month_outlined,
                  value: tb.months,
                  label: "Meses",
                  surfColor: surfColor,
                  borderColor: borderColor,
                  textPrim: textPrim,
                ),
                const SizedBox(width: 10),
                _StatCard(
                  icon: Icons.today_outlined,
                  value: tb.days,
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
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              decoration: BoxDecoration(
                color: surfColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderColor),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(Icons.format_quote, color: _kOrange, size: 28),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      'Un día a la vez',
                      style: TextStyle(
                        fontSize: 18,
                        fontStyle: FontStyle.italic,
                        color: textPrim,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Transform.scale(
                    scaleX: -1,
                    child: const Icon(Icons.format_quote, color: _kOrange, size: 28),
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