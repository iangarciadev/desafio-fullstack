import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

const String baseUrl = String.fromEnvironment(
  'API_URL',
  defaultValue: 'http://localhost:3000',
);

/// Token JWT do usuário autenticado. Nulo quando não há sessão ativa.
String? authToken;

/// Chave global do navegador usada para redirecionar ao login em caso de 401/403.
final navigatorKey = GlobalKey<NavigatorState>();

/// Exceção lançada quando a API retorna um status de erro (4xx/5xx)
/// ou quando ocorre um erro de rede/decodificação.
class ApiException implements Exception {
  final int statusCode;
  final String message;
  ApiException(this.statusCode, this.message);

  @override
  String toString() => message;
}

const _timeout = Duration(seconds: 15);

Map<String, String> get _headers => {
      'Content-Type': 'application/json',
      if (authToken != null) 'Authorization': 'Bearer $authToken',
    };

/// Decodifica a resposta HTTP e lança [ApiException] em caso de erro.
/// Em caso de 401 ou 403, limpa o token e redireciona para o login.
dynamic _decode(http.Response response) {
  if (response.statusCode == 401 || response.statusCode == 403) {
    authToken = null;
    navigatorKey.currentState?.pushNamedAndRemoveUntil('/login', (_) => false);
    throw ApiException(response.statusCode, 'Sessão expirada. Faça login novamente.');
  }
  if (response.body.isEmpty) {
    if (response.statusCode >= 200 && response.statusCode < 300) return null;
    throw ApiException(response.statusCode, 'Erro ${response.statusCode}');
  }
  final data = jsonDecode(response.body);
  if (response.statusCode >= 400) {
    final msg = data is Map
        ? (data['error'] ?? data['message'] ?? 'Erro ${response.statusCode}')
        : 'Erro ${response.statusCode}';
    throw ApiException(response.statusCode, msg.toString());
  }
  return data;
}

/// Realiza uma requisição GET para [path] relativo à [baseUrl].
/// Inclui o [authToken] no header Authorization se disponível.
/// Lança [ApiException] em caso de erro HTTP ou de rede.
Future<T> _withTimeout<T>(Future<T> request) async {
  try {
    return await request.timeout(_timeout);
  } on TimeoutException {
    throw ApiException(0, 'Tempo de conexão esgotado. Verifique sua internet.');
  }
}

Future<dynamic> apiGet(String path) async {
  final response = await _withTimeout(
    http.get(Uri.parse('$baseUrl$path'), headers: _headers),
  );
  return _decode(response);
}

/// Realiza uma requisição POST para [path] com [body] serializado como JSON.
/// Inclui o [authToken] no header Authorization se disponível.
/// Lança [ApiException] em caso de erro HTTP ou de rede.
Future<dynamic> apiPost(String path, Map<String, dynamic> body) async {
  final response = await _withTimeout(
    http.post(Uri.parse('$baseUrl$path'), headers: _headers, body: jsonEncode(body)),
  );
  return _decode(response);
}

/// Realiza uma requisição PUT para [path] com [body] serializado como JSON.
/// Inclui o [authToken] no header Authorization se disponível.
/// Lança [ApiException] em caso de erro HTTP ou de rede.
Future<dynamic> apiPut(String path, Map<String, dynamic> body) async {
  final response = await _withTimeout(
    http.put(Uri.parse('$baseUrl$path'), headers: _headers, body: jsonEncode(body)),
  );
  return _decode(response);
}

/// Realiza uma requisição DELETE para [path].
/// Inclui o [authToken] no header Authorization se disponível.
/// Lança [ApiException] em caso de erro HTTP ou de rede.
Future<void> apiDelete(String path) async {
  final response = await _withTimeout(
    http.delete(Uri.parse('$baseUrl$path'), headers: _headers),
  );
  _decode(response);
}
