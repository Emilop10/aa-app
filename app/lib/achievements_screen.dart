import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

// Modelo para los Logros
class Milestone {
  final String name;
  final Duration duration;
  final IconData icon;

  Milestone({required this.name, required this.duration, required this.icon});
}

// Modelo para el desglose de tiempo
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

  // --- ¡NUEVO! Lista de logros extendida hasta 20 años ---
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
    // Forzamos la relectura de la fecha
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
      appBar: AppBar(
        title: const Text("Mis Logros"),
      ),
      body: sobrietyDate == null
          ? _buildSetDateMessage()
          : _buildCounterAndAchievements(),
    );
  }

  Widget _buildSetDateMessage() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Text(
          "Establece tu fecha de sobriedad en la pantalla de 'Inicio' para ver tus logros.",
          style: TextStyle(fontSize: 18, color: Theme.of(context).textTheme.bodyMedium?.color),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildCounterAndAchievements() {
    final breakdown = timeBreakdown!;
    
    Milestone? nextMilestone = _allMilestones.firstWhere(
      (m) => m.duration > breakdown.totalDuration,
      orElse: () => _allMilestones.last,
    );
    
    double progressToNext = 0;
    if (nextMilestone.duration > breakdown.totalDuration) {
       final durationToNext = nextMilestone.duration;
       final previousMilestoneDuration = _allMilestones.lastWhere(
         (m) => m.duration < nextMilestone.duration,
         orElse: () => Milestone(name: '', duration: Duration.zero, icon: Icons.error)
       ).duration;
       
       final totalSteps = (durationToNext - previousMilestoneDuration).inSeconds;
       final currentSteps = (breakdown.totalDuration - previousMilestoneDuration).inSeconds;
       progressToNext = totalSteps > 0 ? (currentSteps / totalSteps).clamp(0.0, 1.0) : 1.0;
    } else {
      progressToNext = 1.0;
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            CircularPercentIndicator(
              radius: 120,
              lineWidth: 18,
              percent: progressToNext,
              center: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "${breakdown.years} ${breakdown.years == 1 ? 'año' : 'años'}",
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "${breakdown.months} ${breakdown.months == 1 ? 'mes' : 'meses'}",
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Text(
                    "${breakdown.days} ${breakdown.days == 1 ? 'día' : 'días'}",
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
              progressColor: Theme.of(context).primaryColor,
              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.2),
              circularStrokeCap: CircularStrokeCap.round,
            ),
            const SizedBox(height: 24),
            Text(
              "Próximo logro: ${nextMilestone.name}",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Logros Desbloqueados",
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12.0,
              runSpacing: 12.0,
              children: _allMilestones.map((milestone) {
                final bool isAchieved = breakdown.totalDuration >= milestone.duration;
                return _buildMilestoneChip(milestone, isAchieved);
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMilestoneChip(Milestone milestone, bool isAchieved) {
    final theme = Theme.of(context);
    final color = isAchieved ? theme.primaryColor : Colors.grey[400];
    final textColor = isAchieved ? (Theme.of(context).brightness == Brightness.dark ? Colors.black : Colors.white) : Colors.white;

    return Chip(
      avatar: Icon(milestone.icon, color: textColor, size: 20),
      label: Text(milestone.name),
      labelStyle: TextStyle(color: textColor, fontWeight: FontWeight.bold),
      backgroundColor: color,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );
  }
}
