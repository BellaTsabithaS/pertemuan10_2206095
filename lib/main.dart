/*
 * purpose: App entrypoint for local login and product CRUD using SharedPreferences.
 * main callers: Flutter runtime (`main`) and widget navigation (`LoginPage`/`HomePage`).
 * key dependencies: `dart:convert`, `flutter/material.dart`, `shared_preferences`.
 * main/public functions: `main`, `ProductModel.toMap`, `ProductModel.fromMap`, `_HomePageState.loadProducts`, `_HomePageState.showForm`.
 * important side effects: Reads/writes local key-value storage and performs route replacement navigation.
 */
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isLogin = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    checkLogin();
  }

  Future<void> checkLogin() async {
    final prefs = await SharedPreferences.getInstance();
    isLogin = prefs.getBool('isLogin') ?? false;
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const MaterialApp(
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: isLogin ? const HomePage() : const LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController usernameController = TextEditingController();

  Future<void> login() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLogin', true);
    await prefs.setString('username', usernameController.text);
    if (!mounted) {
      return;
    }
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomePage()),
    );
  }

  @override
  void dispose() {
    usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Card(
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Padding(
              padding: const EdgeInsets.all(25),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.person, size: 80, color: Colors.green),
                  const SizedBox(height: 20),
                  TextField(
                    controller: usernameController,
                    decoration: InputDecoration(
                      labelText: 'Username',
                      prefixIcon: const Icon(Icons.person),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Login',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
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

class ProductModel {
  const ProductModel({
    required this.name,
    required this.price,
    required this.description,
  });

  final String name;
  final String price;
  final String description;

  Map<String, String> toMap() {
    return {'name': name, 'price': price, 'description': description};
  }

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      name: map['name'] as String? ?? '',
      price: map['price'] as String? ?? '',
      description: map['description'] as String? ?? '',
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const String _productsKey = 'products';

  String username = '';
  List<ProductModel> products = [];

  @override
  void initState() {
    super.initState();
    getUser();
    loadProducts();
  }

  Future<void> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString('username') ?? '';
    });
  }

  Future<void> loadProducts() async {
    final prefs = await SharedPreferences.getInstance();
    final storedProducts = prefs.getStringList(_productsKey) ?? [];
    final loadedProducts = storedProducts.map((item) {
      final decoded = jsonDecode(item) as Map<String, dynamic>;
      return ProductModel.fromMap(decoded);
    }).toList();

    setState(() {
      products = loadedProducts;
    });
  }

  Future<void> saveProducts() async {
    final prefs = await SharedPreferences.getInstance();
    final encodedProducts = products.map((product) {
      return jsonEncode(product.toMap());
    }).toList();

    await prefs.setStringList(_productsKey, encodedProducts);
  }

  Future<void> addProduct(ProductModel product) async {
    setState(() {
      products.add(product);
    });
    await saveProducts();
  }

  Future<void> editProduct(int index, ProductModel product) async {
    setState(() {
      products[index] = product;
    });
    await saveProducts();
  }

  Future<void> deleteProduct(int index) async {
    setState(() {
      products.removeAt(index);
    });
    await saveProducts();
  }

  Future<void> showForm({ProductModel? product, int? index}) async {
    final nameController = TextEditingController(text: product?.name ?? '');
    final priceController = TextEditingController(text: product?.price ?? '');
    final descriptionController = TextEditingController(
      text: product?.description ?? '',
    );

    try {
      await showDialog<void>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: Text(index == null ? 'Tambah Produk' : 'Edit Produk'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nama Produk',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: priceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Harga',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: descriptionController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Deskripsi',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final name = nameController.text.trim();
                  final price = priceController.text.trim();
                  final description = descriptionController.text.trim();

                  if (name.isEmpty || price.isEmpty || description.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Semua data produk wajib diisi'),
                      ),
                    );
                    return;
                  }

                  final productData = ProductModel(
                    name: name,
                    price: price,
                    description: description,
                  );

                  if (index == null) {
                    await addProduct(productData);
                  } else {
                    await editProduct(index, productData);
                  }

                  if (!dialogContext.mounted) {
                    return;
                  }
                  Navigator.pop(dialogContext);
                },
                child: const Text('Simpan'),
              ),
            ],
          );
        },
      );
    } finally {
      nameController.dispose();
      priceController.dispose();
      descriptionController.dispose();
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('isLogin');
    await prefs.remove('username');
    if (!mounted) {
      return;
    }
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Container(
                height: 100,
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 28,
                      backgroundImage: NetworkImage(
                        'https://picsum.photos/200/300?grayscale',
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Selamat Datang',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 15),
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  username,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Icon(
                                Icons.verified,
                                color: Colors.green,
                                size: 20,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: logout,
                      child: const Icon(Icons.logout, color: Colors.red),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Daftar Produk',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => showForm(),
                    icon: const Icon(Icons.add),
                    label: const Text('Tambah'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: products.isEmpty
                    ? const Center(
                        child: Text(
                          'Belum ada produk',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      )
                    : ListView.builder(
                        itemCount: products.length,
                        itemBuilder: (context, index) {
                          final product = products[index];

                          return Card(
                            child: ListTile(
                              title: Text(product.name),
                              subtitle: Text(
                                'Harga: ${product.price}\n${product.description}',
                              ),
                              leading: IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.green,
                                ),
                                onPressed: () {
                                  showForm(product: product, index: index);
                                },
                              ),
                              trailing: IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () => deleteProduct(index),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
