import 'dart:convert';
import 'package:http/http.dart' as http;

const String baseUrl = String.fromEnvironment(
  'API_URL',
  defaultValue: 'http://localhost:3000',
);

String? authToken;

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

Future<void> apiDelete(String path) async {
  await http.delete(
    Uri.parse('$baseUrl$path'),
    headers: {
      'Content-Type': 'application/json',
      if (authToken != null) 'Authorization': 'Bearer $authToken',
    },
  );
}