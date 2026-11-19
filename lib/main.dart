import 'package:flutter/material.dart';

import 'data/auth_service.dart';
import 'data/fake_auth_service.dart';
import 'data/in_memory_tip_repository.dart';
import 'data/tip_repository.dart';
import 'screens/guide_home_screen.dart';
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
          title: 'Erasmus Student Guide',
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

class MainNavigationShell extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return GuideHomeScreen(
      repository: tipRepository,
      authService: authService,
    );
  }
}
