import 'package:flutter_bloc/flutter_bloc.dart';
import 'checkout_event.dart';
import 'checkout_state.dart';
import '../data/repositories/cart_repository.dart';

class CheckoutBloc extends Bloc<CheckoutEvent, CheckoutState> {
  final CartRepository _repository;

  CheckoutBloc(this._repository) : super(CheckoutInitial()) {
    on<PlaceOrder>(_onPlaceOrder);
  }

  Future<void> _onPlaceOrder(PlaceOrder event, Emitter<CheckoutState> emit) async {
    emit(CheckoutLoading());
    try {
      await Future.delayed(const Duration(seconds: 1));
      await _repository.clearCart();
      emit(CheckoutSuccess());
    } catch (e) {
      emit(CheckoutError(e.toString()));
    }
  }
}
