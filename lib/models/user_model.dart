class UserModel {
  final String id;
  final String? firstName;
  final String? lastName;
  final int totalPoints;
  final String? coupleId;

  UserModel({
    required this.id,
    this.firstName,
    this.lastName,
    required this.totalPoints,
    this.coupleId,
  });

  // Este método convierte el JSON que viene de .NET a un objeto de Flutter
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      totalPoints: json['totalPoints'] ?? 0,
      coupleId: json['coupleId'],
    );
  }
}