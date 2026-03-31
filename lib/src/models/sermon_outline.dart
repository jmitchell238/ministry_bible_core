import 'package:collection/collection.dart';
import 'package:uuid/uuid.dart';

/// The delivery status of a sermon or lesson.
enum SermonStatus { draft, delivered }

/// A single point in a sermon or lesson outline.
class SermonPoint {
  final String heading;

  /// Body text / notes for this point. Null if not yet written.
  final String? body;

  /// Optional canonical verse ID tied to this point (e.g. "John-3-16").
  final String? verseId;

  const SermonPoint({
    required this.heading,
    this.body,
    this.verseId,
  });

  factory SermonPoint.fromJson(Map<String, dynamic> json) => SermonPoint(
        heading: json['heading'] as String,
        body: json['body'] as String?,
        verseId: json['verseId'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'heading': heading,
        'body': body,
        'verseId': verseId,
      };

  SermonPoint copyWith({
    String? heading,
    String? body,
    String? verseId,
    bool clearBody = false,
    bool clearVerseId = false,
  }) =>
      SermonPoint(
        heading: heading ?? this.heading,
        body: clearBody ? null : (body ?? this.body),
        verseId: clearVerseId ? null : (verseId ?? this.verseId),
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SermonPoint &&
          runtimeType == other.runtimeType &&
          heading == other.heading &&
          body == other.body &&
          verseId == other.verseId;

  @override
  int get hashCode => Object.hash(heading, body, verseId);

  @override
  String toString() =>
      'SermonPoint(heading: $heading, body: $body, verseId: $verseId)';
}

/// A sermon or lesson outline, including scripture references and outline points.
///
/// Used by both the Bible reading tracker (e.g. noting what sermon a verse
/// relates to) and ministry/sermon-prep apps.
class SermonOutline {
  final String id;
  final String title;

  /// Scheduled or delivered date; null if not yet set.
  final DateTime? date;

  /// Series name (e.g. "Last Things", "C&C Lesson 52"). Null if standalone.
  final String? seriesName;

  /// Canonical verse IDs for the primary scripture references.
  final List<String> scriptureReferences;

  /// Ordered outline points.
  final List<SermonPoint> points;

  final SermonStatus status;

  /// General notes not tied to a specific outline point.
  final String? notes;

  final DateTime createdAt;
  final DateTime updatedAt;

  const SermonOutline({
    required this.id,
    required this.title,
    this.date,
    this.seriesName,
    required this.scriptureReferences,
    required this.points,
    required this.status,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Creates a new [SermonOutline] with a generated UUID and current timestamps.
  factory SermonOutline.create({
    required String title,
    DateTime? date,
    String? seriesName,
    List<String> scriptureReferences = const [],
    List<SermonPoint> points = const [],
    SermonStatus status = SermonStatus.draft,
    String? notes,
  }) {
    final now = DateTime.now();
    return SermonOutline(
      id: const Uuid().v4(),
      title: title,
      date: date,
      seriesName: seriesName,
      scriptureReferences: List<String>.from(scriptureReferences),
      points: List<SermonPoint>.from(points),
      status: status,
      notes: notes,
      createdAt: now,
      updatedAt: now,
    );
  }

  factory SermonOutline.fromJson(Map<String, dynamic> json) => SermonOutline(
        id: json['id'] as String,
        title: json['title'] as String,
        date: json['date'] != null
            ? DateTime.parse(json['date'] as String)
            : null,
        seriesName: json['seriesName'] as String?,
        scriptureReferences: List<String>.from(
          (json['scriptureReferences'] as List<dynamic>).cast<String>(),
        ),
        points: (json['points'] as List<dynamic>)
            .map((e) => SermonPoint.fromJson(e as Map<String, dynamic>))
            .toList(),
        status: SermonStatus.values.byName(json['status'] as String),
        notes: json['notes'] as String?,
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'date': date?.toIso8601String(),
        'seriesName': seriesName,
        'scriptureReferences': scriptureReferences.toList(),
        'points': points.map((p) => p.toJson()).toList(),
        'status': status.name,
        'notes': notes,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  SermonOutline copyWith({
    String? id,
    String? title,
    DateTime? date,
    String? seriesName,
    List<String>? scriptureReferences,
    List<SermonPoint>? points,
    SermonStatus? status,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool clearDate = false,
    bool clearSeriesName = false,
    bool clearNotes = false,
  }) =>
      SermonOutline(
        id: id ?? this.id,
        title: title ?? this.title,
        date: clearDate ? null : (date ?? this.date),
        seriesName:
            clearSeriesName ? null : (seriesName ?? this.seriesName),
        scriptureReferences: scriptureReferences ??
            List<String>.from(this.scriptureReferences),
        points: points ?? List<SermonPoint>.from(this.points),
        status: status ?? this.status,
        notes: clearNotes ? null : (notes ?? this.notes),
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SermonOutline &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          date == other.date &&
          seriesName == other.seriesName &&
          const ListEquality<String>()
              .equals(scriptureReferences, other.scriptureReferences) &&
          const ListEquality<SermonPoint>()
              .equals(points, other.points) &&
          status == other.status &&
          notes == other.notes &&
          createdAt == other.createdAt &&
          updatedAt == other.updatedAt;

  @override
  int get hashCode => Object.hash(
        id,
        title,
        date,
        seriesName,
        const ListEquality<String>().hash(scriptureReferences),
        const ListEquality<SermonPoint>().hash(points),
        status,
        notes,
        createdAt,
        updatedAt,
      );

  @override
  String toString() =>
      'SermonOutline(id: $id, title: $title, date: $date, '
      'seriesName: $seriesName, references: ${scriptureReferences.length}, '
      'points: ${points.length}, status: $status, '
      'createdAt: $createdAt, updatedAt: $updatedAt)';
}
