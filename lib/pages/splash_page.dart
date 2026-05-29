import 'package:flutter/material.dart';
import '../services/app_prefs.dart';
import '../services/auth_service.dart';
import '../services/profile_notifier.dart';
import '../services/stats_store.dart';
import 'test_intro_page.dart';
import 'welcome_page.dart';
import '../navigation/main_navigation_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(milliseconds: 1800));
    if (!mounted) return;

    final authenticated = await AuthService.isAuthenticated();

    Widget next;
    if (!authenticated) {
      next = const WelcomePage();
    } else {
      // Backend'den güncel kullanıcı bilgilerini çek (placementTestCompleted dahil)
      await AuthService.fetchAndSyncUser();

      // Profili bellekte yükle
      final profile = await loadProfileFromPrefs();
      updateProfileNotifier(profile);

      // Eski hardcoded skill default'larını temizle, sonra backend'den senkronize et
      await StatsStore.clearOldSkillDefaults();
      StatsStore.syncFromBackend();

      final completed = await AppPrefs.getPlacementTestCompleted();
      next = completed ? const MainNavigationPage() : const TestIntroPage();
    }

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => next,
        transitionsBuilder: (_, a, __, c) =>
            FadeTransition(opacity: a, child: c),
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFD7C4EA), Color(0xFF7A3EC8)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.school, size: 80, color: Colors.white.withOpacity(0.95)),
            const SizedBox(height: 20),
            const Text(
              'İngilizce Öğren',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Learn English',
              style: TextStyle(
                fontSize: 15,
                color: Colors.white.withOpacity(0.88),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
