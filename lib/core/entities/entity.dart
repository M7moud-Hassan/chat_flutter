import 'package:dio/dio.dart';

abstract class BaseEntity {
  Map<String, dynamic> toJson();
  Future<FormData> getform() async {
    return FormData();
  }
}
