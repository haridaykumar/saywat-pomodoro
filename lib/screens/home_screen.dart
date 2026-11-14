import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/timer_provider.dart';
import '../providers/settings_provider.dart';
import 'tasks_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final timer = context.watch<TimerProvider>();
    final settings = context.watch<SettingsProvider>();
    final sessionColor = timer.currentType == SessionType.work ? Colors.redAccent : Colors.blueAccent;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Saywat Pomodoro'),
        actions: [
          IconButton(icon: const Icon(Icons.bar_chart), onPressed: () => Navigator.pushNamed(context, '/stats')),
          IconButton(
            icon: const Icon(Icons.checklist),
            onPressed: () async {
              final selected = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TasksScreen()),
              );
              if (selected != null) {
                context.read<TimerProvider>().setSelectedTask(selected);
              }
            },
          ),
          IconButton(icon: const Icon(Icons.settings), onPressed: () => Navigator.pushNamed(context, '/settings')),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (timer.selectedTask != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  'Task: ${timer.selectedTask!.name} (${timer.selectedTask!.pomodoros})',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),
            Text(
              timer.currentType == SessionType.work ? 'FOCUS' : 'REST',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: sessionColor),
            ),
            const SizedBox(height: 24),
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 260,
                  height: 260,
                  child: CircularProgressIndicator(
                    value: timer.progress.clamp(0.0, 1.0),
                    strokeWidth: 14,
                    backgroundColor: Colors.grey.shade300,
                    color: sessionColor,
                  ),
                ),
                Text(timer.formattedTime, style: const TextStyle(fontSize: 64, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 32),
            Text('Completed: ${timer.completedPomodoros}', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (!settings.isStrictMode || !timer.isRunning)
                  ElevatedButton.icon(
                    onPressed: timer.isRunning
                        ? timer.pause
                        : () => timer.start(settings.workMinutes, settings.restMinutes, settings.longRestMinutes, settings.cyclesBeforeLongRest),
                    icon: Icon(timer.isRunning ? Icons.pause : Icons.play_arrow),
                    label: Text(timer.isRunning ? 'Pause' : 'Start'),
                    style: ElevatedButton.styleFrom(backgroundColor: sessionColor, foregroundColor: Colors.white),
                  ),
                const SizedBox(width: 16),
                if (!settings.isStrictMode)
                  OutlinedButton.icon(
                    onPressed: () => timer.reset(settings.workMinutes),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reset'),
                  ),
              ],
            ),
            if (settings.isStrictMode && timer.isRunning)
              const Padding(
                padding: EdgeInsets.only(top: 16),
                child: Text('Strict Mode Active', style: TextStyle(color: Colors.orange)),
              ),
          ],
        ),
      ),
    );
  }
}
