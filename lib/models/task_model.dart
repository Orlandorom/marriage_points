class TaskModel {
  final String id;
  final String title;
  final String? description;
  final int points;
  final bool isCompleted;
  final String? createdByUserId;
  final String? assignedToUserId;// Nuevo campo para diferenciar tareas normales de pedidos/deseos

  TaskModel({
    required this.id,
    required this.title,
    this.description,
    required this.points,
    required this.isCompleted,
    required this.createdByUserId,
    required this.assignedToUserId,
  });

  // Convierte JSON -> Objeto de Flutter
  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      points: json['points'],
      isCompleted: json['isCompleted'] ?? false,
      createdByUserId: json['createdByUserId'],
      assignedToUserId: json['assignedToUserId'],
    );
  }
}