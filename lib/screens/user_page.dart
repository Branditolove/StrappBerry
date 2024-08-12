// ignore_for_file: library_private_types_in_public_api

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:myapp/providers/cart_provider.dart';
import 'package:myapp/models/product_model.dart';
import 'package:badges/badges.dart' as badges;

class UserPage extends StatefulWidget {
  const UserPage({super.key});

  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  List<Product> _products = [];
  String _username = '';
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _loadUsername();
  }

  Future<void> _loadProducts() async {
    final prefs = await SharedPreferences.getInstance();
    final productsJson = prefs.getString('products') ?? '[]';
    final List<dynamic> productList = jsonDecode(productsJson);
    setState(() {
      _products = productList.map((item) => Product.fromJson(item)).toList();
    });
  }

  Future<void> _loadUsername() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _username = prefs.getString('username') ?? 'Usuario';
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    switch (index) {
      case 0:
        Navigator.pushNamed(context, '/products');
        break;
      case 1:
        Navigator.pushNamed(context, '/favorites');
        break;
      case 2:
        Navigator.pushNamed(context, '/account');
        break;
    }
  }

  @override
 @override
Widget build(BuildContext context) {
  final cartProvider = Provider.of<CartProvider>(context);
  final cartItemCount = cartProvider.cartItems?.length ?? 0;

  return Scaffold(
    appBar: AppBar(
      title: Text('Bienvenido $_username'),
      actions: [
        badges.Badge(
          badgeContent: Text(
            cartItemCount.toString(),
            style: const TextStyle(color: Colors.white),
          ),
          position: badges.BadgePosition.topEnd(end: 12, top: 12),
          child: IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.pushNamed(context, '/cart');
            },
          ),
        ),
      ],
    ),
    body: RefreshIndicator(
      onRefresh: _loadProducts,
      child: ProductList(products: _products),
    ),
    bottomNavigationBar: BottomNavigationBar(
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.list),
          label: 'Productos',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.favorite),
          label: 'Favoritos',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Cuenta',
        ),
      ],
      currentIndex: _selectedIndex,
      onTap: _onItemTapped,
    ),
  );
}
}

class ProductList extends StatelessWidget {
  final List<Product> products;

  const ProductList({super.key, required this.products});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return ProductCard(product: product);
      },
    );
  }
}

class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Image.file(
          File(product.imageUrl),
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => const Placeholder(),
        ),
        title: Text(product.name),
        subtitle: Text('\$${product.price}'),
        trailing: IconButton(
          icon: const Icon(Icons.add_shopping_cart),
          onPressed: () {
            Provider.of<CartProvider>(context, listen: false)
                .addProduct(product);
          },
        ),
      ),
    );
  }
}
