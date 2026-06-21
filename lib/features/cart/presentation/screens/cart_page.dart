import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/cart_bloc.dart';
import '../../bloc/cart_event.dart';
import '../../bloc/cart_state.dart';
import '../widgets/cart_item_card.dart';
import 'checkout_page.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../product/presentation/widgets/loading_widget.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartBloc, CartState>(
      builder: (context, state) {
        if (state is CartLoading) {
          return const LoadingWidget(isGrid: false);
        }
        if (state is CartError) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(state.message, style: Theme.of(context).textTheme.bodyLarge),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => context.read<CartBloc>().add(LoadCart()),
                  icon: const Icon(Icons.refresh),
                  label: const Text(AppStrings.retry),
                ),
              ],
            ),
          );
        }
        if (state is CartLoaded) {
          if (state.items.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(AppStrings.emptyCart, style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text('Add items to get started', style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: state.items.length,
                  itemBuilder: (context, index) {
                    final item = state.items[index];
                    return CartItemCard(
                      item: item,
                      onIncrement: () {
                        context.read<CartBloc>().add(UpdateCartQuantityEvent(item.productId, item.quantity + 1));
                      },
                      onDecrement: () {
                        if (item.quantity > 1) {
                          context.read<CartBloc>().add(UpdateCartQuantityEvent(item.productId, item.quantity - 1));
                        } else {
                          context.read<CartBloc>().add(RemoveFromCartEvent(item.productId));
                        }
                      },
                      onRemove: () {
                        context.read<CartBloc>().add(RemoveFromCartEvent(item.productId));
                      },
                    );
                  },
                ),
              ),
              Container(
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
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(AppStrings.total, style: Theme.of(context).textTheme.titleLarge),
                          Text(
                            '\$${state.totalPrice.toStringAsFixed(2)}',
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => CheckoutPage(
                                  totalPrice: state.totalPrice,
                                  items: state.items,
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.shopping_bag),
                          label: Text('${AppStrings.checkout} (\$${state.totalPrice.toStringAsFixed(2)})'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
