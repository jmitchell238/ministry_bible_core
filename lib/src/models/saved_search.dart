import 'package:uuid/uuid.dart';

/// A saved or recent search query, optionally with a user-defined label.
class SavedSearch {
  final String id;
  final String query;
  final String? label;
  final DateTime createdAt;
  final DateTime? lastUsedAt;

  const SavedSearch({
    required this.id,
    required this.query,
    this.label,
    required this.createdAt,
    this.lastUsedAt,
  });

  /// Creates a new [SavedSearch] with a generated UUID and current timestamp.
  factory SavedSearch.create({
    required String query,
    String? label,
  }) {
    final now = DateTime.now();
    return SavedSearch(
      id: const Uuid().v4(),
      query: query,
      label: label,
      createdAt: now,
      lastUsedAt: null,
    );
  }

  factory SavedSearch.fromJson(Map<String, dynamic> json) => SavedSearch(
        id: json['id'] as String,
        query: json['query'] as String,
        label: json['label'] as String?,
        createdAt: DateTime.parse(json['createdAt'] as String),
        lastUsedAt: json['lastUsedAt'] != null
            ? DateTime.parse(json['lastUsedAt'] as String)
            : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'query': query,
        'label': label,
        'createdAt': createdAt.toIso8601String(),
        'lastUsedAt': lastUsedAt?.toIso8601String(),
      };

  SavedSearch copyWith({
    String? id,
    String? query,
    String? label,
    DateTime? createdAt,
    DateTime? lastUsedAt,
    bool clearLabel = false,
    bool clearLastUsedAt = false,
  }) =>
      SavedSearch(
        id: id ?? this.id,
        query: query ?? this.query,
        label: clearLabel ? null : (label ?? this.label),
        createdAt: createdAt ?? this.createdAt,
        lastUsedAt: clearLastUsedAt ? null : (lastUsedAt ?? this.lastUsedAt),
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SavedSearch &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          query == other.query &&
          label == other.label &&
          createdAt == other.createdAt &&
          lastUsedAt == other.lastUsedAt;

  @override
  int get hashCode => Object.hash(id, query, label, createdAt, lastUsedAt);

  @override
  String toString() =>
      'SavedSearch(id: $id, query: $query, label: $label, '
      'createdAt: $createdAt, lastUsedAt: $lastUsedAt)';
}
