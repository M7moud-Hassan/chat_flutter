import 'package:app_badge_plus/app_badge_plus.dart';
import 'package:bloc/bloc.dart';
import 'package:chat_app/chat/domain/entities/categories.dart';
import 'package:chat_app/chat/domain/usercases/get_categories_use_case.dart';
import 'package:chat_app/core/bloc/base_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'categories_event.dart';
part 'categories_state.dart';

class CategoriesBloc extends BaseBloc<CategoriesEvent, CategoriesState> {
  final GetCategoriesUseCase getCategoriesUseCase;
  CategoriesBloc({required this.getCategoriesUseCase})
      : super(CategoriesInitial()) {
    on<CategoriesEvent>((event, emit) async {
      if (event is GetCategories) {
        result = await getCategoriesUseCase();
        emitDone((value) {
          emit(GetCategoriesState(list: value));
        });
      }
    });
  }
}
