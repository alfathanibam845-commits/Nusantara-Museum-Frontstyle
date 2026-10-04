import 'dart:convert';
import 'package:http/http.dart' as http;

const String baseUrl = 'http://localhost:5002/api/v1';

Future<List<dynamic>> getCategories() async {
  final response = await http.get(
    Uri.parse('$baseUrl/categories'),
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);

    return data['data']['categories'];
  }

  throw Exception('Gagal mengambil kategori');
}