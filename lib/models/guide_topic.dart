class SurvivalTip {
  final String id;
  final String title;
  final String category; // e.g. "Dormitories", "Transport", "Daily Life", "Emergency"
  final String summary;
  final String detailedAdvice;
  final String iconName;
  final List<String> tags;

  SurvivalTip({
    required this.id,
    required this.title,
    required this.category,
    required this.summary,
    required this.detailedAdvice,
    required this.iconName,
    required this.tags,
  });
}
