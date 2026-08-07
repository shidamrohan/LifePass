import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  RealtimeChannel? _subscription;

  Future<void> initialize() async {
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle notification tap
      },
    );

    // Request permissions for Android 13+
    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  Future<void> showNotification({required String title, required String body}) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'emergency_alerts',
      'Emergency Alerts',
      channelDescription: 'Notifications for emergency record access',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
      color: Colors.red,
    );
    const NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);
    
    await _flutterLocalNotificationsPlugin.show(
      id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title: title,
      body: body,
      notificationDetails: platformChannelSpecifics,
    );
  }

  void listenForEmergencyAccess() {
    final patientId = Supabase.instance.client.auth.currentUser?.id;
    if (patientId == null) return;

    // Unsubscribe if already listening
    _subscription?.unsubscribe();

    // Listen to new inserts on audit_logs table where patient_id matches
    _subscription = Supabase.instance.client
        .channel('public:audit_logs')
        .onPostgresChanges(
            event: PostgresChangeEvent.insert,
            schema: 'public',
            table: 'audit_logs',
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'patient_id',
              value: patientId,
            ),
            callback: (payload) {
              final action = payload.newRecord['action'];
              if (action == 'emergency_access') {
                showNotification(
                  title: '🚨 Emergency Access Alert!',
                  body: 'A hospital just scanned your QR code and accessed your medical records.',
                );
              }
            })
        .subscribe();
  }

  void stopListening() {
    _subscription?.unsubscribe();
    _subscription = null;
  }
}

final notificationService = NotificationService();
