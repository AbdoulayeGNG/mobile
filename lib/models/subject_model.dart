class Subject {
  final String id;
  final String name;
  final String description;
  final String iconName;
  final String color;
  final DateTime createdAt;
  final DateTime updatedAt;

  Subject({
    required this.id,
    required this.name,
    required this.description,
    required this.iconName,
    this.color = '#2196F3',
    required this.createdAt,
    required this.updatedAt,
  });

  factory Subject.fromJson(Map<String, dynamic> json) {
    return Subject(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      iconName: json['icon_name'] as String,
      color: json['color'] as String? ?? '#2196F3',
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon_name': iconName,
      'color': color,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
