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
  String? selectedStatus;

  @override
  void initState() {
    super.initState();
    fetchTasks();
  }

  /// Busca as tarefas do cliente atual na API, aplicando o filtro de [selectedStatus]
  /// se definido, e atualiza o estado com os resultados.
  Future<void> fetchTasks() async {
    String url = '/tasks?clientId=${widget.clientId}';
    if (selectedStatus != null) url += '&status=$selectedStatus';
    final response = await apiGet(url);
    setState(() {
      tasks = response;
      loading = false;
    });
  }

  /// Atualiza o [status] da tarefa de id [taskId] via API e recarrega a lista.
  Future<void> updateStatus(int taskId, String status) async {
    await apiPut('/tasks/$taskId', {'status': status});
    fetchTasks();
  }

  /// Cria uma nova tarefa com [title] e [description] vinculada ao cliente atual
  /// via API e recarrega a lista.
  Future<void> createTask(String title, String description) async {
    await apiPost('/tasks', {
      'title': title,
      'description': description,
      'clientId': widget.clientId,
    });
    fetchTasks();
  }

  /// Atualiza o [title] e [description] da tarefa de id [taskId] via API
  /// e recarrega a lista.
  Future<void> editTask(int taskId, String title, String description) async {
    await apiPut('/tasks/$taskId', {
      'title': title,
      'description': description,
    });
    fetchTasks();
  }

  /// Remove a tarefa de id [taskId] via API e recarrega a lista.
  Future<void> deleteTask(int taskId) async {
    await apiDelete('/tasks/$taskId');
    fetchTasks();
  }

  /// Retorna um badge colorido representando o [status] da tarefa
  /// ('PENDING', 'IN_PROGRESS' ou 'DONE').
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

  /// Exibe um modal com as opções de status para a tarefa de id [taskId].
  /// Atualiza o status apenas se o valor selecionado for diferente de [currentStatus].
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

  /// Exibe um modal com formulário de criação ou edição de tarefa.
  /// Se [task] for fornecido, pré-preenche os campos para edição;
  /// caso contrário, o formulário é exibido vazio para criação.
  void _showTaskForm({Map? task}) {
    final titleCtrl = TextEditingController(text: task?['title'] ?? '');
    final descCtrl = TextEditingController(text: task?['description'] ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              task == null ? 'Nova tarefa' : 'Editar tarefa',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.text,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: titleCtrl,
              autofocus: true,
              style: GoogleFonts.inter(color: AppColors.text),
              decoration: InputDecoration(
                labelText: 'Título',
                labelStyle: GoogleFonts.inter(color: AppColors.textMuted),
                filled: true,
                fillColor: AppColors.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descCtrl,
              style: GoogleFonts.inter(color: AppColors.text),
              decoration: InputDecoration(
                labelText: 'Descrição (opcional)',
                labelStyle: GoogleFonts.inter(color: AppColors.textMuted),
                filled: true,
                fillColor: AppColors.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final t = titleCtrl.text.trim();
                if (t.isEmpty) return;
                Navigator.pop(context);
                if (task == null) {
                  createTask(t, descCtrl.text.trim());
                } else {
                  editTask(task['id'], t, descCtrl.text.trim());
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                task == null ? 'Adicionar' : 'Salvar',
                style: GoogleFonts.inter(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Exibe um diálogo de confirmação antes de remover a tarefa de id [taskId].
  void _confirmDelete(int taskId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(
          'Excluir tarefa',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            color: AppColors.text,
          ),
        ),
        content: Text(
          'Tem certeza que deseja excluir esta tarefa?',
          style: GoogleFonts.inter(color: AppColors.textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancelar',
              style: GoogleFonts.inter(color: AppColors.textMuted),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              deleteTask(taskId);
            },
            child: Text(
              'Excluir',
              style: GoogleFonts.inter(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  /// Constrói a barra de filtros de status (Todos, Pendente, Em andamento, Concluído)
  /// como uma linha horizontal de [ChoiceChip]s.
  Widget _buildFilters() {
    final filters = <(String?, String)>[
      (null, 'Todos'),
      ('PENDING', 'Pendente'),
      ('IN_PROGRESS', 'Em andamento'),
      ('DONE', 'Concluído'),
    ];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: filters.map((f) {
          final (value, label) = f;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(label),
              selected: selectedStatus == value,
              onSelected: (_) {
                setState(() {
                  selectedStatus = value;
                  loading = true;
                });
                fetchTasks();
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  /// Constrói a tela de listagem de tarefas com filtros, FAB para criação
  /// e opções de edição, exclusão e troca de status por item.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tarefas')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showTaskForm(),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Column(
        children: [
          _buildFilters(),
          Expanded(
            child: loading
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                        borderRadius:
                                            BorderRadius.circular(6),
                                        border: Border.all(
                                            color: AppColors.border),
                                      ),
                                      child: const Icon(
                                        Icons.swap_vert,
                                        size: 18,
                                        color: AppColors.textMuted,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  PopupMenuButton<String>(
                                    icon: const Icon(
                                      Icons.more_vert,
                                      size: 18,
                                      color: AppColors.textMuted,
                                    ),
                                    color: AppColors.surface,
                                    onSelected: (value) {
                                      if (value == 'edit') {
                                        _showTaskForm(task: task);
                                      } else if (value == 'delete') {
                                        _confirmDelete(task['id']);
                                      }
                                    },
                                    itemBuilder: (_) => [
                                      PopupMenuItem(
                                        value: 'edit',
                                        child: Text(
                                          'Editar',
                                          style: GoogleFonts.inter(
                                              color: AppColors.text),
                                        ),
                                      ),
                                      PopupMenuItem(
                                        value: 'delete',
                                        child: Text(
                                          'Excluir',
                                          style: GoogleFonts.inter(
                                              color: Colors.red),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
