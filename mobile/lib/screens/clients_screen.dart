import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/services/api.dart';
import 'package:mobile/theme.dart';
import 'tasks_screen.dart';

class ClientsScreen extends StatefulWidget {
  const ClientsScreen({super.key});

  @override
  State<ClientsScreen> createState() => _ClientsScreenState();
}

class _ClientsScreenState extends State<ClientsScreen> {
  List clients = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchClients();
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  /// Busca a lista de clientes do usuário autenticado na API e atualiza o estado.
  Future<void> fetchClients() async {
    try {
      final response = await apiGet('/clients');
      setState(() {
        clients = response;
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
      _showError(e.toString());
    }
  }

  /// Cria um novo cliente com [name] e [email] via API e recarrega a lista.
  /// Retorna true em caso de sucesso, false se ocorrer erro.
  Future<bool> createClient(String name, String email) async {
    try {
      await apiPost('/clients', {'name': name, 'email': email});
      fetchClients();
      return true;
    } catch (e) {
      _showError(e.toString());
      return false;
    }
  }

  /// Atualiza o cliente de id [clientId] com novos [name] e [email] via API
  /// e recarrega a lista.
  /// Retorna true em caso de sucesso, false se ocorrer erro.
  Future<bool> editClient(int clientId, String name, String email) async {
    try {
      await apiPut('/clients/$clientId', {'name': name, 'email': email});
      fetchClients();
      return true;
    } catch (e) {
      _showError(e.toString());
      return false;
    }
  }

  /// Remove o cliente de id [clientId] via API e recarrega a lista.
  Future<void> deleteClient(int clientId) async {
    try {
      await apiDelete('/clients/$clientId');
      fetchClients();
    } catch (e) {
      _showError(e.toString());
    }
  }

  /// Exibe um modal com formulário de criação ou edição de cliente.
  /// Se [client] for fornecido, pré-preenche os campos para edição;
  /// caso contrário, o formulário é exibido vazio para criação.
  void _showClientForm({Map? client}) {
    final nameCtrl = TextEditingController(text: client?['name'] ?? '');
    final emailCtrl = TextEditingController(text: client?['email'] ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      builder: (ctx) {
        bool saving = false;
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Padding(
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
                    client == null ? 'Novo cliente' : 'Editar cliente',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: nameCtrl,
                    autofocus: true,
                    style: GoogleFonts.inter(color: AppColors.text),
                    decoration: InputDecoration(
                      labelText: 'Nome',
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
                    controller: emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    style: GoogleFonts.inter(color: AppColors.text),
                    decoration: InputDecoration(
                      labelText: 'E-mail',
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
                    onPressed: saving
                        ? null
                        : () async {
                            final n = nameCtrl.text.trim();
                            final e = emailCtrl.text.trim();
                            if (n.isEmpty || e.isEmpty) return;
                            setModalState(() => saving = true);
                            final ok = client == null
                                ? await createClient(n, e)
                                : await editClient(client['id'], n, e);
                            if (ok && ctx.mounted) Navigator.pop(ctx);
                            setModalState(() => saving = false);
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: saving
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            client == null ? 'Adicionar' : 'Salvar',
                            style:
                                GoogleFonts.inter(fontWeight: FontWeight.w600),
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  /// Exibe um diálogo de confirmação antes de remover o cliente de id [clientId].
  void _confirmDelete(int clientId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(
          'Excluir cliente',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            color: AppColors.text,
          ),
        ),
        content: Text(
          'Tem certeza que deseja excluir este cliente?',
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
              deleteClient(clientId);
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

  /// Constrói a tela de listagem de clientes com FAB para criação e opções
  /// de edição/exclusão por item.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Clientes')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showClientForm(),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : clients.isEmpty
              ? Center(
                  child: Text(
                    'Nenhum cliente encontrado.',
                    style: GoogleFonts.inter(color: AppColors.textMuted),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: clients.length,
                  itemBuilder: (context, index) {
                    final client = clients[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                TasksScreen(clientId: client['id'] as int),
                          ),
                        );
                      },
                      child: Container(
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
                                      client['name'] as String? ?? '',
                                      style: GoogleFonts.inter(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.text,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      client['email'] as String? ?? '',
                                      style: GoogleFonts.inter(
                                        fontSize: 13,
                                        color: AppColors.textMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              PopupMenuButton<String>(
                                icon: const Icon(
                                  Icons.more_vert,
                                  size: 18,
                                  color: AppColors.textMuted,
                                ),
                                color: AppColors.surface,
                                onSelected: (value) {
                                  if (value == 'edit') {
                                    _showClientForm(client: client);
                                  } else if (value == 'delete') {
                                    _confirmDelete(client['id'] as int);
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
                                      style:
                                          GoogleFonts.inter(color: Colors.red),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
