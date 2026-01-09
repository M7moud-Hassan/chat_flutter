part of 'categories_bloc.dart';

sealed class CategoriesState extends Equatable {
  const CategoriesState();
  static int num = 0;
  @override
  List<Object> get props => [num++];
}

final class CategoriesInitial extends CategoriesState {}

final class GetCategoriesState extends CategoriesState {
  final List<CategoryModel> list;

  const GetCategoriesState({required this.list});
}
