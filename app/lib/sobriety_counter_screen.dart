import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:ui';

// ─── Paleta ───────────────────────────────────────────────
const _kOrange     = Color(0xFFF97316);
const _kOrangeDeep = Color(0xFFEA580C);
const _kCream      = Color(0xFFFFFBF5);
const _kSurface    = Color(0xFFFFF7ED);
const _kBorder     = Color(0xFFFED7AA);
const _kTextPrim   = Color(0xFF431407);
const _kTextSec    = Color(0xFF92400E);
const _kDarkBg     = Color(0xFF1A0800);
const _kDarkSurf   = Color(0xFF2D1506);

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

class _SobrietyCounterState extends State<SobrietyCounter>
    with TickerProviderStateMixin {
  DateTime? sobrietyDate;
  _TimeBreakdown timeBreakdown =
      _TimeBreakdown(years: 0, months: 0, days: 0, totalDays: 0);
  Timer? _timer;

  // Animación de pulso en el número grande
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  // Animación de entrada de las cards
  late AnimationController _entryController;
  late Animation<double> _heroFade;
  late Animation<Offset> _heroSlide;
  late Animation<double> _card1Fade;
  late Animation<Offset> _card1Slide;
  late Animation<double> _card2Fade;
  late Animation<Offset> _card2Slide;
  late Animation<double> _card3Fade;
  late Animation<Offset> _card3Slide;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.97, end: 1.03).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _heroFade  = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _entryController, curve: const Interval(0.0, 0.5, curve: Curves.easeOut)));
    _heroSlide = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero).animate(
        CurvedAnimation(parent: _entryController, curve: const Interval(0.0, 0.5, curve: Curves.easeOut)));

    _card1Fade  = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _entryController, curve: const Interval(0.25, 0.65, curve: Curves.easeOut)));
    _card1Slide = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
        CurvedAnimation(parent: _entryController, curve: const Interval(0.25, 0.65, curve: Curves.easeOut)));

    _card2Fade  = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _entryController, curve: const Interval(0.45, 0.8, curve: Curves.easeOut)));
    _card2Slide = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
        CurvedAnimation(parent: _entryController, curve: const Interval(0.45, 0.8, curve: Curves.easeOut)));

    _card3Fade  = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _entryController, curve: const Interval(0.6, 1.0, curve: Curves.easeOut)));
    _card3Slide = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
        CurvedAnimation(parent: _entryController, curve: const Interval(0.6, 1.0, curve: Curves.easeOut)));

    _loadSobrietyDate();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    _entryController.dispose();
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
      _entryController.forward();
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
    DateTime tempDate = sobrietyDate ?? DateTime.now();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    await showCupertinoModalPopup(
      context: context,
      builder: (ctx) {
        return Container(
          height: 340,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1C1C1E) : CupertinoColors.systemBackground,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
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
                      child: Text('Cancelar',
                          style: TextStyle(
                              decoration: TextDecoration.none,
                              color: isDark ? Colors.white60 : Colors.black45)),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                    Text('Fecha de Sobriedad',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.none,
                          color: isDark ? Colors.white : Colors.black,
                        )),
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      child: const Text('Listo',
                          style: TextStyle(
                              decoration: TextDecoration.none,
                              color: _kOrange,
                              fontWeight: FontWeight.w600)),
                      onPressed: () async {
                        Navigator.pop(ctx);
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setString(
                            'sobrietyDate', tempDate.toIso8601String());
                        setState(() => sobrietyDate = tempDate);
                        _startTimer();
                        _entryController.forward(from: 0);
                        widget.onDateChanged();
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date,
                  initialDateTime: sobrietyDate ?? DateTime.now(),
                  maximumDate: DateTime.now(),
                  minimumDate: DateTime(1950),
                  onDateTimeChanged: (d) => tempDate = d,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _fmt(int n) => n.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (m) => '${m[1]},',
      );

  @override
  Widget build(BuildContext context) {
    final isDark      = Theme.of(context).brightness == Brightness.dark;
    final bgColor     = isDark ? _kDarkBg   : _kCream;
    final surfColor   = isDark ? _kDarkSurf : _kSurface;
    final borderColor = isDark ? Colors.white.withOpacity(0.08) : _kBorder;
    final textPrim    = isDark ? Colors.white : _kTextPrim;

    return Scaffold(
      backgroundColor: bgColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 100,
            floating: false,
            pinned: true,
            stretch: true,
            backgroundColor: bgColor,
            elevation: 0,
            scrolledUnderElevation: 0,
            automaticallyImplyLeading: false,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 20, bottom: 14),
              title: Text(
                'Sobriedad',
                style: TextStyle(
                  color: textPrim,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
              ),
              stretchModes: const [StretchMode.fadeTitle],
            ),
            // Botón editar fecha movido abajo del título, no en actions
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => _setSobrietyDate(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: _kOrange,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Editar fecha',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: sobrietyDate == null
                ? _buildEmptyState(isDark, textPrim)
                : _buildBody(isDark, textPrim, surfColor, borderColor),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDark, Color textPrim) {
    return SizedBox(
      height: 500,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: _kOrange.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(CupertinoIcons.calendar,
                    size: 38, color: _kOrange),
              ),
              const SizedBox(height: 24),
              Text(
                'Registra tu fecha\nde sobriedad',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: textPrim,
                  height: 1.3,
                  letterSpacing: -0.3,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                'Toca "Editar fecha" arriba para comenzar.',
                style: TextStyle(
                  fontSize: 15,
                  color: isDark ? Colors.white38 : _kTextSec,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody(
      bool isDark, Color textPrim, Color surfColor, Color borderColor) {
    final tb = timeBreakdown;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [

          // ── Hero Card con animación de entrada ───────────────
          FadeTransition(
            opacity: _heroFade,
            child: SlideTransition(
              position: _heroSlide,
              child: _HeroCard(
                isDark: isDark,
                totalDays: _fmt(tb.totalDays),
                pulseAnimation: _pulseAnimation,
              ),
            ),
          ),

          const SizedBox(height: 12),

          // ── Stat cards con animación escalonada ──────────────
          FadeTransition(
            opacity: _card1Fade,
            child: SlideTransition(
              position: _card1Slide,
              child: Row(
                children: [
                  _MiniStatCard(
                    value: '${tb.years}',
                    label: tb.years == 1 ? 'año' : 'años',
                    icon: CupertinoIcons.rosette,
                    isDark: isDark,
                    surfColor: surfColor,
                    borderColor: borderColor,
                    textPrim: textPrim,
                  ),
                  const SizedBox(width: 10),
                  _MiniStatCard(
                    value: '${tb.months}',
                    label: tb.months == 1 ? 'mes' : 'meses',
                    icon: CupertinoIcons.calendar,
                    isDark: isDark,
                    surfColor: surfColor,
                    borderColor: borderColor,
                    textPrim: textPrim,
                  ),
                  const SizedBox(width: 10),
                  _MiniStatCard(
                    value: '${tb.days}',
                    label: tb.days == 1 ? 'día' : 'días',
                    icon: CupertinoIcons.sun_max,
                    isDark: isDark,
                    surfColor: surfColor,
                    borderColor: borderColor,
                    textPrim: textPrim,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // ── Frase motivacional ────────────────────────────────
          FadeTransition(
            opacity: _card2Fade,
            child: SlideTransition(
              position: _card2Slide,
              child: _QuoteCard(
                isDark: isDark,
                surfColor: surfColor,
                borderColor: borderColor,
                textPrim: textPrim,
              ),
            ),
          ),

          const SizedBox(height: 12),

          // ── Fecha de inicio ───────────────────────────────────
          FadeTransition(
            opacity: _card3Fade,
            child: SlideTransition(
              position: _card3Slide,
              child: _StartDateCard(
                date: sobrietyDate!,
                isDark: isDark,
                surfColor: surfColor,
                borderColor: borderColor,
                textPrim: textPrim,
                onEdit: () => _setSobrietyDate(context),
              ),
            ),
          ),

        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Hero Card
// ─────────────────────────────────────────────────────────────────
class _HeroCard extends StatelessWidget {
  final bool isDark;
  final String totalDays;
  final Animation<double> pulseAnimation;

  const _HeroCard({
    required this.isDark,
    required this.totalDays,
    required this.pulseAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 220,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [Color(0xFFF97316), Color(0xFFEA580C), Color(0xFFC2410C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: _kOrange.withOpacity(isDark ? 0.5 : 0.35),
            blurRadius: 28,
            offset: const Offset(0, 10),
            spreadRadius: -4,
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -30,
            top: -30,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.07),
              ),
            ),
          ),
          Positioned(
            left: -20,
            bottom: -40,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        children: [
                          Icon(CupertinoIcons.heart_fill,
                              color: Colors.white, size: 11),
                          SizedBox(width: 5),
                          Text(
                            'EN RECUPERACIÓN',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.8,
                              decoration: TextDecoration.none,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                ScaleTransition(
                  scale: pulseAnimation,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          totalDays,
                          style: const TextStyle(
                            fontSize: 80,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            height: 1.0,
                            letterSpacing: -3,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'días sobrio/a',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.8),
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.2,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Mini stat cards
// ─────────────────────────────────────────────────────────────────
class _MiniStatCard extends StatelessWidget {
  final String value, label;
  final IconData icon;
  final bool isDark;
  final Color surfColor, borderColor, textPrim;

  const _MiniStatCard({
    required this.value,
    required this.label,
    required this.icon,
    required this.isDark,
    required this.surfColor,
    required this.borderColor,
    required this.textPrim,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 18),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withOpacity(0.06)
                  : Colors.white.withOpacity(0.7),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark
                    ? Colors.white.withOpacity(0.1)
                    : Colors.white.withOpacity(0.8),
                width: 0.8,
              ),
            ),
            child: Column(
              children: [
                Icon(icon, color: _kOrange, size: 22),
                const SizedBox(height: 8),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: textPrim,
                    letterSpacing: -0.5,
                    decoration: TextDecoration.none,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white38 : _kTextSec,
                    fontWeight: FontWeight.w500,
                    decoration: TextDecoration.none,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Quote Card
// ─────────────────────────────────────────────────────────────────
class _QuoteCard extends StatelessWidget {
  final bool isDark;
  final Color surfColor, borderColor, textPrim;

  const _QuoteCard({
    required this.isDark,
    required this.surfColor,
    required this.borderColor,
    required this.textPrim,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withOpacity(0.06)
                : Colors.white.withOpacity(0.7),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark
                  ? Colors.white.withOpacity(0.1)
                  : Colors.white.withOpacity(0.8),
              width: 0.8,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: _kOrange.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(CupertinoIcons.quote_bubble,
                    color: _kOrange, size: 18),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  'Un día a la vez',
                  style: TextStyle(
                    fontSize: 17,
                    fontStyle: FontStyle.italic,
                    color: textPrim,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.1,
                    decoration: TextDecoration.none,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Start Date Card
// ─────────────────────────────────────────────────────────────────
class _StartDateCard extends StatelessWidget {
  final DateTime date;
  final bool isDark;
  final Color surfColor, borderColor, textPrim;
  final VoidCallback onEdit;

  const _StartDateCard({
    required this.date,
    required this.isDark,
    required this.surfColor,
    required this.borderColor,
    required this.textPrim,
    required this.onEdit,
  });

  String _formatDate(DateTime d) {
    const months = [
      'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
      'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre'
    ];
    return '${d.day} de ${months[d.month - 1]} de ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withOpacity(0.06)
                : Colors.white.withOpacity(0.7),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark
                  ? Colors.white.withOpacity(0.1)
                  : Colors.white.withOpacity(0.8),
              width: 0.8,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: _kOrange.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(CupertinoIcons.flag,
                    color: _kOrange, size: 17),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Fecha de inicio',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white38 : _kTextSec,
                        fontWeight: FontWeight.w500,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatDate(date),
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: textPrim,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ],
                ),
              ),
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: onEdit,
                child: const Icon(CupertinoIcons.chevron_right,
                    color: _kOrange, size: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
