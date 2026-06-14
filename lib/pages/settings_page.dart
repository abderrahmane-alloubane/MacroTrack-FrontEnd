import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/local_storage_service.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Paramètres')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListenableBuilder(
              listenable: AppTheme.themeNotifier,
              builder: (context, _) {
                final isDark = AppTheme.themeNotifier.value == ThemeMode.dark;
                return SwitchListTile(
                  secondary: Icon(
                    isDark ? Icons.dark_mode : Icons.light_mode,
                    color: AppColors.primaryBlue,
                  ),
                  title: Text('Mode sombre',
                    style: TextStyle(color: AppColors.textWhite)),
                  subtitle: Text(isDark ? 'Activé' : 'Désactivé',
                    style: TextStyle(color: AppColors.textDarkGray)),
                  value: isDark,
                  onChanged: (v) {
                    final mode = v ? ThemeMode.dark : ThemeMode.light;
                    AppTheme.themeNotifier.value = mode;
                    LocalStorageService.saveThemeMode(mode);
                  },
                  activeTrackColor: AppColors.primaryBlue.withValues(alpha: 0.5),
                  activeThumbColor: AppColors.primaryBlue,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
