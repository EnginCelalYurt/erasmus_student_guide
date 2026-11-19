import 'package:flutter/material.dart';

import 'data/auth_service.dart';
import 'data/local_tip_repository.dart';
import 'data/persistent_auth_service.dart';
import 'data/tip_repository.dart';
import 'screens/guide_home_screen.dart';
import 'screens/orientation_screen.dart';
import 'screens/share_screen.dart';
import 'state/app_state.dart';
import 'theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ErasmusStudentGuideApp());
}

class ErasmusStudentGuideApp extends StatefulWidget {
  const ErasmusStudentGuideApp({super.key});

  @override
  State<ErasmusStudentGuideApp> createState() => _ErasmusStudentGuideAppState();
}

class _ErasmusStudentGuideAppState extends State<ErasmusStudentGuideApp> {
  final AppState _app = AppState();
  final LocalTipRepository _localTipRepository = LocalTipRepository();
  final PersistentAuthService _persistentAuthService = PersistentAuthService();

  @override
  void initState() {
    super.initState();
    _initializeLocalData();
  }

  Future<void> _initializeLocalData() async {
    await _localTipRepository.init();
    await _persistentAuthService.init();
    await _app.load();
    if (mounted) setState(() {});
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
            tipRepository: _localTipRepository,
            authService: _persistentAuthService,
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

        // Week 4 Scope Check: Clean MVP navigation (Guide, Share, Arrival Checklist)
        // Campus, Places and Saved tabs cut according to team plan.
        return Scaffold(
          body: IndexedStack(
            index: _index,
            children: [
              GuideHomeScreen(
                repository: widget.tipRepository,
                authService: widget.authService,
              ),
              ShareScreen(
                repository: widget.tipRepository,
                authService: widget.authService,
                onTipPublished: () => setState(() => _index = 0),
              ),
              OrientationScreen(app: app),
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
                tooltip: 'Browse student guides and tips',
              ),
              const NavigationDestination(
                icon: Icon(Icons.add_circle_outline),
                selectedIcon: Icon(Icons.add_circle),
                label: 'Share',
                tooltip: 'Share your advice (TUL student sign-in required)',
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
                tooltip: 'Sourced arrival steps and student notes',
              ),
            ],
          ),
        );
      },
    );
  }
}
