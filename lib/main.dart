import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'data/caching_tip_repository.dart';
import 'data/draft_store.dart';
import 'data/firebase_auth_service.dart';
import 'data/firestore_tip_repository.dart';
import 'data/fake_auth_service.dart';
import 'data/in_memory_tip_repository.dart';
import 'data/local_store.dart';
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
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final store = await SharedPreferencesStore.open();
  runApp(
    UniversityGuideApp(
      draftStore: DraftStore(store),
      guide: GuideViewModel(
        // Keeps the last loaded tips and votes on the device for offline use.
        repository: CachingTipRepository(
          inner: FirestoreTipRepository(),
          store: store,
        ),
        authService: FirebaseAuthService(),
      ),
    ),
  );
}

class UniversityGuideApp extends StatefulWidget {
  final DraftStore? draftStore;
  final GuideViewModel? guide;

  const UniversityGuideApp({super.key, this.draftStore, this.guide});

  @override
  State<UniversityGuideApp> createState() => _UniversityGuideAppState();
}

class _UniversityGuideAppState extends State<UniversityGuideApp> {
  final AppState _app = AppState();
  late final GuideViewModel _guide =
      widget.guide ??
      GuideViewModel(
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
          home: MainNavigationShell(
            app: _app,
            guide: _guide,
            draftStore: widget.draftStore,
          ),
        );
      },
    );
  }
}

class MainNavigationShell extends StatefulWidget {
  final AppState app;
  final GuideViewModel guide;
  final DraftStore? draftStore;

  const MainNavigationShell({
    super.key,
    required this.app,
    required this.guide,
    this.draftStore,
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
                viewModel: widget.guide,
                app: app,
                draftStore: widget.draftStore,
              ),
              CampusScreen(app: app),
              CityPlacesScreen(app: app),
              OrientationScreen(app: app),
              SavedScreen(app: app, guide: widget.guide),
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
