import 'package:equatable/equatable.dart';
import '../data/models/cart_item_model.dart';

abstract class CartEvent extends Equatable {
  const CartEvent();

  @override
  List<Object?> get props => [];
}

class LoadCart extends CartEvent {}

class AddToCartEvent extends CartEvent {
  final CartItemModel item;

  const AddToCartEvent(this.item);

  @override
  List<Object?> get props => [item];
}

class UpdateCartQuantityEvent extends CartEvent {
  final int productId;
  final int quantity;

  const UpdateCartQuantityEvent(this.productId, this.quantity);

  @override
  List<Object?> get props => [productId, quantity];
}

class RemoveFromCartEvent extends CartEvent {
  final int productId;

  const RemoveFromCartEvent(this.productId);

  @override
  List<Object?> get props => [productId];
}

class ClearCartEvent extends CartEvent {}
