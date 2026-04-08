import 'dart:convert';
import 'package:http/http.dart' as http;

const String baseUrl = String.fromEnvironment(
  'API_URL',
  defaultValue: 'http://localhost:3000',
);

/// Token JWT do usuário autenticado. Nulo quando não há sessão ativa.
String? authToken;

/// Realiza uma requisição GET para [path] relativo à [baseUrl].
/// Inclui o [authToken] no header Authorization se disponível.
/// Retorna o corpo da resposta decodificado como JSON.
Future<dynamic> apiGet(String path) async {
  final response = await http.get(
    Uri.parse('$baseUrl$path'),
    headers: {
      'Content-Type': 'application/json',
      if (authToken != null) 'Authorization': 'Bearer $authToken',
    },
  );
  return jsonDecode(response.body);
}

/// Realiza uma requisição POST para [path] com [body] serializado como JSON.
/// Inclui o [authToken] no header Authorization se disponível.
/// Retorna o corpo da resposta decodificado como JSON.
Future<dynamic> apiPost(String path, Map<String, dynamic> body) async {
  final response = await http.post(
    Uri.parse('$baseUrl$path'),
    headers: {
      'Content-Type': 'application/json',
      if (authToken != null) 'Authorization': 'Bearer $authToken',
    },
    body: jsonEncode(body),
  );
  return jsonDecode(response.body);
}

/// Realiza uma requisição PUT para [path] com [body] serializado como JSON.
/// Inclui o [authToken] no header Authorization se disponível.
/// Retorna o corpo da resposta decodificado como JSON.
Future<dynamic> apiPut(String path, Map<String, dynamic> body) async {
  final response = await http.put(
    Uri.parse('$baseUrl$path'),
    headers: {
      'Content-Type': 'application/json',
      if (authToken != null) 'Authorization': 'Bearer $authToken',
    },
    body: jsonEncode(body),
  );
  return jsonDecode(response.body);
}

/// Realiza uma requisição DELETE para [path].
/// Inclui o [authToken] no header Authorization se disponível.
Future<void> apiDelete(String path) async {
  await http.delete(
    Uri.parse('$baseUrl$path'),
    headers: {
      'Content-Type': 'application/json',
      if (authToken != null) 'Authorization': 'Bearer $authToken',
    },
  );
}