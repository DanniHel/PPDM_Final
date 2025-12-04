import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;  // ← latest_all para compatibilidad completa
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import '../models/document.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
  FlutterLocalNotificationsPlugin();

  // Inicializar al arrancar la app (con zona horaria local)
  static Future<void> init() async {
    tz.initializeTimeZones();  // ← Inicializa todas las zonas horarias

    // Configurar la zona horaria local del dispositivo
    final String timeZoneName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));

    const AndroidInitializationSettings android =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings settings =
    InitializationSettings(android: android);

    await _notifications.initialize(settings);
  }

  // Programar recordatorio 7 días antes del vencimiento
  static Future<void> scheduleReminder(Document doc) async {
    if (doc.expiryDate == null) return;

    final DateTime alertDate = doc.expiryDate!.subtract(const Duration(days: 7));

    // Si ya pasó la fecha de aviso, no programamos nada
    if (alertDate.isBefore(DateTime.now())) return;

    final tz.TZDateTime scheduledDate = tz.TZDateTime.from(alertDate, tz.local);

    await _notifications.zonedSchedule(
      doc.id.hashCode, // ID único basado en el UUID del documento
      '¡Tu documento está por vencer!',
      '${doc.name} vence el ${_formatDate(doc.expiryDate!)}',
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'document_reminders',
          'Recordatorios de documentos',
          channelDescription: 'Notificaciones de vencimiento de documentos',
          importance: Importance.max,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,  // ← Agregado: Valor por defecto para fechas absolutas (resuelve el error)
    );
  }

  // Helper para formato bonito de fecha
  static String _formatDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
}