class Tip {
  final String id;
  final String title;
  final String category;
  final String summary;
  final String body; // Detailed advice / body
  final String iconName;
  final List<String> tags;
  final String author;
  final int helpfulCount;
  final DateTime createdAt;
  final String? actionLabel;
  final String? actionUrl;
  final bool isMarkedHelpful;

  const Tip({
    required this.id,
    required this.title,
    required this.category,
    required this.summary,
    required this.body,
    required this.iconName,
    required this.tags,
    required this.author,
    required this.helpfulCount,
    required this.createdAt,
    this.actionLabel,
    this.actionUrl,
    this.isMarkedHelpful = false,
  });

  Tip copyWith({
    String? id,
    String? title,
    String? category,
    String? summary,
    String? body,
    String? iconName,
    List<String>? tags,
    String? author,
    int? helpfulCount,
    DateTime? createdAt,
    String? actionLabel,
    String? actionUrl,
    bool? isMarkedHelpful,
  }) {
    return Tip(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      summary: summary ?? this.summary,
      body: body ?? this.body,
      iconName: iconName ?? this.iconName,
      tags: tags ?? this.tags,
      author: author ?? this.author,
      helpfulCount: helpfulCount ?? this.helpfulCount,
      createdAt: createdAt ?? this.createdAt,
      actionLabel: actionLabel ?? this.actionLabel,
      actionUrl: actionUrl ?? this.actionUrl,
      isMarkedHelpful: isMarkedHelpful ?? this.isMarkedHelpful,
    );
  }
}

class NewTip {
  final String title;
  final String category;
  final String summary;
  final String body;
  final List<String> tags;
  final String? actionLabel;
  final String? actionUrl;

  const NewTip({
    required this.title,
    required this.category,
    required this.summary,
    required this.body,
    this.tags = const [],
    this.actionLabel,
    this.actionUrl,
  });

  /// Validates the body text for sharing a new tip.
  /// Used for the share form validation.
  static String? validateBody(String? body) {
    if (body == null || body.trim().isEmpty) {
      return 'Advice body cannot be empty.';
    }
    final trimmed = body.trim();
    if (trimmed.length < 15) {
      return 'Please write at least 15 characters to provide meaningful advice.';
    }
    if (trimmed.length > 2500) {
      return 'Advice body cannot exceed 2500 characters.';
    }
    return null;
  }

  /// Validates the title of a new tip.
  static String? validateTitle(String? title) {
    if (title == null || title.trim().isEmpty) {
      return 'Title cannot be empty.';
    }
    final trimmed = title.trim();
    if (trimmed.length < 5) {
      return 'Title must be at least 5 characters.';
    }
    if (trimmed.length > 100) {
      return 'Title cannot exceed 100 characters.';
    }
    return null;
  }
}
