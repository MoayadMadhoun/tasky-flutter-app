import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/connectivity_provider.dart';
import '../providers/theme_provider.dart';

class SettingsScreen extends StatelessWidget {
  static const routeName = '/settings';
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isOnline = context.select<ConnectivityProvider, bool>((p) => p.isOnline);
    final themeMode = context.select<ThemeProvider, ThemeMode>((p) => p.themeMode);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(12),
          children: [
            Card(
              child: ListTile(
                leading: Icon(isOnline ? Icons.wifi : Icons.wifi_off),
                title: const Text('Connectivity'),
                subtitle: Text(isOnline ? 'Online' : 'Offline'),
              ),
            ),
            const SizedBox(height: 8),
            Card(
              child: Column(
                children: [
                  const ListTile(
                    leading: Icon(Icons.palette_outlined),
                    title: Text('Theme'),
                    subtitle: Text('Choose Light / Dark / System'),
                  ),
                  RadioListTile<ThemeMode>(
                    value: ThemeMode.system,
                    groupValue: themeMode,
                    onChanged: (v) => context.read<ThemeProvider>().setThemeMode(v!),
                    title: const Text('System'),
                  ),
                  RadioListTile<ThemeMode>(
                    value: ThemeMode.light,
                    groupValue: themeMode,
                    onChanged: (v) => context.read<ThemeProvider>().setThemeMode(v!),
                    title: const Text('Light'),
                  ),
                  RadioListTile<ThemeMode>(
                    value: ThemeMode.dark,
                    groupValue: themeMode,
                    onChanged: (v) => context.read<ThemeProvider>().setThemeMode(v!),
                    title: const Text('Dark'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
