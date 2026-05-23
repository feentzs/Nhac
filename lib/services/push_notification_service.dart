import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PushNotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  final AndroidNotificationChannel _androidChannel = const AndroidNotificationChannel(
    'nhac_high_importance_channel', 
    'Notificações de Pedidos', 
    description: 'Avisos importantes sobre o estado do seu pedido.',
    importance: Importance.max, 
    playSound: true,
    enableVibration: true,
  );

  Future<void> initialize() async {
    NotificationSettings settings = await _fcm.requestPermission();

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('Permissão de notificações concedida!');
      
      String? token = await _fcm.getToken();
      if (token != null) {
        print('MEU FCM TOKEN: $token');
        await _guardarTokenNoBancoDeDados(token); 
      }

      _fcm.onTokenRefresh.listen((novoToken) {
        _guardarTokenNoBancoDeDados(novoToken);
      });

      await _localNotifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(_androidChannel);

      const AndroidInitializationSettings androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
      const InitializationSettings initSettings = InitializationSettings(android: androidInit);
      
      await _localNotifications.initialize(
        settings: initSettings, 
      );

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        RemoteNotification? notification = message.notification;
        AndroidNotification? android = message.notification?.android;

        if (notification != null && android != null) {
          _localNotifications.show(
            id: notification.hashCode,
            title: notification.title,
            body: notification.body,
            notificationDetails: NotificationDetails(
              android: AndroidNotificationDetails(
                _androidChannel.id,
                _androidChannel.name,
                channelDescription: _androidChannel.description,
                importance: Importance.max,
                priority: Priority.high,
                icon: '@mipmap/ic_launcher',
              ),
            ),
          );
        }
      });
    }
  }

  Future<void> _guardarTokenNoBancoDeDados(String token) async {

    String? userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId != null) {
      try {
        await FirebaseFirestore.instance
            .collection('usuarios') 
            .doc(userId)
            .set({
              'fcmToken': token,
            }, SetOptions(merge: true)); 

        debugPrint('✅ FCM Token atualizado no Firestore com sucesso!');
      } catch (e) {
        debugPrint('❌ Erro ao guardar o token no Firestore: $e');
      }
    } else {
      debugPrint('Nenhum utilizador logado. O token não foi guardado na base de dados.');
    }
  }
}