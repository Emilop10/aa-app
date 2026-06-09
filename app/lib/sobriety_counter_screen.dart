import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:home_widget/home_widget.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'dart:ui';
import 'app_colors.dart';

const _kCream      = Color(0xFFFFFBF5);
const _kSurface    = Color(0xFFFFF7ED);
const _kBorder     = Color(0xFFFED7AA);
const _kTextPrim   = Color(0xFF431407);
const _kTextSec    = Color(0xFF92400E);
const _kDarkBg     = Color(0xFF1A0800);
const _kDarkSurf   = Color(0xFF2D1506);

const _kQuotes = [
  'Un día a la vez.',
  'Primero lo primero.',
  'Fácilmente y sin esfuerzo.',
  'Sigue viniendo.',
  'Primero lo primero.',
  'Confía en el proceso.',
  'La gratitud es la actitud.',
  'Deja ir y deja a Dios.',
  'Llama antes de caer.',
  'Esto también pasará.',
  'No tienes que sentirte bien para hacer lo correcto.',
  'El éxito es la suma de pequeños esfuerzos repetidos cada día.',
  'Hoy es todo lo que tienes.',
  'La sobriedad es un regalo que te haces a ti mismo.',
  'No estás solo/a en este camino.',
  'Cada día sobrio es una victoria.',
  'La humildad es la base de la recuperación.',
  'Acepta lo que no puedes cambiar.',
  'El programa funciona si lo trabajas.',
  'Mantén la mente abierta.',
  'La recuperación es posible.',
  'Un pensamiento a la vez.',
  'La fe mueve montañas.',
  'Hoy no tengo que beber.',
  'Mi recuperación es mi responsabilidad.',
  'La honestidad es el primer paso.',
  'Pide ayuda antes de necesitarla.',
  'Tus peores días sobrio son mejores que tus mejores días bebiendo.',
  'La serenidad no es la ausencia de conflicto, sino la capacidad de manejarlo.',
  'Perdona, no por ellos, sino por ti.',
  'La esperanza es el ancla del alma.',
  'Cambia lo que puedes, acepta lo que no puedes.',
  'Cada 24 horas es una nueva oportunidad.',
  'El amor es el motor de la recuperación.',
  'No tienes que hacerlo todo hoy.',
  'La paciencia es una virtud en el camino.',
  'Conecta con otros que entienden.',
  'La rendición no es derrota, es liberación.',
  'Haz lo que sabes que es correcto.',
  'La recovery es un maratón, no una carrera.',
  'Tu historia puede ser la esperanza de alguien más.',
  'Permanece presente.',
  'La gratitud abre puertas.',
  'Pequeños pasos llevan lejos.',
  'No compares tus adentros con los afueras de otros.',
  'Tú no causaste esto, no puedes controlarlo, no puedes curarlo.',
  'El servicio sana.',
  'Juntos lo logramos.',
  'Mantente cerca del teléfono.',
  'La oración y la meditación son herramientas, úsalas.',
];

String _todaysQuote() {
  final dayOfYear = DateTime.now().difference(DateTime(DateTime.now().year, 1, 1)).inDays;
  return _kQuotes[dayOfYear % _kQuotes.length];
}

class _SobrietyPeriod {
  final DateTime start;
  final DateTime end;
  final int days;
  _SobrietyPeriod({required this.start, required this.end, required this.days});
  Map<String, dynamic> toJson() => {'start': start.toIso8601String(), 'end': end.toIso8601String(), 'days': days};
  factory _SobrietyPeriod.fromJson(Map<String, dynamic> j) => _SobrietyPeriod(
    start: DateTime.parse(j['start']),
    end: DateTime.parse(j['end']),
    days: j['days'],
  );
}

class SobrietyCounter extends StatefulWidget {
  final VoidCallback onDateChanged;
  const SobrietyCounter({super.key, required this.onDateChanged});
  @override
  _SobrietyCounterState createState() => _SobrietyCounterState();
}

class _TimeBreakdown {
  final int years, months, days, totalDays;
  _TimeBreakdown({required this.years, required this.months, required this.days, required this.totalDays});
}

class _SobrietyCounterState extends State<SobrietyCounter>
    with TickerProviderStateMixin {
  DateTime? sobrietyDate;
  _TimeBreakdown timeBreakdown = _TimeBreakdown(years: 0, months: 0, days: 0, totalDays: 0);
  Timer? _timer;
  List<_SobrietyPeriod> _history = [];
  bool _showHistory = false;

  // Pulso suave del número
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  // Orbes flotantes en la hero card
  late AnimationController _orb1Controller;
  late AnimationController _orb2Controller;
  late AnimationController _orb3Controller;
  late Animation<double> _orb1Anim;
  late Animation<double> _orb2Anim;
  late Animation<double> _orb3Anim;

  // Glow rotante alrededor del número
  late AnimationController _glowController;
  late Animation<double> _glowRotation;
  late Animation<double> _glowOpacity;

  // Respiración del fondo
  late AnimationController _bgBreathController;
  late Animation<double> _bgBreath;

  // Entrada escalonada
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

    // Pulso número
    _pulseController = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.96, end: 1.04).animate(
        CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));

    // Orbes flotantes (distintas velocidades y fases)
    _orb1Controller = AnimationController(vsync: this, duration: const Duration(seconds: 6))..repeat(reverse: true);
    _orb2Controller = AnimationController(vsync: this, duration: const Duration(seconds: 8))..repeat(reverse: true);
    _orb3Controller = AnimationController(vsync: this, duration: const Duration(seconds: 5))..repeat(reverse: true);
    _orb1Anim = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _orb1Controller, curve: Curves.easeInOut));
    _orb2Anim = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _orb2Controller, curve: Curves.easeInOut));
    _orb3Anim = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _orb3Controller, curve: Curves.easeInOut));

    // Glow rotante
    _glowController = AnimationController(vsync: this, duration: const Duration(seconds: 5))..repeat();
    _glowRotation = Tween<double>(begin: 0, end: 2 * math.pi).animate(
        CurvedAnimation(parent: _glowController, curve: Curves.linear));
    _glowOpacity = Tween<double>(begin: 0.3, end: 0.7).animate(
        CurvedAnimation(parent: _glowController, curve: Curves.easeInOut));

    // Respiración de fondo
    _bgBreathController = AnimationController(vsync: this, duration: const Duration(seconds: 7))..repeat(reverse: true);
    _bgBreath = Tween<double>(begin: 0.03, end: 0.09).animate(
        CurvedAnimation(parent: _bgBreathController, curve: Curves.easeInOut));

    // Entrada
    _entryController = AnimationController(vsync: this, duration: const Duration(milliseconds: 950));
    _heroFade  = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _entryController, curve: const Interval(0.0, 0.5, curve: Curves.easeOut)));
    _heroSlide = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero).animate(CurvedAnimation(parent: _entryController, curve: const Interval(0.0, 0.5, curve: Curves.easeOut)));
    _card1Fade  = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _entryController, curve: const Interval(0.25, 0.65, curve: Curves.easeOut)));
    _card1Slide = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(CurvedAnimation(parent: _entryController, curve: const Interval(0.25, 0.65, curve: Curves.easeOut)));
    _card2Fade  = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _entryController, curve: const Interval(0.45, 0.8, curve: Curves.easeOut)));
    _card2Slide = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(CurvedAnimation(parent: _entryController, curve: const Interval(0.45, 0.8, curve: Curves.easeOut)));
    _card3Fade  = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _entryController, curve: const Interval(0.6, 1.0, curve: Curves.easeOut)));
    _card3Slide = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(CurvedAnimation(parent: _entryController, curve: const Interval(0.6, 1.0, curve: Curves.easeOut)));

    _loadSobrietyDate();
    _loadHistory();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    _orb1Controller.dispose();
    _orb2Controller.dispose();
    _orb3Controller.dispose();
    _glowController.dispose();
    _bgBreathController.dispose();
    _entryController.dispose();
    super.dispose();
  }

  _TimeBreakdown _calculateYearsMonthsDays(DateTime start, DateTime end) {
    int years  = end.year  - start.year;
    int months = end.month - start.month;
    int days   = end.day   - start.day;
    if (months < 0 || (months == 0 && days < 0)) { years--; months += 12; }
    if (days < 0) { months--; days += DateTime(end.year, end.month, 0).day; }
    return _TimeBreakdown(years: years, months: months, days: days, totalDays: end.difference(start).inDays);
  }

  Future<void> _loadSobrietyDate() async {
    final prefs = await SharedPreferences.getInstance();
    final dateString = prefs.getString('sobrietyDate');
    if (dateString != null && mounted) {
      setState(() {
        sobrietyDate  = DateTime.parse(dateString);
        timeBreakdown = _calculateYearsMonthsDays(sobrietyDate!, DateTime.now());
        _startTimer();
      });
      _updateWidget();
      _entryController.forward();
    }
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('sobriety_history');
    if (raw != null && mounted) {
      final list = (jsonDecode(raw) as List).map((j) => _SobrietyPeriod.fromJson(j)).toList();
      setState(() => _history = list);
    }
  }

  Future<void> _updateWidget() async {
    if (sobrietyDate == null) return;
    final days = DateTime.now().difference(sobrietyDate!).inDays;
    const months = ["ene","feb","mar","abr","may","jun","jul","ago","sep","oct","nov","dic"];
    final s = sobrietyDate!;
    final startStr = "${s.day} ${months[s.month-1]} ${s.year}";
    await HomeWidget.saveWidgetData<int>("sobriety_days", days);
    await HomeWidget.saveWidgetData<String>("sobriety_start_date", startStr);
    await HomeWidget.updateWidget(name: "SobrietyWidget", iOSName: "SobrietyWidget");
  }

  void _startTimer() {
    _timer?.cancel();
    if (sobrietyDate != null) {
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) setState(() => timeBreakdown = _calculateYearsMonthsDays(sobrietyDate!, DateTime.now()));
      });
    }
  }

  Future<void> _setSobrietyDate(BuildContext context) async {
    DateTime tempDate = sobrietyDate ?? DateTime.now();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = appPrimaryColor.value;

    await showCupertinoModalPopup(
      context: context,
      builder: (ctx) => Container(
        height: 340,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1C1C1E) : CupertinoColors.systemBackground,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 36, height: 4,
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
                    onPressed: () => Navigator.pop(ctx),
                    child: Text('Cancelar', style: TextStyle(decoration: TextDecoration.none, color: isDark ? Colors.white60 : Colors.black45)),
                  ),
                  Text('Fecha de Sobriedad', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, decoration: TextDecoration.none, color: isDark ? Colors.white : Colors.black)),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () async {
                      Navigator.pop(ctx);
                      // Save old period to history
                      if (sobrietyDate != null) {
                        final period = _SobrietyPeriod(
                          start: sobrietyDate!,
                          end: DateTime.now(),
                          days: DateTime.now().difference(sobrietyDate!).inDays,
                        );
                        final newHistory = [period, ..._history];
                        setState(() => _history = newHistory);
                        final prefs2 = await SharedPreferences.getInstance();
                        await prefs2.setString('sobriety_history', jsonEncode(newHistory.map((p) => p.toJson()).toList()));
                      }
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setString('sobrietyDate', tempDate.toIso8601String());
                      setState(() => sobrietyDate = tempDate);
                      _startTimer();
                      _entryController.forward(from: 0);
                      widget.onDateChanged();
                    },
                    child: Text('Listo', style: TextStyle(decoration: TextDecoration.none, color: primary, fontWeight: FontWeight.w600)),
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
      ),
    );
  }

  String _fmt(int n) => n.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Color>(
      valueListenable: appPrimaryColor,
      builder: (context, primary, child) {
        final isDark      = Theme.of(context).brightness == Brightness.dark;
        final bgColor     = isDark ? _kDarkBg : _kCream;
        final surfColor   = isDark ? _kDarkSurf : _kSurface;
        final borderColor = isDark ? Colors.white.withOpacity(0.08) : _kBorder;
        final textPrim    = isDark ? Colors.white : _kTextPrim;

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
                  automaticallyImplyLeading: false,
                  flexibleSpace: FlexibleSpaceBar(
                    titlePadding: const EdgeInsets.only(left: 20, bottom: 14),
                    title: Text('Sobriedad', style: TextStyle(color: textPrim, fontSize: 28, fontWeight: FontWeight.w700, letterSpacing: -0.5, decoration: TextDecoration.none)),
                    stretchModes: const [StretchMode.fadeTitle],
                  ),
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
                            decoration: BoxDecoration(color: primary, borderRadius: BorderRadius.circular(20)),
                            child: const Text('Editar fecha', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600, decoration: TextDecoration.none)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SliverToBoxAdapter(
                  child: sobrietyDate == null
                      ? _buildEmptyState(isDark, textPrim, primary)
                      : _buildBody(isDark, textPrim, surfColor, borderColor, primary),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(bool isDark, Color textPrim, Color primary) {
    return SizedBox(
      height: 500,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80, height: 80,
                decoration: BoxDecoration(color: primary.withOpacity(0.12), shape: BoxShape.circle),
                child: Icon(CupertinoIcons.calendar, size: 38, color: primary),
              ),
              const SizedBox(height: 24),
              Text('Registra tu fecha\nde sobriedad', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: textPrim, height: 1.3, letterSpacing: -0.3, decoration: TextDecoration.none), textAlign: TextAlign.center),
              const SizedBox(height: 10),
              Text('Toca "Editar fecha" arriba para comenzar.', style: TextStyle(fontSize: 15, color: isDark ? Colors.white38 : _kTextSec, height: 1.5, decoration: TextDecoration.none), textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody(bool isDark, Color textPrim, Color surfColor, Color borderColor, Color primary) {
    final tb = timeBreakdown;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FadeTransition(
            opacity: _heroFade,
            child: SlideTransition(
              position: _heroSlide,
              child: _HeroCard(
                isDark: isDark,
                totalDays: _fmt(tb.totalDays),
                pulseAnimation: _pulseAnimation,
                orb1: _orb1Anim,
                orb2: _orb2Anim,
                orb3: _orb3Anim,
                glowRotation: _glowRotation,
                glowOpacity: _glowOpacity,
                primary: primary,
              ),
            ),
          ),
          const SizedBox(height: 12),
          FadeTransition(
            opacity: _card1Fade,
            child: SlideTransition(
              position: _card1Slide,
              child: Row(
                children: [
                  _MiniStatCard(value: '${tb.years}',  label: tb.years  == 1 ? 'año'  : 'años',  icon: CupertinoIcons.rosette,  isDark: isDark, surfColor: surfColor, borderColor: borderColor, textPrim: textPrim, primary: primary),
                  const SizedBox(width: 10),
                  _MiniStatCard(value: '${tb.months}', label: tb.months == 1 ? 'mes'  : 'meses', icon: CupertinoIcons.calendar, isDark: isDark, surfColor: surfColor, borderColor: borderColor, textPrim: textPrim, primary: primary),
                  const SizedBox(width: 10),
                  _MiniStatCard(value: '${tb.days}',   label: tb.days   == 1 ? 'día'  : 'días',  icon: CupertinoIcons.sun_max,  isDark: isDark, surfColor: surfColor, borderColor: borderColor, textPrim: textPrim, primary: primary),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          FadeTransition(
            opacity: _card2Fade,
            child: SlideTransition(
              position: _card2Slide,
              child: _QuoteCard(isDark: isDark, surfColor: surfColor, borderColor: borderColor, textPrim: textPrim, primary: primary, quote: _todaysQuote()),
            ),
          ),
          const SizedBox(height: 12),
          FadeTransition(
            opacity: _card3Fade,
            child: SlideTransition(
              position: _card3Slide,
              child: _StartDateCard(date: sobrietyDate!, isDark: isDark, surfColor: surfColor, borderColor: borderColor, textPrim: textPrim, onEdit: () => _setSobrietyDate(context), primary: primary),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Hero Card con animaciones ambientales
// ─────────────────────────────────────────────────────────────────
class _HeroCard extends StatelessWidget {
  final bool isDark;
  final String totalDays;
  final Animation<double> pulseAnimation;
  final Animation<double> orb1, orb2, orb3;
  final Animation<double> glowRotation, glowOpacity;
  final Color primary;

  const _HeroCard({
    required this.isDark,
    required this.totalDays,
    required this.pulseAnimation,
    required this.orb1,
    required this.orb2,
    required this.orb3,
    required this.glowRotation,
    required this.glowOpacity,
    required this.primary,
  });

  @override
  Widget build(BuildContext context) {
    final deep = appPrimaryDeep(primary);
    final dark = appPrimaryDark(primary);
    return AnimatedBuilder(
      animation: Listenable.merge([pulseAnimation, orb1, orb2, orb3, glowRotation, glowOpacity]),
      builder: (context, _) {
        return Container(
          width: double.infinity,
          height: 240,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: LinearGradient(
              colors: [primary, deep, dark],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: primary.withOpacity(isDark ? 0.5 : 0.35),
                blurRadius: 28,
                offset: const Offset(0, 10),
                spreadRadius: -4,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: Stack(
              children: [
                // Orbe 1 — grande, flota arriba a la derecha
                Positioned(
                  right: -40 + (orb1.value * 20),
                  top:   -40 + (orb1.value * 15),
                  child: Container(
                    width: 160, height: 160,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.10 + orb1.value * 0.05),
                    ),
                  ),
                ),
                // Orbe 2 — mediano, flota abajo a la izquierda
                Positioned(
                  left:   -30 + (orb2.value * 18),
                  bottom: -50 + (orb2.value * 20),
                  child: Container(
                    width: 130, height: 130,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.07 + orb2.value * 0.04),
                    ),
                  ),
                ),
                // Orbe 3 — pequeño, flota al centro derecha
                Positioned(
                  right: 30 + (orb3.value * 15),
                  bottom: 30 + (orb3.value * 10),
                  child: Container(
                    width: 60, height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.08 + orb3.value * 0.06),
                    ),
                  ),
                ),

                // Contenido centrado
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Badge superior
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(CupertinoIcons.heart_fill, color: Colors.white, size: 11),
                            SizedBox(width: 5),
                            Text('EN RECUPERACIÓN', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.8, decoration: TextDecoration.none)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Glow rotante + número
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          // Glow giratorio detrás del número
                          Transform.rotate(
                            angle: glowRotation.value,
                            child: Container(
                              width: 160, height: 160,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: SweepGradient(
                                  colors: [
                                    Colors.white.withOpacity(glowOpacity.value * 0.4),
                                    Colors.transparent,
                                    Colors.white.withOpacity(glowOpacity.value * 0.2),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                          ),
                          // Número animado con pulso
                          ScaleTransition(
                            scale: pulseAnimation,
                            child: Column(
                              children: [
                                Text(
                                  totalDays,
                                  style: const TextStyle(
                                    fontSize: 76,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    height: 1.0,
                                    letterSpacing: -3,
                                    decoration: TextDecoration.none,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 6),
                      Text(
                        'días sobrio/a',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.85),
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.3,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ],
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

// ─────────────────────────────────────────────────────────────────
// Mini stat cards
// ─────────────────────────────────────────────────────────────────
class _MiniStatCard extends StatelessWidget {
  final String value, label;
  final IconData icon;
  final bool isDark;
  final Color surfColor, borderColor, textPrim, primary;

  const _MiniStatCard({required this.value, required this.label, required this.icon, required this.isDark, required this.surfColor, required this.borderColor, required this.textPrim, required this.primary});

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
              color: isDark ? Colors.white.withOpacity(0.06) : Colors.white.withOpacity(0.7),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: isDark ? Colors.white.withOpacity(0.1) : Colors.white.withOpacity(0.8), width: 0.8),
            ),
            child: Column(
              children: [
                Icon(icon, color: primary, size: 22),
                const SizedBox(height: 8),
                Text(value, style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: textPrim, letterSpacing: -0.5, decoration: TextDecoration.none)),
                const SizedBox(height: 2),
                Text(label, style: TextStyle(fontSize: 12, color: isDark ? Colors.white38 : _kTextSec, fontWeight: FontWeight.w500, decoration: TextDecoration.none)),
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
  final Color surfColor, borderColor, textPrim, primary;
  const _QuoteCard({required this.isDark, required this.surfColor, required this.borderColor, required this.textPrim, required this.primary});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withOpacity(0.06) : Colors.white.withOpacity(0.7),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: isDark ? Colors.white.withOpacity(0.1) : Colors.white.withOpacity(0.8), width: 0.8),
          ),
          child: Row(
            children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(color: primary.withOpacity(0.15), shape: BoxShape.circle),
                child: Icon(CupertinoIcons.quote_bubble, color: primary, size: 18),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text('Un día a la vez', style: TextStyle(fontSize: 17, fontStyle: FontStyle.italic, color: textPrim, fontWeight: FontWeight.w500, letterSpacing: 0.1, decoration: TextDecoration.none)),
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
  final Color surfColor, borderColor, textPrim, primary;
  final VoidCallback onEdit;
  const _StartDateCard({required this.date, required this.isDark, required this.surfColor, required this.borderColor, required this.textPrim, required this.onEdit, required this.primary});

  String _formatDate(DateTime d) {
    const months = ['enero','febrero','marzo','abril','mayo','junio','julio','agosto','septiembre','octubre','noviembre','diciembre'];
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
            color: isDark ? Colors.white.withOpacity(0.06) : Colors.white.withOpacity(0.7),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: isDark ? Colors.white.withOpacity(0.1) : Colors.white.withOpacity(0.8), width: 0.8),
          ),
          child: Row(
            children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(color: primary.withOpacity(0.15), shape: BoxShape.circle),
                child: Icon(CupertinoIcons.flag, color: primary, size: 17),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Fecha de inicio', style: TextStyle(fontSize: 12, color: isDark ? Colors.white38 : _kTextSec, fontWeight: FontWeight.w500, decoration: TextDecoration.none)),
                    const SizedBox(height: 2),
                    Text(_formatDate(date), style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: textPrim, decoration: TextDecoration.none)),
                  ],
                ),
              ),
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: onEdit,
                child: Icon(CupertinoIcons.chevron_right, color: primary, size: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
