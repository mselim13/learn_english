import 'package:flutter/material.dart';
import '../services/app_prefs.dart';
import '../utils/responsive.dart';
import '../widgets/responsive_page.dart';
import 'welcome_page.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _controller = PageController();
  int _page = 0;
  static const _pages = [
    {'title': 'Kelime öğren', 'body': 'Binlerce kelime ve örnek cümle ile İngilizceni geliştir.', 'icon': Icons.menu_book},
    {'title': 'Pratik yap', 'body': 'Quiz, dinleme ve yazma alıştırmalarıyla pratik yap.', 'icon': Icons.sports_esports},
    {'title': 'İlerlemeni takip et', 'body': 'Rozetler, streak ve istatistiklerle motivasyonunu yüksek tut.', 'icon': Icons.trending_up},
  ];

  void _next() async {
    if (_page < _pages.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() => _page++);
    } else {
      await AppPrefs.setOnboardingSeen(true);
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const WelcomePage(),
          transitionsBuilder: (_, a, __, c) =>
              FadeTransition(opacity: a, child: c),
          transitionDuration: const Duration(milliseconds: 400),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final iconSize = Responsive.scaled(context, min: 56, max: 92);
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _page = i),
                itemBuilder: (context, i) {
                  final p = _pages[i];
                  return ResponsivePage(
                    scroll: false,
                    padding: EdgeInsets.symmetric(
                      horizontal: Responsive.horizontalPadding(context),
                      vertical: 0,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          p['icon'] as IconData,
                          size: iconSize,
                          color: const Color(0xFF7A3EC8),
                        ),
                        SizedBox(height: Responsive.gapLg(context)),
                        Text(
                          p['title'] as String,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: Responsive.fontSizeTitle(context),
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF4A148C),
                          ),
                        ),
                        SizedBox(height: Responsive.gapMd(context)),
                        Text(
                          p['body'] as String,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: Responsive.fontSizeBody(context),
                            height: 1.5,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.all(Responsive.cardPadding(context)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(
                      _pages.length,
                      (i) => Container(
                        margin: EdgeInsets.only(right: Responsive.gapXs(context)),
                        width: _page == i ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _page == i
                              ? const Color(0xFF7A3EC8)
                              : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _next,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7A3EC8),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: Responsive.scaled(context, min: 18, max: 28),
                        vertical: Responsive.buttonPaddingVertical(context),
                      ),
                      minimumSize: Size(0, Responsive.minTouchTarget(context)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(Responsive.cardRadius(context) + 6),
                      ),
                    ),
                    child: Text(_page < _pages.length - 1 ? 'İleri' : 'Başla'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
