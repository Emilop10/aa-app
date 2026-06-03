import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'app_colors.dart';

const _kCream   = Color(0xFFFFFBF5);
const _kDarkBg  = Color(0xFF1A0800);
const _kTextPrim = Color(0xFF431407);

class StepsTraditionsScreen extends StatefulWidget {
  const StepsTraditionsScreen({super.key});
  @override
  _StepsTraditionsScreenState createState() => _StepsTraditionsScreenState();
}

class _StepsTraditionsScreenState extends State<StepsTraditionsScreen>
    with TickerProviderStateMixin {

  late AnimationController _bgBreathController;
  late Animation<double> _bgBreath;
  late AnimationController _entryController;
  late Animation<double> _card1Fade;
  late Animation<Offset> _card1Slide;
  late Animation<double> _card2Fade;
  late Animation<Offset> _card2Slide;

  bool _openingPasos = false;
  bool _openingTradiciones = false;

  @override
  void initState() {
    super.initState();
    _bgBreathController = AnimationController(
        vsync: this, duration: const Duration(seconds: 7))
      ..repeat(reverse: true);
    _bgBreath = Tween<double>(begin: 0.03, end: 0.09).animate(
        CurvedAnimation(parent: _bgBreathController, curve: Curves.easeInOut));

    _entryController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 950));
    _card1Fade  = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.0, 0.55, curve: Curves.easeOut)));
    _card1Slide = Tween<Offset>(
            begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(CurvedAnimation(
            parent: _entryController,
            curve: const Interval(0.0, 0.55, curve: Curves.easeOut)));
    _card2Fade  = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.35, 1.0, curve: Curves.easeOut)));
    _card2Slide = Tween<Offset>(
            begin: const Offset(0, 0.1), end: Offset.zero)
        .animate(CurvedAnimation(
            parent: _entryController,
            curve: const Interval(0.35, 1.0, curve: Curves.easeOut)));

    _entryController.forward();
  }

  @override
  void dispose() {
    _bgBreathController.dispose();
    _entryController.dispose();
    super.dispose();
  }

  Future<void> _openPdf(String assetPath, String title,
      {required bool isPasos}) async {
    if (isPasos) {
      setState(() => _openingPasos = true);
    } else {
      setState(() => _openingTradiciones = true);
    }

    try {
      final dir  = await getTemporaryDirectory();
      final fileName = assetPath.split('/').last;
      final file = File('${dir.path}/$fileName');

      if (!await file.exists()) {
        final data = await rootBundle.load(assetPath);
        await file.writeAsBytes(
            data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
      }

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (ctx) => _PdfViewerScreen(
              filePath: file.path,
              title: title,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) _showError('Error al abrir el PDF.');
    } finally {
      if (mounted) {
        setState(() {
          _openingPasos       = false;
          _openingTradiciones = false;
        });
      }
    }
  }

  void _showError(String msg) {
    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('Error'),
        content: Text(msg),
        actions: [
          CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () => Navigator.pop(ctx),
              child: const Text('OK')),
        ],
      ),
    );
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
                  leading: CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => Navigator.pop(context),
                    child: Icon(CupertinoIcons.chevron_left, color: primary),
                  ),
                  flexibleSpace: FlexibleSpaceBar(
                    titlePadding: const EdgeInsets.only(left: 20, bottom: 14),
                    title: Text(
                      '12 Pasos y Tradiciones',
                      style: TextStyle(
                        color: textPrim,
                        fontSize: 22,
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
                            child: _buildCard(
                              context: context,
                              title: '12 Pasos',
                              subtitle: 'El camino hacia la recuperación',
                              icon: CupertinoIcons.list_number,
                              primary: primary,
                              isDark: isDark,
                              isLoading: _openingPasos,
                              onTap: () => _openPdf(
                                  'assets/12_pasos.pdf', '12 Pasos',
                                  isPasos: true),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        FadeTransition(
                          opacity: _card2Fade,
                          child: SlideTransition(
                            position: _card2Slide,
                            child: _buildCard(
                              context: context,
                              title: '12 Tradiciones',
                              subtitle: 'Los principios que nos unen',
                              icon: CupertinoIcons.rays,
                              primary: primary,
                              isDark: isDark,
                              isLoading: _openingTradiciones,
                              onTap: () => _openPdf(
                                  'assets/12_tradiciones.pdf',
                                  '12 Tradiciones',
                                  isPasos: false),
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

  Widget _buildCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color primary,
    required bool isDark,
    required bool isLoading,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withOpacity(0.06)
                  : Colors.white.withOpacity(0.75),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isDark
                    ? Colors.white.withOpacity(0.1)
                    : Colors.white.withOpacity(0.8),
                width: 0.8,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: primary.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: primary, size: 26),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : _kTextPrim,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? Colors.white38 : _kTextPrim.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                isLoading
                    ? CupertinoActivityIndicator(color: primary)
                    : Icon(CupertinoIcons.arrow_up_right_square,
                        color: primary, size: 22),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Pantalla de visor PDF ────────────────────────────────────────────────────

class _PdfViewerScreen extends StatefulWidget {
  final String filePath;
  final String title;
  const _PdfViewerScreen({required this.filePath, required this.title});

  @override
  _PdfViewerScreenState createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<_PdfViewerScreen> {
  int _currentPage = 0;
  int _totalPages  = 0;
  bool _isReady    = false;
  PDFViewController? _controller;

  @override
  Widget build(BuildContext context) {
    final primary = appPrimaryColor.value;
    final isDark  = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        elevation: 0,
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => Navigator.pop(context),
          child: Icon(CupertinoIcons.chevron_left, color: primary),
        ),
        title: Text(
          widget.title,
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF431407),
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        actions: [
          if (_totalPages > 0)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Text(
                  '${_currentPage + 1} / $_totalPages',
                  style: TextStyle(
                    color: isDark ? Colors.white54 : Colors.black45,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: Stack(
        children: [
          PDFView(
            filePath: widget.filePath,
            enableSwipe: true,
            swipeHorizontal: false,
            autoSpacing: true,
            pageFling: true,
            pageSnap: true,
            fitEachPage: true,
            nightMode: isDark,
            onRender: (pages) {
              setState(() {
                _totalPages = pages ?? 0;
                _isReady    = true;
              });
            },
            onPageChanged: (page, total) {
              setState(() {
                _currentPage = page ?? 0;
                _totalPages  = total ?? 0;
              });
            },
            onViewCreated: (ctrl) {
              _controller = ctrl;
            },
            onError: (e) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e')),
                );
              }
            },
          ),
          if (!_isReady)
            Center(
              child: CupertinoActivityIndicator(color: primary, radius: 14),
            ),
        ],
      ),
    );
  }
}
