import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:ui';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_colors.dart';

const _kCream    = Color(0xFFFFFBF5);
const _kTextPrim = Color(0xFF431407);
const _kDarkBg   = Color(0xFF1A0800);

class _OnboardPage {
  final IconData icon;
  final String   title;
  final String   body;
  const _OnboardPage(this.icon, this.title, this.body);
}

const _pages = [
  _OnboardPage(
    CupertinoIcons.heart_fill,
    'Bienvenido',
    'Esta app es un compañero discreto para tu camino en A.A. '
    'Diseñada para ayudarte a mantenerte enfocado en tu recuperación, '
    'un día a la vez.',
  ),
  _OnboardPage(
    CupertinoIcons.calendar_today,
    'Tu Contador de Sobriedad',
    'Registra tu fecha de inicio y lleva el conteo exacto de tus días, '
    'meses y años de sobriedad. Tu progreso siempre visible, '
    'un recordatorio constante de tu fortaleza.',
  ),
  _OnboardPage(
    CupertinoIcons.sun_max_fill,
    'Reflexión Diaria',
    'Cada día encontrarás una lectura de reflexión para meditar. '
    'Puedes explorar cualquier fecha del año usando el calendario '
    'y compartir la reflexión con quien quieras.',
  ),
  _OnboardPage(
    CupertinoIcons.book_fill,
    'Literatura de A.A.',
    'Accede al Libro Azul, los 12 Pasos y Tradiciones, Las Promesas, '
    'Cómo Funciona, Oraciones, el Glosario y más — '
    'todo con lector personalizable y modo noche.',
  ),
  _OnboardPage(
    CupertinoIcons.pencil_outline,
    'Escritura',
    'Escribe en tu Diario personal o en el Diario de Gratitud. '
    'La escritura es una herramienta poderosa para el autoconocimiento '
    'y para cultivar la serenidad en tu camino.',
  ),
  _OnboardPage(
    CupertinoIcons.person_2_fill,
    'Contactos de Apoyo',
    'Guarda a tu padrino, madrina y personas de confianza. '
    'Llámalos o mándales mensaje con un solo toque, '
    'justo cuando más lo necesitas.',
  ),
];

class OnboardingScreen extends StatefulWidget {
  final Widget nextScreen;
  final bool isReplay;

  const OnboardingScreen({
    super.key,
    required this.nextScreen,
    this.isReplay = false,
  });

  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {

  final PageController _pageController = PageController();
  int _currentPage = 0;

  late AnimationController _bgBreathController;
  late Animation<double>   _bgBreath;

  @override
  void initState() {
    super.initState();
    _bgBreathController = AnimationController(
        vsync: this, duration: const Duration(seconds: 6))
      ..repeat(reverse: true);
    _bgBreath = Tween<double>(begin: 0.04, end: 0.11).animate(
        CurvedAnimation(parent: _bgBreathController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _pageController.dispose();
    _bgBreathController.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    if (!widget.isReplay) {
      final p = await SharedPreferences.getInstance();
      await p.setBool('onboarding_done', true);
    }
    if (!mounted) return;
    if (widget.isReplay) {
      Navigator.of(context).pop();
    } else {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => widget.nextScreen,
          transitionsBuilder: (_, anim, __, child) =>
              FadeTransition(opacity: anim, child: child),
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    }
  }

  void _next() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _finish();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Color>(
      valueListenable: appPrimaryColor,
      builder: (context, primary, _) {
        final isDark   = Theme.of(context).brightness == Brightness.dark;
        final bgColor  = isDark ? _kDarkBg : _kCream;
        final textPrim = isDark ? Colors.white : _kTextPrim;

        return Scaffold(
          backgroundColor: bgColor,
          body: AnimatedBuilder(
            animation: _bgBreath,
            builder: (context, child) => Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.topCenter,
                  radius: 1.3,
                  colors: [primary.withOpacity(_bgBreath.value), bgColor],
                ),
              ),
              child: child,
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // Top bar
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Back button when replaying
                        if (widget.isReplay)
                          CupertinoButton(
                            padding: const EdgeInsets.all(8),
                            onPressed: () => Navigator.pop(context),
                            child: Icon(CupertinoIcons.xmark,
                                color: textPrim.withOpacity(0.4), size: 20),
                          )
                        else
                          const SizedBox(width: 60),
                        // Page counter
                        Text(
                          '${_currentPage + 1} / ${_pages.length}',
                          style: TextStyle(
                            fontSize: 13,
                            color: textPrim.withOpacity(0.35),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        // Skip button
                        CupertinoButton(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          onPressed: _finish,
                          child: Text(
                            _currentPage == _pages.length - 1
                                ? '      '
                                : 'Saltar',
                            style: TextStyle(
                              color: textPrim.withOpacity(0.4),
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Pages
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: _pages.length,
                      onPageChanged: (i) =>
                          setState(() => _currentPage = i),
                      itemBuilder: (ctx, i) =>
                          _buildPage(_pages[i], primary, isDark, textPrim),
                    ),
                  ),

                  // Dots + button
                  Padding(
                    padding: const EdgeInsets.fromLTRB(32, 0, 32, 40),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(_pages.length, (i) {
                            final active = i == _currentPage;
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 3),
                              width: active ? 22 : 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: active
                                    ? primary
                                    : primary.withOpacity(0.22),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            );
                          }),
                        ),
                        const SizedBox(height: 28),
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: CupertinoButton(
                            padding: EdgeInsets.zero,
                            color: primary,
                            borderRadius: BorderRadius.circular(16),
                            onPressed: _next,
                            child: Text(
                              _currentPage == _pages.length - 1
                                  ? (widget.isReplay ? 'Cerrar' : 'Empezar')
                                  : 'Siguiente',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPage(
      _OnboardPage page, Color primary, bool isDark, Color textPrim) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withOpacity(0.07)
                      : Colors.white.withOpacity(0.75),
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withOpacity(0.1)
                        : Colors.white.withOpacity(0.9),
                    width: 0.8,
                  ),
                ),
                child: Icon(page.icon, color: primary, size: 48),
              ),
            ),
          ),
          const SizedBox(height: 36),
          Text(
            page.title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: textPrim,
              letterSpacing: -0.5,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            page.body,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: textPrim.withOpacity(0.58),
              height: 1.65,
            ),
          ),
        ],
      ),
    );
  }
}
