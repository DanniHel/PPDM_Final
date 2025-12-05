import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import '../models/document.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    tz.initializeTimeZones();

    // ← CAMBIO 1: Ahora devuelve TimezoneInfo, así que usamos .identifier
    final TimezoneInfo timeZoneInfo = await FlutterTimezone.getLocalTimezone();
    final String timeZoneName = timeZoneInfo.identifier;  // ← Extrae el string

    tz.setLocalLocation(tz.getLocation(timeZoneName));

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

    await _notifications.zonedSchedule(
      doc.id.hashCode,
      '¡Documento por vencer!',
      '${doc.name} vence el ${doc.expiryDate!.day}/${doc.expiryDate!.month}/${doc.expiryDate!.year}',
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'reminders', 'Recordatorios',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  static String _formatDate(DateTime date) => '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

}