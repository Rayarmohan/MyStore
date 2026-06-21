import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../data/models/product_model.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../cart/bloc/cart_bloc.dart';
import '../../../cart/bloc/cart_event.dart';
import '../../../cart/bloc/cart_state.dart';
import '../../../cart/data/models/cart_item_model.dart';
import '../../../cart/presentation/screens/cart_page.dart';

class ProductDetailPage extends StatelessWidget {
  final ProductModel product;

  const ProductDetailPage({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartBloc, CartState>(
      builder: (context, cartState) {
        final cartItem = cartState is CartLoaded
            ? cartState.items.where((i) => i.productId == product.id).firstOrNull
            : null;
        final qty = cartItem?.quantity ?? 0;

        return Scaffold(
          appBar: AppBar(
            title: const Text(AppStrings.productDetail),
            actions: [
              BlocBuilder<CartBloc, CartState>(
                builder: (context, state) {
                  int count = 0;
                  if (state is CartLoaded) {
                    count = state.items.length;
                  }
                  return Stack(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.shopping_cart_outlined),
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => Scaffold(
                              appBar: AppBar(title: const Text(AppStrings.cart)),
                              body: const CartPage(),
                            ),
                          ),
                        ),
                      ),
                      if (count > 0)
                        Positioned(
                          right: 4,
                          top: 4,
                          child: Container(
                            padding: const EdgeInsets.all(3),
                            decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                            constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                            child: Text(
                              '$count',
                              style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Theme.of(context).cardColor
                      : Colors.white,
                  padding: const EdgeInsets.all(32),
                  child: Hero(
                    tag: 'product_${product.id}',
                    child: CachedNetworkImage(
                      imageUrl: product.image,
                      height: 280,
                      fit: BoxFit.contain,
                      placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                      errorWidget: (context, url, error) => const Icon(Icons.image, size: 100),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          product.category[0].toUpperCase() + product.category.substring(1),
                          style: TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(product.title, style: Theme.of(context).textTheme.headlineMedium),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Text(
                            '\$${product.price.toStringAsFixed(2)}',
                            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 12),
                          if (product.rating != null && product.rating!.rate > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.accent,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.star, size: 16, color: Colors.white),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${product.rating!.rate.toStringAsFixed(1)} (${product.rating!.count})',
                                    style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(AppStrings.description, style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 8),
                      Text(
                        product.description,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          height: 1.5,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: qty > 0
                  ? Row(
                      children: [
                        Row(
                          children: [
                            _QtyButton(
                              icon: Icons.remove,
                              onTap: () {
                                if (qty > 1) {
                                  context.read<CartBloc>().add(UpdateCartQuantityEvent(product.id, qty - 1));
                                } else {
                                  context.read<CartBloc>().add(RemoveFromCartEvent(product.id));
                                }
                              },
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: Text(
                                '$qty',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                              ),
                            ),
                            _QtyButton(
                              icon: Icons.add,
                              onTap: () => context.read<CartBloc>().add(UpdateCartQuantityEvent(product.id, qty + 1)),
                            ),
                          ],
                        ),
                        const Spacer(),
                        SizedBox(
                          height: 44,
                          child: ElevatedButton.icon(
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => Scaffold(
                                  appBar: AppBar(title: const Text(AppStrings.cart)),
                                  body: const CartPage(),
                                ),
                              ),
                            ),
                            icon: const Icon(Icons.shopping_cart, size: 18),
                            label: Text('View Cart \$${(product.price * qty).toStringAsFixed(2)}'),
                          ),
                        ),
                      ],
                    )
                  : SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          context.read<CartBloc>().add(AddToCartEvent(
                            CartItemModel(
                              productId: product.id,
                              title: product.title,
                              price: product.price,
                              image: product.image,
                              category: product.category,
                            ),
                          ));
                        },
                        icon: const Icon(Icons.add_shopping_cart),
                        label: const Text(AppStrings.addToCart),
                      ),
                    ),
            ),
          ),
        );
      },
    );
  }
}

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _QtyButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
        ),
        child: Icon(icon, size: 18, color: AppColors.primary),
      ),
    );
  }
}
