class Level {
  final String id;
  final String name;
  final String description;
  final int order;
  final DateTime createdAt;
  final DateTime updatedAt;

  Level({
    required this.id,
    required this.name,
    required this.description,
    required this.order,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Level.fromJson(Map<String, dynamic> json) {
    return Level(
      id: json['id'] as String,
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
      'name': name,
      'description': description,
      'order': order,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
