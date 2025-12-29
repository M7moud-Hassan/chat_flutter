import 'package:chat_app/chat/data/datasources/chat_db.dart';
import 'package:chat_app/chat/data/models/attachement.model.dart';
import 'package:chat_app/chat/data/models/message.model.dart';
import 'package:chat_app/chat/data/models/pagination_model.dart';
import 'package:chat_app/chat/data/models/recent_chat.model.dart';
import 'package:chat_app/chat/data/models/user.model.dart';
import 'package:chat_app/chat/domain/entities/assign_to_entity.dart';
import 'package:chat_app/chat/domain/entities/messgae_pagination.dart';
import 'package:chat_app/chat/domain/entities/update_fcm.dart';
import 'package:chat_app/core/conts/api.dart';
import 'package:chat_app/core/entities/entity.dart';
import 'package:chat_app/core/utils/app_utils.dart';
import 'package:dio/dio.dart';

class ChatDBImpl implements ChatDB {
  final Dio dio;

  ChatDBImpl({required this.dio});

  @override
  Future<User> login() async {
    final deviceId = await AppUtils.getDeviceId();
    final response = await dio.post(Api.login, data: {"device_id": deviceId});
    final user = User.fromMap(response.data);
    AppUtils.user = user;
    await AppUtils.instance.setUser();
    final token = await AppUtils.instance.fcmToken();
    await updateUserInfo(UpdateFcm(fcmToken: token ?? '', deviceId: deviceId));
    return user;
  }

  @override
  Future<void> updateUserInfo(UpdateFcm entity) async {
    final response = await dio.post(Api.me, data: entity.toJson());
    // AppUtils.user!.setFcm(entity.fcmToken);
    // await AppUtils.instance.setUser();
  }

  @override
  Future<RecentChat> createChat(BaseEntity entity) async {
    final response =
        await dio.post(Api.createRoom, data: await entity.getform());
    return RecentChat.fromMap(response.data['response']);
  }

  @override
  Future<PageinationModel<RecentChat>> getRooms(bool me) async {
    var response;
    if (me) {
      response = await dio.get(
          '${Api.rooms}?page_size=10000&assign_to=${AppUtils.user?.id}&category=${AppUtils.activeRoom}');
    } else {
      response = await dio
          .get('${Api.rooms}?page_size=10000&category=${AppUtils.activeRoom}');
    }
    return PageinationModel.fromJson(
        response.data['response'], RecentChat.fromMap);
  }

  @override
  Future<PageinationModel<UserReadMessage>> getMessage(
      MessgaePagination room) async {
    final response = await dio.get(
        '${Api.rooms}${room.roomId}/messages/?page=${room.page}&page_size=${room.sizePage}');
    return PageinationModel.fromJson(
        response.data['response'], UserReadMessage.fromMap);
  }

  @override
  Future<Attachment> sendAttachment(BaseEntity entity) async {
    final response =
        await dio.post(Api.addAttachment, data: await entity.getform());
    return Attachment.fromMap(response.data['response']);
  }

  @override
  Future<List<User>> getAdmins() async {
    final response = await dio.get('accounts/accounts/');
    return (response.data['response'] as List)
        .map((e) => User.fromMap(e))
        .toList();
  }

  @override
  Future<void> assignChat(AssignToEntity entity) async {
    final response =
        await dio.patch('chat/room/${entity.roomId}/', data: entity.toJson());
    return;
  }
}
