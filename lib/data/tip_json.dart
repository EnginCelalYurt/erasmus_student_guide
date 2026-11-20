import '../models/tip.dart';

Map<String, dynamic> tipToJson(Tip tip) => {
      'id': tip.id,
      'title': tip.title,
      'body': tip.body,
      'category': tip.category.name,
      'authorName': tip.authorName,
      'createdAt': tip.createdAt.toIso8601String(),
      'helpful': tip.helpful,
      'notHelpful': tip.notHelpful,
    };

/// Throws if the data is not a valid tip; callers treat that as "no copy".
Tip tipFromJson(Map<String, dynamic> json) => Tip(
      id: json['id'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      category: TipCategory.values.byName(json['category'] as String),
      authorName: json['authorName'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      helpful: json['helpful'] as int,
      notHelpful: json['notHelpful'] as int,
    );
