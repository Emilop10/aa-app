import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'notification_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = false;
  TimeOfDay _notificationTime = const TimeOfDay(hour: 9, minute: 0);

  final String _enabledKey = 'notifications_enabled';
  final String _timeKey = 'notification_time';

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
      _notificationTime = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_enabledKey, _notificationsEnabled);
    await prefs.setString(_timeKey, '${_notificationTime.hour}:${_notificationTime.minute}');
  }

  void _onNotificationToggle(bool value) {
    setState(() {
      _notificationsEnabled = value;
    });
    if (_notificationsEnabled) {
      NotificationService.instance.scheduleDailyNotification(_notificationTime);
    } else {
      NotificationService.instance.cancelAllNotifications();
    }
    _saveSettings();
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _notificationTime,
    );
    if (picked != null && picked != _notificationTime) {
      setState(() {
        _notificationTime = picked;
      });
      if (_notificationsEnabled) {
        NotificationService.instance.scheduleDailyNotification(_notificationTime);
      }
      _saveSettings();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajustes'),
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Activar Notificaciones Diarias'),
            subtitle: const Text('Recibe un recordatorio para tu reflexión diaria.'),
            value: _notificationsEnabled,
            onChanged: _onNotificationToggle,
            secondary: const Icon(Icons.notifications_active_outlined),
          ),
          const Divider(),
          ListTile(
            title: const Text('Hora del Recordatorio'),
            subtitle: Text('Las notificaciones se enviarán a las ${_notificationTime.format(context)}'),
            leading: const Icon(Icons.access_time_outlined),
            onTap: () => _selectTime(context),
            enabled: _notificationsEnabled,
          ),
          // ¡CORREGIDO! El botón de prueba ha sido eliminado.
        ],
      ),
    );
  }
}
