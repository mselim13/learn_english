import 'dart:async';
import 'package:flutter/material.dart';
import 'test_intro_page.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../navigation/main_navigation_page.dart';
import '../services/app_prefs.dart';
import '../utils/responsive.dart';


class AfterRegisterPage extends StatefulWidget {
  const AfterRegisterPage({super.key});

  @override
  State<AfterRegisterPage> createState() =>
      _AfterRegisterPageState();
}

class _AfterRegisterPageState
    extends State<AfterRegisterPage> {

  @override
  void initState() {
    super.initState();

    /// 5 saniye sonra diğer sayfa
    Timer(const Duration(seconds: 5), () async {
      final completed = await AppPrefs.getPlacementTestCompleted();
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => completed ? const MainNavigationPage() : const TestIntroPage(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final titleSize = Responsive.fontSizeTitle(context);
    final welcomeSize = Responsive.scaled(context, min: 28, max: 44);
    return Scaffold(
      body: Container(
        width: double.infinity,
        padding: EdgeInsets.all(Responsive.cardPadding(context)),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFD7C4EA),
              Color(0xFF7A3EC8),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final maxArtHeight = constraints.maxHeight * 0.55;
              final artHeight = Responsive.scaled(context, min: 220, max: 460).clamp(180, maxArtHeight);
              return Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(height: Responsive.gapSm(context)),
                  Text(
                    "LinguaAI",
                    style: TextStyle(
                      fontSize: titleSize,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                  Column(
                    children: [
                      Text(
                        "Aramıza Hoş Geldin!",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: welcomeSize,
                          fontWeight: FontWeight.bold,
                          color: Colors.purple,
                        ),
                      ),
                      SizedBox(height: Responsive.gapLg(context)),
                      SvgPicture.asset(
                        "assets/images/after_register.svg",
                        height: artHeight.toDouble(),
                        fit: BoxFit.contain,
                      ),
                    ],
                  ),
                  SizedBox(height: Responsive.gapLg(context)),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
