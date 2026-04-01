import 'package:uuid/uuid.dart';

/// Status of a [PrayerRequest].
enum PrayerStatus { active, answered, archived }

/// A prayer request, optionally anchored to a scripture verse.
class PrayerRequest {
  final String id;
  final String content;
  final String? verseId;
  final PrayerStatus status;
  final DateTime createdAt;
  final DateTime? answeredAt;

  const PrayerRequest({
    required this.id,
    required this.content,
    this.verseId,
    required this.status,
    required this.createdAt,
    this.answeredAt,
  });

  /// Creates a new [PrayerRequest] with a generated UUID and current timestamp.
  factory PrayerRequest.create({
    required String content,
    String? verseId,
    PrayerStatus status = PrayerStatus.active,
  }) {
    return PrayerRequest(
      id: const Uuid().v4(),
      content: content,
      verseId: verseId,
      status: status,
      createdAt: DateTime.now(),
      answeredAt: null,
    );
  }

  factory PrayerRequest.fromJson(Map<String, dynamic> json) => PrayerRequest(
        id: json['id'] as String,
        content: json['content'] as String,
        verseId: json['verseId'] as String?,
        status: PrayerStatus.values.byName(json['status'] as String),
        createdAt: DateTime.parse(json['createdAt'] as String),
        answeredAt: json['answeredAt'] != null
            ? DateTime.parse(json['answeredAt'] as String)
            : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'content': content,
        'verseId': verseId,
        'status': status.name,
        'createdAt': createdAt.toIso8601String(),
        'answeredAt': answeredAt?.toIso8601String(),
      };

  PrayerRequest copyWith({
    String? id,
    String? content,
    String? verseId,
    PrayerStatus? status,
    DateTime? createdAt,
    DateTime? answeredAt,
    bool clearVerseId = false,
    bool clearAnsweredAt = false,
  }) =>
      PrayerRequest(
        id: id ?? this.id,
        content: content ?? this.content,
        verseId: clearVerseId ? null : (verseId ?? this.verseId),
        status: status ?? this.status,
        createdAt: createdAt ?? this.createdAt,
        answeredAt: clearAnsweredAt ? null : (answeredAt ?? this.answeredAt),
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PrayerRequest &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          content == other.content &&
          verseId == other.verseId &&
          status == other.status &&
          createdAt == other.createdAt &&
          answeredAt == other.answeredAt;

  @override
  int get hashCode =>
      Object.hash(id, content, verseId, status, createdAt, answeredAt);

  @override
  String toString() =>
      'PrayerRequest(id: $id, content: $content, status: ${status.name}, '
      'verseId: $verseId, createdAt: $createdAt, answeredAt: $answeredAt)';
}
