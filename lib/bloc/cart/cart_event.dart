import 'package:equatable/equatable.dart';
import 'cart_state.dart';

abstract class CartEvent extends Equatable {
  const CartEvent();

  @override
  List<Object> get props => [];
}

class CartItemAdded extends CartEvent {
  final CartItem item;

  const CartItemAdded(this.item);

  @override
  List<Object> get props => [item];
}

class CartItemRemoved extends CartEvent {
  final String itemId;

  const CartItemRemoved(this.itemId);

  @override
  List<Object> get props => [itemId];
}

class CartCleared extends CartEvent {}
