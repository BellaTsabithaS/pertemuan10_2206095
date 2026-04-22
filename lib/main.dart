import 'package:flutter/material.dart';

// model
class Product {
  String name;
  int price;
  String imageUrl;

  Product({required this.name, required this.price, required this.imageUrl});
}

void main() {
  runApp(MaterialApp(debugShowCheckedModeBanner: false, home: ProductPage()));
}

class ProductPage extends StatefulWidget {
  @override
  _ProductPageState createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  List<Product> products = [];

  // tambah
  void addProduct(Product product) {
    setState(() {
      products.add(product);
    });
  }

  // update
  void updateProduct(int index, Product product) {
    setState(() {
      products[index] = product;
    });
  }

  // delete
  void deleteProduct(int index) {
    setState(() {
      products.removeAt(index);
    });
  }

  // konfirmasi delete
  void confirmDelete(int index) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Hapus Produk'),
        content: Text('Yakin mau hapus produk ini?'),
        actions: [
          TextButton(
            child: Text('Batal'),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            child: Text('Hapus'),
            onPressed: () {
              deleteProduct(index);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  // form tambah & edit
  void showForm({Product? product, int? index}) {
    TextEditingController nameController = TextEditingController(
      text: product?.name ?? '',
    );
    TextEditingController priceController = TextEditingController(
      text: product?.price.toString() ?? '',
    );
    TextEditingController imageUrlController = TextEditingController(
      text: product?.imageUrl ?? '',
    );

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(product == null ? 'Tambah Produk' : 'Edit Produk'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Nama Produk'),
            ),
            TextField(
              controller: priceController,
              decoration: InputDecoration(labelText: 'Harga Produk'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: imageUrlController,
              decoration: InputDecoration(labelText: 'Image URL'),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            child: Text('Simpan'),
            onPressed: () {
              String name = nameController.text;
              int price = int.tryParse(priceController.text) ?? 0;
              String imageUrl = imageUrlController.text;

              if (name.isEmpty) return;

              final newProduct = Product(
                name: name,
                price: price,
                imageUrl: imageUrl,
              );

              if (product == null) {
                addProduct(newProduct);
              } else {
                updateProduct(index!, newProduct);
              }

              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  // detail dari index
  void showDetail(int index) {
    final product = products[index];

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Detail Produk'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (product.imageUrl.isNotEmpty)
              Image.network(
                product.imageUrl,
                height: 120,
                errorBuilder: (_, __, ___) =>
                    Icon(Icons.broken_image, size: 60),
              ),
            Text('Index: $index'),
            Text('Nama: ${product.name}'),
            Text('Harga: Rp ${product.price}'),
          ],
        ),
        actions: [
          TextButton(
            child: Text('Tutup'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('CRUD Product'), backgroundColor: Colors.blue),
      body: products.isEmpty
          ? Center(child: Text('Belum ada produk'))
          : ListView.builder(
              itemCount: products.length,
              itemBuilder: (_, index) {
                return ListTile(
                  leading: products[index].imageUrl.isEmpty
                      ? CircleAvatar(child: Icon(Icons.image))
                      : CircleAvatar(
                          backgroundImage: NetworkImage(
                            products[index].imageUrl,
                          ),
                        ),
                  title: Text(products[index].name),
                  subtitle: Text('Rp ${products[index].price}'),

                  // klik ? detail
                  onTap: () => showDetail(index),

                  // FIX biar tombol delete muncul
                  trailing: SizedBox(
                    width: 100,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // edit
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () =>
                              showForm(product: products[index], index: index),
                        ),

                        // delete
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () => confirmDelete(index),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showForm(),
        child: Icon(Icons.add),
      ),
    );
  }
}
