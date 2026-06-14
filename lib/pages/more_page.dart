import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';
import '../services/local_storage_service.dart';
import 'login_page.dart';
import 'profile_page.dart';
import 'settings_page.dart';
import 'about_page.dart';

class MorePage extends StatelessWidget {
  final VoidCallback? onLogout;
  final VoidCallback? onProfileUpdated;

  const MorePage({super.key, this.onLogout, this.onProfileUpdated});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Plus')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.person_outline,
                      color: AppColors.primaryBlue),
                  title: Text('Profil',
                      style: TextStyle(color: AppColors.textWhite)),
                  subtitle: Text('Objectifs, ratios de macros',
                      style: TextStyle(color: AppColors.textDarkGray)),
                  trailing: Icon(Icons.chevron_right,
                      color: AppColors.textDarkGray),
                  onTap: () async {
                    final updated = await Navigator.push<bool>(context,
                      MaterialPageRoute(builder: (_) => const ProfilePage()));
                    if (updated == true) onProfileUpdated?.call();
                  },
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                ListTile(
                  leading: Icon(Icons.settings_outlined,
                      color: AppColors.primaryBlue),
                  title: Text('Paramètres',
                      style: TextStyle(color: AppColors.textWhite)),
                  subtitle: Text('Préférences de l\'application',
                      style: TextStyle(color: AppColors.textDarkGray)),
                  trailing: Icon(Icons.chevron_right,
                      color: AppColors.textDarkGray),
                  onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const SettingsPage())),
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                ListTile(
                  leading: Icon(Icons.info_outline,
                      color: AppColors.primaryBlue),
                  title: Text('À propos',
                      style: TextStyle(color: AppColors.textWhite)),
                  subtitle: Text('MacroTrack v0.1.0',
                      style: TextStyle(color: AppColors.textDarkGray)),
                  trailing: Icon(Icons.chevron_right,
                      color: AppColors.textDarkGray),
                  onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const AboutPage())),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: onLogout ?? () {
                ApiService.logout();
                LocalStorageService.clear();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                  (route) => false,
                );
              },
              icon: const Icon(Icons.logout),
              label: const Text('Déconnexion'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.errorRed,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
