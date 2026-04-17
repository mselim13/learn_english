import 'package:flutter/material.dart';
import 'register_page.dart';
import 'login_page.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../utils/responsive.dart';



class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final artHeight = Responsive.scaled(context, min: 180, max: 320);
    return Scaffold(
      body: Container(
        width: double.infinity,
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
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: Responsive.maxContentWidth(context)),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: Responsive.horizontalPadding(context)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Hoş Geldiniz",
                      style: TextStyle(
                        fontSize: Responsive.fontSizeTitle(context),
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                    SizedBox(height: Responsive.gapSm(context)),
                    Text(
                      "İngilizce öğrenmek artık çok kolay!",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: Responsive.fontSizeBody(context)),
                    ),
                    SizedBox(height: Responsive.gapXl(context)),
                    SizedBox(
                      height: artHeight,
                      child: SvgPicture.asset(
                        "assets/images/welcome.svg",
                        fit: BoxFit.contain,
                      ),
                    ),
                    SizedBox(height: Responsive.gapXl(context)),
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
                        height: Responsive.minTouchTarget(context),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(Responsive.cardRadius(context) + 2),
                          color: Colors.white.withOpacity(0.3),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          "Hesap Oluştur",
                          style: TextStyle(
                            fontSize: Responsive.fontSizeButton(context),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: Responsive.gapMd(context)),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const LoginPage(),
                          ),
                        );
                      },
                      child: Text(
                        "Zaten hesabın var mı? Giriş Yap",
                        style: TextStyle(fontSize: Responsive.fontSizeBodySmall(context)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
