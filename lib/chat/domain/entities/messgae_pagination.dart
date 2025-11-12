import 'package:chat_app/core/entities/entity.dart';

class MessgaePagination extends BaseEntity {
  final String roomId;
  final int? page; // Make page nullable
  final int sizePage;
  final String? beforeId; // Add cursor support for better infinite scroll

  MessgaePagination({
    required this.roomId,
    this.page,
    required this.sizePage,
    this.beforeId,
  });

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'roomId': roomId,
      'sizePage': sizePage,
    };

    if (page != null) {
      data['page'] = page;
    }

    if (beforeId != null) {
      data['beforeId'] = beforeId;
    }

    return data;
  }
}
