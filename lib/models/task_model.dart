class TaskModel {
  final String id;
  final String title;
  final String? description;
  final int points;
  final bool isCompleted;

  TaskModel({
    required this.id,
    required this.title,
    this.description,
    required this.points,
    required this.isCompleted,
  });

  // Convierte JSON -> Objeto de Flutter
  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      points: json['points'],
      isCompleted: json['isCompleted'] ?? false,
    );
  }
}