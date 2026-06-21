import '../../../../core/database/app_database.dart';
import '../models/cart_item_model.dart';

class CartLocalDataSource {
  final AppDatabase _database;

  CartLocalDataSource(this._database);

  Future<void> addToCart(CartItemModel item) async {
    await _database.insertCartItem(item.toMap());
  }

  Future<List<CartItemModel>> getCartItems() async {
    final data = await _database.getCartItems();
    return data.map((e) => CartItemModel.fromMap(e)).toList();
  }

  Future<void> updateQuantity(int productId, int quantity) async {
    await _database.updateCartItemQuantity(productId, quantity);
  }

  Future<void> removeItem(int productId) async {
    await _database.removeCartItem(productId);
  }

  Future<void> clearCart() async {
    await _database.clearCart();
  }
}
