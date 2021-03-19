import 'dart:io';

import 'package:app_task/model/receipt.dart';
import 'package:app_task/repository/auth_repository.dart';
import 'package:app_task/repository/receipt_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

part 'create_receipt_state.dart';

class CreateReceiptCubit extends Cubit<CreateReceiptState> {
  final ReceiptRepository repository;

  CreateReceiptCubit({this.repository}) : super(CreateReceiptInitial());

  void addReceipt(String name, String description, File file,
      String createdKey, String createdName) async {
    emit(LoadingCreateReceiptState());
    var result = await repository.addReceipt(
        name, description, file, createdKey, createdName);
    result.fold(
      (errorMessage) => emit(FailureCreateReceiptState(errorMessage)),
      (result) => emit(SuccessCreateReceiptState(result)),
    );
  }

  void updateReceipt(String key, String name, String description, File file) async {
    emit(LoadingCreateReceiptState());
    var result = await repository.updateReceipt(
        key, name, description, file);
    result.fold(
      (errorMessage) => emit(FailureCreateReceiptState(errorMessage)),
      (result) => emit(SuccessCreateReceiptState(result)),
    );
  }
}
