import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';
import '../services/local_storage_service.dart';
import 'login_page.dart';

class MorePage extends StatelessWidget {
  final VoidCallback? onLogout;

  const MorePage({super.key, this.onLogout});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('More')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.person_outline,
                      color: AppColors.primaryBlue),
                  title: const Text('Profile',
                      style: TextStyle(color: AppColors.textWhite)),
                  subtitle: const Text('Edit name, goals, preferences',
                      style: TextStyle(color: AppColors.textDarkGray)),
                  trailing: const Icon(Icons.chevron_right,
                      color: AppColors.textDarkGray),
                  onTap: () {},
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                ListTile(
                  leading: const Icon(Icons.settings_outlined,
                      color: AppColors.primaryBlue),
                  title: const Text('Settings',
                      style: TextStyle(color: AppColors.textWhite)),
                  subtitle: const Text('App preferences',
                      style: TextStyle(color: AppColors.textDarkGray)),
                  trailing: const Icon(Icons.chevron_right,
                      color: AppColors.textDarkGray),
                  onTap: () {},
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                ListTile(
                  leading: const Icon(Icons.info_outline,
                      color: AppColors.primaryBlue),
                  title: const Text('About',
                      style: TextStyle(color: AppColors.textWhite)),
                  subtitle: const Text('MacroTrack v0.1.0',
                      style: TextStyle(color: AppColors.textDarkGray)),
                  trailing: const Icon(Icons.chevron_right,
                      color: AppColors.textDarkGray),
                  onTap: () {},
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
              label: const Text('Log Out'),
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
