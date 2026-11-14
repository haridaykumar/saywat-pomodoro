import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class Task {
  String name;
  int pomodoros;

  Task({required this.name, this.pomodoros = 0});

  Map<String, dynamic> toJson() => {'name': name, 'pomodoros': pomodoros};
  factory Task.fromJson(Map<String, dynamic> json) =>
      Task(name: json['name'], pomodoros: json['pomodoros'] ?? 0);
}

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  List<Task> tasks = [];
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('tasks_json') ?? '[]';
    final List decoded = jsonDecode(data);
    setState(() {
      tasks = decoded.map((e) => Task.fromJson(e)).toList();
    });
  }

  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final data = jsonEncode(tasks.map((t) => t.toJson()).toList());
    await prefs.setString('tasks_json', data);
  }

  Future<void> _addTask() async {
    if (_controller.text.trim().isEmpty) return;
    tasks.add(Task(name: _controller.text.trim()));
    _controller.clear();
    await _saveTasks();
    setState(() {});
  }

  Future<void> _removeTask(int index) async {
    tasks.removeAt(index);
    await _saveTasks();
    setState(() {});
  }

  void _selectTask(Task task) {
    Navigator.pop(context, task);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tasks')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(hintText: 'Add a task...'),
                    onSubmitted: (_) => _addTask(),
                  ),
                ),
                IconButton(onPressed: _addTask, icon: const Icon(Icons.add)),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
                return ListTile(
                  title: Text(task.name),
                  subtitle: Text('${task.pomodoros} pomodoros'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.check_circle_outline),
                        onPressed: () => _selectTask(task),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _removeTask(index),
                      ),
                    ],
                  ),
                  onTap: () => _selectTask(task),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
