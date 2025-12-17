import 'package:chat_app/core/entities/entity.dart';
import 'package:chat_app/core/utils/app_utils.dart' show AppUtils;
import 'package:dio/dio.dart';

class CreateRoomEneity extends BaseEntity {
  final String name;
  final String? image;
  final int idCategory;

  CreateRoomEneity({
    required this.name,
    this.image,
    int? idCategory,
  }) : idCategory = idCategory ?? AppUtils.activeRoom ?? 0;

  @override
  Map<String, dynamic> toJson() {
    // TODO: implement toJson
    throw UnimplementedError();
  }

  @override
  Future<FormData> getform() async {
    return FormData.fromMap({
      "name": name,
      "category": idCategory,
      if (image != null)
        'image': await MultipartFile.fromFile(image!, filename: 'image.jpg'),
    });
  }
}
