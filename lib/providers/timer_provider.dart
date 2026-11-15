import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:vibration/vibration.dart';
import '../services/notification_service.dart';
import 'dart:convert';

enum SessionType { work, rest, longRest }

class Task {
  String name;
  int pomodoros;
  Task({required this.name, this.pomodoros = 0});
  Map<String, dynamic> toJson() => {'name': name, 'pomodoros': pomodoros};
  factory Task.fromJson(Map<String, dynamic> json) =>
      Task(name: json['name'], pomodoros: json['pomodoros'] ?? 0);
}

class TimerProvider extends ChangeNotifier {
  Duration remaining = const Duration(minutes: 25);
  Duration totalDuration = const Duration(minutes: 25);
  bool isRunning = false;
  SessionType currentType = SessionType.work;
  int completedPomodoros = 0;
  int currentCycle = 0;
  Timer? _timer;
  DateTime? _endTime;
  Task? selectedTask;
  final AudioPlayer _audioPlayer = AudioPlayer();

  void setSelectedTask(Task? task) {
    selectedTask = task;
    notifyListeners();
  }

  Future<void> start(int workMin, int restMin, int longRestMin, int cycles) async {
    if (isRunning) return;
    await _audioPlayer.stop();
    isRunning = true;
    _endTime = DateTime.now().add(remaining);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick(workMin, restMin, longRestMin, cycles));
    notifyListeners();
  }

  void pause() {
    isRunning = false;
    _timer?.cancel();
    notifyListeners();
  }

  void reset(int workMin) {
    isRunning = false;
    _timer?.cancel();
    currentType = SessionType.work;
    totalDuration = Duration(minutes: workMin);
    remaining = totalDuration;
    notifyListeners();
  }

  void _tick(int workMin, int restMin, int longRestMin, int cycles) {
    if (_endTime == null) return;
    remaining = _endTime!.difference(DateTime.now());
    if (remaining.inSeconds <= 0) {
      _completeSession(workMin, restMin, longRestMin, cycles);
    }
    notifyListeners();
  }

  Future<void> _completeSession(int workMin, int restMin, int longRestMin, int cycles) async {
    _timer?.cancel();
    isRunning = false;

    final isWorkSession = currentType == SessionType.work;
    await _playCompletionFeedback(isWorkSession);

    if (isWorkSession) {
      completedPomodoros++;
      currentCycle++;
      await _saveCompletedSession();
      if (selectedTask != null) {
        await _incrementTaskPomodoros(selectedTask!);
      }
      await NotificationService.showNotification(title: 'Focus Complete', body: 'Time for a break!');
      if (currentCycle >= cycles) {
        currentType = SessionType.longRest;
        totalDuration = Duration(minutes: longRestMin);
        currentCycle = 0;
      } else {
        currentType = SessionType.rest;
        totalDuration = Duration(minutes: restMin);
      }
    } else {
      currentType = SessionType.work;
      totalDuration = Duration(minutes: workMin);
      await NotificationService.showNotification(title: 'Break Over', body: 'Time to focus again!');
    }
    remaining = totalDuration;
    notifyListeners();
  }

  Future<void> _incrementTaskPomodoros(Task task) async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('tasks_json') ?? '[]';
    final List decoded = jsonDecode(data);
    final tasks = decoded.map((e) => Task.fromJson(e)).toList();
    final index = tasks.indexWhere((t) => t.name == task.name);
    if (index != -1) {
      tasks[index].pomodoros++;
      selectedTask = tasks[index];
      await prefs.setString('tasks_json', jsonEncode(tasks.map((t) => t.toJson()).toList()));
      notifyListeners();
    }
  }

  Future<void> _playCompletionFeedback(bool isWorkSession) async {
    try {
      await _audioPlayer.stop();
      final sound = isWorkSession ? 'sounds/work_complete.mp3' : 'sounds/rest_complete.mp3';
      await _audioPlayer.play(AssetSource(sound));
    } catch (_) {}
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(duration: 500);
    }
  }

  Future<void> _saveCompletedSession() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T')[0];
    final key = 'pomodoros_$today';
    final count = (prefs.getInt(key) ?? 0) + 1;
    await prefs.setInt(key, count);
  }

  String get formattedTime {
    final m = remaining.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = remaining.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  double get progress {
    if (totalDuration.inSeconds == 0) return 0;
    return 1 - (remaining.inSeconds / totalDuration.inSeconds);
  }
}