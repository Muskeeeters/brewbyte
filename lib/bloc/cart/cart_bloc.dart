import 'package:flutter_bloc/flutter_bloc.dart';
import 'cart_event.dart';
import 'cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  CartBloc() : super(const CartLoaded()) {
    on<CartItemAdded>(_onItemAdded);
    on<CartItemRemoved>(_onItemRemoved);
    on<CartCleared>(_onCleared);
  }

  void _onItemAdded(CartItemAdded event, Emitter<CartState> emit) {
    if (state is CartLoaded) {
      final List<CartItem> updatedItems = List.from((state as CartLoaded).items);
      updatedItems.add(event.item);
      emit(CartLoaded(items: updatedItems));
    }
  }

  void _onItemRemoved(CartItemRemoved event, Emitter<CartState> emit) {
    if (state is CartLoaded) {
      final List<CartItem> updatedItems = List.from((state as CartLoaded).items);
      updatedItems.removeWhere((item) => item.id == event.itemId);
      emit(CartLoaded(items: updatedItems));
    }
  }

  void _onCleared(CartCleared event, Emitter<CartState> emit) {
    emit(const CartLoaded(items: []));
  }
}
