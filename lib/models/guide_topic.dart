class SurvivalTip {
  final String id;
  final String title;
  final String category;
  final String summary;
  final String detailedAdvice;
  final String iconName;
  final List<String> tags;
  final String? actionLabel;
  final String? actionUrl;

  SurvivalTip({
    required this.id,
    required this.title,
    required this.category,
    required this.summary,
    required this.detailedAdvice,
    required this.iconName,
    required this.tags,
    this.actionLabel,
    this.actionUrl,
  });
}

class CityPlace {
  final String id;
  final String name;
  final String kind;
  final String area;
  final String note;
  final String mapsQuery;

  const CityPlace({
    required this.id,
    required this.name,
    required this.kind,
    required this.area,
    required this.note,
    required this.mapsQuery,
  });
}

class ChecklistItem {
  final String id;
  final String title;
  final String detail;
  final String phase;
  bool done;

  ChecklistItem({
    required this.id,
    required this.title,
    required this.detail,
    required this.phase,
    this.done = false,
  });
}
