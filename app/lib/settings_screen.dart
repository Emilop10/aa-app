import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:ui';
import 'package:shared_preferences/shared_preferences.dart';
import 'notification_service.dart';
import 'onboarding_screen.dart';
import 'app_colors.dart';

// ─── Paleta ───────────────────────────────────────────────
const _kCream    = Color(0xFFFFFBF5);
const _kTextPrim = Color(0xFF431407);
const _kTextSec  = Color(0xFF92400E);
const _kDarkBg   = Color(0xFF1A0800);

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with TickerProviderStateMixin {
  bool _notificationsEnabled = false;
  TimeOfDay _notificationTime = const TimeOfDay(hour: 9, minute: 0);
  bool _gratitudeNotifEnabled = false;
  TimeOfDay _gratitudeNotifTime = const TimeOfDay(hour: 20, minute: 0);
  Color _selectedColor = const Color(0xFFF97316);
  ThemeMode _selectedThemeMode = ThemeMode.system;

  final String _enabledKey = 'notifications_enabled';
  final String _timeKey    = 'notification_time';

  // Respiración de fondo
  late AnimationController _bgBreathController;
  late Animation<double> _bgBreath;

  // Entrada escalonada
  late AnimationController _entryController;
  late Animation<double> _labelFade;
  late Animation<Offset> _labelSlide;
  late Animation<double> _colorCardFade;
  late Animation<Offset> _colorCardSlide;
  late Animation<double> _card1Fade;
  late Animation<Offset> _card1Slide;
  late Animation<double> _card2Fade;
  late Animation<Offset> _card2Slide;

  @override
  void initState() {
    super.initState();

    // Respiración de fondo
    _bgBreathController = AnimationController(vsync: this, duration: const Duration(seconds: 7))..repeat(reverse: true);
    _bgBreath = Tween<double>(begin: 0.03, end: 0.09).animate(
        CurvedAnimation(parent: _bgBreathController, curve: Curves.easeInOut));

    // Entrada escalonada
    _entryController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1100));
    _labelFade      = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _entryController, curve: const Interval(0.0, 0.35, curve: Curves.easeOut)));
    _labelSlide     = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero).animate(CurvedAnimation(parent: _entryController, curve: const Interval(0.0, 0.35, curve: Curves.easeOut)));
    _colorCardFade  = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _entryController, curve: const Interval(0.15, 0.55, curve: Curves.easeOut)));
    _colorCardSlide = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(CurvedAnimation(parent: _entryController, curve: const Interval(0.15, 0.55, curve: Curves.easeOut)));
    _card1Fade      = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _entryController, curve: const Interval(0.4, 0.75, curve: Curves.easeOut)));
    _card1Slide     = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(CurvedAnimation(parent: _entryController, curve: const Interval(0.4, 0.75, curve: Curves.easeOut)));
    _card2Fade      = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _entryController, curve: const Interval(0.6, 1.0, curve: Curves.easeOut)));
    _card2Slide     = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(CurvedAnimation(parent: _entryController, curve: const Interval(0.6, 1.0, curve: Curves.easeOut)));

    _loadSettings();
  }

  @override
  void dispose() {
    _bgBreathController.dispose();
    _entryController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool(_enabledKey) ?? false;
      final timeString = prefs.getString(_timeKey) ?? '09:00';
      final parts = timeString.split(':');
      _notificationTime = TimeOfDay(
          hour: int.parse(parts[0]), minute: int.parse(parts[1]));
      _gratitudeNotifEnabled = prefs.getBool('gratitude_notif_enabled') ?? false;
      final gratitudeTimeString = prefs.getString('gratitude_notif_time') ?? '20:00';
      final gratitudeParts = gratitudeTimeString.split(':');
      _gratitudeNotifTime = TimeOfDay(
          hour: int.parse(gratitudeParts[0]), minute: int.parse(gratitudeParts[1]));
      _selectedColor = appPrimaryColor.value;
      _selectedThemeMode = appThemeMode.value;
    });
    _entryController.forward();
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_enabledKey, _notificationsEnabled);
    await prefs.setString(
        _timeKey, '${_notificationTime.hour}:${_notificationTime.minute}');
    await prefs.setBool('gratitude_notif_enabled', _gratitudeNotifEnabled);
    await prefs.setString('gratitude_notif_time',
        '${_gratitudeNotifTime.hour}:${_gratitudeNotifTime.minute}');
  }

  void _onNotificationToggle(bool value) {
    setState(() => _notificationsEnabled = value);
    if (_notificationsEnabled) {
      NotificationService.instance.scheduleDailyNotification(_notificationTime);
    } else {
      NotificationService.instance.cancelAllNotifications();
    }
    _saveSettings();
  }

  void _onGratitudeToggle(bool value) {
    setState(() => _gratitudeNotifEnabled = value);
    if (_gratitudeNotifEnabled) {
      NotificationService.instance.scheduleGratitudeNotification(_gratitudeNotifTime);
    } else {
      NotificationService.instance.cancelGratitudeNotification();
    }
    _saveSettings();
  }

  void _selectGratitudeTime(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    int tempHour   = _gratitudeNotifTime.hour;
    int tempMinute = _gratitudeNotifTime.minute;

    showCupertinoModalPopup(
      context: context,
      builder: (ctx) => Container(
        height: 320,
        decoration: BoxDecoration(
          color: isDark
              ? const Color(0xFF1C1C1E)
              : CupertinoColors.systemBackground,
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
                            color: isDark ? Colors.white60 : Colors.black45)),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                  Text(
                    'Hora del Recordatorio',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: Text('Listo',
                        style: TextStyle(
                            color: _selectedColor, fontWeight: FontWeight.w600)),
                    onPressed: () {
                      Navigator.pop(ctx);
                      setState(() => _gratitudeNotifTime =
                          TimeOfDay(hour: tempHour, minute: tempMinute));
                      if (_gratitudeNotifEnabled) {
                        NotificationService.instance
                            .scheduleGratitudeNotification(_gratitudeNotifTime);
                      }
                      _saveSettings();
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: CupertinoTimerPicker(
                mode: CupertinoTimerPickerMode.hm,
                initialTimerDuration: Duration(
                    hours: _gratitudeNotifTime.hour,
                    minutes: _gratitudeNotifTime.minute),
                onTimerDurationChanged: (Duration d) {
                  tempHour   = d.inHours;
                  tempMinute = d.inMinutes % 60;
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatGratitudeTime() {
    final h = _gratitudeNotifTime.hour.toString().padLeft(2, '0');
    final m = _gratitudeNotifTime.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  void _selectTime(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    int tempHour   = _notificationTime.hour;
    int tempMinute = _notificationTime.minute;

    showCupertinoModalPopup(
      context: context,
      builder: (ctx) => Container(
        height: 320,
        decoration: BoxDecoration(
          color: isDark
              ? const Color(0xFF1C1C1E)
              : CupertinoColors.systemBackground,
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
                    child: Text('Cancelar',
                        style: TextStyle(
                            color: isDark ? Colors.white60 : Colors.black45)),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                  Text(
                    'Hora del Recordatorio',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: Text('Listo',
                        style: TextStyle(
                            color: _selectedColor, fontWeight: FontWeight.w600)),
                    onPressed: () {
                      Navigator.pop(ctx);
                      setState(() => _notificationTime =
                          TimeOfDay(hour: tempHour, minute: tempMinute));
                      if (_notificationsEnabled) {
                        NotificationService.instance
                            .scheduleDailyNotification(_notificationTime);
                      }
                      _saveSettings();
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: CupertinoTimerPicker(
                mode: CupertinoTimerPickerMode.hm,
                initialTimerDuration: Duration(
                    hours: _notificationTime.hour,
                    minutes: _notificationTime.minute),
                onTimerDurationChanged: (Duration d) {
                  tempHour   = d.inHours;
                  tempMinute = d.inMinutes % 60;
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime() {
    final h = _notificationTime.hour.toString().padLeft(2, '0');
    final m = _notificationTime.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  Widget _themeSegment({
    required IconData icon,
    required String label,
    required ThemeMode mode,
    required Color primary,
    required bool isDark,
  }) {
    final isSelected = _selectedThemeMode == mode;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() => _selectedThemeMode = mode);
          saveThemeMode(mode);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.all(3),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? primary : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected
                    ? Colors.white
                    : (isDark ? Colors.white54 : Colors.black45),
              ),
              const SizedBox(height: 3),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected
                      ? Colors.white
                      : (isDark ? Colors.white54 : Colors.black45),
                ),
              ),
            ],
          ),
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
                  leading: CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: Icon(CupertinoIcons.chevron_left, color: primary),
                    onPressed: () => Navigator.pop(context),
                  ),
                  flexibleSpace: FlexibleSpaceBar(
                    titlePadding: const EdgeInsets.only(left: 20, bottom: 14),
                    title: Text(
                      'Ajustes',
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
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        // ── Section label: Apariencia ─────────────────
                        FadeTransition(
                          opacity: _labelFade,
                          child: SlideTransition(
                            position: _labelSlide,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 4, bottom: 10),
                              child: Text(
                                'APARIENCIA',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.8,
                                  color: isDark ? Colors.white38 : _kTextSec,
                                ),
                              ),
                            ),
                          ),
                        ),

                        // ── Theme mode card ───────────────────────────
                        FadeTransition(
                          opacity: _colorCardFade,
                          child: SlideTransition(
                            position: _colorCardSlide,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 18, vertical: 16),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? Colors.white.withOpacity(0.06)
                                        : Colors.white.withOpacity(0.75),
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
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: primary.withOpacity(0.15),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(CupertinoIcons.moon_stars,
                                            color: primary, size: 20),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Modo de pantalla',
                                              style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w600,
                                                color: textPrim,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Container(
                                              decoration: BoxDecoration(
                                                color: isDark
                                                    ? Colors.white.withOpacity(0.08)
                                                    : Colors.black.withOpacity(0.06),
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                              child: Row(
                                                children: [
                                                  _themeSegment(
                                                    icon: CupertinoIcons.sun_max,
                                                    label: 'Claro',
                                                    mode: ThemeMode.light,
                                                    primary: primary,
                                                    isDark: isDark,
                                                  ),
                                                  _themeSegment(
                                                    icon: CupertinoIcons.moon,
                                                    label: 'Oscuro',
                                                    mode: ThemeMode.dark,
                                                    primary: primary,
                                                    isDark: isDark,
                                                  ),
                                                  _themeSegment(
                                                    icon: CupertinoIcons.device_phone_portrait,
                                                    label: 'Auto',
                                                    mode: ThemeMode.system,
                                                    primary: primary,
                                                    isDark: isDark,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // ── Color picker card ─────────────────────────
                        FadeTransition(
                          opacity: _colorCardFade,
                          child: SlideTransition(
                            position: _colorCardSlide,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 18, vertical: 18),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? Colors.white.withOpacity(0.06)
                                        : Colors.white.withOpacity(0.75),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: isDark
                                          ? Colors.white.withOpacity(0.1)
                                          : Colors.white.withOpacity(0.8),
                                      width: 0.8,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            width: 40,
                                            height: 40,
                                            decoration: BoxDecoration(
                                              color: primary.withOpacity(0.15),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(CupertinoIcons.paintbrush,
                                                color: primary, size: 20),
                                          ),
                                          const SizedBox(width: 14),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Color del tema',
                                                  style: TextStyle(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.w600,
                                                    color: textPrim,
                                                  ),
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  'Personaliza el color principal de la app',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: isDark
                                                        ? Colors.white38
                                                        : _kTextSec,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      GridView.builder(
                                        shrinkWrap: true,
                                        physics: const NeverScrollableScrollPhysics(),
                                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 8,
                                          crossAxisSpacing: 10,
                                          mainAxisSpacing: 10,
                                        ),
                                        itemCount: kColorOptions.length,
                                        itemBuilder: (context, index) {
                                          final option = kColorOptions[index];
                                          final isSelected = _selectedColor.value == option.color.value;
                                          return GestureDetector(
                                            onTap: () {
                                              setState(() => _selectedColor = option.color);
                                              saveColor(option.color);
                                            },
                                            child: AnimatedContainer(
                                              duration: const Duration(milliseconds: 200),
                                              decoration: BoxDecoration(
                                                color: option.color,
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  color: isSelected
                                                      ? Colors.white
                                                      : Colors.transparent,
                                                  width: isSelected ? 3 : 0,
                                                ),
                                                boxShadow: isSelected
                                                    ? [
                                                        BoxShadow(
                                                          color: option.color.withOpacity(0.5),
                                                          blurRadius: 8,
                                                          spreadRadius: 1,
                                                        )
                                                      ]
                                                    : [],
                                              ),
                                              child: isSelected
                                                  ? const Icon(Icons.check,
                                                      color: Colors.white, size: 16)
                                                  : null,
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // ── Section label: Notificaciones ─────────────
                        FadeTransition(
                          opacity: _card1Fade,
                          child: SlideTransition(
                            position: _card1Slide,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 4, bottom: 10),
                              child: Text(
                                'NOTIFICACIONES',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.8,
                                  color: isDark ? Colors.white38 : _kTextSec,
                                ),
                              ),
                            ),
                          ),
                        ),

                        // ── Notifications toggle card ─────────────────
                        FadeTransition(
                          opacity: _card1Fade,
                          child: SlideTransition(
                            position: _card1Slide,
                            child: ClipRRect(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(20),
                                topRight: Radius.circular(20),
                                bottomLeft: Radius.circular(4),
                                bottomRight: Radius.circular(4),
                              ),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 18, vertical: 16),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? Colors.white.withOpacity(0.06)
                                        : Colors.white.withOpacity(0.75),
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(20),
                                      topRight: Radius.circular(20),
                                      bottomLeft: Radius.circular(4),
                                      bottomRight: Radius.circular(4),
                                    ),
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
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: primary.withOpacity(0.15),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(CupertinoIcons.bell,
                                            color: primary, size: 20),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Notificaciones Diarias',
                                              style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w600,
                                                color: textPrim,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              'Recordatorio para tu reflexión diaria',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: isDark
                                                    ? Colors.white38
                                                    : _kTextSec,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      CupertinoSwitch(
                                        value: _notificationsEnabled,
                                        activeColor: primary,
                                        onChanged: _onNotificationToggle,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 2),

                        // ── Time picker card ──────────────────────────
                        FadeTransition(
                          opacity: _card2Fade,
                          child: SlideTransition(
                            position: _card2Slide,
                            child: GestureDetector(
                              onTap: _notificationsEnabled
                                  ? () => _selectTime(context)
                                  : null,
                              child: ClipRRect(
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(4),
                                  topRight: Radius.circular(4),
                                  bottomLeft: Radius.circular(20),
                                  bottomRight: Radius.circular(20),
                                ),
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                  child: Opacity(
                                    opacity: _notificationsEnabled ? 1.0 : 0.45,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 18, vertical: 16),
                                      decoration: BoxDecoration(
                                        color: isDark
                                            ? Colors.white.withOpacity(0.06)
                                            : Colors.white.withOpacity(0.75),
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(4),
                                          topRight: Radius.circular(4),
                                          bottomLeft: Radius.circular(20),
                                          bottomRight: Radius.circular(20),
                                        ),
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
                                            width: 40,
                                            height: 40,
                                            decoration: BoxDecoration(
                                              color: primary.withOpacity(0.15),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(CupertinoIcons.clock,
                                                color: primary, size: 20),
                                          ),
                                          const SizedBox(width: 14),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Hora del Recordatorio',
                                                  style: TextStyle(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.w600,
                                                    color: textPrim,
                                                  ),
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  'Las notificaciones se enviarán a las ${_formatTime()}',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: isDark
                                                        ? Colors.white38
                                                        : _kTextSec,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Icon(
                                            CupertinoIcons.chevron_right,
                                            color: isDark
                                                ? Colors.white24
                                                : _kTextSec.withOpacity(0.4),
                                            size: 16,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // ── Section label: Gratitud ───────────────────
                        FadeTransition(
                          opacity: _card2Fade,
                          child: SlideTransition(
                            position: _card2Slide,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 4, bottom: 10),
                              child: Text(
                                'GRATITUD',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.8,
                                  color: isDark ? Colors.white38 : _kTextSec,
                                ),
                              ),
                            ),
                          ),
                        ),

                        // ── Gratitude toggle card ─────────────────────
                        FadeTransition(
                          opacity: _card2Fade,
                          child: SlideTransition(
                            position: _card2Slide,
                            child: ClipRRect(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(20),
                                topRight: Radius.circular(20),
                                bottomLeft: Radius.circular(4),
                                bottomRight: Radius.circular(4),
                              ),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 18, vertical: 16),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? Colors.white.withOpacity(0.06)
                                        : Colors.white.withOpacity(0.75),
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(20),
                                      topRight: Radius.circular(20),
                                      bottomLeft: Radius.circular(4),
                                      bottomRight: Radius.circular(4),
                                    ),
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
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: primary.withOpacity(0.15),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(CupertinoIcons.sun_min,
                                            color: primary, size: 20),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Recordatorio de Gratitud',
                                              style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w600,
                                                color: textPrim,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              'Recuerda escribir tu gratitud cada día',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: isDark
                                                    ? Colors.white38
                                                    : _kTextSec,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      CupertinoSwitch(
                                        value: _gratitudeNotifEnabled,
                                        activeColor: primary,
                                        onChanged: _onGratitudeToggle,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 2),

                        // ── Gratitude time picker card ────────────────
                        FadeTransition(
                          opacity: _card2Fade,
                          child: SlideTransition(
                            position: _card2Slide,
                            child: GestureDetector(
                              onTap: _gratitudeNotifEnabled
                                  ? () => _selectGratitudeTime(context)
                                  : null,
                              child: ClipRRect(
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(4),
                                  topRight: Radius.circular(4),
                                  bottomLeft: Radius.circular(20),
                                  bottomRight: Radius.circular(20),
                                ),
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                  child: Opacity(
                                    opacity: _gratitudeNotifEnabled ? 1.0 : 0.45,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 18, vertical: 16),
                                      decoration: BoxDecoration(
                                        color: isDark
                                            ? Colors.white.withOpacity(0.06)
                                            : Colors.white.withOpacity(0.75),
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(4),
                                          topRight: Radius.circular(4),
                                          bottomLeft: Radius.circular(20),
                                          bottomRight: Radius.circular(20),
                                        ),
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
                                            width: 40,
                                            height: 40,
                                            decoration: BoxDecoration(
                                              color: primary.withOpacity(0.15),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(CupertinoIcons.clock,
                                                color: primary, size: 20),
                                          ),
                                          const SizedBox(width: 14),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Hora del Recordatorio',
                                                  style: TextStyle(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.w600,
                                                    color: textPrim,
                                                  ),
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  'Las notificaciones se enviarán a las ${_formatGratitudeTime()}',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: isDark
                                                        ? Colors.white38
                                                        : _kTextSec,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Icon(
                                            CupertinoIcons.chevron_right,
                                            color: isDark
                                                ? Colors.white24
                                                : _kTextSec.withOpacity(0.4),
                                            size: 16,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // ── Section label: Acerca de ──────────────────
                        FadeTransition(
                          opacity: _card2Fade,
                          child: SlideTransition(
                            position: _card2Slide,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 4, bottom: 10),
                              child: Text(
                                'ACERCA DE',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.8,
                                  color: isDark ? Colors.white38 : _kTextSec,
                                ),
                              ),
                            ),
                          ),
                        ),

                        // ── Ver instrucciones card ────────────────────
                        FadeTransition(
                          opacity: _card2Fade,
                          child: SlideTransition(
                            position: _card2Slide,
                            child: GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => OnboardingScreen(
                                    nextScreen: const SizedBox.shrink(),
                                    isReplay: true,
                                  ),
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 18, vertical: 16),
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? Colors.white.withOpacity(0.06)
                                          : Colors.white.withOpacity(0.75),
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
                                          width: 40,
                                          height: 40,
                                          decoration: BoxDecoration(
                                            color: primary.withOpacity(0.15),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                              CupertinoIcons.question_circle,
                                              color: primary,
                                              size: 20),
                                        ),
                                        const SizedBox(width: 14),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Ver instrucciones',
                                                style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w600,
                                                  color: textPrim,
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                'Repasa la guía de todas las funciones',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: isDark
                                                      ? Colors.white38
                                                      : _kTextSec,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Icon(
                                          CupertinoIcons.chevron_right,
                                          color: isDark
                                              ? Colors.white24
                                              : _kTextSec.withOpacity(0.4),
                                          size: 16,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
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
}
