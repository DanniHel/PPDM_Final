// lib/services/notification_service.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;
import '../models/document.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
  FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    tz_data.initializeTimeZones();
    final utcLocation = tz.getLocation('UTC');
    tz.setLocalLocation(utcLocation);

    const AndroidInitializationSettings android =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings settings =
    InitializationSettings(android: android);

    await _notifications.initialize(settings);
  }

  static Future<void> scheduleReminder(Document doc) async {
    if (doc.expiryDate == null) return;

    final alertDate = doc.expiryDate!.subtract(const Duration(days: 7));
    if (alertDate.isBefore(DateTime.now())) return;

    final scheduledDate = tz.TZDateTime.from(alertDate, tz.local);

    try {
      await _notifications.zonedSchedule(
        doc.id.hashCode,
        '¡Documento por vencer!',
        '${doc.name} vence en 7 días (${_format(doc.expiryDate!)})',
        scheduledDate,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'reminders',
            'Recordatorios de vencimiento',
            channelDescription: 'Notificaciones 7 días antes del vencimiento',
            importance: Importance.max,
            priority: Priority.high,
            playSound: true,
            enableVibration: true,
            showWhen: true,
            when: 0,
          ),
        ),
        // ESTA ES LA LÍNEA MÁGICA: NO REQUIERE PERMISO
        androidScheduleMode: AndroidScheduleMode.alarmClock,
        uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: null,
      );
    } catch (e) {
      debugPrint("Notificación programada con fallback: $e");
      // Fallback: usar modo inexacto si falla
      await _notifications.zonedSchedule(
        doc.id.hashCode + 999999,
        '¡Documento por vencer!',
        '${doc.name} vence pronto',
        scheduledDate,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'reminders_fallback',
            'Recordatorios (fallback)',
            importance: Importance.high,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.inexact,
        uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }

  static String _format(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
}