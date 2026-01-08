class CategoryModel {
  final String name;
  final int id;
  final int numMessage;

  CategoryModel(
      {required this.name, required this.id, required this.numMessage});

  factory CategoryModel.fromJson(Map<String, dynamic> json) => CategoryModel(
      name: json['name'],
      id: json['id'],
      numMessage: json['num_messages_not_seen']);
}
