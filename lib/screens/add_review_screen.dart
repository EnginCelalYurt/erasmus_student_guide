import 'package:flutter/material.dart';
import '../models/course_review.dart';

class AddReviewScreen extends StatefulWidget {
  final List<CourseItem> courses;
  final Function(CourseItem, Review) onReviewSubmitted;

  const AddReviewScreen({
    super.key,
    required this.courses,
    required this.onReviewSubmitted,
  });

  @override
  State<AddReviewScreen> createState() => _AddReviewScreenState();
}

class _AddReviewScreenState extends State<AddReviewScreen> {
  final _formKey = GlobalKey<FormState>();

  CourseItem? _selectedCourse;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _commentController = TextEditingController();
  double _rating = 5.0;
  String _semester = 'Fall 2024';

  final List<String> _semesters = [
    'Fall 2024',
    'Spring 2024',
    'Fall 2023',
    'Spring 2023',
    'Local Mentor (Full-Time)',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.courses.isNotEmpty) {
      _selectedCourse = widget.courses.first;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _countryController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please resolve the highlighted form errors.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    if (_selectedCourse == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a course to review.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final newReview = Review(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      author: _nameController.text.trim().isEmpty
          ? 'Anonymous Erasmus'
          : _nameController.text.trim(),
      homeCountry: _countryController.text.trim().isEmpty
          ? 'Erasmus Exchange'
          : _countryController.text.trim(),
      semester: _semester,
      rating: _rating,
      comment: _commentController.text.trim(),
      helpfulCount: 1,
    );

    widget.onReviewSubmitted(_selectedCourse!, newReview);

    // Reset fields
    _commentController.clear();
    _nameController.clear();
    _countryController.clear();
    setState(() {
      _rating = 5.0;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Review posted for ${_selectedCourse!.code}! Thank you for helping peers! 🎉',
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Student Advice'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Share Your Erasmus Experience',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Help future exchange students at Politechnika Łódzka make the best academic choices.',
                style: TextStyle(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 24),

              // Course Selector
              DropdownButtonFormField<CourseItem>(
                initialValue: _selectedCourse,
                decoration: const InputDecoration(
                  labelText: 'Select Course',
                  prefixIcon: Icon(Icons.school),
                  border: OutlineInputBorder(),
                ),
                items: widget.courses.map((course) {
                  return DropdownMenuItem<CourseItem>(
                    value: course,
                    child: Text(
                      '${course.code} - ${course.name}',
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() {
                    _selectedCourse = val;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Rating bar
              Text(
                'Overall Rating:',
                style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  ...List.generate(5, (index) {
                    final starVal = index + 1;
                    return IconButton(
                      icon: Icon(
                        starVal <= _rating ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                        size: 32,
                      ),
                      onPressed: () {
                        setState(() {
                          _rating = starVal.toDouble();
                        });
                      },
                    );
                  }),
                  const SizedBox(width: 8),
                  Text(
                    '${_rating.toInt()} / 5',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Name and Country
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Your Name / Nickname',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _countryController,
                      decoration: const InputDecoration(
                        labelText: 'Home Country',
                        hintText: 'e.g. Italy 🇮🇹',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.flag),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Semester dropdown
              DropdownButtonFormField<String>(
                initialValue: _semester,
                decoration: const InputDecoration(
                  labelText: 'Exchange Period',
                  prefixIcon: Icon(Icons.calendar_today),
                  border: OutlineInputBorder(),
                ),
                items: _semesters.map((s) {
                  return DropdownMenuItem(value: s, child: Text(s));
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _semester = val;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),

              // Review comment
              TextFormField(
                controller: _commentController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Your Advice & Review *',
                  hintText:
                      'Describe lecture attendance, exam difficulty, grading, professor assistance, or lab projects...',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Please enter your review comment.';
                  }
                  if (val.trim().length < 15) {
                    return 'Please write at least 15 characters to provide useful advice.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Submit button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: FilledButton.icon(
                  icon: const Icon(Icons.send_rounded),
                  label: const Text(
                    'Submit Student Review',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  onPressed: _submitForm,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
