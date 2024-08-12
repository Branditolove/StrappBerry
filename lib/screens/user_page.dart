import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:myapp/providers/cart_provider.dart';
import 'package:myapp/models/product_model.dart';
import 'package:badges/badges.dart' as badges;

class UserPage extends StatefulWidget {
  const UserPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
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
    _loadFavorites();
  }

  Future<void> _loadProducts() async {
    // Implementa la carga de productos desde SharedPreferences o una API
    // Por ahora, usaremos datos de ejemplo
    setState(() {
      _products = [
        Product(
            id: '1',
            name: 'MAC',
            price: 300,
            imageUrl: 'assets/product1.png',
            descripcion: 'MAC PRO',
            category: '',
            quantity: 1),
        Product(
            id: '2',
            name: 'PS5',
            price: 500,
            imageUrl: 'assets/product2.png',
            descripcion: 'Consola PS5',
            category: '',
            quantity: 1),
      ];
    });
  }

  Future<void> _loadFavorites() async {
    // Implementa la carga de favoritos desde SharedPreferences o una API
    // Por ahora, usaremos datos de ejemplo
    setState(() {
      _favorites = [
        Product(
            id: '1',
            name: 'Producto 1',
            price: 100,
            imageUrl: 'assets/product1.png',
            descripcion: '',
            category: '',
            quantity: 1),
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
      if (index == 0) {
        _loadProducts();
      } else if (index == 1) {
        _loadFavorites();
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
                Navigator.pushNamed(context, '/cart');
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
              // Implementa la lógica para cerrar sesión
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove('username');
              // ignore: use_build_context_synchronously
              Navigator.pushReplacementNamed(context, '/login');
            },
            child: const Text('Cerrar Sesión'),
          ),
        ],
      ),
    );
  }
}
