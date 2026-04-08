import 'package:flutter/material.dart';
import 'package:mobile/services/api.dart';
import 'tasks_screen.dart';

class ClientsScreen extends StatefulWidget {
  const ClientsScreen({super.key});

  @override
  State<ClientsScreen> createState() => _ClientsScreenState();
}

class _ClientsScreenState extends State<ClientsScreen> {
  List clients = [];

  @override
  void initState() {
    super.initState();
    fetchClients();
  }

  Future<void> fetchClients() async {
    final response = await apiGet('/clients');
    setState(() {
      clients = response;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Clientes')),
      body: ListView.builder(
        itemCount: clients.length,
        itemBuilder: (context, index) {
          final client = clients[index];
          return ListTile(
            title: Text(client['name']),
            subtitle: Text(client['email']),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => TasksScreen(clientId: client['id']),
                ),
              );
            },
          );
        },
      ),
    );
  }
}