import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/post.dart';
import '../models/comment.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:3000/api';

  // =========================================================
  // GET POSTS
  // =========================================================

  static Future<List<Post>> getPosts() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/posts'),
      );

      if (response.statusCode != 200) {
        throw Exception(
          'GET /posts gagal. Status: ${response.statusCode}\n'
          'Response: ${response.body}',
        );
      }

      final json = jsonDecode(response.body);

      if (json['success'] != true) {
        throw Exception(
          json['message'] ?? 'API gagal mengambil artikel',
        );
      }

      final List<dynamic> data = json['data'] ?? [];

      return data.map((item) {
        return Post(
          id: item['id'] ?? 0,

          title: item['title'] ?? 'Tanpa Judul',

          content: item['content'] ?? '',

          author: item['author'] ?? 'Admin',

          // Ambil gambar dari API.
          // Kalau tidak ada, gunakan Bromo.
          image: _getImage(item),

          // Mendukung categoryId maupun category_id.
          categoryId:
              item['categoryId'] ??
              item['category_id'] ??
              1,

          categoryName:
              item['categoryName'] ??
              item['category_name'] ??
              'Umum',

          likes: item['likes'] ?? 0,

          isLiked: item['isLiked'] ?? false,
        );
      }).toList();
    } catch (e) {
      throw Exception(
        'Gagal mengambil artikel:\n$e',
      );
    }
  }

  // =========================================================
  // GET IMAGE
  // =========================================================

  static String _getImage(dynamic item) {
    final image = item['image'];

    if (image == null) {
      return '';
    }

    if (image.toString().trim().isEmpty) {
      return '';
    }

    return image.toString();
  }

  // =========================================================
  // GET POST BY ID
  // =========================================================

  static Future<Post> getPostById(int id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/posts/$id'),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Gagal mengambil artikel. Status: ${response.statusCode}',
      );
    }

    final json = jsonDecode(response.body);

    if (json['success'] != true) {
      throw Exception(
        json['message'] ?? 'Artikel tidak ditemukan',
      );
    }

    final item = json['data'];

    return Post(
      id: item['id'] ?? id,
      title: item['title'] ?? 'Tanpa Judul',
      content: item['content'] ?? '',
      author: item['author'] ?? 'Admin',
      image: _getImage(item),
      categoryId:
          item['categoryId'] ??
          item['category_id'] ??
          1,
      categoryName:
          item['categoryName'] ??
          item['category_name'] ??
          'Umum',
      likes: item['likes'] ?? 0,
      isLiked: item['isLiked'] ?? false,
    );
  }

  // =========================================================
  // CREATE POST
  // =========================================================

  static Future<Post> createPost({
    required String title,
    required String content,
    required String author,
    required int categoryId,
    required String categoryName,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/posts'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'title': title,
        'content': content,
        'author': author,
        'categoryId': categoryId,
        'categoryName': categoryName,
      }),
    );

    if (response.statusCode != 201 &&
        response.statusCode != 200) {
      throw Exception(
        'Gagal membuat artikel.\n'
        'Status: ${response.statusCode}\n'
        'Response: ${response.body}',
      );
    }

    final json = jsonDecode(response.body);
    final item = json['data'];

    return Post(
      id: item['id'] ?? 0,
      title: item['title'] ?? title,
      content: item['content'] ?? content,
      author: item['author'] ?? author,
      image: _getImage(item),
      categoryId:
          item['categoryId'] ??
          item['category_id'] ??
          categoryId,
      categoryName:
          item['categoryName'] ??
          item['category_name'] ??
          categoryName,
      likes: item['likes'] ?? 0,
      isLiked: item['isLiked'] ?? false,
    );
  }

  // =========================================================
  // UPDATE POST
  // =========================================================

  static Future<Post> updatePost({
    required int id,
    required String title,
    required String content,
    required int categoryId,
    required String categoryName,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/posts/$id'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'title': title,
        'content': content,
        'categoryId': categoryId,
        'categoryName': categoryName,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Gagal memperbarui artikel.\n'
        'Status: ${response.statusCode}\n'
        'Response: ${response.body}',
      );
    }

    final json = jsonDecode(response.body);
    final item = json['data'];

    return Post(
      id: item['id'] ?? id,
      title: item['title'] ?? title,
      content: item['content'] ?? content,
      author: item['author'] ?? 'Admin',
      image: _getImage(item),
      categoryId:
          item['categoryId'] ??
          item['category_id'] ??
          categoryId,
      categoryName:
          item['categoryName'] ??
          item['category_name'] ??
          categoryName,
      likes: item['likes'] ?? 0,
      isLiked: item['isLiked'] ?? false,
    );
  }

  // =========================================================
  // DELETE POST
  // =========================================================

  static Future<bool> deletePost(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/posts/$id'),
    );

    return response.statusCode == 200 ||
        response.statusCode == 204;
  }

  // =========================================================
  // GET COMMENTS
  // =========================================================

  static Future<List<Comment>> getComments(int postId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/comments/$postId'),
    );

    if (response.statusCode != 200) {
      return [];
    }

    final json = jsonDecode(response.body);

    if (json['success'] != true) {
      return [];
    }

    final List<dynamic> data = json['data'] ?? [];

    return data.map((item) {
      return Comment(
        id: item['id'] ?? 0,
        postId: item['postId'] ?? postId,
        author: item['name'] ?? 'Anonymous',
        content: item['comment'] ?? '',
        createdAt: item['createdAt'] ?? 'Baru saja',
      );
    }).toList();
  }

  // =========================================================
  // DELETE COMMENT
  // =========================================================

  static Future<bool> deleteComment(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/comments/$id'),
    );

    return response.statusCode == 200 ||
        response.statusCode == 204;
  }

  // =========================================================
  // ADD COMMENT
  // =========================================================

  static Future<Comment> addComment({
    required int postId,
    required String author,
    required String content,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/comments/$postId'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'name': author,
        'comment': content,
      }),
    );

    if (response.statusCode != 201 &&
        response.statusCode != 200) {
      throw Exception(
        'Gagal menambahkan komentar.\n'
        'Status: ${response.statusCode}\n'
        'Response: ${response.body}',
      );
    }

    final json = jsonDecode(response.body);
    final item = json['data'];

    return Comment(
      id: item['id'] ??
          DateTime.now().millisecondsSinceEpoch,
      postId: postId,
      author: author,
      content: content,
      createdAt: 'Baru saja',
    );
  }
}