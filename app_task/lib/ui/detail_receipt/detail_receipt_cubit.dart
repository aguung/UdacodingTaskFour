import 'package:app_task/repository/receipt_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'detail_receipt_state.dart';

class DetailReceiptCubit extends Cubit<DetailReceiptState> {
  final ReceiptRepository repository;

  DetailReceiptCubit({this.repository}) : super(DetailReceiptInitial());

  void addLikeReceipt(String key, String user) async {
    emit(LoadingDetailReceiptState());
    var result = await repository.addLike(key, user);
    result.fold(
          (errorMessage) => emit(FailureDetailReceiptState(errorMessage)),
          (result) => emit(SuccessDetailReceiptState(result)),
    );
  }
}
