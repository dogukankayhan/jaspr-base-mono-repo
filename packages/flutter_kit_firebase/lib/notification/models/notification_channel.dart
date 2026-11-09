import 'package:flutter_local_notifications/flutter_local_notifications.dart';

enum AppNotificationChannel {
  general(
    id: 'general',
    name: 'Genel Bildirimler',
    description: 'Uygulama genel bildirimleri',
    importance: Importance.defaultImportance,
  ),
  promotional(
    id: 'promotional',
    name: 'Kampanyalar',
    description: 'Kampanya ve fırsat bildirimleri',
    importance: Importance.high,
  ),
  critical(
    id: 'critical',
    name: 'Önemli Bildirimler',
    description: 'Güvenlik ve kritik sistem bildirimleri',
    importance: Importance.max,
  );

  const AppNotificationChannel({
    required this.id,
    required this.name,
    required this.description,
    required this.importance,
  });

  final String id;
  final String name;
  final String description;
  final Importance importance;

  AndroidNotificationChannel get androidChannel => AndroidNotificationChannel(
    id,
    name,
    description: description,
    importance: importance,
  );
}
