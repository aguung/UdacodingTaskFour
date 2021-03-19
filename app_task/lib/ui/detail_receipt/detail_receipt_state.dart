part of 'detail_receipt_cubit.dart';

abstract class DetailReceiptState extends Equatable {
  const DetailReceiptState();

  @override
  List<Object> get props => [];
}

class DetailReceiptInitial extends DetailReceiptState {}

class SuccessDetailReceiptState extends DetailReceiptState {
  final String message;

  SuccessDetailReceiptState(this.message);

  @override
  List<Object> get props => [message];

  @override
  String toString() {
    return 'SuccessDetailReceiptState{message: $message}';
  }
}

class LoadingDetailReceiptState extends DetailReceiptState {}

class FailureDetailReceiptState extends DetailReceiptState {
  final String errorMessage;

  FailureDetailReceiptState(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];

  @override
  String toString() {
    return 'FailureDetailReceiptState{errorMessage: $errorMessage}';
  }
}
