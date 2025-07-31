import 'package:flutter/material.dart';

class SubscriptionService {
  final String name;
  final IconData icon;
  final Color color;

  SubscriptionService(this.name, this.icon, this.color);
}

final List<SubscriptionService> popularSubscriptions = [
  SubscriptionService('Netflix', Icons.movie_outlined, Colors.red),
  SubscriptionService('Spotify', Icons.music_note_outlined, Colors.green),
  SubscriptionService('Disney+', Icons.movie_creation_outlined, Colors.blue),
  SubscriptionService('Apple Music', Icons.music_note_outlined, Colors.black87),
  SubscriptionService('Amazon Prime', Icons.shopping_bag_outlined, Colors.blueAccent),
  SubscriptionService('YouTube Premium', Icons.play_circle_outline, Colors.red),
  SubscriptionService('Notion', Icons.note_outlined, Colors.black),
  SubscriptionService('Adobe Creative Cloud', Icons.design_services_outlined, Colors.purple),
  SubscriptionService('Microsoft 365', Icons.desktop_windows_outlined, Colors.blue),
  SubscriptionService('Dropbox', Icons.cloud_outlined, Colors.blue),
  SubscriptionService('Slack', Icons.chat_bubble_outline, Colors.purple),
  SubscriptionService('Zoom', Icons.videocam_outlined, Colors.blue),
  SubscriptionService('Google One', Icons.storage_outlined, Colors.blue),
  SubscriptionService('iCloud', Icons.cloud_outlined, Colors.blue),
  SubscriptionService('PlayStation Plus', Icons.sports_esports_outlined, Colors.blue),
  SubscriptionService('Xbox Game Pass', Icons.sports_esports_outlined, Colors.green),
];