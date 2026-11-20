import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'data/fake_auth_service.dart';
import 'data/in_memory_tip_repository.dart';
import 'firebase_options.dart';
import 'screens/campus_screen.dart';
import 'screens/city_places_screen.dart';
import 'screens/guide_home_screen.dart';
import 'screens/orientation_screen.dart';
import 'screens/saved_screen.dart';
import 'state/app_state.dart';
import 'theme.dart';
import 'viewmodels/guide_view_model.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const UniversityGuideApp());
}

class UniversityGuideApp extends StatefulWidget {
  const UniversityGuideApp({super.key});

  @override
  State<UniversityGuideApp> createState() => _UniversityGuideAppState();
}

class _UniversityGuideAppState extends State<UniversityGuideApp> {
  final AppState _app = AppState();
  // The only place that decides which data and sign-in implementation is used.
  final GuideViewModel _guide = GuideViewModel(
    repository: InMemoryTipRepository(),
    authService: FakeAuthService(),
  );

  @override
  void initState() {
    super.initState();
    _app.load();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _app,
      builder: (context, _) {
        return MaterialApp(
          title: 'Erasmus Student Guide',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: _app.themeMode,
          home: MainNavigationShell(app: _app, guide: _guide),
        );
      },
    );
  }
}

class MainNavigationShell extends StatefulWidget {
  final AppState app;
  final GuideViewModel guide;

  const MainNavigationShell({
    super.key,
    required this.app,
    required this.guide,
  });

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.app,
      builder: (context, _) {
        final app = widget.app;
        final savedCount = app.totalSavedCount;

        return Scaffold(
          body: IndexedStack(
            index: _index,
            children: [
              GuideHomeScreen(viewModel: widget.guide),
              CampusScreen(app: app),
              CityPlacesScreen(app: app),
              OrientationScreen(app: app),
              SavedScreen(app: app),
            ],
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _index,
            onDestinationSelected: (value) => setState(() => _index = value),
            destinations: [
              const NavigationDestination(
                icon: Icon(Icons.lightbulb_outline),
                selectedIcon: Icon(Icons.lightbulb),
                label: 'Guide',
              ),
              const NavigationDestination(
                icon: Icon(Icons.account_balance_outlined),
                selectedIcon: Icon(Icons.account_balance),
                label: 'Campus',
              ),
              const NavigationDestination(
                icon: Icon(Icons.place_outlined),
                selectedIcon: Icon(Icons.place),
                label: 'Places',
              ),
              NavigationDestination(
                icon: Badge(
                  isLabelVisible: app.checklistDone > 0,
                  label: Text('${app.checklistDone}'),
                  child: const Icon(Icons.checklist_rtl_outlined),
                ),
                selectedIcon: Badge(
                  isLabelVisible: app.checklistDone > 0,
                  label: Text('${app.checklistDone}'),
                  child: const Icon(Icons.checklist_rtl),
                ),
                label: 'Checklist',
              ),
              NavigationDestination(
                icon: Badge(
                  isLabelVisible: savedCount > 0,
                  label: Text('$savedCount'),
                  child: const Icon(Icons.bookmark_border),
                ),
                selectedIcon: Badge(
                  isLabelVisible: savedCount > 0,
                  label: Text('$savedCount'),
                  child: const Icon(Icons.bookmark),
                ),
                label: 'Saved',
              ),
            ],
          ),
        );
      },
    );
  }
}
