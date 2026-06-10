class TaskModel {
  final String id;
  final String title;
  final String? description;
  final String? createdByUserId;
  final String? assignedToUserId;
  final int status;
  final int points;

  TaskModel({
    required this.id,
    required this.title,
    this.description,
    this.createdByUserId,
    this.assignedToUserId,
    this.status = 0,
    this.points = 0,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'],
      createdByUserId: json['createdByUserId'],
      assignedToUserId: json['assignedToUserId'],
      status: json['status'] ?? 0,
      points: json['points'] ?? 0, // El deseo llega con 0, la pareja le dará valor
    );
  }
}