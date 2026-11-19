import 'package:flutter/material.dart';

import 'repositories/tip_repository.dart';
import 'screens/campus_screen.dart';
import 'screens/city_places_screen.dart';
import 'screens/guide_home_screen.dart';
import 'screens/orientation_screen.dart';
import 'screens/saved_screen.dart';
import 'services/fake_auth_service.dart';
import 'state/app_state.dart';
import 'theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const UniversityGuideApp());
}

class UniversityGuideApp extends StatefulWidget {
  const UniversityGuideApp({super.key});

  @override
  State<UniversityGuideApp> createState() => _UniversityGuideAppState();
}

class _UniversityGuideAppState extends State<UniversityGuideApp> {
  final AppState _app = AppState();
  final TipRepository _tipRepository = InMemoryTipRepository();
  final AuthService _authService = FakeAuthService();

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
          title: 'Campus & University Guide',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: _app.themeMode,
          home: MainNavigationShell(
            app: _app,
            tipRepository: _tipRepository,
            authService: _authService,
          ),
        );
      },
    );
  }
}

class MainNavigationShell extends StatefulWidget {
  final AppState app;
  final TipRepository tipRepository;
  final AuthService authService;

  const MainNavigationShell({
    super.key,
    required this.app,
    required this.tipRepository,
    required this.authService,
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
              GuideHomeScreen(
                repository: widget.tipRepository,
                authService: widget.authService,
              ),
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
