part of 'create_receipt_cubit.dart';

abstract class CreateReceiptState extends Equatable {
  const CreateReceiptState();

  @override
  List<Object> get props => [];
}

class CreateReceiptInitial extends CreateReceiptState {}

class SuccessCreateReceiptState extends CreateReceiptState {
  final String message;

  SuccessCreateReceiptState(this.message);

  @override
  List<Object> get props => [message];

  @override
  String toString() {
    return 'SuccessCreateReceiptState{message: $message}';
  }
}

class LoadingCreateReceiptState extends CreateReceiptState {}

class FailureCreateReceiptState extends CreateReceiptState {
  final String errorMessage;

  FailureCreateReceiptState(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];

  @override
  String toString() {
    return 'FailureCreateReceiptState{errorMessage: $errorMessage}';
  }
}
