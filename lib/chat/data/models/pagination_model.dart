import 'package:chat_app/core/utils/app_utils.dart';

class PageinationModel<T> {
  final int count;
  final String? next;
  final String? previous;
  final List<T> results;

  static empty() => <dynamic>[];
  PageinationModel(
      {required this.count,
      required this.next,
      required this.previous,
      required this.results});
  factory PageinationModel.fromJson(
          Map<String, dynamic> json, dynamic fromJsom) =>
      PageinationModel(
          count: json['count'],
          next: json['next'],
          previous: json['previous'],
          results: AppUtils.generateList(json['results'], fromJsom));
}
