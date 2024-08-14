import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:myapp/widgets/add_product_form.dart';
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

    if (productList.isEmpty) {
      // Agregar productos predefinidos si la lista está vacía
      productList.addAll([
        Product(
          id: '1',
          name: 'Laptop',
          price: 999.99,
          imageUrl: 'assets/images/laptop.jpg', // Ruta del asset local
          descripcion: 'Potente laptop para trabajo y juegos',
          category: 'Laptops',
          quantity: 1,
        ).toJson(),
        Product(
          id: '2',
          name: 'Smartphone',
          price: 699.99,
          imageUrl: 'assets/images/smartphone.jpg', // Ruta del asset local
          descripcion: 'Smartphone de última generación',
          category: 'Celulares',
          quantity: 1,
        ).toJson(),
        Product(
          id: '3',
          name: 'Tablet',
          price: 299.99,
          imageUrl: 'assets/images/tablet.jpg', // Ruta del asset local
          descripcion: 'Tablet versátil para entretenimiento y productividad',
          category: 'Tablets',
          quantity: 1,
        ).toJson(),
      ]);

      // Guardar los productos predefinidos
      await prefs.setString('products', jsonEncode(productList));
    }

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

  void _openAddProductForm({Product? product}) async {
    await showDialog(
      context: context,
      builder: (context) => const Dialog(
        child: AddProductForm(), // Usamos el formulario que hemos editado
      ),
    );

    // Recargar productos después de agregar o editar
    _loadProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Administrar Productos'),
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
                  child: Image.asset(
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
                            onPressed: () => _openAddProductForm(product: product),
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
        onPressed: () => _openAddProductForm(),
        backgroundColor: Colors.blueGrey[700],
        child: const Icon(Icons.add),
      ),
    );
  }
}
