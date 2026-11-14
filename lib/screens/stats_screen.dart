import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  List<FlSpot> spots = [];
  int totalToday = 0;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T')[0];
    totalToday = prefs.getInt('pomodoros_$today') ?? 0;

    spots = List.generate(7, (i) {
      final date = DateTime.now().subtract(Duration(days: 6 - i));
      final key = 'pomodoros_${date.toIso8601String().split('T')[0]}';
      final count = prefs.getInt(key) ?? 0;
      return FlSpot(i.toDouble(), count.toDouble());
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Statistics')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text('Today: $totalToday Pomodoros', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            SizedBox(
              height: 220,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: true),
                  titlesData: const FlTitlesData(show: true),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: Colors.redAccent,
                      barWidth: 4,
                      belowBarData: BarAreaData(show: true, color: Colors.redAccent.withOpacity(0.3)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Last 7 Days'),
          ],
        ),
      ),
    );
  }
}
