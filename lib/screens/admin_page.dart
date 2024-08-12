// ignore_for_file: library_private_types_in_public_api

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:myapp/screens/addeddit_product_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:myapp/models/product_model.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
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

  void _deleteProduct(Product product) async {
    setState(() {
      _products.remove(product);
    });
    await _saveProducts();
  }

  Future<void> _saveProducts() async {
    final prefs = await SharedPreferences.getInstance();
    final productsJson = jsonEncode(_products.map((p) => p.toJson()).toList());
    await prefs.setString('products', productsJson);
  }

  void _addOrEditProduct({Product? product}) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddEditProductPage(product: product),
      ),
    );

    if (result != null) {
      setState(() {
        if (product == null) {
          _products.add(result);
        } else {
          final index = _products.indexWhere((p) => p.id == result.id);
          if (index != -1) {
            _products[index] = result;
          }
        }
      });
      await _saveProducts();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Productos'),
        backgroundColor: Colors.blueGrey[700],
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: _products.length,
        itemBuilder: (context, index) {
          final product = _products[index];
          return Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Image.network(
                    product.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const Placeholder(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(product.name,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text('\$${product.price}',
                          style: const TextStyle(color: Colors.red)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () =>
                                _addOrEditProduct(product: product),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => _deleteProduct(product),
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
        onPressed: () => _addOrEditProduct(),
        backgroundColor: Colors.blueGrey[700],
        child: const Icon(Icons.add),
      ),
    );
  }
}
