enum TipCategory {
  firstWeeks('First weeks'),
  dormitories('Dormitories'),
  transport('Transport'),
  emergency('Emergency'),
  studentLife('Student life'),
  dailyLife('Daily life');

  const TipCategory(this.label);

  final String label;
}

enum VoteValue { helpful, notHelpful }

class Tip {
  const Tip({
    required this.id,
    required this.title,
    required this.body,
    required this.category,
    required this.authorName,
    required this.createdAt,
    this.helpful = 0,
    this.notHelpful = 0,
  });

  final String id;
  final String title;
  final String body;
  final TipCategory category;
  final String authorName;
  final DateTime createdAt;
  final int helpful;
  final int notHelpful;

  int get totalVotes => helpful + notHelpful;

  Tip copyWith({int? helpful, int? notHelpful}) {
    return Tip(
      id: id,
      title: title,
      body: body,
      category: category,
      authorName: authorName,
      createdAt: createdAt,
      helpful: helpful ?? this.helpful,
      notHelpful: notHelpful ?? this.notHelpful,
    );
  }
}

class NewTip {
  const NewTip({
    required this.title,
    required this.body,
    required this.category,
    this.authorName = 'TUL student',
  });

  static const minBodyLength = 15;

  final String title;
  final String body;
  final TipCategory category;
  final String authorName;

  static String? validateTitle(String? text) {
    if (text == null || text.trim().isEmpty) {
      return 'Enter a title.';
    }
    return null;
  }

  static String? validateBody(String? text) {
    if (text == null || text.trim().length < minBodyLength) {
      return 'Write at least $minBodyLength characters.';
    }
    return null;
  }
}
