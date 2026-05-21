/*
purpose: Single-file Flutter app berisi model, service, dan UI untuk consume posts API.
main callers: Flutter entrypoint `main()`.
key dependencies: `package:flutter/material.dart`, `package:http/http.dart`, `dart:convert`.
main/public functions: `PostService.getPosts`, `PostModel.fromJson`, `PostPage`.
important side effects: HTTP GET request ke JSONPlaceholder API.
*/

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// service
class PostService {
  static Future<List<PostModel>> getPosts() async {
    final response = await http.get(
      Uri.parse('https://jsonplaceholder.typicode.com/posts'),
    );
    // pengkondisian jika berhasil
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => PostModel.fromJson(e)).toList();
    }
    // pengkondisian jika gagal
    throw Exception('Gagal Mengambil Data');
  }
}

// postmodel
class PostModel {
  int id;
  String title;
  String body;

  PostModel({required this.id, required this.title, required this.body});

  // factory method
  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(id: json['id'], title: json['title'], body: json['body']);
  }
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Pertemuan 8 - Consume API',
      home: PostPage(),
    );
  }
}

class PostPage extends StatefulWidget {
  const PostPage({super.key});

  @override
  State<PostPage> createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  late Future<List<PostModel>> futurePost;

  // memanggil method service
  @override
  void initState() {
    super.initState();
    futurePost = PostService.getPosts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Daftar Postingan API',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.amberAccent,
      ),
      body: FutureBuilder<List<PostModel>>(
        future: futurePost,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final posts = snapshot.data!;
            return ListView.builder(
              itemCount: posts.length,
              itemBuilder: (context, index) {
                final post = posts[index];
                return Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [Text(post.title), Text(post.body)],
                  ),
                );
              },
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
