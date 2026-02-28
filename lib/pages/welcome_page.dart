import 'package:flutter/material.dart';
import 'register_page.dart';
import 'login_page.dart';
import 'package:flutter_svg/flutter_svg.dart';



class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24),
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            const Text(
              "Hoş Geldiniz",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),

            const SizedBox(height: 16),

            const Text(
              "İngilizce öğrenmek artık çok kolay!",
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 40),

            Container(
              height: 250,
              decoration: BoxDecoration(
              ),
              child: SvgPicture.asset(
                "assets/images/welcome.svg",
                fit: BoxFit.contain,
              ),
            ),


            const SizedBox(height: 40),

            /// REGISTER BUTONU
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const RegisterPage(),
                  ),
                );
              },
              child: Container(
                width: double.infinity,
                height: 55,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white.withOpacity(0.3),
                ),
                alignment: Alignment.center,
                child: const Text(
                  "Hesap Oluştur",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const LoginPage(),
                  ),
                );
              },
              child: const Text(
                "Zaten hesabın var mı? Giriş Yap",
              ),
            ),

          ],
        ),
      ),
    );
  }
}
