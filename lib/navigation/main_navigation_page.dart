import 'dart:async';

import 'package:flutter/material.dart';
import '../pages/home_page.dart';
import '../pages/ai_conversation_page.dart';
import '../pages/vocabulary_book_page.dart';
import '../pages/stats_page.dart';
import '../pages/profile_page.dart';
import '../pages/welcome_page.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../utils/responsive.dart';

typedef VocabularyBookRefresh = Future<void> Function();

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _selectedIndex = 0;
  VocabularyBookRefresh? _refreshVocab;
  VoidCallback? _reloadStats;
  StreamSubscription<void>? _sessionSub;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkAuth());
    // Token süresi dolunca otomatik olarak login sayfasına yönlendir
    _sessionSub = sessionExpiredStream.stream.listen((_) => _onSessionExpired());
  }

  @override
  void dispose() {
    _sessionSub?.cancel();
    super.dispose();
  }

  Future<void> _onSessionExpired() async {
    if (!mounted) return;
    await AuthService.logout();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Oturum süresi doldu. Lütfen tekrar giriş yapın.'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 4),
      ),
    );
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const WelcomePage()),
      (route) => false,
    );
  }

  Future<void> _checkAuth() async {
    final authenticated = await AuthService.isAuthenticated();
    if (!mounted) return;
    if (!authenticated) {
      await AuthService.logout();
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const WelcomePage()),
        (route) => false,
      );
    }
  }

  late final List<Widget> _pages = [
    const HomePage(),
    const AiConversationPage(),
    VocabularyBookPage(
      onExposeRefresh: (fn) => _refreshVocab = fn,
    ),
    StatsPage(
      onExposeReload: (fn) => _reloadStats = fn,
    ),
    const ProfilePage(),
  ];

  void _onItemTapped(int index) {
    if (index < 0 || index >= _pages.length) return;
    setState(() {
      _selectedIndex = index;
    });
    if (index == 2) {
      // Refresh vocabulary book when switching tabs (IndexedStack keeps state).
      _refreshVocab?.call();
    }
    if (index == 3) {
      // İstatistik tabına geçilince arka planda backend'den yenile.
      _reloadStats?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final useRail = Responsive.isTablet(context) || Responsive.isDesktop(context);
    final navMargin = Responsive.gapMd(context);
    final navIconSize = Responsive.iconSizeSmall(context);

    if (useRail) {
      return Scaffold(
        backgroundColor: const Color(0xFFF5F0FA),
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: _selectedIndex.clamp(0, _pages.length - 1),
              onDestinationSelected: _onItemTapped,
              backgroundColor: Colors.grey.shade100,
              extended: Responsive.isDesktop(context),
              leading: SizedBox(height: Responsive.gapMd(context)),
              trailing: SizedBox(height: Responsive.gapMd(context)),
              destinations: const [
                NavigationRailDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: Text('Ana Sayfa')),
                NavigationRailDestination(icon: Icon(Icons.chat_bubble_outline), selectedIcon: Icon(Icons.chat_bubble), label: Text('İngilizce AI')),
                NavigationRailDestination(icon: Icon(Icons.menu_book_outlined), selectedIcon: Icon(Icons.menu_book), label: Text('Kelime defteri')),
                NavigationRailDestination(icon: Icon(Icons.bar_chart_outlined), selectedIcon: Icon(Icons.bar_chart), label: Text('İstatistik')),
                NavigationRailDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: Text('Profil')),
              ],
            ),
            Expanded(
              child: IndexedStack(
                index: _selectedIndex.clamp(0, _pages.length - 1),
                children: _pages,
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F0FA),
      body: IndexedStack(
        index: _selectedIndex.clamp(0, _pages.length - 1),
        children: _pages,
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          margin: EdgeInsets.fromLTRB(navMargin, 0, navMargin, navMargin),
          padding: EdgeInsets.symmetric(vertical: Responsive.gapXs(context)),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(Responsive.cardRadius(context) + Responsive.gapSm(context)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNavItem(Icons.home, 0, navIconSize),
              _buildNavItem(Icons.chat_bubble_outline, 1, navIconSize),
              _buildNavItem(Icons.menu_book_outlined, 2, navIconSize),
              _buildNavItem(Icons.bar_chart, 3, navIconSize),
              _buildNavItem(Icons.person, 4, navIconSize),
            ],
          ),
        ),
      ),
    );
  }

  static const List<String> _navLabels = [
    'Ana Sayfa',
    'İngilizce AI',
    'Kelime defteri',
    'İstatistik',
    'Profil',
  ];

  Widget _buildNavItem(IconData icon, int index, double iconSize) {
    final safeIndex = _selectedIndex.clamp(0, _pages.length - 1);
    final bool isActive = safeIndex == index;
    final label = index < _navLabels.length ? _navLabels[index] : '';

    return Tooltip(
      message: label,
      child: Semantics(
        button: true,
        label: label,
        selected: isActive,
        child: GestureDetector(
          onTap: () => _onItemTapped(index),
          behavior: HitTestBehavior.opaque,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.symmetric(
              horizontal: Responsive.gapSm(context),
              vertical: Responsive.gapSm(context),
            ),
            decoration: BoxDecoration(
              color: isActive ? const Color(0xFF4A148C) : Colors.transparent,
              borderRadius: BorderRadius.circular(Responsive.cardRadius(context)),
              shape: BoxShape.rectangle,
            ),
            child: Icon(
              icon,
              size: iconSize,
              color: isActive ? Colors.white : Colors.grey,
            ),
          ),
        ),
      ),
    );
  }
}
