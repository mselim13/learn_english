import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:learn_english/navigation/main_navigation_page.dart';
import '../utils/responsive.dart';

class ResultPage extends StatelessWidget {
  const ResultPage({
    super.key,
    required this.score,
    required this.total,
    required this.level,
  });

  final int score;
  final int total;
  final String level;

  static const _levelInfo = {
    'A1': (
      label: 'Başlangıç',
      desc: 'Temel İngilizce ifadeler ve günlük konuşmalara yeni başlıyorsun.',
      color: Color(0xFF43A047),
    ),
    'A2': (
      label: 'Temel',
      desc: 'Basit cümleler kurabilir, günlük ihtiyaçlarını karşılayabilirsin.',
      color: Color(0xFF00897B),
    ),
    'B1': (
      label: 'Orta',
      desc: 'Tanıdık konularda anlaşabilir, deneyimlerini paylaşabilirsin.',
      color: Color(0xFF1E88E5),
    ),
    'B2': (
      label: 'Orta-Üst',
      desc: 'Karmaşık metinleri anlayabilir, akıcı iletişim kurabilirsin.',
      color: Color(0xFF5E35B1),
    ),
    'C1': (
      label: 'İleri',
      desc: 'Zor metinleri anlayabilir, kendini esnek ve doğal ifade edebilirsin.',
      color: Color(0xFF8E24AA),
    ),
    'C2': (
      label: 'Ustalık',
      desc: 'İngilizceyi neredeyse anadil düzeyinde kullanabilirsin.',
      color: Color(0xFFC62828),
    ),
  };

  @override
  Widget build(BuildContext context) {
    final info = _levelInfo[level] ??
        (label: 'Bilinmiyor', desc: '', color: const Color(0xFF7A3EC8));
    final percentage = ((score / total) * 100).round();

    return GestureDetector(
      onTap: () => Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainNavigationPage()),
      ),
      child: Scaffold(
        body: Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFD7C6E6), Color(0xFF8E63C7)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final maxW = constraints.maxWidth;
                final cardW = (maxW * 0.86).clamp(280.0, 420.0);

                return Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                        maxWidth: Responsive.maxContentWidth(context)),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: Responsive.horizontalPadding(context),
                        vertical: Responsive.verticalPadding(context),
                      ),
                      child: Column(
                        children: [
                          // Başlık
                          Text(
                            'LinguaAI',
                            style: TextStyle(
                              fontSize: Responsive.fontSizeTitle(context),
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: Responsive.gapLg(context)),

                          // Ana kart
                          Container(
                            width: cardW,
                            padding: EdgeInsets.all(
                                Responsive.cardPadding(context) * 1.2),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(
                                  Responsive.cardRadius(context) + 12),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.35),
                                width: 1.5,
                              ),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SvgPicture.asset(
                                  'assets/images/test_level.svg',
                                  height: (constraints.maxHeight * 0.20)
                                      .clamp(80.0, 160.0),
                                  fit: BoxFit.contain,
                                ),
                                SizedBox(height: Responsive.gapMd(context)),

                                // Seviye etiketi
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 5),
                                  decoration: BoxDecoration(
                                    color:
                                        info.color.withValues(alpha: 0.20),
                                    borderRadius: BorderRadius.circular(50),
                                    border: Border.all(
                                      color:
                                          info.color.withValues(alpha: 0.55),
                                    ),
                                  ),
                                  child: Text(
                                    info.label.toUpperCase(),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                ),
                                SizedBox(height: Responsive.gapSm(context)),

                                // Büyük seviye harfi
                                Text(
                                  level,
                                  style: TextStyle(
                                    fontSize: Responsive.scaled(
                                        context, min: 52, max: 72),
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    height: 1,
                                  ),
                                ),
                                SizedBox(height: Responsive.gapMd(context)),

                                // Skor çubuğu
                                Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Puan',
                                          style: TextStyle(
                                            color: Colors.white
                                                .withValues(alpha: 0.85),
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        Text(
                                          '$score / $total  •  %$percentage',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    ClipRRect(
                                      borderRadius:
                                          BorderRadius.circular(8),
                                      child: LinearProgressIndicator(
                                        value: score / total,
                                        minHeight: 10,
                                        backgroundColor: Colors.white
                                            .withValues(alpha: 0.25),
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                info.color),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: Responsive.gapLg(context)),

                          // Açıklama kutusu
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(
                                Responsive.cardPadding(context) * 0.9),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.92),
                              borderRadius: BorderRadius.circular(
                                  Responsive.cardRadius(context)),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  info.desc,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize:
                                        Responsive.fontSizeBody(context),
                                    color: const Color(0xFF4A148C),
                                    fontWeight: FontWeight.w500,
                                    height: 1.4,
                                  ),
                                ),
                                SizedBox(height: Responsive.gapSm(context)),
                                Text(
                                  'Profiline gitmek için ekrana dokun.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize:
                                        Responsive.fontSizeBodySmall(context),
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const Spacer(),
                          Padding(
                            padding: EdgeInsets.only(
                                bottom: Responsive.gapMd(context)),
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
  }
}
