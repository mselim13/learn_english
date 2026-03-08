import 'package:flutter/material.dart';
import '../pages/home_page.dart';
import '../pages/lesson_page.dart';
import '../pages/vocabulary_book_page.dart';
import '../pages/stats_page.dart';
import '../pages/profile_page.dart';
import '../pages/welcome_page.dart';
import '../services/app_prefs.dart';
import '../utils/responsive.dart';

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkAuth());
  }

  Future<void> _checkAuth() async {
    final authenticated = await AppPrefs.isAuthenticated();
    if (!mounted) return;
    if (!authenticated) {
      await AppPrefs.setLoggedIn(false);
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const WelcomePage()),
        (route) => false,
      );
    }
  }

  final List<Widget> _pages = const [
    HomePage(),
    LessonPage(),
    VocabularyBookPage(),
    StatsPage(),
    ProfilePage(),
  ];

  void _onItemTapped(int index) {
    if (index < 0 || index >= _pages.length) return;
    setState(() {
      _selectedIndex = index;
    });
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
                NavigationRailDestination(icon: Icon(Icons.school_outlined), selectedIcon: Icon(Icons.school), label: Text('Ders')),
                NavigationRailDestination(icon: Icon(Icons.menu_book_outlined), selectedIcon: Icon(Icons.menu_book), label: Text('Kelime')),
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
              _buildNavItem(Icons.school_outlined, 1, navIconSize),
              _buildNavItem(Icons.menu_book_outlined, 2, navIconSize),
              _buildNavItem(Icons.bar_chart, 3, navIconSize),
              _buildNavItem(Icons.person, 4, navIconSize),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index, double iconSize) {
    final safeIndex = _selectedIndex.clamp(0, _pages.length - 1);
    final bool isActive = safeIndex == index;

    return GestureDetector(
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
    );
  }
}
