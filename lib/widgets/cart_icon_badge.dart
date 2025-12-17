import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/cart/cart_bloc.dart';
import '../bloc/cart/cart_state.dart';

class CartIconBadge extends StatelessWidget {
  final Color color;

  const CartIconBadge({super.key, this.color = Colors.white});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartBloc, CartState>(
      builder: (context, state) {
        int count = 0;
        if (state is CartLoaded) {
          count = state.items.length;
        }

        return Stack(
          alignment: Alignment.topRight,
          children: [
            IconButton(
              icon: Icon(Icons.shopping_cart, color: color),
              onPressed: () {
                context.push('/cart');
              },
            ),
            if (count > 0)
              Positioned(
                right: 5,
                top: 5,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Text(
                    '$count',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
