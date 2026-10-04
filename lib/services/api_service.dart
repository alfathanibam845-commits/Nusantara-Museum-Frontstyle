import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String baseUrl = 'http://localhost:5002/api/v1';

Future<List<dynamic>> getCategories() async {
  try {
    final response = await http.get(
      Uri.parse('$baseUrl/categories'),
    );

    print('GET CATEGORIES STATUS: ${response.statusCode}');
    print('GET CATEGORIES RESPONSE: ${response.body}');

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);

      if (decoded is Map<String, dynamic>) {
        final data = decoded['data'];

        if (data is Map<String, dynamic>) {
          final categories = data['categories'];

          if (categories is List) {
            return categories;
          }
        }
      }

      throw Exception(
        'Format response kategori tidak valid.',
      );
    }

    throw Exception(
      'Gagal mengambil kategori: ${response.body}',
    );
  } catch (error) {
    print('GET CATEGORIES ERROR: $error');
    rethrow;
  }
}

Future<List<dynamic>> getPosts() async {
  try {
    final response = await http.get(
      Uri.parse('$baseUrl/posts'),
    );

    print('GET POSTS STATUS: ${response.statusCode}');
    print('GET POSTS RESPONSE: ${response.body}');

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);

      if (decoded is Map<String, dynamic>) {
        final data = decoded['data'];

        if (data is Map<String, dynamic>) {
          final posts = data['posts'];

          if (posts is List) {
            return posts;
          }
        }
      }

      throw Exception(
        'Format response artikel tidak valid.',
      );
    }

    throw Exception(
      'Gagal mengambil artikel: ${response.body}',
    );
  } catch (error) {
    print('GET POSTS ERROR: $error');
    rethrow;
  }
}

Future<bool> loginUser(
  String email,
  String password,
) async {
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    print('LOGIN STATUS: ${response.statusCode}');
    print('LOGIN RESPONSE: ${response.body}');

    if (response.statusCode != 200) {
      return false;
    }

    final decoded = jsonDecode(response.body);

    if (decoded is! Map<String, dynamic>) {
      print('RESPONSE LOGIN TIDAK VALID');
      return false;
    }

    String? token;

    final dynamic decodedData = decoded['data'];

    if (decodedData is Map<String, dynamic>) {
      if (decodedData['token'] != null) {
        token = decodedData['token'].toString();
      }
    }

    token ??= decoded['token']?.toString();

    if (token == null || token.isEmpty) {
      print('TOKEN TIDAK DITEMUKAN');
      return false;
    }

    dynamic userData;

    if (decodedData is Map<String, dynamic>) {
      userData = decodedData['user'];
    }

    userData ??= decoded['user'];

    int? userId;

    if (userData is Map<String, dynamic>) {
      final dynamic id =
          userData['id'] ?? userData['userId'];

      if (id != null) {
        userId = int.tryParse(
          id.toString(),
        );
      }
    }

    final prefs =
        await SharedPreferences.getInstance();

    await prefs.setString(
      'token',
      token,
    );

    if (userId != null) {
      await prefs.setInt(
        'userId',
        userId,
      );

      print(
        'USER ID BERHASIL DISIMPAN: $userId',
      );
    } else {
      print(
        'USER ID TIDAK DITEMUKAN DI RESPONSE LOGIN',
      );
    }

    print('TOKEN BERHASIL DISIMPAN');

    return true;
  } catch (error) {
    print('LOGIN ERROR: $error');

    return false;
  }
}

Future<String?> getToken() async {
  final prefs =
      await SharedPreferences.getInstance();

  return prefs.getString('token');
}

Future<int?> getSavedUserId() async {
  final prefs =
      await SharedPreferences.getInstance();

  return prefs.getInt('userId');
}

Future<void> logoutUser() async {
  final prefs =
      await SharedPreferences.getInstance();

  await prefs.remove('token');
  await prefs.remove('userId');

  print('SESSION BERHASIL DIHAPUS');
}

Future<Map<String, dynamic>> getProfile({
  required int userId,
}) async {
  try {
    final token = await getToken();

    if (token == null || token.isEmpty) {
      throw Exception(
        'Belum login. Silakan login terlebih dahulu.',
      );
    }

    final response = await http.get(
      Uri.parse(
        '$baseUrl/users/profile/$userId',
      ),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    print('========================================');
    print(
      'GET PROFILE STATUS: ${response.statusCode}',
    );
    print(
      'GET PROFILE RESPONSE: ${response.body}',
    );
    print('========================================');

    if (response.statusCode == 401) {
      await logoutUser();

      throw Exception(
        'Sesi habis, silakan login kembali.',
      );
    }

    if (response.statusCode != 200) {
      throw Exception(
        'Gagal mengambil profile: ${response.body}',
      );
    }

    if (response.body.trim().isEmpty) {
      throw Exception(
        'Response profile dari server kosong.',
      );
    }

    final decoded = jsonDecode(
      response.body,
    );

    if (decoded is! Map<String, dynamic>) {
      throw Exception(
        'Format response profile tidak valid.',
      );
    }

    final dynamic data = decoded['data'];

    if (data is Map<String, dynamic>) {
      final dynamic user = data['user'];

      if (user is Map<String, dynamic>) {
        return user;
      }

      if (_isUserMap(data)) {
        return data;
      }

      final dynamic nestedData =
          data['data'];

      if (nestedData is Map<String, dynamic>) {
        final dynamic nestedUser =
            nestedData['user'];

        if (nestedUser is Map<String, dynamic>) {
          return nestedUser;
        }

        if (_isUserMap(nestedData)) {
          return nestedData;
        }
      }
    }

    final dynamic user =
        decoded['user'];

    if (user is Map<String, dynamic>) {
      return user;
    }

    if (_isUserMap(decoded)) {
      return decoded;
    }

    throw Exception(
      'Data user tidak ditemukan pada response backend.',
    );
  } catch (error) {
    print(
      'GET PROFILE ERROR: $error',
    );

    rethrow;
  }
}

bool _isUserMap(
  Map<String, dynamic> data,
) {
  return data.containsKey('id') ||
      data.containsKey('userId') ||
      data.containsKey('username') ||
      data.containsKey('email');
}

Future<bool> createPost({
  required int userId,
  required int categoryId,
  required String title,
  required String content,
  String? status,
  XFile? image,
}) async {
  try {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/posts'),
    );

    request.fields['userId'] =
        userId.toString();

    request.fields['categoryId'] =
        categoryId.toString();

    request.fields['title'] =
        title;

    request.fields['content'] =
        content;

    request.fields['status'] =
        status ?? 'published';

    if (image != null) {
      final bytes =
          await image.readAsBytes();

      final multipartFile =
          http.MultipartFile.fromBytes(
        'image',
        bytes,
        filename: image.name,
      );

      request.files.add(
        multipartFile,
      );
    }

    final streamedResponse =
        await request.send();

    final response =
        await http.Response.fromStream(
      streamedResponse,
    );

    print(
      'CREATE POST STATUS: ${response.statusCode}',
    );

    print(
      'CREATE POST RESPONSE: ${response.body}',
    );

    return response.statusCode == 201;
  } catch (error) {
    print(
      'CREATE POST ERROR: $error',
    );

    return false;
  }
}

Future<bool> updatePost({
  required int postId,
  required int categoryId,
  required String title,
  required String content,
  String? status,
  XFile? image,
}) async {
  try {
    final request = http.MultipartRequest(
      'PUT',
      Uri.parse('$baseUrl/posts/$postId'),
    );

    request.fields['categoryId'] =
        categoryId.toString();

    request.fields['title'] =
        title;

    request.fields['content'] =
        content;

    request.fields['status'] =
        status ?? 'published';

    if (image != null) {
      final bytes =
          await image.readAsBytes();

      final multipartFile =
          http.MultipartFile.fromBytes(
        'image',
        bytes,
        filename: image.name,
      );

      request.files.add(
        multipartFile,
      );
    }

    final streamedResponse =
        await request.send();

    final response =
        await http.Response.fromStream(
      streamedResponse,
    );

    print(
      'UPDATE POST STATUS: ${response.statusCode}',
    );

    print(
      'UPDATE POST RESPONSE: ${response.body}',
    );

    return response.statusCode == 200;
  } catch (error) {
    print(
      'UPDATE POST ERROR: $error',
    );

    return false;
  }
}

Future<bool> deletePost({
  required int postId,
}) async {
  try {
    final response = await http.delete(
      Uri.parse('$baseUrl/posts/$postId'),
    );

    print(
      'DELETE POST STATUS: ${response.statusCode}',
    );

    print(
      'DELETE POST RESPONSE: ${response.body}',
    );

    return response.statusCode == 200;
  } catch (error) {
    print(
      'DELETE POST ERROR: $error',
    );

    return false;
  }
}