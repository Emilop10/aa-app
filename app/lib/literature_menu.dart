import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:ui';
import 'libro_azul_screen.dart';
import 'steps_traditions_screen.dart';
import 'prayers_screen.dart';
import 'app_colors.dart';

const _kCream    = Color(0xFFFFFBF5);
const _kTextPrim = Color(0xFF431407);
const _kDarkBg   = Color(0xFF1A0800);

class LiteratureMenu extends StatefulWidget {
  const LiteratureMenu({super.key});
  @override
  _LiteratureMenuState createState() => _LiteratureMenuState();
}

class _LiteratureMenuState extends State<LiteratureMenu>
    with TickerProviderStateMixin {

  late AnimationController _bgBreathController;
  late Animation<double>   _bgBreath;
  late AnimationController _entryController;
  late Animation<double>   _card1Fade;
  late Animation<Offset>   _card1Slide;
  late Animation<double>   _card2Fade;
  late Animation<Offset>   _card2Slide;
  late Animation<double>   _card3Fade;
  late Animation<Offset>   _card3Slide;

  @override
  void initState() {
    super.initState();
    _bgBreathController = AnimationController(
        vsync: this, duration: const Duration(seconds: 7))
      ..repeat(reverse: true);
    _bgBreath = Tween<double>(begin: 0.03, end: 0.09).animate(
        CurvedAnimation(parent: _bgBreathController, curve: Curves.easeInOut));

    _entryController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1100));
    _card1Fade  = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut)));
    _card1Slide = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(CurvedAnimation(
            parent: _entryController,
            curve: const Interval(0.0, 0.5, curve: Curves.easeOut)));
    _card2Fade  = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.25, 0.75, curve: Curves.easeOut)));
    _card2Slide = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero)
        .animate(CurvedAnimation(
            parent: _entryController,
            curve: const Interval(0.25, 0.75, curve: Curves.easeOut)));
    _card3Fade  = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.5, 1.0, curve: Curves.easeOut)));
    _card3Slide = Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero)
        .animate(CurvedAnimation(
            parent: _entryController,
            curve: const Interval(0.5, 1.0, curve: Curves.easeOut)));

    _entryController.forward();
  }

  @override
  void dispose() {
    _bgBreathController.dispose();
    _entryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Color>(
      valueListenable: appPrimaryColor,
      builder: (context, primary, child) {
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
                  radius: 1.2,
                  colors: [
                    primary.withOpacity(_bgBreath.value),
                    bgColor,
                  ],
                ),
              ),
              child: child,
            ),
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverAppBar(
                  expandedHeight: 100,
                  floating: false,
                  pinned: true,
                  stretch: true,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  scrolledUnderElevation: 0,
                  flexibleSpace: FlexibleSpaceBar(
                    titlePadding: const EdgeInsets.only(left: 20, bottom: 14),
                    title: Text(
                      'Literatura',
                      style: TextStyle(
                        color: textPrim,
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                      ),
                    ),
                    stretchModes: const [StretchMode.fadeTitle],
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                    child: Column(
                      children: [
                        FadeTransition(
                          opacity: _card1Fade,
                          child: SlideTransition(
                            position: _card1Slide,
                            child: _buildMenuItem(
                              context: context,
                              title: 'Libro Azul',
                              subtitle: 'Texto básico de A.A.',
                              icon: CupertinoIcons.book_fill,
                              primary: primary,
                              isDark: isDark,
                              targetScreen: const LibroAzulScreen(),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        FadeTransition(
                          opacity: _card2Fade,
                          child: SlideTransition(
                            position: _card2Slide,
                            child: _buildMenuItem(
                              context: context,
                              title: '12 Pasos y Tradiciones',
                              subtitle: 'El programa de recuperación',
                              icon: CupertinoIcons.list_number,
                              primary: primary,
                              isDark: isDark,
                              targetScreen: const StepsTraditionsScreen(),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        FadeTransition(
                          opacity: _card3Fade,
                          child: SlideTransition(
                            position: _card3Slide,
                            child: _buildMenuItem(
                              context: context,
                              title: 'Oraciones',
                              subtitle: 'Serenidad, San Francisco y más',
                              icon: CupertinoIcons.heart_fill,
                              primary: primary,
                              isDark: isDark,
                              targetScreen: const PrayersScreen(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color primary,
    required bool isDark,
    required Widget targetScreen,
  }) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => targetScreen),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 22),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withOpacity(0.06)
                  : Colors.white.withOpacity(0.72),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: isDark
                    ? Colors.white.withOpacity(0.09)
                    : Colors.white.withOpacity(0.9),
                width: 0.8,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: primary.withOpacity(0.13),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: primary, size: 24),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : _kTextPrim,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark
                              ? Colors.white38
                              : _kTextPrim.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(CupertinoIcons.chevron_right,
                    color: primary.withOpacity(0.6), size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
