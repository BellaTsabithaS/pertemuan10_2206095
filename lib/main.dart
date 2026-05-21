import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class PhotoService {
  static Future<List<PhotoModel>> getPhotos() async {
    final response = await http.get(
      Uri.parse('https://jsonplaceholder.typicode.com/photos?_limit=100'),
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data
          .map((e) => PhotoModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    throw Exception('Gagal Mengambil Data Foto');
  }
}

class PhotoModel {
  final int id;
  final String title;
  final String url;
  final String thumbnailUrl;

  PhotoModel({
    required this.id,
    required this.title,
    required this.url,
    required this.thumbnailUrl,
  });

  factory PhotoModel.fromJson(Map<String, dynamic> json) {
    return PhotoModel(
      id: json['id'] as int,
      title: json['title'] as String,
      url: json['url'] as String,
      thumbnailUrl: json['thumbnailUrl'] as String,
    );
  }
}

class PhotoProvider extends ChangeNotifier {
  List<PhotoModel> photos = [];
  bool isLoading = false;
  String? errorMessage;

  Future<void> fetchPhotos() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      photos = await PhotoService.getPhotos();
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => PhotoProvider()..fetchPhotos(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pertemuan 8 - Provider Daftar Foto',
      home: PhotoPage(),
    );
  }
}

class PhotoPage extends StatelessWidget {
  const PhotoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Daftar Foto API',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.amber,
      ),
      body: Consumer<PhotoProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.errorMessage != null) {
            return Center(child: Text('Error: ${provider.errorMessage}'));
          }

          if (provider.photos.isEmpty) {
            return const Center(child: Text('Data foto kosong'));
          }

          return RefreshIndicator(
            onRefresh: provider.fetchPhotos,
            child: ListView.builder(
              itemCount: provider.photos.length,
              itemBuilder: (context, index) {
                final photo = provider.photos[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  child: ListTile(
                    leading: Image.network(
                      photo.thumbnailUrl,
                      width: 56,
                      height: 56,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.image),
                    ),
                    title: Text(photo.title),
                    subtitle: Text('ID: ${photo.id}'),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
