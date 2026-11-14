import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Work Duration: ${settings.workMinutes} min'),
          Slider(
            value: settings.workMinutes.toDouble(),
            min: 1,
            max: 60,
            divisions: 11,
            label: '${settings.workMinutes}',
            onChanged: (v) => settings.updateWorkMinutes(v.toInt()),
          ),
          Text('Rest Duration: ${settings.restMinutes} min'),
          Slider(
            value: settings.restMinutes.toDouble(),
            min: 1,
            max: 30,
            divisions: 29,
            label: '${settings.restMinutes}',
            onChanged: (v) => settings.updateRestMinutes(v.toInt()),
          ),
          SwitchListTile(
            title: const Text('Strict Mode'),
            subtitle: const Text('Disable pause/reset during active session'),
            value: settings.isStrictMode,
            onChanged: settings.toggleStrictMode,
          ),
          SwitchListTile(
            title: const Text('Dark Mode'),
            value: settings.isDarkMode,
            onChanged: settings.toggleDarkMode,
          ),
        ],
      ),
    );
  }
}
