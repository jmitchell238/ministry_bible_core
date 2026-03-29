import 'package:collection/collection.dart';
import 'bible_chapter.dart';

/// A book of the Bible containing chapters.
class BibleBook {
  final int id;
  final String name;
  final String testament;
  final List<BibleChapter> chapters;

  const BibleBook({
    required this.id,
    required this.name,
    required this.testament,
    required this.chapters,
  });

  factory BibleBook.fromJson(Map<String, dynamic> json) {
    final id = json['id'] as int;
    final name = json['name'] as String;
    final testament = json['testament'] as String;
    final chaptersJson = json['chapters'] as List<dynamic>;

    final chapters = chaptersJson
        .map((chapterJson) => BibleChapter.fromJson(
              chapterJson as Map<String, dynamic>,
              bookId: id,
              bookName: name,
            ))
        .toList();

    return BibleBook(
      id: id,
      name: name,
      testament: testament,
      chapters: chapters,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'testament': testament,
        'chapters': chapters.map((c) => c.toJson()).toList(),
      };

  BibleBook copyWith({
    int? id,
    String? name,
    String? testament,
    List<BibleChapter>? chapters,
  }) =>
      BibleBook(
        id: id ?? this.id,
        name: name ?? this.name,
        testament: testament ?? this.testament,
        chapters: chapters ?? this.chapters,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BibleBook &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          testament == other.testament &&
          const ListEquality<BibleChapter>().equals(chapters, other.chapters);

  @override
  int get hashCode => Object.hash(
        id,
        name,
        testament,
        const ListEquality<BibleChapter>().hash(chapters),
      );

  @override
  String toString() =>
      'BibleBook(id: $id, name: $name, testament: $testament, chapters: ${chapters.length})';
}
