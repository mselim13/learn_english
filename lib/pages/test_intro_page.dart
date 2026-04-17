import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'placement_test_page.dart';
import '../utils/responsive.dart';

class TestIntroPage extends StatelessWidget {
  const TestIntroPage({super.key});

  @override
  Widget build(BuildContext context) {
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
              final maxArtH = constraints.maxHeight * 0.45;
              final artH = Responsive.scaled(context, min: 180, max: 420).clamp(140, maxArtH);
              return Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: Responsive.maxContentWidth(context)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(height: Responsive.gapSm(context)),

                      /// Logo / Başlık
                      Text(
                        "LinguaAI",
                        style: TextStyle(
                          fontSize: Responsive.fontSizeTitle(context),
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                      ),

                      /// Orta Alan
                      Column(
                        children: [
                          SvgPicture.asset(
                            "assets/images/test.svg",
                            height: artH.toDouble(),
                            fit: BoxFit.contain,
                          ),
                          SizedBox(height: Responsive.gapMd(context)),
                          Container(
                            padding: EdgeInsets.all(Responsive.cardPadding(context) * 0.85),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(Responsive.cardRadius(context)),
                            ),
                            child: Text(
                              "Şimdi de İngilizce seviyeni "
                              "belirlemek için bir test çözmen "
                              "gerekiyor.\nHazırsan başlayalım!",
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: Responsive.fontSizeBody(context)),
                            ),
                          ),
                          SizedBox(height: Responsive.gapMd(context)),

                          /// HAZIRIM! Butonu
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const PlacementTestPage(),
                                ),
                              );
                            },
                            child: Container(
                              width: double.infinity,
                              height: Responsive.minTouchTarget(context),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(Responsive.cardRadius(context)),
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFD7C4EA),
                                    Color(0xFF7A3EC8),
                                  ],
                                ),
                              ),
                              child: Text(
                                "HAZIRIM!",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: Responsive.fontSizeButton(context),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: Responsive.gapSm(context)),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
