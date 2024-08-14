import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:myapp/screens/cart_page.dart';
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
  List<Product> _favorites = [];
  String _username = '';
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadUsername();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    final prefs = await SharedPreferences.getInstance();
    final productsJson = prefs.getString('products') ?? '[]';
    final List<dynamic> productList = jsonDecode(productsJson);

    // Productos predefinidos
    final predefinedProducts = [
      Product(
        id: '1',
        name: 'Laptop',
        price: 999.99,
        imageUrl: 'assets/laptop.png',
        descripcion: 'Potente laptop para trabajo y juegos',
        category: 'Laptops',
        quantity: 1,
      ),
      Product(
        id: '2',
        name: 'Smartphone',
        price: 699.99,
        imageUrl: 'assets/smartpone.png',
        descripcion: 'Smartphone de última generación',
        category: 'Celulares',
        quantity: 1,
      ),
      Product(
        id: '3',
        name: 'Tablet',
        price: 299.99,
        imageUrl: 'assets/tablet.png',
        descripcion: 'Tablet versátil para entretenimiento y productividad',
        category: 'Tablets',
        quantity: 1,
      ),
    ];

    setState(() {
      _products = [
        ...predefinedProducts,
        ...productList.map((json) => Product.fromJson(json)).toList(),
      ];
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
    if (index == 1) {
      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      setState(() {
        _favorites = cartProvider.favoriteProducts.values.toList();
      });
    }
  });
}

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final cartItemCount = cartProvider.cartItems.length;

    final List<Widget> pages = <Widget>[
      ProductList(products: _products),
      FavoritesPage(favorites: _favorites),
      AccountPage(username: _username),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Bienvenido $_username'),
        actions: [
          badges.Badge(
            badgeContent: Text(
              cartItemCount.toString(),
              style: const TextStyle(color: Colors.white),
            ),
            position: badges.BadgePosition.topEnd(top: 0, end: 3),
            child: IconButton(
              icon: const Icon(Icons.shopping_cart),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CartPage()),
                );
              },
            ),
          ),
        ],
      ),
      body: pages[_selectedIndex],
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
    final cartProvider = Provider.of<CartProvider>(context);
    final isFavorite = cartProvider.isFavorite(product);

    return Card(
      margin: const EdgeInsets.all(8),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Image.asset(
          product.imageUrl,
          fit: BoxFit.cover,
          width: 50,
          height: 50,
          errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
        ),
        title: Text(product.name),
        subtitle: Text('\$${product.price}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                Icons.shopping_cart,
                color: cartProvider.cartItems.containsKey(product.id)
                    ? Colors.blue
                    : Colors.grey,
              ),
              onPressed: () {
                if (cartProvider.cartItems.containsKey(product.id)) {
                  cartProvider.removeProduct(product);
                } else {
                  cartProvider.addProduct(product);
                }
              },
            ),
            IconButton(
              icon: Icon(
                Icons.favorite,
                color: isFavorite ? Colors.red : Colors.grey,
              ),
              onPressed: () {
                cartProvider.toggleFavorite(product);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class FavoritesPage extends StatelessWidget {
  final List<Product> favorites;

  const FavoritesPage({super.key, required this.favorites});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: favorites.length,
      itemBuilder: (context, index) {
        final product = favorites[index];
        return ProductCard(product: product);
      },
    );
  }
}

class AccountPage extends StatelessWidget {
  final String username;

  const AccountPage({super.key, required this.username});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Bienvenido, $username'),
          ElevatedButton(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove('username');
              Navigator.pushReplacementNamed(context, '/login');
            },
            child: const Text('Cerrar Sesión'),
          ),
        ],
      ),
    );
  }
}
