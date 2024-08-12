// ignore_for_file: library_private_types_in_public_api

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:myapp/widgets/add_product_form.dart';
import 'package:myapp/widgets/edit_product_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:myapp/models/product_model.dart';

class ProductListWidget extends StatefulWidget {
  const ProductListWidget({super.key});

  @override
  _ProductListWidgetState createState() => _ProductListWidgetState();
}

class _ProductListWidgetState extends State<ProductListWidget> {
  List<Product> _products = [];

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    final prefs = await SharedPreferences.getInstance();
    final productsJson = prefs.getString('products') ?? '[]';
    final List<dynamic> productList = jsonDecode(productsJson);
    setState(() {
      _products = productList.map((item) => Product.fromJson(item)).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Productos'),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(10),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 0.75,
        ),
        itemCount: _products.length,
        itemBuilder: (context, index) {
          final product = _products[index];
          return Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: product.imageUrl.isNotEmpty
                      ? Image.file(File(product.imageUrl), fit: BoxFit.cover)
                      : const Placeholder(),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(product.name,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text('\$${product.price.toStringAsFixed(2)}',
                          style: const TextStyle(color: Colors.red)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              // Navegar a la pantalla de edición
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      EditProductForm(product: product),
                                ),
                              ).then((_) => _loadProducts());
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              // Mostrar diálogo de confirmación antes de borrar
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text("Confirmar borrado"),
                                    content: const Text(
                                        "¿Estás seguro de que quieres borrar este producto?"),
                                    actions: [
                                      TextButton(
                                        child: const Text("Cancelar"),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                      TextButton(
                                        child: const Text("Borrar"),
                                        onPressed: () {
                                          _deleteProduct(product);
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddProductForm()),
          ).then((_) => _loadProducts());
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _deleteProduct(Product product) async {
    final prefs = await SharedPreferences.getInstance();
    final productsJson = prefs.getString('products') ?? '[]';
    final List<dynamic> productList = jsonDecode(productsJson);
    productList.removeWhere((item) => item['id'] == product.id);
    await prefs.setString('products', jsonEncode(productList));
    _loadProducts();
  }
}
