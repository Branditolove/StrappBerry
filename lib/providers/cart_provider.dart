import 'package:flutter/foundation.dart';
import 'package:myapp/models/product_model.dart';

class CartProvider with ChangeNotifier {
  final Map<String, CartItem> _cartItems = {};
  final Map<String, Product> _favoriteProducts = {};

  Map<String, CartItem> get cartItems => _cartItems;
  Map<String, Product> get favoriteProducts => _favoriteProducts;

  void addProduct(Product product) {
    if (_cartItems.containsKey(product.id)) {
      _cartItems.update(
        product.id,
        (existingCartItem) => CartItem(
          product: existingCartItem.product,
          quantity: existingCartItem.quantity + 1,
        ),
      );
    } else {
      _cartItems.putIfAbsent(
        product.id,
        () => CartItem(
          product: product,
          quantity: 1,
        ),
      );
    }
    notifyListeners();
  }

  void removeProduct(Product product) {
    if (!_cartItems.containsKey(product.id)) return;

    if (_cartItems[product.id]!.quantity > 1) {
      _cartItems.update(
        product.id,
        (existingCartItem) => CartItem(
          product: existingCartItem.product,
          quantity: existingCartItem.quantity - 1,
        ),
      );
    } else {
      _cartItems.remove(product.id);
    }
    notifyListeners();
  }

  int getProductQuantity(Product product) {
    return _cartItems[product.id]?.quantity ?? 0;
  }

  double get totalPrice {
    return _cartItems.values.fold(
      0.0,
      (sum, cartItem) => sum + (cartItem.product.price * cartItem.quantity),
    );
  }

  void clearCart() {
    _cartItems.clear();
    notifyListeners();
  }

  void toggleFavorite(Product product) {
    if (_favoriteProducts.containsKey(product.id)) {
      _favoriteProducts.remove(product.id);
    } else {
      _favoriteProducts[product.id] = product;
    }
    notifyListeners();
  }

  bool isFavorite(Product product) {
    return _favoriteProducts.containsKey(product.id);
  }
}

class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});
}
