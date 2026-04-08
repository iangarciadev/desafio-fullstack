import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/services/api.dart';
import 'package:mobile/theme.dart';

class TasksScreen extends StatefulWidget {
  final int clientId;
  const TasksScreen({super.key, required this.clientId});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  List tasks = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchTasks();
  }

  Future<void> fetchTasks() async {
    final response = await apiGet('/tasks?clientId=${widget.clientId}');
    setState(() {
      tasks = response;
      loading = false;
    });
  }

  Future<void> updateStatus(int taskId, String status) async {
    await apiPut('/tasks/$taskId', {'status': status});
    fetchTasks();
  }

  Widget _statusBadge(String status) {
    final configs = {
      'PENDING': (
        bg: AppColors.pendingBg,
        fg: AppColors.pendingText,
        label: 'Pendente',
      ),
      'IN_PROGRESS': (
        bg: AppColors.inProgressBg,
        fg: AppColors.inProgressText,
        label: 'Em andamento',
      ),
      'DONE': (
        bg: AppColors.doneBg,
        fg: AppColors.doneText,
        label: 'Concluído',
      ),
    };

    final c = configs[status] ??
        (bg: AppColors.border, fg: AppColors.textMuted, label: status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: c.bg,
        borderRadius: BorderRadius.circular(9999),
      ),
      child: Text(
        c.label,
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: c.fg,
        ),
      ),
    );
  }

  void _showStatusPicker(int taskId, String currentStatus) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                child: Text(
                  'Alterar status',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.text,
                  ),
                ),
              ),
              const Divider(color: AppColors.border, height: 1),
              for (final entry in [
                ('PENDING', 'Pendente'),
                ('IN_PROGRESS', 'Em andamento'),
                ('DONE', 'Concluído'),
              ])
                ListTile(
                  title: Text(
                    entry.$2,
                    style: GoogleFonts.inter(
                      color: AppColors.text,
                      fontWeight: entry.$1 == currentStatus
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                  trailing: entry.$1 == currentStatus
                      ? const Icon(Icons.check, color: AppColors.primary)
                      : null,
                  onTap: () {
                    Navigator.pop(context);
                    if (entry.$1 != currentStatus) {
                      updateStatus(taskId, entry.$1);
                    }
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tarefas')),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : tasks.isEmpty
              ? Center(
                  child: Text(
                    'Nenhuma tarefa encontrada.',
                    style: GoogleFonts.inter(color: AppColors.textMuted),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    final status = task['status'] as String;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: cardDecoration,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    task['title'],
                                    style: GoogleFonts.inter(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.text,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  _statusBadge(status),
                                ],
                              ),
                            ),
                            GestureDetector(
                              onTap: () =>
                                  _showStatusPicker(task['id'], status),
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: AppColors.background,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: AppColors.border),
                                ),
                                child: const Icon(
                                  Icons.swap_vert,
                                  size: 18,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
