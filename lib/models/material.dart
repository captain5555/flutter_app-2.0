class Material {
  final int id;
  final int userId;
  final String fileName;
  final String? title;
  final String? description;
  final String usageTag;
  final String viralTag;
  final String folderType;
  final int fileSize;
  final String filePath;
  final String? thumbnailPath;
  final bool isDeleted;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;

  Material({
    required this.id,
    required this.userId,
    required this.fileName,
    this.title,
    this.description,
    required this.usageTag,
    required this.viralTag,
    required this.folderType,
    required this.fileSize,
    required this.filePath,
    this.thumbnailPath,
    this.isDeleted = false,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  String get displayTitle => title ?? fileName;

  bool get isImage => folderType == 'images';
  bool get isVideo => folderType == 'videos';

  String get fileSizeFormatted {
    if (fileSize < 1024) return '$fileSize B';
    if (fileSize < 1024 * 1024) return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    if (fileSize < 1024 * 1024 * 1024) return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(fileSize / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  factory Material.fromJson(Map<String, dynamic> json) {
    return Material(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      userId: json['user_id'] is int ? json['user_id'] : int.parse(json['user_id'].toString()),
      fileName: json['file_name'] as String? ?? json['filename'] as String? ?? '',
      title: json['title'] as String?,
      description: json['description'] as String?,
      usageTag: json['usage_tag'] as String? ?? 'unused',
      viralTag: json['viral_tag'] as String? ?? 'not_viral',
      folderType: json['folder_type'] as String? ?? 'images',
      fileSize: json['file_size'] is int ? json['file_size'] : int.parse(json['file_size']?.toString() ?? '0'),
      filePath: json['file_path'] as String? ?? json['oss_key'] as String? ?? '',
      thumbnailPath: json['thumbnail_path'] as String?,
      isDeleted: json['is_deleted'] as bool? ?? false,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at']) : null,
      deletedAt: json['deleted_at'] != null ? DateTime.tryParse(json['deleted_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'file_name': fileName,
      'title': title,
      'description': description,
      'usage_tag': usageTag,
      'viral_tag': viralTag,
      'folder_type': folderType,
      'file_size': fileSize,
      'file_path': filePath,
      'thumbnail_path': thumbnailPath,
      'is_deleted': isDeleted,
    };
  }

  Material copyWith({
    int? id,
    int? userId,
    String? fileName,
    String? title,
    String? description,
    String? usageTag,
    String? viralTag,
    String? folderType,
    int? fileSize,
    String? filePath,
    String? thumbnailPath,
    bool? isDeleted,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return Material(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      fileName: fileName ?? this.fileName,
      title: title ?? this.title,
      description: description ?? this.description,
      usageTag: usageTag ?? this.usageTag,
      viralTag: viralTag ?? this.viralTag,
      folderType: folderType ?? this.folderType,
      fileSize: fileSize ?? this.fileSize,
      filePath: filePath ?? this.filePath,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }
}
