part of 'checkout_bloc.dart';

@freezed
class CheckoutState with _$CheckoutState {
  const factory CheckoutState.initial() = _Initial;
  const factory CheckoutState.loading() = _Loading;

  const factory CheckoutState.loaded(
    List<ProductQuantity> items,
    Discount? discountModel,
    int discount,
    int discountAmount,
    int tax,
    int serviceCharge,
    int totalQuantity,
    int totalPrice,
    String draftName,
    String? orderType, // ✅ tambahkan di akhir sebagai positional
  ) = _Loaded;

  const factory CheckoutState.error(String message) = _Error;

  // save draft order
  const factory CheckoutState.savedDraftOrder(int orderId) = _SavedDraftOrder;
}
