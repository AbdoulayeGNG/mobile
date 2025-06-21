class Grade {
  final String id;
  final String levelId;
  final String name;
  final String description;
  final int order;
  final DateTime createdAt;
  final DateTime updatedAt;

  Grade({
    required this.id,
    required this.levelId,
    required this.name,
    required this.description,
    required this.order,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Grade.fromJson(Map<String, dynamic> json) {
    return Grade(
      id: json['id'] as String,
      levelId: json['levelId'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      order: json['order'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'levelId': levelId,
      'name': name,
      'description': description,
      'order': order,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
