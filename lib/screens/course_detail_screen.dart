import 'package:flutter/material.dart';
import '../models/course_review.dart';

class CourseDetailScreen extends StatefulWidget {
  final CourseItem course;
  final VoidCallback onBookmarkToggle;
  final Function(Review) onAddReview;

  const CourseDetailScreen({
    super.key,
    required this.course,
    required this.onBookmarkToggle,
    required this.onAddReview,
  });

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> {
  void _openAddReviewDialog() {
    final nameController = TextEditingController();
    final countryController = TextEditingController();
    final commentController = TextEditingController();
    double selectedRating = 5.0;
    String selectedSemester = 'Fall 2024';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (dialogCtx, setDialogState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(dialogCtx).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Review ${widget.course.code}',
                          style: Theme.of(dialogCtx).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(dialogCtx),
                        )
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Your Rating:',
                      style: Theme.of(dialogCtx).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: List.generate(5, (index) {
                        final starValue = index + 1;
                        return IconButton(
                          icon: Icon(
                            starValue <= selectedRating
                                ? Icons.star
                                : Icons.star_border,
                            color: Colors.amber,
                            size: 32,
                          ),
                          onPressed: () {
                            setDialogState(() {
                              selectedRating = starValue.toDouble();
                            });
                          },
                        );
                      }),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Your Name or Nickname',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: countryController,
                      decoration: const InputDecoration(
                        labelText: 'Home Country (e.g., France 🇫🇷)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.flag),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: commentController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Student Advice & Experience',
                        hintText: 'Share exam tips, workload, or professor vibe...',
                        border: OutlineInputBorder(),
                        alignLabelWithHint: true,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        icon: const Icon(Icons.send),
                        label: const Text('Post Review'),
                        onPressed: () {
                          if (commentController.text.trim().length < 10) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please write at least 10 characters.'),
                                backgroundColor: Colors.redAccent,
                              ),
                            );
                            return;
                          }
                          final newReview = Review(
                            id: DateTime.now().millisecondsSinceEpoch.toString(),
                            author: nameController.text.trim().isEmpty
                                ? 'Erasmus Peer'
                                : nameController.text.trim(),
                            homeCountry: countryController.text.trim().isEmpty
                                ? 'Exchange Student'
                                : countryController.text.trim(),
                            semester: selectedSemester,
                            rating: selectedRating,
                            comment: commentController.text.trim(),
                            helpfulCount: 1,
                          );

                          widget.onAddReview(newReview);
                          setState(() {});
                          Navigator.pop(dialogCtx);

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Your review was successfully published! 🎉'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final course = widget.course;

    return Scaffold(
      appBar: AppBar(
        title: Text(course.code),
        actions: [
          Semantics(
            label: course.isSaved ? 'Remove from bookmarks' : 'Add to bookmarks',
            button: true,
            child: IconButton(
              icon: Icon(
                course.isSaved ? Icons.bookmark : Icons.bookmark_border,
                color: course.isSaved ? Colors.amber[700] : null,
              ),
              onPressed: () {
                setState(() {
                  widget.onBookmarkToggle();
                });
              },
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            course.name,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.blue.shade200),
                          ),
                          child: Text(
                            '${course.ects} ECTS',
                            style: TextStyle(
                              color: Colors.blue.shade900,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        Chip(
                          avatar: const Icon(Icons.school, size: 16),
                          label: Text(course.faculty),
                        ),
                        Chip(
                          avatar: const Icon(Icons.language, size: 16),
                          label: Text(course.language),
                        ),
                        Chip(
                          avatar: const Icon(Icons.speed, size: 16),
                          label: Text('Difficulty: ${course.difficulty}'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 24),
                        const SizedBox(width: 4),
                        Text(
                          course.averageRating.toStringAsFixed(1),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '(${course.reviews.length} student reviews)',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    Text(
                      'Course Overview',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      course.description,
                      style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Reviews Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Student Experiences (${course.reviews.length})',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton.icon(
                  onPressed: _openAddReviewDialog,
                  icon: const Icon(Icons.rate_review),
                  label: const Text('Add Review'),
                ),
              ],
            ),
            const SizedBox(height: 8),

            if (course.reviews.isEmpty)
              Card(
                color: Colors.grey.shade50,
                child: const Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Center(
                    child: Text('No reviews yet. Be the first Erasmus student to share advice!'),
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: course.reviews.length,
                separatorBuilder: (ctx, i) => const SizedBox(height: 12),
                itemBuilder: (ctx, i) {
                  final review = course.reviews[i];
                  return Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(14.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    review.author,
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    '${review.homeCountry} • ${review.semester}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  const Icon(Icons.star, color: Colors.amber, size: 18),
                                  const SizedBox(width: 2),
                                  Text(
                                    review.rating.toStringAsFixed(1),
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            review.comment,
                            style: const TextStyle(height: 1.35),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Icon(Icons.thumb_up_alt_outlined,
                                  size: 14, color: Colors.grey.shade600),
                              const SizedBox(width: 4),
                              Text(
                                '${review.helpfulCount} students found this helpful',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
