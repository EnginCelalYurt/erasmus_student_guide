import 'package:flutter/material.dart';
import 'data/sample_data.dart';
import 'models/course_review.dart';
import 'screens/add_review_screen.dart';
import 'screens/home_screen.dart';
import 'screens/saved_screen.dart';
import 'screens/survival_guide_screen.dart';

void main() {
  runApp(const ErasmusGuideApp());
}

class ErasmusGuideApp extends StatelessWidget {
  const ErasmusGuideApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Erasmus Student Guide - TUL',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF003399), // Erasmus European Blue
          primary: const Color(0xFF003399),
          secondary: const Color(0xFFA91D22), // Politechnika Łódzka Crimson
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          elevation: 0,
        ),
        cardTheme: CardThemeData(
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      home: const MainNavigationShell(),
    );
  }
}

class MainNavigationShell extends StatefulWidget {
  const MainNavigationShell({super.key});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _currentIndex = 0;
  final List<CourseItem> _courses = List.from(SampleData.courses);

  void _toggleBookmark(CourseItem course) {
    setState(() {
      course.isSaved = !course.isSaved;
    });
  }

  void _addReviewToCourse(CourseItem course, Review review) {
    setState(() {
      course.reviews.insert(0, review);
      final total = course.reviews.fold<double>(
          0.0, (previousValue, element) => previousValue + element.rating);
      course.averageRating = total / course.reviews.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    final savedCourses = _courses.where((c) => c.isSaved).toList();

    final List<Widget> pages = [
      HomeScreen(
        courses: _courses,
        onBookmarkToggle: _toggleBookmark,
        onAddReviewToCourse: _addReviewToCourse,
      ),
      SurvivalGuideScreen(
        tips: SampleData.survivalTips,
      ),
      AddReviewScreen(
        courses: _courses,
        onReviewSubmitted: _addReviewToCourse,
      ),
      SavedScreen(
        savedCourses: savedCourses,
        onBookmarkToggle: _toggleBookmark,
        onAddReviewToCourse: _addReviewToCourse,
      ),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.school_outlined),
            selectedIcon: Icon(Icons.school),
            label: 'Courses',
          ),
          const NavigationDestination(
            icon: Icon(Icons.map_outlined),
            selectedIcon: Icon(Icons.map),
            label: 'Lodz Guide',
          ),
          const NavigationDestination(
            icon: Icon(Icons.add_circle_outline),
            selectedIcon: Icon(Icons.add_circle),
            label: 'Share Tip',
          ),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: savedCourses.isNotEmpty,
              label: Text('${savedCourses.length}'),
              child: const Icon(Icons.bookmark_border),
            ),
            selectedIcon: Badge(
              isLabelVisible: savedCourses.isNotEmpty,
              label: Text('${savedCourses.length}'),
              child: const Icon(Icons.bookmark),
            ),
            label: 'Saved',
          ),
        ],
      ),
    );
  }
}
