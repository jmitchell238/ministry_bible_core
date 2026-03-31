import 'package:collection/collection.dart';
import 'package:uuid/uuid.dart';
import 'scripture_passage.dart';

/// A named, ordered list of scripture passages — for sermon series,
/// study sets, and topical collections.
class PassageCollection {
  final String id;
  final String name;
  final String? description;

  /// Ordered passages. Verse text ([ScripturePassage.verses]) may be empty
  /// when stored as a reference; populate via BibleContentService when needed.
  final List<ScripturePassage> passages;

  /// Optional color tag as an ARGB integer.
  final int? color;

  final DateTime createdAt;
  final DateTime updatedAt;

  const PassageCollection({
    required this.id,
    required this.name,
    this.description,
    required this.passages,
    this.color,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Creates a new [PassageCollection] with a generated UUID and current timestamps.
  factory PassageCollection.create({
    required String name,
    String? description,
    List<ScripturePassage> passages = const [],
    int? color,
  }) {
    final now = DateTime.now();
    return PassageCollection(
      id: const Uuid().v4(),
      name: name,
      description: description,
      passages: List<ScripturePassage>.from(passages),
      color: color,
      createdAt: now,
      updatedAt: now,
    );
  }

  factory PassageCollection.fromJson(Map<String, dynamic> json) =>
      PassageCollection(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['description'] as String?,
        passages: (json['passages'] as List<dynamic>)
            .map((e) => ScripturePassage.fromJson(e as Map<String, dynamic>))
            .toList(),
        color: json['color'] as int?,
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'passages': passages.map((p) => p.toJson()).toList(),
        'color': color,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  PassageCollection copyWith({
    String? id,
    String? name,
    String? description,
    List<ScripturePassage>? passages,
    int? color,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool clearDescription = false,
    bool clearColor = false,
  }) =>
      PassageCollection(
        id: id ?? this.id,
        name: name ?? this.name,
        description: clearDescription ? null : (description ?? this.description),
        passages: passages ?? List<ScripturePassage>.from(this.passages),
        color: clearColor ? null : (color ?? this.color),
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PassageCollection &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          description == other.description &&
          const ListEquality<ScripturePassage>()
              .equals(passages, other.passages) &&
          color == other.color &&
          createdAt == other.createdAt &&
          updatedAt == other.updatedAt;

  @override
  int get hashCode => Object.hash(
        id,
        name,
        description,
        const ListEquality<ScripturePassage>().hash(passages),
        color,
        createdAt,
        updatedAt,
      );

  @override
  String toString() =>
      'PassageCollection(id: $id, name: $name, passages: ${passages.length}, '
      'color: $color, createdAt: $createdAt)';
}
