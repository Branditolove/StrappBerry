import 'package:flutter/material.dart';
import 'package:myapp/screens/addeddit_product_page.dart';
import 'package:myapp/screens/admin_page.dart';
import 'package:myapp/screens/cart_page.dart';
import 'package:myapp/screens/login_page.dart';
import 'package:myapp/screens/register_page.dart';
import 'package:myapp/screens/user_page.dart';
import 'package:myapp/providers/cart_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupAdminAccounts(); // Asegura que las cuentas de administrador estén configuradas
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

Future<void> setupAdminAccounts() async {
  final prefs = await SharedPreferences.getInstance();
  final adminAccountsJson = prefs.getString('adminAccounts') ?? '[]';

  if (adminAccountsJson == '[]') {
    final adminAccounts = [
      {'email': 'brandon@strappberry.com', 'password': 'papitas1'},
      {'email': 'admin@strappberry.com', 'password': 'papitas2'},
    ];
    await prefs.setString('adminAccounts', jsonEncode(adminAccounts));
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StrappBerry Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
      ),
      home:
          LoginPage(), // Muestra la página de inicio de sesión al iniciar la aplicación
      debugShowCheckedModeBanner: false,
      routes: {
        '/login': (context) => LoginPage(),
        '/register': (context) => RegisterPage(),
        '/admin': (context) => const AdminPage(),
        '/user': (context) => const UserPage(),
        '/cart': (context) => const CartPage(),
        '/products': (context) => const AddEditProductPage(),
      },
    );
  }
}
