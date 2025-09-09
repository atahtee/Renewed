import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Settings',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: Colors.grey[50],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.purple, Colors.deepPurple],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.star, color: Colors.white, size: 24),
                      SizedBox(width: 8),
                      Text(
                        'Premium',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Unlock all features and remove ads',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      _showPremiumDialog(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.purple,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Upgrade Now'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            _buildSettingsSection('App Settings', [
              _buildSettingsTile(
                Icons.notifications,
                'Notifications',
                'Manage notification preferences',
                () {},
              ),
              _buildSettingsTile(
                Icons.language,
                'Language',
                'Choose your preferred language',
                () {},
              ),
              _buildSettingsTile(
                Icons.dark_mode,
                'Dark Mode',
                'Switch between light and dark theme',
                () {},
              ),
            ]),

            const SizedBox(height: 16),

            _buildSettingsSection('Support', [
              _buildSettingsTile(
                Icons.star_rate,
                'Rate App',
                'Rate us on the App Store',
                () => _rateApp(),
              ),
              _buildSettingsTile(
                Icons.share,
                'Share App',
                'Share this app with friends',
                () => _shareApp(),
              ),
              _buildSettingsTile(
                Icons.help,
                'Help & Support',
                'Get help and contact support',
                () {},
              ),
              _buildSettingsTile(
                Icons.privacy_tip,
                'Privacy Policy',
                'Read our privacy policy',
                () {},
              ),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildSettingsTile(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon, color: Colors.black54),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: Colors.black54, fontSize: 12),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.black38),
      onTap: onTap,
    );
  }

  void _showPremiumDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Premium Features'),
        content: const Text('Premium features coming soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _rateApp() async {
  final String packageName = "com.renewed.app";

  final Uri playStoreUri = Uri.parse("market://details?id=$packageName");
  final Uri webUri = Uri.parse("https://play.google.com/store/apps/details?id=$packageName");

  if (await canLaunchUrl(playStoreUri)) {
    await launchUrl(
      playStoreUri,
      mode: LaunchMode.externalNonBrowserApplication, // ✅ correct mode
    );
  } else {
    await launchUrl(
      webUri,
      mode: LaunchMode.externalApplication,
    );
  }
}


  void _shareApp() {
    print('Share app functionality');
  }
}
