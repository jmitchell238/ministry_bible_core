import 'package:uuid/uuid.dart';

/// A named grouping of [Bookmark] objects.
class BookmarkCollection {
  final String id;
  final String name;
  final String? description;
  final DateTime createdAt;

  /// Optional color tag as an ARGB integer.
  final int? color;

  const BookmarkCollection({
    required this.id,
    required this.name,
    this.description,
    required this.createdAt,
    this.color,
  });

  /// Creates a new [BookmarkCollection] with a generated UUID and current timestamp.
  factory BookmarkCollection.create({
    required String name,
    String? description,
    int? color,
  }) =>
      BookmarkCollection(
        id: const Uuid().v4(),
        name: name,
        description: description,
        createdAt: DateTime.now(),
        color: color,
      );

  factory BookmarkCollection.fromJson(Map<String, dynamic> json) =>
      BookmarkCollection(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['description'] as String?,
        createdAt: DateTime.parse(json['createdAt'] as String),
        color: json['color'] as int?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'createdAt': createdAt.toIso8601String(),
        'color': color,
      };

  BookmarkCollection copyWith({
    String? id,
    String? name,
    String? description,
    DateTime? createdAt,
    int? color,
    bool clearDescription = false,
    bool clearColor = false,
  }) =>
      BookmarkCollection(
        id: id ?? this.id,
        name: name ?? this.name,
        description: clearDescription ? null : (description ?? this.description),
        createdAt: createdAt ?? this.createdAt,
        color: clearColor ? null : (color ?? this.color),
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BookmarkCollection &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          description == other.description &&
          createdAt == other.createdAt &&
          color == other.color;

  @override
  int get hashCode => Object.hash(id, name, description, createdAt, color);

  @override
  String toString() =>
      'BookmarkCollection(id: $id, name: $name, description: $description, '
      'createdAt: $createdAt, color: $color)';
}
