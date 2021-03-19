import 'package:app_task/repository/receipt_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'favorite_state.dart';

class FavoriteCubit extends Cubit<FavoriteState> {
  final ReceiptRepository repository;

  FavoriteCubit({this.repository}) : super(FavoriteInitial());

  void removeLikeReceipt(String key, String user) async {
    emit(LoadingFavoriteState());
    var result = await repository.removeLike(key, user);
    result.fold(
      (errorMessage) => emit(FailureFavoriteState(errorMessage)),
      (result) => emit(SuccessFavoriteState(result)),
    );
  }
}
