import 'package:flutter/foundation.dart';
import '../models/cart.dart';
import '../models/menu.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CartProvider with ChangeNotifier {
  static const String _cartKey = 'cart';
  final SharedPreferences _prefs;
  Cart? _cart;

  CartProvider(this._prefs) {
    _loadCart();
  }

  Cart? get cart => _cart;

  Future<void> _loadCart() async {
    final cartJson = _prefs.getString(_cartKey);
    if (cartJson != null) {
      final Map<String, dynamic> cartMap = json.decode(cartJson);
      _cart = Cart(
        standId: cartMap['standId'],
        items: (cartMap['items'] as List).map((item) {
          final menuMap = item['menu'] as Map<String, dynamic>;
          return CartItem(
            menu: Menu.fromJson(menuMap),
            quantity: item['quantity'],
          );
        }).toList(),
      );
      notifyListeners();
      _saveCart();
    }
  }

  Future<void> _saveCart() async {
    if (_cart == null) {
      await _prefs.remove(_cartKey);
    } else {
      final cartMap = {
        'standId': _cart!.standId,
        'items': _cart!.items
            .map((item) => {
                  'menu': item.menu,
                  'quantity': item.quantity,
                })
            .toList(),
      };
      await _prefs.setString(_cartKey, json.encode(cartMap));
    }
  }

  void addItem(Menu menu) {
    if (_cart == null) {
      _cart = Cart(
        standId: menu.standId,
        items: [CartItem(menu: menu)],
      );
      notifyListeners();
      _saveCart();
      return;
    }

    final existingItem =
        _cart!.items.where((item) => item.menu.id == menu.id).firstOrNull;

    if (existingItem != null) {
      existingItem.quantity++;
      notifyListeners();
      _saveCart();
    } else {
      _cart = Cart(
        standId: _cart!.standId,
        items: [..._cart!.items, CartItem(menu: menu)],
      );
      notifyListeners();
      _saveCart();
    }
  }

  void incrementItem(Menu menu) {
    if (_cart == null) return;

    final existingItem =
        _cart!.items.where((item) => item.menu.id == menu.id).firstOrNull;

    if (existingItem != null) {
      existingItem.quantity++;
      notifyListeners();
      _saveCart();
    }
  }

  void decrementItem(Menu menu) {
    if (_cart == null) return;

    final existingItem =
        _cart!.items.where((item) => item.menu.id == menu.id).firstOrNull;

    if (existingItem != null) {
      if (existingItem.quantity > 1) {
        existingItem.quantity--;
        notifyListeners();
        _saveCart();
      } else {
        _cart = Cart(
          standId: _cart!.standId,
          items: _cart!.items.where((item) => item.menu.id != menu.id).toList(),
        );
        notifyListeners();
        _saveCart();
      }

      if (_cart!.items.isEmpty) {
        _cart = null;
        notifyListeners();
        _saveCart();
      }
    }
  }

  void clearCart() {
    _cart = null;
    notifyListeners();
    _saveCart();
  }
}
