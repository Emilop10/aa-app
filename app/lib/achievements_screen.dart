import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

class Milestone {
  final String name;
  final Duration duration;
  final IconData icon;
  Milestone({required this.name, required this.duration, required this.icon});
}

class _TimeBreakdown {
  final int years;
  final int months;
  final int days;
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

  static const kPrimary = Color(0xFFF97316);
  static const kSurface = Color(0xFFFFF7ED);
  static const kBorder = Color(0xFFFED7AA);
  static const kTextPrimary = Color(0xFF431407);
  static const kTextSecondary = Color(0xFF92400E);

  final List<Milestone> _allMilestones = [
    Milestone(name: '24 Horas', duration: const Duration(days: 1), icon: Icons.shield_outlined),
    Milestone(name: '1 Semana', duration: const Duration(days: 7), icon: Icons.celebration_outlined),
    Milestone(name: '1 Mes', duration: const Duration(days: 30), icon: Icons.star_border),
    Milestone(name: '3 Meses', duration: const Duration(days: 90), icon: Icons.emoji_events_outlined),
    Milestone(name: '6 Meses', duration: const Duration(days: 180), icon: Icons.military_tech_outlined),
    Milestone(name: '1 Año', duration: const Duration(days: 365), icon: Icons.cake_outlined),
    Milestone(name: '2 Años', duration: const Duration(days: 365 * 2), icon: Icons.auto_awesome),
    Milestone(name: '3 Años', duration: const Duration(days: 365 * 3), icon: Icons.workspace_premium_outlined),
    Milestone(name: '5 Años', duration: const Duration(days: 365 * 5), icon: Icons.verified_user_outlined),
    Milestone(name: '10 Años', duration: const Duration(days: 365 * 10), icon: Icons.diamond_outlined),
    Milestone(name: '15 Años', duration: const Duration(days: 365 * 15), icon: Icons.brightness_7_outlined),
    Milestone(name: '20 Años', duration: const Duration(days: 365 * 20), icon: Icons.whatshot_outlined),
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
    final end = DateTime.now();
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
    return _TimeBreakdown(
      years: years,
      months: months,
      days: days,
      totalDuration: end.difference(start),
    );
  }

  Future<void> _loadSobrietyDate() async {
    final prefs = await SharedPreferences.getInstance();
    final dateString = prefs.getString('sobrietyDate');
    if (dateString != null) {
      if (mounted) {
        setState(() {
          sobrietyDate = DateTime.parse(dateString);
          timeBreakdown = _calculateTime(sobrietyDate!);
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
            timeBreakdown = _calculateTime(sobrietyDate!);
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Mis Logros")),
      body: sobrietyDate == null
          ? _buildSetDateMessage()
          : _buildCounterAndAchievements(),
    );
  }

  Widget _buildSetDateMessage() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.emoji_events_outlined, size: 60, color: kPrimary.withOpacity(0.5)),
            const SizedBox(height: 20),
            Text(
              "Establece tu fecha de sobriedad en 'Inicio' para ver tus logros.",
              style: TextStyle(fontSize: 18, color: kTextSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCounterAndAchievements() {
    final breakdown = timeBreakdown!;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    Milestone? nextMilestone = _allMilestones.firstWhere(
      (m) => m.duration > breakdown.totalDuration,
      orElse: () => _allMilestones.last,
    );

    double progressToNext = 0;
    if (nextMilestone.duration > breakdown.totalDuration) {
      final previousMilestoneDuration = _allMilestones.lastWhere(
        (m) => m.duration < nextMilestone.duration,
        orElse: () => Milestone(name: '', duration: Duration.zero, icon: Icons.error),
      ).duration;
      final totalSteps = (nextMilestone.duration - previousMilestoneDuration).inSeconds;
      final currentSteps = (breakdown.totalDuration - previousMilestoneDuration).inSeconds;
      progressToNext = totalSteps > 0 ? (currentSteps / totalSteps).clamp(0.0, 1.0) : 1.0;
    } else {
      progressToNext = 1.0;
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          // ── Header con círculo de progreso ──
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 32),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFEA580C), Color(0xFFF97316)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
            ),
            child: Column(
              children: [
                CircularPercentIndicator(
                  radius: 100,
                  lineWidth: 14,
                  percent: progressToNext,
                  center: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "${breakdown.years}a",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "${breakdown.months}m ${breakdown.days}d",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  progressColor: Colors.white,
                  backgroundColor: Colors.white.withOpacity(0.25),
                  circularStrokeCap: CircularStrokeCap.round,
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "Próximo logro: ${nextMilestone.name}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Lista de logros ──
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Todos los logros",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : kTextPrimary,
                  ),
                ),
                const SizedBox(height: 14),
                ..._allMilestones.map((milestone) {
                  final bool isAchieved = breakdown.totalDuration >= milestone.duration;
                  return _buildMilestoneCard(milestone, isAchieved, isDarkMode);
                }).toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMilestoneCard(Milestone milestone, bool isAchieved, bool isDarkMode) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isAchieved
            ? (isDarkMode ? const Color(0xFF2D1506) : kSurface)
            : (isDarkMode ? const Color(0xFF1C1C1C) : const Color(0xFFF5F5F5)),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isAchieved
              ? (isDarkMode ? const Color(0xFF92400E) : kBorder)
              : (isDarkMode ? Colors.grey[800]! : Colors.grey[200]!),
          width: isAchieved ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          // Ícono
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: isAchieved
                  ? kPrimary
                  : (isDarkMode ? Colors.grey[800] : Colors.grey[200]),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isAchieved ? milestone.icon : Icons.lock_outline,
              color: isAchieved ? Colors.white : Colors.grey,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          // Nombre
          Expanded(
            child: Text(
              milestone.name,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isAchieved ? FontWeight.w600 : FontWeight.normal,
                color: isAchieved
                    ? (isDarkMode ? Colors.white : kTextPrimary)
                    : Colors.grey,
              ),
            ),
          ),
          // Badge o flecha
          if (isAchieved)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: kPrimary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                "✓ Logrado",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          else
            Icon(Icons.lock_outline, color: Colors.grey[400], size: 18),
        ],
      ),
    );
  }
}