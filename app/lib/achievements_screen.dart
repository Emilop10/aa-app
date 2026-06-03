import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:ui';

// ─── Paleta ───────────────────────────────────────────────
const _kOrange    = Color(0xFFF97316);
const _kCream     = Color(0xFFFFFBF5);
const _kSurface   = Color(0xFFFFF7ED);
const _kBorder    = Color(0xFFFED7AA);
const _kTextPrim  = Color(0xFF431407);
const _kTextSec   = Color(0xFF92400E);
const _kDarkBg    = Color(0xFF1A0800);
const _kDarkSurf  = Color(0xFF2D1506);

class Milestone {
  final String name;
  final Duration duration;
  final IconData icon;
  Milestone({required this.name, required this.duration, required this.icon});
}

class _TimeBreakdown {
  final int years, months, days;
  final Duration totalDuration;
  _TimeBreakdown({
    required this.years,
    required this.months,
    required this.days,
    required this.totalDuration,
  });
}

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  _AchievementsScreenState createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  DateTime? sobrietyDate;
  _TimeBreakdown? timeBreakdown;
  Timer? _timer;

  final List<Milestone> _allMilestones = [
    Milestone(name: '24 Horas',  duration: const Duration(days: 1),        icon: CupertinoIcons.shield),
    Milestone(name: '1 Semana',  duration: const Duration(days: 7),        icon: CupertinoIcons.sparkles),
    Milestone(name: '1 Mes',     duration: const Duration(days: 30),       icon: CupertinoIcons.star),
    Milestone(name: '3 Meses',   duration: const Duration(days: 90),       icon: CupertinoIcons.rosette),
    Milestone(name: '6 Meses',   duration: const Duration(days: 180),      icon: CupertinoIcons.bolt),
    Milestone(name: '1 Año',     duration: const Duration(days: 365),      icon: CupertinoIcons.gift),
    Milestone(name: '2 Años',    duration: const Duration(days: 365 * 2),  icon: CupertinoIcons.flame),
    Milestone(name: '3 Años',    duration: const Duration(days: 365 * 3),  icon: CupertinoIcons.crown),
    Milestone(name: '5 Años',    duration: const Duration(days: 365 * 5),  icon: CupertinoIcons.checkmark_seal),
    Milestone(name: '10 Años',   duration: const Duration(days: 365 * 10), icon: CupertinoIcons.diamond),
    Milestone(name: '15 Años',   duration: const Duration(days: 365 * 15), icon: CupertinoIcons.sun_max),
    Milestone(name: '20 Años',   duration: const Duration(days: 365 * 20), icon: CupertinoIcons.infinite),
  ];

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

  _TimeBreakdown _calculateTime(DateTime start) {
    final end    = DateTime.now();
    int years    = end.year  - start.year;
    int months   = end.month - start.month;
    int days     = end.day   - start.day;
    if (months < 0 || (months == 0 && days < 0)) { years--; months += 12; }
    if (days < 0) { months--; days += DateTime(end.year, end.month, 0).day; }
    return _TimeBreakdown(
      years: years, months: months, days: days,
      totalDuration: end.difference(start),
    );
  }

  Future<void> _loadSobrietyDate() async {
    final prefs      = await SharedPreferences.getInstance();
    final dateString = prefs.getString('sobrietyDate');
    if (dateString != null && mounted) {
      setState(() {
        sobrietyDate  = DateTime.parse(dateString);
        timeBreakdown = _calculateTime(sobrietyDate!);
        _startTimer();
      });
    }
  }

  void _startTimer() {
    _timer?.cancel();
    if (sobrietyDate != null) {
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) setState(() => timeBreakdown = _calculateTime(sobrietyDate!));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark     = Theme.of(context).brightness == Brightness.dark;
    final bgColor    = isDark ? _kDarkBg : _kCream;
    final textPrim   = isDark ? Colors.white : _kTextPrim;

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
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 20, bottom: 14),
              title: Text(
                'Logros',
                style: TextStyle(
                  color: textPrim,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
              ),
              stretchModes: const [StretchMode.fadeTitle],
            ),
          ),
          SliverToBoxAdapter(
            child: sobrietyDate == null
                ? _buildEmptyState(isDark, textPrim)
                : _buildContent(isDark, textPrim),
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
                width: 80, height: 80,
                decoration: BoxDecoration(
                  color: _kOrange.withOpacity(0.12), shape: BoxShape.circle,
                ),
                child: const Icon(CupertinoIcons.star, size: 38, color: _kOrange),
              ),
              const SizedBox(height: 24),
              Text(
                'Establece tu fecha de\nsobriedad en Inicio\npara ver tus logros.',
                style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.w700,
                  color: textPrim, height: 1.4, letterSpacing: -0.3,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(bool isDark, Color textPrim) {
    final breakdown = timeBreakdown!;

    Milestone nextMilestone = _allMilestones.firstWhere(
      (m) => m.duration > breakdown.totalDuration,
      orElse: () => _allMilestones.last,
    );

    double progressToNext = 0;
    if (nextMilestone.duration > breakdown.totalDuration) {
      final prevDuration = _allMilestones.lastWhere(
        (m) => m.duration < nextMilestone.duration,
        orElse: () => Milestone(name: '', duration: Duration.zero, icon: CupertinoIcons.circle),
      ).duration;
      final totalSteps   = (nextMilestone.duration - prevDuration).inSeconds;
      final currentSteps = (breakdown.totalDuration - prevDuration).inSeconds;
      progressToNext = totalSteps > 0 ? (currentSteps / totalSteps).clamp(0.0, 1.0) : 1.0;
    } else {
      progressToNext = 1.0;
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Hero Card con círculo de progreso ──
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
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
            child: Column(
              children: [
                CircularPercentIndicator(
                  radius: 90,
                  lineWidth: 12,
                  percent: progressToNext,
                  center: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${breakdown.years}a',
                        style: const TextStyle(
                          color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${breakdown.months}m ${breakdown.days}d',
                        style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13),
                      ),
                    ],
                  ),
                  progressColor: Colors.white,
                  backgroundColor: Colors.white.withOpacity(0.25),
                  circularStrokeCap: CircularStrokeCap.round,
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Próximo logro: ${nextMilestone.name}',
                    style: const TextStyle(
                      color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ── Título lista ──
          Text(
            'Todos los logros',
            style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.w700,
              color: textPrim, letterSpacing: -0.3,
            ),
          ),

          const SizedBox(height: 12),

          // ── Lista de milestones ──
          ..._allMilestones.map((milestone) {
            final isAchieved = breakdown.totalDuration >= milestone.duration;
            return _buildMilestoneCard(milestone, isAchieved, isDark, textPrim);
          }),
        ],
      ),
    );
  }

  Widget _buildMilestoneCard(Milestone milestone, bool isAchieved, bool isDark, Color textPrim) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: isAchieved
                  ? (isDark ? _kOrange.withOpacity(0.15) : Colors.white.withOpacity(0.85))
                  : (isDark ? Colors.white.withOpacity(0.04) : Colors.white.withOpacity(0.5)),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isAchieved
                    ? (isDark ? _kOrange.withOpacity(0.4) : _kBorder)
                    : (isDark ? Colors.white.withOpacity(0.06) : Colors.white.withOpacity(0.6)),
                width: isAchieved ? 1.2 : 0.8,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    color: isAchieved
                        ? _kOrange
                        : (isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.05)),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isAchieved ? milestone.icon : CupertinoIcons.lock,
                    color: isAchieved ? Colors.white : (isDark ? Colors.white24 : Colors.black26),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    milestone.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: isAchieved ? FontWeight.w600 : FontWeight.w400,
                      color: isAchieved
                          ? textPrim
                          : (isDark ? Colors.white30 : Colors.black38),
                    ),
                  ),
                ),
                if (isAchieved)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: _kOrange, borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      '✓ Logrado',
                      style: TextStyle(
                        color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                else
                  Icon(CupertinoIcons.lock,
                      color: isDark ? Colors.white24 : Colors.black26, size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
