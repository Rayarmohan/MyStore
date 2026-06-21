import '../models/cart_item_model.dart';

abstract class CartRepository {
  Future<List<CartItemModel>> getCartItems();
  Future<void> addToCart(CartItemModel item);
  Future<void> updateQuantity(int productId, int quantity);
  Future<void> removeItem(int productId);
  Future<void> clearCart();
}
