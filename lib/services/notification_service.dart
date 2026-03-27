import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    _initialized = true;
  }

  void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap
  }

  Future<void> requestPermissions() async {
    await _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
  }

  Future<void> showSensorAlert({
    required String title,
    required String body,
    required String sensorType,
    required double value,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'sensor_alerts',
      'Sensor Alerts',
      channelDescription: 'Alertas de sensores del jardín',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
      payload: 'sensor:$sensorType:$value',
    );
  }

  Future<void> showWateringReminder({
    required String plantName,
    required int hoursSinceLastWatering,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      'watering_reminders',
      'Recordatorios de Riego',
      channelDescription: 'Recordatorios para regar tus plantas',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      plantName.hashCode,
      '¡Hora de regar!',
      'Tu $plantName necesita agua. Han pasado $hoursSinceLastWatering horas desde el último riego.',
      details,
      payload: 'watering:$plantName',
    );
  }

  Future<void> showAchievementUnlocked({
    required String achievementName,
    required int xpReward,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'achievements',
      'Logros',
      channelDescription: 'Notificaciones de logros desbloqueados',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      achievementName.hashCode,
      '¡Logro Desbloqueado! 🏆',
      'Has conseguido "$achievementName" y ganado $xpReward XP',
      details,
      payload: 'achievement:$achievementName',
    );
  }

  Future<void> showLevelUp({
    required int newLevel,
    required int totalXp,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'level_up',
      'Subida de Nivel',
      channelDescription: 'Notificaciones de subida de nivel',
      importance: Importance.max,
      priority: Priority.max,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      newLevel,
      '¡Felicidades! Subiste al nivel $newLevel 🎉',
      'Has acumulado $totalXp XP en total',
      details,
      payload: 'levelup:$newLevel',
    );
  }

  Future<void> cancelAll() async {
    await _notifications.cancelAll();
  }

  Future<void> cancel(int id) async {
    await _notifications.cancel(id);
  }
}
