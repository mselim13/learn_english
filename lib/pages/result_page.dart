import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:learn_english/navigation/main_navigation_page.dart';
import '../services/app_prefs.dart';
import '../utils/responsive.dart';

class ResultPage extends StatelessWidget {
  const ResultPage({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: AppPrefs.getUserLevel(),
      builder: (context, snap) {
        final level = snap.data ?? 'A2';
        return GestureDetector(
          onTap: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const MainNavigationPage()),
            );
          },
          child: Scaffold(
            body: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFFD7C6E6),
                    Color(0xFF8E63C7),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: SafeArea(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final maxW = constraints.maxWidth;
                    final maxH = constraints.maxHeight;

                    final cardW = (maxW * 0.86).clamp(280.0, 420.0);
                    final cardH = (maxH * 0.55).clamp(320.0, 520.0);
                    final artH = (cardH * 0.45).clamp(120.0, 240.0);

                    return Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: Responsive.maxContentWidth(context),
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: Responsive.horizontalPadding(context),
                            vertical: Responsive.verticalPadding(context),
                          ),
                          child: Column(
                            children: [
                              Text(
                                "LinguaAI",
                                style: TextStyle(
                                  fontSize: Responsive.fontSizeTitle(context),
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: Responsive.gapLg(context)),

                              /// Seviye Kartı
                              Container(
                                width: cardW,
                                height: cardH,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(Responsive.cardRadius(context) + 12),
                                  border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SvgPicture.asset(
                                      "assets/images/test_level.svg",
                                      height: artH,
                                      fit: BoxFit.contain,
                                    ),
                                    SizedBox(height: Responsive.gapMd(context)),
                                    Text(
                                      level,
                                      style: TextStyle(
                                        fontSize: Responsive.scaled(context, min: 42, max: 64),
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              SizedBox(height: Responsive.gapLg(context)),

                              /// Mesaj Kutusu
                              Container(
                                width: double.infinity,
                                padding: EdgeInsets.all(Responsive.cardPadding(context) * 0.9),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  borderRadius: BorderRadius.circular(Responsive.cardRadius(context)),
                                ),
                                child: Text(
                                  "Senin için hazırladığımız profil sayfasına artık gidebilirsin.\n"
                                  "Devam etmek için ekrana dokun!",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: Responsive.fontSizeBody(context),
                                    color: const Color(0xFF4A148C),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),

                              const Spacer(),
                              Padding(
                                padding: EdgeInsets.only(bottom: Responsive.gapMd(context)),
                                child: Icon(
                                  Icons.touch_app_rounded,
                                  color: Colors.white70,
                                  size: Responsive.iconSizeMedium(context),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}