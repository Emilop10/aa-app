import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:ui';
import 'package:shared_preferences/shared_preferences.dart';
import 'notification_service.dart';

// ─── Paleta ───────────────────────────────────────────────
const _kOrange   = Color(0xFFF97316);
const _kCream    = Color(0xFFFFFBF5);
const _kTextPrim = Color(0xFF431407);
const _kTextSec  = Color(0xFF92400E);
const _kDarkBg   = Color(0xFF1A0800);

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = false;
  TimeOfDay _notificationTime = const TimeOfDay(hour: 9, minute: 0);

  final String _enabledKey = 'notifications_enabled';
  final String _timeKey    = 'notification_time';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool(_enabledKey) ?? false;
      final timeString = prefs.getString(_timeKey) ?? '09:00';
      final parts = timeString.split(':');
      _notificationTime = TimeOfDay(
          hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_enabledKey, _notificationsEnabled);
    await prefs.setString(
        _timeKey, '${_notificationTime.hour}:${_notificationTime.minute}');
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
                    child: const Text('Listo',
                        style: TextStyle(
                            color: _kOrange, fontWeight: FontWeight.w600)),
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

  @override
  Widget build(BuildContext context) {
    final isDark   = Theme.of(context).brightness == Brightness.dark;
    final bgColor  = isDark ? _kDarkBg : _kCream;
    final textPrim = isDark ? Colors.white : _kTextPrim;

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
            leading: CupertinoButton(
              padding: EdgeInsets.zero,
              child: Icon(CupertinoIcons.chevron_left, color: _kOrange),
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
                  // Section label
                  Padding(
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

                  // ── Notifications toggle card ────────────────────
                  ClipRRect(
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
                                color: _kOrange.withOpacity(0.15),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(CupertinoIcons.bell,
                                  color: _kOrange, size: 20),
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
                              activeColor: _kOrange,
                              onChanged: _onNotificationToggle,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 2),

                  // ── Time picker card ─────────────────────────────
                  GestureDetector(
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
                                    color: _kOrange.withOpacity(0.15),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(CupertinoIcons.clock,
                                      color: _kOrange, size: 20),
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
