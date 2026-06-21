import '../datasources/cart_local_datasource.dart';
import '../models/cart_item_model.dart';
import 'cart_repository.dart';

class CartRepositoryImpl implements CartRepository {
  final CartLocalDataSource _localDataSource;

  CartRepositoryImpl(this._localDataSource);

  @override
  Future<List<CartItemModel>> getCartItems() async {
    return await _localDataSource.getCartItems();
  }

  @override
  Future<void> addToCart(CartItemModel item) async {
    await _localDataSource.addToCart(item);
  }

  @override
  Future<void> updateQuantity(int productId, int quantity) async {
    await _localDataSource.updateQuantity(productId, quantity);
  }

  @override
  Future<void> removeItem(int productId) async {
    await _localDataSource.removeItem(productId);
  }

  @override
  Future<void> clearCart() async {
    await _localDataSource.clearCart();
  }
}
