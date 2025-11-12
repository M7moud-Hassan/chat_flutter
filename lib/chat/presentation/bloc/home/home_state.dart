part of 'home_bloc.dart';

sealed class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object> get props => [];
}

final class HomeInitial extends HomeState {}

final class DoneCreateRoom extends HomeState {
  final RecentChat room;

  const DoneCreateRoom({required this.room});
}

final class DoneGetRoomsState extends HomeState {
  final List<RecentChat> chats;

  const DoneGetRoomsState({required this.chats});
}

final class DoneGetRoomsState2 extends HomeState {
  final List<RecentChat> chats;

  const DoneGetRoomsState2({required this.chats});
}
