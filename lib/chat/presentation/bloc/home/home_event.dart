part of 'home_bloc.dart';

sealed class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object> get props => [];
}

final class CreateRoom extends HomeEvent {
  final BaseEntity entity;

  const CreateRoom({required this.entity});
}

final class GetRoomsEvent extends HomeEvent {}

final class GetChatMe extends HomeEvent {}
