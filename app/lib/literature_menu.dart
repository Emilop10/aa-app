import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:ui';
// IMPORTAMOS LA NUEVA PANTALLA DEL LECTOR EPUB
import 'libro_azul_epub_screen.dart';
import 'steps_traditions_screen.dart';

// ─── Paleta ───────────────────────────────────────────────
const _kOrange   = Color(0xFFF97316);
const _kCream    = Color(0xFFFFFBF5);
const _kTextPrim = Color(0xFF431407);
const _kDarkBg   = Color(0xFF1A0800);

class LiteratureMenu extends StatelessWidget {
  const LiteratureMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark   = Theme.of(context).brightness == Brightness.dark;
    final bgColor  = isDark ? _kDarkBg : _kCream;
    final textPrim = isDark ? Colors.white : _kTextPrim;

    return Scaffold(
      backgroundColor: bgColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 100,
            floating: false,
            pinned: true,
            stretch: true,
            backgroundColor: bgColor,
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
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
              child: Column(
                children: [
                  _buildMenuItem(
                    context: context,
                    title: 'Libro Azul',
                    imagePath: 'assets/images/big_book_bg.png',
                    targetScreen: const LibroAzulEpubScreen(),
                  ),
                  const SizedBox(height: 16),
                  _buildMenuItem(
                    context: context,
                    title: '12 Pasos / 12 Tradiciones',
                    imagePath: 'assets/images/steps_traditions_bg.png',
                    targetScreen: StepsTraditionsScreen(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required String title,
    required String imagePath,
    required Widget targetScreen,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => targetScreen),
        );
      },
      child: Container(
        height: 160,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.18),
              blurRadius: 16,
              offset: const Offset(0, 6),
              spreadRadius: -2,
            ),
          ],
          image: DecorationImage(
            image: AssetImage(imagePath),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.4),
              BlendMode.darken,
            ),
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              // Title centered
              Center(
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        offset: Offset(1, 1),
                        blurRadius: 4,
                        color: Colors.black87,
                      ),
                    ],
                  ),
                ),
              ),
              // Chevron bottom right
              Positioned(
                bottom: 14,
                right: 16,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    CupertinoIcons.chevron_right,
                    color: Colors.white,
                    size: 16,
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
