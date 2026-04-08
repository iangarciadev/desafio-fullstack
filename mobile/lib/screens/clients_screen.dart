import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/services/api.dart';
import 'package:mobile/theme.dart';
import 'login_screen.dart';
import 'tasks_screen.dart';

class ClientsScreen extends StatefulWidget {
  const ClientsScreen({super.key});

  @override
  State<ClientsScreen> createState() => _ClientsScreenState();
}

class _ClientsScreenState extends State<ClientsScreen> {
  List<dynamic> clients = [];
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

  /// Cria um novo cliente com os dados fornecidos via API e recarrega a lista.
  /// Retorna true em caso de sucesso, false se ocorrer erro.
  Future<bool> createClient(Map<String, dynamic> data) async {
    try {
      await apiPost('/clients', data);
      fetchClients();
      return true;
    } catch (e) {
      _showError(e.toString());
      return false;
    }
  }

  /// Atualiza o cliente de id [clientId] com os dados fornecidos via API
  /// e recarrega a lista.
  /// Retorna true em caso de sucesso, false se ocorrer erro.
  Future<bool> editClient(int clientId, Map<String, dynamic> data) async {
    try {
      await apiPut('/clients/$clientId', data);
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
    final cepCtrl = TextEditingController(text: client?['cep'] ?? '');
    final logradouroCtrl = TextEditingController(text: client?['logradouro'] ?? '');
    final numeroCtrl = TextEditingController(text: client?['numero'] ?? '');
    final complementoCtrl = TextEditingController(text: client?['complemento'] ?? '');
    final bairroCtrl = TextEditingController(text: client?['bairro'] ?? '');
    final cidadeCtrl = TextEditingController(text: client?['cidade'] ?? '');
    final estadoCtrl = TextEditingController(text: client?['estado'] ?? '');

    InputDecoration fieldDecoration(String label, {String? error, bool readOnly = false}) =>
        InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.inter(color: AppColors.textMuted),
          errorText: error,
          filled: true,
          fillColor: readOnly ? AppColors.border.withAlpha(80) : AppColors.background,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.border),
          ),
        );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      builder: (ctx) {
        bool saving = false;
        bool cepPreenchido = client?['logradouro'] != null;
        String? emailError;
        String? cepError;
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            Future<void> buscarCEP(String value) async {
              final digits = value.replaceAll(RegExp(r'\D'), '');
              if (digits.length != 8) return;
              try {
                final res = await http.get(
                  Uri.parse('https://viacep.com.br/ws/$digits/json/'),
                );
                final data = jsonDecode(res.body) as Map<String, dynamic>;
                if (data['erro'] == true) {
                  setModalState(() => cepError = 'CEP não encontrado.');
                } else {
                  setModalState(() {
                    logradouroCtrl.text = data['logradouro'] ?? '';
                    bairroCtrl.text = data['bairro'] ?? '';
                    cidadeCtrl.text = data['localidade'] ?? '';
                    estadoCtrl.text = data['uf'] ?? '';
                    cepPreenchido = true;
                    cepError = null;
                  });
                }
              } catch (_) {
                setModalState(() => cepError = 'Erro ao buscar CEP.');
              }
            }

            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
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
                      decoration: fieldDecoration('Nome'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      style: GoogleFonts.inter(color: AppColors.text),
                      decoration: fieldDecoration('E-mail', error: emailError),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Endereço (opcional)',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 120,
                          child: TextField(
                            controller: cepCtrl,
                            keyboardType: TextInputType.number,
                            maxLength: 9,
                            style: GoogleFonts.inter(color: AppColors.text),
                            decoration: fieldDecoration('CEP', error: cepError)
                                .copyWith(counterText: ''),
                            onChanged: (v) {
                              // Aplica máscara xxxxx-xxx
                              final digits = v.replaceAll(RegExp(r'\D'), '');
                              final masked = digits.length > 5
                                  ? '${digits.substring(0, 5)}-${digits.substring(5)}'
                                  : digits;
                              if (cepCtrl.text != masked) {
                                cepCtrl.value = TextEditingValue(
                                  text: masked,
                                  selection: TextSelection.collapsed(offset: masked.length),
                                );
                              }
                              setModalState(() => cepError = null);
                              if (digits.length == 8) buscarCEP(digits);
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: logradouroCtrl,
                            readOnly: cepPreenchido,
                            style: GoogleFonts.inter(color: AppColors.text),
                            decoration: fieldDecoration('Logradouro', readOnly: cepPreenchido),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        SizedBox(
                          width: 90,
                          child: TextField(
                            controller: numeroCtrl,
                            keyboardType: TextInputType.text,
                            style: GoogleFonts.inter(color: AppColors.text),
                            decoration: fieldDecoration('Número'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: complementoCtrl,
                            style: GoogleFonts.inter(color: AppColors.text),
                            decoration: fieldDecoration('Complemento'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: bairroCtrl,
                            readOnly: cepPreenchido,
                            style: GoogleFonts.inter(color: AppColors.text),
                            decoration: fieldDecoration('Bairro', readOnly: cepPreenchido),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: cidadeCtrl,
                            readOnly: cepPreenchido,
                            style: GoogleFonts.inter(color: AppColors.text),
                            decoration: fieldDecoration('Cidade', readOnly: cepPreenchido),
                          ),
                        ),
                        const SizedBox(width: 10),
                        SizedBox(
                          width: 60,
                          child: TextField(
                            controller: estadoCtrl,
                            readOnly: cepPreenchido,
                            style: GoogleFonts.inter(color: AppColors.text),
                            decoration: fieldDecoration('UF', readOnly: cepPreenchido),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: saving
                          ? null
                          : () async {
                              final n = nameCtrl.text.trim();
                              final e = emailCtrl.text.trim();
                              if (n.isEmpty || e.isEmpty) return;
                              if (!RegExp(r'^[\w.+-]+@[\w-]+\.[a-zA-Z]{2,}$').hasMatch(e)) {
                                setModalState(() => emailError = 'E-mail inválido');
                                return;
                              }
                              setModalState(() { emailError = null; saving = true; });
                              final data = <String, dynamic>{
                                'name': n,
                                'email': e,
                                if (cepCtrl.text.isNotEmpty) 'cep': cepCtrl.text,
                                if (logradouroCtrl.text.isNotEmpty) 'logradouro': logradouroCtrl.text,
                                if (numeroCtrl.text.isNotEmpty) 'numero': numeroCtrl.text,
                                if (complementoCtrl.text.isNotEmpty) 'complemento': complementoCtrl.text,
                                if (bairroCtrl.text.isNotEmpty) 'bairro': bairroCtrl.text,
                                if (cidadeCtrl.text.isNotEmpty) 'cidade': cidadeCtrl.text,
                                if (estadoCtrl.text.isNotEmpty) 'estado': estadoCtrl.text,
                              };
                              final ok = client == null
                                  ? await createClient(data)
                                  : await editClient(client['id'] as int, data);
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
                              style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                            ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    ).then((_) {
      nameCtrl.dispose();
      emailCtrl.dispose();
      cepCtrl.dispose();
      logradouroCtrl.dispose();
      numeroCtrl.dispose();
      complementoCtrl.dispose();
      bairroCtrl.dispose();
      cidadeCtrl.dispose();
      estadoCtrl.dispose();
    });
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
      appBar: AppBar(
        title: const Text('Clientes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sair',
            onPressed: () {
              authToken = null;
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
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
                                    if ((client['logradouro'] as String?) != null) ...[
                                      const SizedBox(height: 2),
                                      Text(
                                        [
                                          client['logradouro'],
                                          if ((client['numero'] as String?) != null) client['numero'],
                                          if ((client['bairro'] as String?) != null) '— ${client['bairro']}',
                                          if ((client['cidade'] as String?) != null && (client['estado'] as String?) != null)
                                            '${client['cidade']}/${client['estado']}',
                                        ].join(', '),
                                        style: GoogleFonts.inter(
                                          fontSize: 12,
                                          color: AppColors.textMuted,
                                        ),
                                      ),
                                    ],
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
