import 'package:flutter/material.dart';
import '../models/course_review.dart';
import 'course_detail_screen.dart';

class SavedScreen extends StatelessWidget {
  final List<CourseItem> savedCourses;
  final Function(CourseItem) onBookmarkToggle;
  final Function(CourseItem, Review) onAddReviewToCourse;

  const SavedScreen({
    super.key,
    required this.savedCourses,
    required this.onBookmarkToggle,
    required this.onAddReviewToCourse,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Courses & Bookmarks'),
      ),
      body: savedCourses.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.bookmark_border_rounded,
                      size: 64,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No saved courses yet',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap the bookmark icon on any course card to save it here for quick reference when preparing your Learning Agreement.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: savedCourses.length,
              itemBuilder: (context, index) {
                final course = savedCourses[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 1.5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    title: Text(
                      '${course.code} - ${course.name}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        '${course.faculty} • ${course.ects} ECTS • Rating: ${course.averageRating.toStringAsFixed(1)} ★',
                      ),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.bookmark, color: Colors.amber),
                      onPressed: () => onBookmarkToggle(course),
                      tooltip: 'Remove bookmark',
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (ctx) => CourseDetailScreen(
                            course: course,
                            onBookmarkToggle: () => onBookmarkToggle(course),
                            onAddReview: (r) => onAddReviewToCourse(course, r),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
