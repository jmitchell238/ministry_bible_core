import 'package:uuid/uuid.dart';

/// The current memorization stage of a verse.
enum MemorizationStatus { learning, reviewing, mastered }

/// Tracks the memorization progress for a single Bible verse,
/// including spaced-repetition review scheduling.
class MemorizationEntry {
  final String id;

  /// Canonical verse ID, e.g. "John-3-16".
  final String verseId;

  final MemorizationStatus status;

  /// Scheduled date for the next spaced-repetition review. Null when not yet
  /// scheduled (e.g. immediately after creation).
  final DateTime? nextReviewDate;

  /// The last time this verse was actively reviewed. Null if never reviewed.
  final DateTime? lastReviewedAt;

  /// Total number of completed reviews.
  final int reviewCount;

  final DateTime createdAt;
  final DateTime updatedAt;

  const MemorizationEntry({
    required this.id,
    required this.verseId,
    required this.status,
    this.nextReviewDate,
    this.lastReviewedAt,
    required this.reviewCount,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Creates a new [MemorizationEntry] with a generated UUID and current timestamps.
  factory MemorizationEntry.create({
    required String verseId,
    MemorizationStatus status = MemorizationStatus.learning,
    DateTime? nextReviewDate,
  }) {
    final now = DateTime.now();
    return MemorizationEntry(
      id: const Uuid().v4(),
      verseId: verseId,
      status: status,
      nextReviewDate: nextReviewDate,
      lastReviewedAt: null,
      reviewCount: 0,
      createdAt: now,
      updatedAt: now,
    );
  }

  factory MemorizationEntry.fromJson(Map<String, dynamic> json) =>
      MemorizationEntry(
        id: json['id'] as String,
        verseId: json['verseId'] as String,
        status: MemorizationStatus.values.byName(json['status'] as String),
        nextReviewDate: json['nextReviewDate'] != null
            ? DateTime.parse(json['nextReviewDate'] as String)
            : null,
        lastReviewedAt: json['lastReviewedAt'] != null
            ? DateTime.parse(json['lastReviewedAt'] as String)
            : null,
        reviewCount: json['reviewCount'] as int,
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'verseId': verseId,
        'status': status.name,
        'nextReviewDate': nextReviewDate?.toIso8601String(),
        'lastReviewedAt': lastReviewedAt?.toIso8601String(),
        'reviewCount': reviewCount,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  MemorizationEntry copyWith({
    String? id,
    String? verseId,
    MemorizationStatus? status,
    DateTime? nextReviewDate,
    DateTime? lastReviewedAt,
    int? reviewCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool clearNextReviewDate = false,
    bool clearLastReviewedAt = false,
  }) =>
      MemorizationEntry(
        id: id ?? this.id,
        verseId: verseId ?? this.verseId,
        status: status ?? this.status,
        nextReviewDate: clearNextReviewDate
            ? null
            : (nextReviewDate ?? this.nextReviewDate),
        lastReviewedAt: clearLastReviewedAt
            ? null
            : (lastReviewedAt ?? this.lastReviewedAt),
        reviewCount: reviewCount ?? this.reviewCount,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MemorizationEntry &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          verseId == other.verseId &&
          status == other.status &&
          nextReviewDate == other.nextReviewDate &&
          lastReviewedAt == other.lastReviewedAt &&
          reviewCount == other.reviewCount &&
          createdAt == other.createdAt &&
          updatedAt == other.updatedAt;

  @override
  int get hashCode => Object.hash(
        id,
        verseId,
        status,
        nextReviewDate,
        lastReviewedAt,
        reviewCount,
        createdAt,
        updatedAt,
      );

  @override
  String toString() =>
      'MemorizationEntry(id: $id, verseId: $verseId, status: $status, '
      'reviewCount: $reviewCount, nextReviewDate: $nextReviewDate)';
}
