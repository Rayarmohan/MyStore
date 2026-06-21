import 'package:equatable/equatable.dart';

abstract class ProductEvent extends Equatable {
  const ProductEvent();

  @override
  List<Object?> get props => [];
}

class LoadProducts extends ProductEvent {}

class LoadProductDetail extends ProductEvent {
  final int productId;

  const LoadProductDetail(this.productId);

  @override
  List<Object?> get props => [productId];
}
