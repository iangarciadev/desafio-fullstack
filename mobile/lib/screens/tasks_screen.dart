import 'package:flutter/material.dart';
import 'package:mobile/services/api.dart';

class TasksScreen extends StatefulWidget {
  final int clientId;
  const TasksScreen({super.key, required this.clientId});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  List tasks = [];

  @override
  void initState() {
    super.initState();
    fetchTasks();
  }

  Future<void> fetchTasks() async {
    final response = await apiGet('/tasks?clientId=${widget.clientId}');
    setState(() {
      tasks = response;
    });
  }

  Future<void> updateStatus(int taskId, String status) async {
    await apiPut('/tasks/$taskId', {'status': status});
    fetchTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tarefas')),
      body: ListView.builder(
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          final task = tasks[index];
          return ListTile(
            title: Text(task['title']),
            subtitle: Text(task['status']),
            trailing: DropdownButton<String>(
              value: task['status'],
              items: const [
                DropdownMenuItem(value: 'PENDING', child: Text('Pendente')),
                DropdownMenuItem(value: 'IN_PROGRESS', child: Text('Em andamento')),
                DropdownMenuItem(value: 'DONE', child: Text('Concluído')),
              ],
              onChanged: (value) {
                if (value != null) updateStatus(task['id'], value);
              },
            ),
          );
        },
      ),
    );
  }
}