enum CourseType { pdf, video, text, quiz }

class Course {
  final String id;
  final String title;
  final String description;
  final String authorId;
  final String levelId;
  final String gradeId;
  final String subjectId;
  final String type; // Ajout du type de cours
  final String content;
  String? filePath;
  bool isDownloaded; // Ajout du statut de téléchargement
  String? lastAccessedAt;
  final String createdAt;
  String updatedAt;

  Course({
    required this.id,
    required this.title,
    required this.description,
    required this.authorId,
    required this.levelId,
    required this.gradeId,
    required this.subjectId,
    required this.type, // Ajout du paramètre type
    required this.content,
    this.filePath,
    this.isDownloaded = false, // Valeur par défaut à false
    this.lastAccessedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      authorId: json['author_id'] as String,
      levelId: json['level_id'] as String,
      gradeId: json['grade_id'] as String,
      subjectId: json['subject_id'] as String,
      type: json['type'] as String, // Conversion du type
      content: json['content'] as String,
      filePath: json['file_path'] as String?,
      isDownloaded:
          (json['is_downloaded'] as int?) == 1, // Conversion de int à bool
      lastAccessedAt: json['last_accessed_at'] as String?,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'author_id': authorId,
    'level_id': levelId,
    'grade_id': gradeId,
    'subject_id': subjectId,
    'type': type,
    'content': content,
    'file_path': filePath,
    'is_downloaded': isDownloaded ? 1 : 0, // Conversion de bool à int
    'last_accessed_at': lastAccessedAt,
    'created_at': createdAt,
    'updated_at': updatedAt,
  };

  Course copyWith({
    String? id,
    String? title,
    String? description,
    String? authorId,
    String? levelId,
    String? gradeId,
    String? subjectId,
    String? type,
    String? content,
    String? filePath,
    bool? isDownloaded,
    String? lastAccessedAt,
    String? createdAt,
    String? updatedAt,
  }) {
    return Course(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      authorId: authorId ?? this.authorId,
      levelId: levelId ?? this.levelId,
      gradeId: gradeId ?? this.gradeId,
      subjectId: subjectId ?? this.subjectId,
      type: type ?? this.type,
      content: content ?? this.content,
      filePath: filePath ?? this.filePath,
      isDownloaded: isDownloaded ?? this.isDownloaded,
      lastAccessedAt: lastAccessedAt ?? this.lastAccessedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
