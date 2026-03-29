import 'bible_verse.dart';

/// A Bible search result containing the matched verse and highlight info.
class SearchResult {
  final BibleVerse verse;
  final String highlightedText;
  final int matchPosition;

  const SearchResult({
    required this.verse,
    required this.highlightedText,
    required this.matchPosition,
  });

  factory SearchResult.fromJson(
    Map<String, dynamic> json, {
    required int bookId,
    required String bookName,
    required int chapter,
  }) =>
      SearchResult(
        verse: BibleVerse.fromJson(
          json['verse'] as Map<String, dynamic>,
          bookId: bookId,
          bookName: bookName,
          chapter: chapter,
        ),
        highlightedText: json['highlightedText'] as String,
        matchPosition: json['matchPosition'] as int,
      );

  Map<String, dynamic> toJson() => {
        'verse': verse.toJson(),
        'highlightedText': highlightedText,
        'matchPosition': matchPosition,
      };

  SearchResult copyWith({
    BibleVerse? verse,
    String? highlightedText,
    int? matchPosition,
  }) =>
      SearchResult(
        verse: verse ?? this.verse,
        highlightedText: highlightedText ?? this.highlightedText,
        matchPosition: matchPosition ?? this.matchPosition,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SearchResult &&
          runtimeType == other.runtimeType &&
          verse.id == other.verse.id &&
          highlightedText == other.highlightedText &&
          matchPosition == other.matchPosition;

  @override
  int get hashCode => Object.hash(verse.id, highlightedText, matchPosition);

  @override
  String toString() =>
      'SearchResult(verse: ${verse.id}, highlightedText: $highlightedText, '
      'matchPosition: $matchPosition)';
}
