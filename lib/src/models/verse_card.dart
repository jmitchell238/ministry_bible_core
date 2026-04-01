/// A verse formatted and ready to share or display.
///
/// Produced by [VerseCardFormatter]. Contains everything an app needs to
/// render or copy a verse: the text, a human-readable reference, the
/// translation code, and optional theming hints.
class VerseCard {
  final String verseId;
  final String reference;
  final String verseText;
  final String translationCode;
  final String? theme;
  final String? color;
  final DateTime createdAt;

  const VerseCard({
    required this.verseId,
    required this.reference,
    required this.verseText,
    required this.translationCode,
    this.theme,
    this.color,
    required this.createdAt,
  });

  /// Formatted text suitable for clipboard or social sharing.
  ///
  /// Format: `"verseText\n— Reference (Translation)"`
  String get shareText => '$verseText\n— $reference ($translationCode)';

  factory VerseCard.fromJson(Map<String, dynamic> json) => VerseCard(
        verseId: json['verseId'] as String,
        reference: json['reference'] as String,
        verseText: json['verseText'] as String,
        translationCode: json['translationCode'] as String,
        theme: json['theme'] as String?,
        color: json['color'] as String?,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );

  Map<String, dynamic> toJson() => {
        'verseId': verseId,
        'reference': reference,
        'verseText': verseText,
        'translationCode': translationCode,
        'theme': theme,
        'color': color,
        'createdAt': createdAt.toIso8601String(),
      };

  VerseCard copyWith({
    String? verseId,
    String? reference,
    String? verseText,
    String? translationCode,
    String? theme,
    String? color,
    DateTime? createdAt,
    bool clearTheme = false,
    bool clearColor = false,
  }) =>
      VerseCard(
        verseId: verseId ?? this.verseId,
        reference: reference ?? this.reference,
        verseText: verseText ?? this.verseText,
        translationCode: translationCode ?? this.translationCode,
        theme: clearTheme ? null : (theme ?? this.theme),
        color: clearColor ? null : (color ?? this.color),
        createdAt: createdAt ?? this.createdAt,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VerseCard &&
          runtimeType == other.runtimeType &&
          verseId == other.verseId &&
          reference == other.reference &&
          verseText == other.verseText &&
          translationCode == other.translationCode &&
          theme == other.theme &&
          color == other.color &&
          createdAt == other.createdAt;

  @override
  int get hashCode => Object.hash(
        verseId, reference, verseText, translationCode, theme, color, createdAt,
      );

  @override
  String toString() =>
      'VerseCard(verseId: $verseId, reference: $reference, '
      'translationCode: $translationCode, theme: $theme, color: $color)';
}
