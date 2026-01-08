part of 'categories_bloc.dart';

sealed class CategoriesState extends Equatable {
  const CategoriesState();

  @override
  List<Object> get props => [];
}

final class CategoriesInitial extends CategoriesState {}

final class GetCategoriesState extends CategoriesState {
  final List<CategoryModel> list;

  const GetCategoriesState({required this.list});
}
