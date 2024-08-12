import 'package:flutter/material.dart';
import 'package:myapp/models/product_model.dart';

class CartProvider with ChangeNotifier {
  final List<Product> _items = [];

  List<Product> get items => _items;

  get cartItems => null;

  void addProduct(Product product) {
    _items.add(product);
    notifyListeners();
  }

  void removeProduct(Product product) {
    _items.remove(product);
    notifyListeners();
  }
}
