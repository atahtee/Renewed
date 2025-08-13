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
  SubscriptionService(
    'Amazon Prime',
    Icons.shopping_bag_outlined,
    Colors.blueAccent,
  ),
  SubscriptionService('YouTube Premium', Icons.play_circle_outline, Colors.red),
  SubscriptionService('Notion', Icons.note_outlined, Colors.black),
  SubscriptionService(
    'Adobe Creative Cloud',
    Icons.design_services_outlined,
    Colors.purple,
  ),
  SubscriptionService(
    'Microsoft 365',
    Icons.desktop_windows_outlined,
    Colors.blue,
  ),
  SubscriptionService('Dropbox', Icons.cloud_outlined, Colors.blue),
  SubscriptionService('Slack', Icons.chat_bubble_outline, Colors.purple),
  SubscriptionService('Zoom', Icons.videocam_outlined, Colors.blue),
  SubscriptionService('Google One', Icons.storage_outlined, Colors.blue),
  SubscriptionService('iCloud', Icons.cloud_outlined, Colors.blue),
  SubscriptionService(
    'PlayStation Plus',
    Icons.sports_esports_outlined,
    Colors.indigo,
  ),
  SubscriptionService(
    'Xbox Game Pass',
    Icons.sports_esports_outlined,
    Colors.green,
  ),
  SubscriptionService('HBO Max', Icons.tv_outlined, Colors.deepPurple),
  SubscriptionService('Hulu', Icons.tv_outlined, Colors.greenAccent),
  SubscriptionService(
    'Paramount+',
    Icons.movie_filter_outlined,
    Colors.blueAccent,
  ),
  SubscriptionService('Apple TV+', Icons.tv_outlined, Colors.black),
  SubscriptionService('Canva Pro', Icons.brush_outlined, Colors.purpleAccent),
  SubscriptionService('Grammarly', Icons.spellcheck_outlined, Colors.green),
  SubscriptionService('QuillBot', Icons.text_fields_outlined, Colors.teal),
  SubscriptionService('ChatGPT Plus', Icons.smart_toy_outlined, Colors.grey),
  SubscriptionService('LinkedIn Premium', Icons.work_outline, Colors.blueGrey),
  SubscriptionService('Coursera Plus', Icons.school_outlined, Colors.blue),
  SubscriptionService(
    'Skillshare',
    Icons.cast_for_education_outlined,
    Colors.orangeAccent,
  ),
  SubscriptionService(
    'Duolingo Plus',
    Icons.translate_outlined,
    Colors.lightGreen,
  ),
  SubscriptionService('Tidal', Icons.music_video_outlined, Colors.indigoAccent),
  SubscriptionService(
    'Crunchyroll',
    Icons.theaters_outlined,
    Colors.deepOrange,
  ),
  SubscriptionService(
    'Game Pass Ultimate',
    Icons.sports_esports_outlined,
    Colors.lightGreen,
  ),
  SubscriptionService(
    'Nintendo Switch Online',
    Icons.sports_esports_outlined,
    Colors.redAccent,
  ),
  SubscriptionService('Peacock', Icons.tv_outlined, Colors.teal),
  SubscriptionService('Audible', Icons.headphones_outlined, Colors.amber),
  SubscriptionService(
    'Headspace',
    Icons.self_improvement_outlined,
    Colors.blueAccent,
  ),
  SubscriptionService('NordVPN', Icons.security_outlined, Colors.blue),
  SubscriptionService('1Password', Icons.lock_outlined, Colors.blueGrey),
  SubscriptionService(
    'MasterClass',
    Icons.school_outlined,
    Colors.yellowAccent,
  ),
  SubscriptionService('HelloFresh', Icons.restaurant_outlined, Colors.green),
  SubscriptionService(
    'Birchbox',
    Icons.face_retouching_natural_outlined,
    Colors.pink,
  ),
  SubscriptionService('Stitch Fix', Icons.style_outlined, Colors.purple),
  SubscriptionService('BarkBox', Icons.pets_outlined, Colors.brown),
  SubscriptionService(
    'ClassPass',
    Icons.fitness_center_outlined,
    Colors.orange,
  ),
  SubscriptionService('ESPN+', Icons.sports_baseball_outlined, Colors.red),
];
