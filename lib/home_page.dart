import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  final String name;
  final int price;
  final String imageUrl;

  const HomePage({
    super.key,
    required this.name,
    required this.price,
    required this.imageUrl,
  });

  String formatRupiah(int value) {
    final text = value.toString();
    final reversed = text.split('').reversed.toList();
    final chunks = <String>[];

    for (int i = 0; i < reversed.length; i += 3) {
      final end = (i + 3 < reversed.length) ? i + 3 : reversed.length;
      final chunk = reversed.sublist(i, end).reversed.join();
      chunks.add(chunk);
    }

    return 'Rp ${chunks.reversed.join('.')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      imageUrl,
                      width: 180,
                      height: 120,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    formatRupiah(price),
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/second');
                    },
                    child: const Text('Lihat Detail'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
