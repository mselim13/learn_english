import 'dart:async';
import 'package:flutter/material.dart';
import 'test_intro_page.dart';
import 'package:flutter_svg/flutter_svg.dart';


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
    Timer(const Duration(seconds: 5), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const TestIntroPage(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
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
          mainAxisAlignment:
          MainAxisAlignment.spaceBetween,
          children: [

            const SizedBox(height: 20),

            const Text(
              "LinguaAI",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),

            Column(
              children: [
                const Text(
                  "Aramıza Hoş Geldin!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 50,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple,
                  ),
                ),

                const SizedBox(height: 30),

                SvgPicture.asset(
                  "assets/images/after_register.svg",
                  height: 450,
                  fit: BoxFit.contain,
                ),
              ],
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
