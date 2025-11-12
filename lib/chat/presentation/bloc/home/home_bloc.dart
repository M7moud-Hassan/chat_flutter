import 'package:bloc/bloc.dart';
import 'package:chat_app/chat/data/models/pagination_model.dart';
import 'package:chat_app/chat/data/models/recent_chat.model.dart';
import 'package:chat_app/chat/domain/usercases/create_room_use_case.dart';
import 'package:chat_app/chat/domain/usercases/get_rooms_use_case.dart';
import 'package:chat_app/core/bloc/base_bloc.dart';
import 'package:chat_app/core/entities/entity.dart';
import 'package:equatable/equatable.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends BaseBloc<HomeEvent, HomeState> {
  final CreateRoomUseCase createRoomUseCase;
  final GetRoomsUseCase getRoomsUseCase;
  HomeBloc({required this.createRoomUseCase, required this.getRoomsUseCase})
      : super(HomeInitial()) {
    on<HomeEvent>((event, emit) async {
      if (event is CreateRoom) {
        result = await createRoomUseCase(event.entity);
        emitDone((p0) {
          emit(DoneCreateRoom(room: p0));
        });
      }
      if (event is GetRoomsEvent) {
        result = await getRoomsUseCase(false);
        emitDone((p0) {
          emit(DoneGetRoomsState(
              chats: (p0 as PageinationModel).results as List<RecentChat>));
        });
      }
      if (event is GetChatMe) {
        result = await getRoomsUseCase(true);
        emitDone((p0) {
          emit(DoneGetRoomsState2(
              chats: (p0 as PageinationModel).results as List<RecentChat>));
        });
      }
    });
  }
}
