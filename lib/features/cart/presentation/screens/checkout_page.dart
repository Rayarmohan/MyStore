import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../bloc/cart_bloc.dart';
import '../../bloc/cart_event.dart';
import '../../bloc/checkout_bloc.dart';
import '../../bloc/checkout_event.dart';
import '../../bloc/checkout_state.dart';
import '../../data/models/cart_item_model.dart';
import '../../data/repositories/cart_repository.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/di/service_locator.dart';

class CheckoutPage extends StatelessWidget {
  final double totalPrice;
  final List<CartItemModel> items;

  const CheckoutPage({super.key, required this.totalPrice, required this.items});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CheckoutBloc(sl<CartRepository>()),
      child: _CheckoutView(totalPrice: totalPrice, items: items),
    );
  }
}

class _CheckoutView extends StatelessWidget {
  final double totalPrice;
  final List<CartItemModel> items;

  const _CheckoutView({required this.totalPrice, required this.items});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CheckoutBloc, CheckoutState>(
      listener: (context, state) {
        if (state is CheckoutSuccess) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              content: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(
                        color: AppColors.accent,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check, color: Colors.white, size: 36),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      AppStrings.orderPlaced,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Your order has been placed successfully!',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          Navigator.of(context).pop();
                          context.read<CartBloc>().add(LoadCart());
                        },
                        child: const Text('Continue Shopping'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        if (state is CheckoutError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(title: const Text(AppStrings.checkout)),
          body: state is CheckoutLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                        children: [
                          _SectionHeader(
                            title: 'Order Summary',
                            trailing: '${items.length} item${items.length > 1 ? 's' : ''}',
                          ),
                          const SizedBox(height: 8),
                          ..._buildItemList(context),
                          const SizedBox(height: 20),
                          _buildPriceCard(context),
                        ],
                      ),
                    ),
                    _buildBottomBar(context),
                  ],
                ),
        );
      },
    );
  }

  List<Widget> _buildItemList(BuildContext context) {
    final list = <Widget>[];
    for (var i = 0; i < items.length; i++) {
      list.add(_CheckoutItemCard(item: items[i]));
      if (i < items.length - 1) {
        list.add(const Divider(height: 1));
      }
    }
    return list;
  }

  Widget _buildPriceCard(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Theme.of(context).dividerColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _PriceRow(label: 'Subtotal', amount: '\$${totalPrice.toStringAsFixed(2)}'),
            const SizedBox(height: 10),
            _PriceRow(
              label: 'Delivery',
              amount: 'FREE',
              amountColor: AppColors.accent,
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(height: 1),
            ),
            _PriceRow(
              label: 'Total',
              amount: '\$${totalPrice.toStringAsFixed(2)}',
              labelStyle: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              amountStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, MediaQuery.of(context).padding.bottom + 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton.icon(
          onPressed: () => context.read<CheckoutBloc>().add(PlaceOrder()),
          icon: const Icon(Icons.lock_outline, size: 18),
          label: Text('${AppStrings.payNow} \$${totalPrice.toStringAsFixed(2)}'),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String trailing;

  const _SectionHeader({required this.title, this.trailing = ''});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        const Spacer(),
        if (trailing.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              trailing,
              style: TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
      ],
    );
  }
}

class _CheckoutItemCard extends StatelessWidget {
  final CartItemModel item;

  const _CheckoutItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Theme.of(context).scaffoldBackgroundColor
                  : Colors.grey[100],
              padding: const EdgeInsets.all(8),
              child: CachedNetworkImage(
                imageUrl: item.image,
                width: 48,
                height: 48,
                fit: BoxFit.contain,
                placeholder: (context, url) => const SizedBox(
                  width: 48,
                  height: 48,
                  child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                ),
                errorWidget: (context, url, error) => const Icon(Icons.image, size: 24, color: Colors.grey),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  'Qty ${item.quantity} \u00D7 \$${item.price.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '\$${item.totalPrice.toStringAsFixed(2)}',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  final String label;
  final String amount;
  final Color? amountColor;
  final TextStyle? labelStyle;
  final TextStyle? amountStyle;

  const _PriceRow({
    required this.label,
    required this.amount,
    this.amountColor,
    this.labelStyle,
    this.amountStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: labelStyle ?? Theme.of(context).textTheme.bodyLarge),
        Text(
          amount,
          style: amountStyle ??
              Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: amountColor,
                fontWeight: amountColor != null ? FontWeight.w600 : null,
              ),
        ),
      ],
    );
  }
}
