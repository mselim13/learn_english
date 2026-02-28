import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:learn_english/pages/result_page.dart';

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
          child: Column(
            children: [
              const Spacer(flex: 1),

              /// Uygulama Başlığı
              const Text(
                "LinguaAI",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF8E63C7), // Görseldeki mor tonu
                ),
              ),

              const SizedBox(height: 20),

              /// Orta Görsel
              SvgPicture.asset(
                "assets/images/see_result.svg",
                height: 250,
                fit: BoxFit.contain,
              ),

              const SizedBox(height: 40),

              const Spacer(flex: 1),

              /// Bilgi Kartı
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Column(
                    children: [
                      Text(
                        "Testi başarıyla tamamladın!",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "Sonucunda İngilizce seviyeni tespit ettik.",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 20),
                      Text(
                        "Sonucu görmek için tıkla!",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),

              const Spacer(flex: 1),

              /// Alt Buton
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 85),
                child: GestureDetector(
                  onTap: () {
                    Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const ResultPage()),
                    );
                  },
                  child: Container(
                    height: 60,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFFC7B1E6), // Açık mor
                          Color(0xFF7B44C6), // Koyu mor
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: const Text(
                      "SONUCUMU GÖR",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}