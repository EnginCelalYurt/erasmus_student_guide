class Review {
  final String id;
  final String author;
  final String homeCountry;
  final String semester;
  final double rating;
  final String comment;
  final int helpfulCount;

  Review({
    required this.id,
    required this.author,
    required this.homeCountry,
    required this.semester,
    required this.rating,
    required this.comment,
    this.helpfulCount = 0,
  });
}

class CourseItem {
  final String id;
  final String code;
  final String name;
  final String faculty;
  final int ects;
  final String language;
  double averageRating;
  final String difficulty; // e.g. "Moderate", "Challenging", "Easy"
  final String description;
  final List<Review> reviews;
  bool isSaved;

  CourseItem({
    required this.id,
    required this.code,
    required this.name,
    required this.faculty,
    required this.ects,
    required this.language,
    required this.averageRating,
    required this.difficulty,
    required this.description,
    required this.reviews,
    this.isSaved = false,
  });
}
