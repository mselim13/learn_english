import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:learn_english/pages/result_page.dart';
import '../utils/responsive.dart';

class SeeResultPage extends StatelessWidget {
  const SeeResultPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFD7C6E6), Color(0xFF9171C1)], // Arka plan gradyanı
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final artH = (constraints.maxHeight * 0.28).clamp(140.0, 280.0);
              return Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: Responsive.maxContentWidth(context)),
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: Responsive.horizontalPadding(context),
                      vertical: Responsive.verticalPadding(context),
                    ),
                    child: Column(
                      children: [
                        SizedBox(height: Responsive.gapLg(context)),
                        Text(
                          "LinguaAI",
                          style: TextStyle(
                            fontSize: Responsive.fontSizeTitle(context),
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF8E63C7),
                          ),
                        ),
                        SizedBox(height: Responsive.gapMd(context)),
                        SvgPicture.asset(
                          "assets/images/see_result.svg",
                          height: artH,
                          fit: BoxFit.contain,
                        ),
                        SizedBox(height: Responsive.gapLg(context)),
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(
                            vertical: Responsive.cardPadding(context),
                            horizontal: Responsive.cardPadding(context) * 0.9,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(Responsive.cardRadius(context) + 12),
                          ),
                          child: Column(
                            children: [
                              Text(
                                "Testi başarıyla tamamladın!",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: Responsive.fontSizeBody(context),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: Responsive.gapXs(context)),
                              Text(
                                "Sonucunda İngilizce seviyeni tespit ettik.",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: Responsive.fontSizeBody(context),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: Responsive.gapMd(context)),
                              Text(
                                "Sonucu görmek için tıkla!",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: Responsive.fontSizeBody(context),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: Responsive.gapXl(context)),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (_) => const ResultPage()),
                            );
                          },
                          child: Container(
                            height: Responsive.minTouchTarget(context),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(Responsive.cardRadius(context)),
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFFC7B1E6), // Açık mor
                                  Color(0xFF7B44C6), // Koyu mor
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Text(
                              "SONUCUMU GÖR",
                              style: TextStyle(
                                fontSize: Responsive.fontSizeButton(context),
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.1,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: Responsive.gapLg(context)),
                      ],
                    ),
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