import 'package:flutter/material.dart';
import 'after_register_page.dart';
import '../services/auth_service.dart';
import '../utils/responsive.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final headerHeight = Responsive.scaled(context, min: 150, max: 220);
    final cardPad = Responsive.cardPadding(context);
    final radius = Responsive.cardRadius(context) + 12;
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: headerHeight,
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
              alignment: Alignment.center,
              child: Text(
                "LinguaAI",
                style: TextStyle(
                  fontSize: Responsive.fontSizeTitle(context),
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
            ),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(radius)),
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: Responsive.maxContentWidth(context)),
                    child: Padding(
                      padding: EdgeInsets.all(cardPad),
                      child: ListView(
                        children: [
                          Text(
                            "Hesap Oluştur",
                            style: TextStyle(
                              fontSize: Responsive.fontSizeTitle(context),
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurple,
                            ),
                          ),
                          SizedBox(height: Responsive.gapLg(context)),
                          Text("Ad Soyad", style: TextStyle(fontSize: Responsive.fontSizeBody(context))),
                          SizedBox(height: Responsive.gapXs(context)),
                          TextField(
                            controller: _nameController,
                            decoration: InputDecoration(
                              hintText: "örn. Nihan Karaca",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(Responsive.cardRadius(context)),
                              ),
                            ),
                          ),
                          SizedBox(height: Responsive.gapMd(context)),
                          Text("E-Posta", style: TextStyle(fontSize: Responsive.fontSizeBody(context))),
                          SizedBox(height: Responsive.gapXs(context)),
                          TextField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              hintText: "örn. nihan@gmail.com",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(Responsive.cardRadius(context)),
                              ),
                            ),
                          ),
                          SizedBox(height: Responsive.gapMd(context)),
                          Text("Parola", style: TextStyle(fontSize: Responsive.fontSizeBody(context))),
                          SizedBox(height: Responsive.gapXs(context)),
                          TextField(
                            controller: _passwordController,
                            obscureText: true,
                            decoration: InputDecoration(
                              hintText: "************",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(Responsive.cardRadius(context)),
                              ),
                            ),
                          ),
                          SizedBox(height: Responsive.gapLg(context)),
                          GestureDetector(
                            onTap: () async {
                      final result = await AuthService.registerWithEmail(
                        name: _nameController.text,
                        email: _emailController.text,
                        password: _passwordController.text,
                      );

                      if (!result.success) {
                        if (!mounted) return;
                        String message;
                        switch (result.error) {
                          case RegisterError.emptyName:
                            message = 'Lütfen Ad Soyad girin.';
                            break;
                          case RegisterError.emptyEmail:
                            message = 'Lütfen e-posta adresinizi girin.';
                            break;
                          case RegisterError.weakPassword:
                            message = 'Parola en az 6 karakter olmalıdır.';
                            break;
                          default:
                            message = 'Kayıt işlemi tamamlanamadı.';
                        }
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(message)),
                        );
                        return;
                      }

                      if (!mounted) return;
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                          const AfterRegisterPage(),
                        ),
                      );
                    },
                            child: Container(
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
                                "Kaydol",
                                style: TextStyle(
                                  fontSize: Responsive.fontSizeButton(context),
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: Responsive.gapLg(context)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
