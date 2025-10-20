part of 'delete_discount_cubit.dart';

enum DeleteDiscountStatus { initial, loading, success, error }

class DeleteDiscountState {
  final DeleteDiscountStatus status;
  final String? message;

  const DeleteDiscountState({
    required this.status,
    this.message,
  });

  factory DeleteDiscountState.initial() =>
      const DeleteDiscountState(status: DeleteDiscountStatus.initial);

  factory DeleteDiscountState.loading() =>
      const DeleteDiscountState(status: DeleteDiscountStatus.loading);

  factory DeleteDiscountState.success() =>
      const DeleteDiscountState(status: DeleteDiscountStatus.success);

  factory DeleteDiscountState.error(String message) =>
      DeleteDiscountState(status: DeleteDiscountStatus.error, message: message);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DeleteDiscountState &&
        other.status == status &&
        other.message == message;
  }

  @override
  int get hashCode => Object.hash(status, message);
}
