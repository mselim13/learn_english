import 'package:flutter/material.dart';
import 'package:learn_english/navigation/main_navigation_page.dart';
import 'package:learn_english/services/app_prefs.dart';
import 'package:learn_english/services/auth_service.dart';
import '../utils/responsive.dart';
import 'forgot_password_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _rememberMe = false;
  bool _loading = false;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSavedEmail();
  }

  Future<void> _loadSavedEmail() async {
    final email = await AppPrefs.getSavedEmail();
    final remember = await AppPrefs.getRememberMe();
    if (mounted) {
      setState(() {
        _rememberMe = remember;
        if (email != null) _emailController.text = email;
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _onLogin() async {
    if (_loading) return;
    setState(() => _loading = true);

    final result = await AuthService.loginWithEmail(
      email: _emailController.text,
      password: _passwordController.text,
      rememberMe: _rememberMe,
    );

    if (!mounted) return;
    setState(() => _loading = false);

    if (!result.success) {
      final message = switch (result.error) {
        LoginError.emptyEmail => 'Lütfen e-posta adresinizi girin.',
        LoginError.emptyPassword => 'Lütfen parolanızı girin.',
        LoginError.invalidCredentials => 'E-posta veya parola hatalı.',
        LoginError.networkError =>
          'Sunucuya bağlanılamadı. İnternet bağlantınızı kontrol edin.',
        _ => 'Giriş yapılamadı.',
      };
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const MainNavigationPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final headerHeight = Responsive.scaled(context, min: 160, max: 240);
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
                  colors: [Color(0xFFD7C4EA), Color(0xFF7A3EC8)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                'LinguaAI',
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
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(radius)),
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                        maxWidth: Responsive.maxContentWidth(context)),
                    child: Padding(
                      padding: EdgeInsets.all(cardPad),
                      child: ListView(
                        children: [
                          Text(
                            'Giriş Yap',
                            style: TextStyle(
                              fontSize: Responsive.fontSizeTitle(context),
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurple,
                            ),
                          ),
                          SizedBox(height: Responsive.gapLg(context)),
                          Text('E-Posta',
                              style: TextStyle(
                                  fontSize: Responsive.fontSizeBody(context))),
                          SizedBox(height: Responsive.gapXs(context)),
                          TextField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              hintText: 'örn. nihan@gmail.com',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                    Responsive.cardRadius(context)),
                              ),
                            ),
                          ),
                          SizedBox(height: Responsive.gapMd(context)),
                          Text('Parola',
                              style: TextStyle(
                                  fontSize: Responsive.fontSizeBody(context))),
                          SizedBox(height: Responsive.gapXs(context)),
                          TextField(
                            controller: _passwordController,
                            obscureText: true,
                            decoration: InputDecoration(
                              hintText: '••••••••',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                    Responsive.cardRadius(context)),
                              ),
                            ),
                          ),
                          SizedBox(height: Responsive.gapSm(context)),
                          Row(
                            children: [
                              Checkbox(
                                value: _rememberMe,
                                onChanged: (v) =>
                                    setState(() => _rememberMe = v ?? false),
                                activeColor: Colors.deepPurple,
                              ),
                              Text(
                                'Beni hatırla',
                                style: TextStyle(
                                    fontSize:
                                        Responsive.fontSizeBodySmall(context)),
                              ),
                            ],
                          ),
                          SizedBox(height: Responsive.gapMd(context)),
                          GestureDetector(
                            onTap: _loading ? null : _onLogin,
                            child: Container(
                              height: Responsive.minTouchTarget(context),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                    Responsive.cardRadius(context)),
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFD7C4EA),
                                    Color(0xFF7A3EC8)
                                  ],
                                ),
                              ),
                              child: _loading
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                          color: Colors.white, strokeWidth: 2),
                                    )
                                  : Text(
                                      'Giriş Yap',
                                      style: TextStyle(
                                        fontSize:
                                            Responsive.fontSizeButton(context),
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),
                          SizedBox(height: Responsive.gapSm(context)),
                          Center(
                            child: GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const ForgotPasswordPage()),
                              ),
                              child: Text(
                                'Parolanı mı unuttun?',
                                style: TextStyle(
                                  color: Colors.deepPurple,
                                  fontWeight: FontWeight.w500,
                                  fontSize:
                                      Responsive.fontSizeBodySmall(context),
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
