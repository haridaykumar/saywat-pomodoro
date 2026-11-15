import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  String range = 'Weekly';
  DateTimeRange? customRange;
  List<BarChartGroupData> barGroups = [];
  Map<String, int> taskStats = {};
  int totalPomodoros = 0;
  double averagePerDay = 0;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    DateTime start;
    DateTime end = now;

    if (range == 'Weekly') {
      start = now.subtract(const Duration(days: 6));
    } else if (range == 'Monthly') {
      start = DateTime(now.year, now.month, 1);
    } else if (customRange != null) {
      start = customRange!.start;
      end = customRange!.end;
    } else {
      start = now.subtract(const Duration(days: 6));
    }

    totalPomodoros = 0;
    taskStats.clear();
    barGroups.clear();

    final days = end.difference(start).inDays + 1;
    for (int i = 0; i < days; i++) {
      final date = start.add(Duration(days: i));
      final key = 'pomodoros_${DateFormat('yyyy-MM-dd').format(date)}';
      final count = prefs.getInt(key) ?? 0;
      totalPomodoros += count;

      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: count.toDouble(),
              color: Colors.redAccent,
              width: days > 14 ? 8 : 16,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
      );
    }

    averagePerDay = days > 0 ? totalPomodoros / days : 0;

    final taskData = prefs.getString('tasks_json') ?? '[]';
    final List decoded = jsonDecode(taskData);
    for (var item in decoded) {
      final name = item['name'] as String;
      final pomos = item['pomodoros'] as int? ?? 0;
      if (pomos > 0) taskStats[name] = pomos;
    }

    setState(() {});
  }

  Future<void> _pickCustomRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        range = 'Custom';
        customRange = picked;
      });
      _loadStats();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Statistics')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8,
              children: [
                ChoiceChip(label: const Text('Weekly'), selected: range == 'Weekly', onSelected: (_) { setState(() => range = 'Weekly'); _loadStats(); }),
                ChoiceChip(label: const Text('Monthly'), selected: range == 'Monthly', onSelected: (_) { setState(() => range = 'Monthly'); _loadStats(); }),
                ChoiceChip(label: const Text('Custom'), selected: range == 'Custom', onSelected: (_) => _pickCustomRange()),
              ],
            ),
            const SizedBox(height: 20),

            // Summary cards
            Row(
              children: [
                Expanded(child: _summaryCard('Total', '$totalPomodoros', Icons.timer)),
                const SizedBox(width: 12),
                Expanded(child: _summaryCard('Avg / Day', averagePerDay.toStringAsFixed(1), Icons.trending_up)),
              ],
            ),
            const SizedBox(height: 24),

            const Text('Activity', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            SizedBox(
              height: 220,
              child: barGroups.isEmpty
                  ? const Center(child: Text('No data for this period'))
                  : BarChart(
                      BarChartData(
                        barGroups: barGroups,
                        titlesData: const FlTitlesData(show: false),
                        borderData: FlBorderData(show: false),
                        gridData: const FlGridData(show: true, drawVerticalLine: false),
                      ),
                    ),
            ),
            const SizedBox(height: 28),

            const Text('Per Task', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            if (taskStats.isEmpty)
              const Padding(padding: EdgeInsets.all(16), child: Text('No task data yet'))
            else
              ...taskStats.entries.map((e) => Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: const Icon(Icons.task_alt, color: Colors.redAccent),
                      title: Text(e.key),
                      trailing: Text('${e.value}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                  )),
          ],
        ),
      ),
    );
  }

  Widget _summaryCard(String title, String value, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: Colors.redAccent),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text(title, style: const TextStyle(fontSize: 14, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}