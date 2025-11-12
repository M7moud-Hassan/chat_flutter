import 'package:chat_app/core/entities/entity.dart';
import 'package:dio/dio.dart';

class CreateRoomEneity extends BaseEntity {
  final String name;
  final String? image;

  CreateRoomEneity({required this.name, this.image});
  @override
  Map<String, dynamic> toJson() {
    // TODO: implement toJson
    throw UnimplementedError();
  }

  @override
  Future<FormData> getform() async {
    return FormData.fromMap({
      "name": name,
      if (image != null)
        'image': await MultipartFile.fromFile(image!, filename: 'image.jpg'),
    });
  }
}
