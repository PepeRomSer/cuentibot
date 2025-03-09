class Profile {
  final String id;
  final String userId;
  final String name;
  final int age;
  final String gender;
  final bool favorite;
  final String description;
  final String avatar;
  final DateTime createdAt;

  Profile({
    required this.id,
    required this.userId,
    required this.name,
    required this.age,
    required this.gender,
    required this.favorite,
    required this.description,
    required this.avatar,
    required this.createdAt,
  });

  // Convertir de JSON a objeto Profile
  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'],
      userId: json['user_id'],
      name: json['name'],
      age: json['age'],
      gender: json['gender'],
      favorite: json['favorite'] ?? false,
      description: json['description'] ?? '',
      avatar: json['avatar'] ?? '',
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  // Convertir de objeto Profile a JSON para Supabase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'age': age,
      'gender': gender,
      'favorite': favorite,
      'description': description,
      'avatar': avatar,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
