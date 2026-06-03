import 'dart:convert';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_colors.dart';

const _kCream   = Color(0xFFFFFBF5);
const _kDarkBg  = Color(0xFF1A1A1A);
const _kSepia   = Color(0xFFF8F0E3);

// ─── Modelo ──────────────────────────────────────────────────────────────────
class _Chapter {
  final String title;
  final String content;
  const _Chapter({required this.title, required this.content});
}

// ─── Pantalla principal ───────────────────────────────────────────────────────
class LibroAzulScreen extends StatefulWidget {
  const LibroAzulScreen({super.key});
  @override
  _LibroAzulScreenState createState() => _LibroAzulScreenState();
}

class _LibroAzulScreenState extends State<LibroAzulScreen>
    with TickerProviderStateMixin {

  List<_Chapter> _chapters = [];
  int _currentChapter = 0;
  bool _loading = true;

  // UI state
  bool _showBars   = true;
  bool _showIndex  = false;
  double _fontSize = 17.0;
  int _theme = 0; // 0=auto 1=sepia 2=dark

  // Scroll
  final ScrollController _scrollController = ScrollController();

  // Animations
  late AnimationController _barsAnim;
  late Animation<double>   _barsFade;
  late AnimationController _indexAnim;
  late Animation<Offset>   _indexSlide;
  late Animation<double>   _indexFade;

  // Progress
  double _readProgress = 0.0;

  @override
  void initState() {
    super.initState();

    _barsAnim = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 200));
    _barsFade = CurvedAnimation(parent: _barsAnim, curve: Curves.easeInOut);
    _barsAnim.value = 1.0;

    _indexAnim = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 280));
    _indexSlide = Tween<Offset>(
            begin: const Offset(-1.0, 0), end: Offset.zero)
        .animate(CurvedAnimation(parent: _indexAnim, curve: Curves.easeOut));
    _indexFade = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _indexAnim, curve: Curves.easeOut));

    _scrollController.addListener(_onScroll);
    _loadContent();
  }

  @override
  void dispose() {
    _barsAnim.dispose();
    _indexAnim.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.hasClients) {
      final max = _scrollController.position.maxScrollExtent;
      if (max > 0) {
        setState(() {
          _readProgress = _scrollController.offset / max;
        });
      }
    }
  }

  Future<void> _loadContent() async {
    final jsonStr =
        await rootBundle.loadString('assets/libro_azul_content.json');
    final List<dynamic> raw = json.decode(jsonStr);
    final prefs = await SharedPreferences.getInstance();
    final savedChapter = prefs.getInt('libro_azul_chapter') ?? 0;
    final savedFontSize = prefs.getDouble('libro_azul_fontsize') ?? 17.0;

    setState(() {
      _chapters = raw
          .map((e) => _Chapter(
                title: e['title'] as String,
                content: e['content'] as String,
              ))
          .where((c) => c.content.length > 10)
          .toList();
      _currentChapter = savedChapter.clamp(0, _chapters.length - 1);
      _fontSize       = savedFontSize;
      _loading        = false;
    });
  }

  Future<void> _saveState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('libro_azul_chapter', _currentChapter);
    await prefs.setDouble('libro_azul_fontsize', _fontSize);
  }

  void _goToChapter(int index) {
    setState(() {
      _currentChapter = index;
      _readProgress   = 0;
    });
    _saveState();
    _scrollController.jumpTo(0);
    _closeIndex();
  }

  void _toggleBars() {
    setState(() => _showBars = !_showBars);
    if (_showBars) {
      _barsAnim.forward();
    } else {
      _barsAnim.reverse();
      if (_showIndex) _closeIndex();
    }
  }

  void _openIndex() {
    setState(() => _showIndex = true);
    _indexAnim.forward();
  }

  void _closeIndex() {
    _indexAnim.reverse().then((_) {
      if (mounted) setState(() => _showIndex = false);
    });
  }

  void _changeFontSize(double delta) {
    setState(() {
      _fontSize = (_fontSize + delta).clamp(13.0, 26.0);
    });
    _saveState();
  }

  // ─── Colores según tema de lectura ───────────────────────────────────────
  Color _bg(bool systemDark) {
    if (_theme == 1) return _kSepia;
    if (_theme == 2) return _kDarkBg;
    return systemDark ? _kDarkBg : _kCream;
  }

  Color _textColor(bool systemDark) {
    if (_theme == 1) return const Color(0xFF3B2A1A);
    if (_theme == 2) return const Color(0xFFE8E0D5);
    return systemDark ? const Color(0xFFE8E0D5) : const Color(0xFF1C1C1E);
  }

  bool get _isDarkReading =>
      _theme == 2 || (_theme == 0 && false); // handled below

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Color>(
      valueListenable: appPrimaryColor,
      builder: (context, primary, _) {
        final systemDark = Theme.of(context).brightness == Brightness.dark;
        final isDark     = _theme == 2 || (_theme == 0 && systemDark);
        final bg         = _bg(systemDark);
        final textColor  = _textColor(systemDark);

        return Scaffold(
          backgroundColor: bg,
          body: _loading ? _buildLoading(primary, bg) : _buildReader(
            context, primary, isDark, bg, textColor,
          ),
        );
      },
    );
  }

  // ─── Loading ──────────────────────────────────────────────────────────────
  Widget _buildLoading(Color primary, Color bg) {
    return Container(
      color: bg,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CupertinoActivityIndicator(radius: 16, color: primary),
            const SizedBox(height: 16),
            const Text('Cargando libro...',
                style: TextStyle(fontSize: 15, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  // ─── Reader principal ──────────────────────────────────────────────────────
  Widget _buildReader(BuildContext context, Color primary, bool isDark,
      Color bg, Color textColor) {
    final chapter = _chapters[_currentChapter];

    return Stack(
      children: [
        // ── Contenido ──────────────────────────────────────────────────
        GestureDetector(
          onTap: () {
            if (_showIndex) {
              _closeIndex();
            } else {
              _toggleBars();
            }
          },
          child: SingleChildScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 72,
              bottom: MediaQuery.of(context).padding.bottom + 100,
              left: 24,
              right: 24,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Título del capítulo
                Text(
                  chapter.title,
                  style: TextStyle(
                    fontSize: _fontSize + 6,
                    fontWeight: FontWeight.w700,
                    color: primary,
                    height: 1.3,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                // Línea decorativa
                Container(
                  width: 48,
                  height: 3,
                  decoration: BoxDecoration(
                    color: primary.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 28),
                // Texto seleccionable
                SelectableText(
                  chapter.content,
                  style: TextStyle(
                    fontSize: _fontSize,
                    height: 1.75,
                    color: textColor,
                    letterSpacing: 0.1,
                    fontFamily: 'Times New Roman',
                  ),
                ),
              ],
            ),
          ),
        ),

        // ── Barra superior ────────────────────────────────────────────
        FadeTransition(
          opacity: _barsFade,
          child: Align(
            alignment: Alignment.topCenter,
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                child: Container(
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top + 4,
                    bottom: 10,
                    left: 4,
                    right: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.black.withOpacity(0.65)
                        : Colors.white.withOpacity(0.85),
                    border: Border(
                      bottom: BorderSide(
                        color: isDark
                            ? Colors.white.withOpacity(0.08)
                            : Colors.black.withOpacity(0.07),
                        width: 0.5,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      // Regresar
                      CupertinoButton(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        onPressed: () => Navigator.pop(context),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(CupertinoIcons.chevron_left,
                                color: primary, size: 18),
                            const SizedBox(width: 2),
                            Text('Literatura',
                                style: TextStyle(color: primary, fontSize: 16)),
                          ],
                        ),
                      ),

                      const Spacer(),

                      // Título corto
                      Text(
                        'Libro Azul',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                      ),

                      const Spacer(),

                      // Índice
                      CupertinoButton(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        onPressed: _showIndex ? _closeIndex : _openIndex,
                        child: Icon(CupertinoIcons.list_bullet,
                            color: primary, size: 22),
                      ),

                      // Opciones (fuente + tema)
                      CupertinoButton(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        onPressed: () =>
                            _showReaderOptions(context, primary, isDark),
                        child: Icon(CupertinoIcons.textformat,
                            color: primary, size: 22),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),

        // ── Barra inferior ────────────────────────────────────────────
        FadeTransition(
          opacity: _barsFade,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                child: Container(
                  padding: EdgeInsets.only(
                    top: 10,
                    bottom: MediaQuery.of(context).padding.bottom + 10,
                    left: 20,
                    right: 20,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.black.withOpacity(0.65)
                        : Colors.white.withOpacity(0.85),
                    border: Border(
                      top: BorderSide(
                        color: isDark
                            ? Colors.white.withOpacity(0.08)
                            : Colors.black.withOpacity(0.07),
                        width: 0.5,
                      ),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Progreso de lectura
                      ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: LinearProgressIndicator(
                          value: _readProgress,
                          backgroundColor: isDark
                              ? Colors.white.withOpacity(0.1)
                              : Colors.black.withOpacity(0.08),
                          valueColor:
                              AlwaysStoppedAnimation<Color>(primary),
                          minHeight: 3,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Capítulo anterior
                          CupertinoButton(
                            padding: EdgeInsets.zero,
                            onPressed: _currentChapter > 0
                                ? () => _goToChapter(_currentChapter - 1)
                                : null,
                            child: Icon(
                              CupertinoIcons.chevron_left,
                              color: _currentChapter > 0
                                  ? primary
                                  : Colors.grey.withOpacity(0.3),
                              size: 22,
                            ),
                          ),

                          // Nombre del capítulo actual
                          Expanded(
                            child: Text(
                              chapter.title,
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark
                                    ? Colors.white54
                                    : Colors.black45,
                              ),
                            ),
                          ),

                          // Capítulo siguiente
                          CupertinoButton(
                            padding: EdgeInsets.zero,
                            onPressed:
                                _currentChapter < _chapters.length - 1
                                    ? () =>
                                        _goToChapter(_currentChapter + 1)
                                    : null,
                            child: Icon(
                              CupertinoIcons.chevron_right,
                              color: _currentChapter < _chapters.length - 1
                                  ? primary
                                  : Colors.grey.withOpacity(0.3),
                              size: 22,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),

        // ── Panel de índice (desliza desde la izquierda) ──────────────
        if (_showIndex)
          FadeTransition(
            opacity: _indexFade,
            child: GestureDetector(
              onTap: _closeIndex,
              child: Container(color: Colors.black.withOpacity(0.4)),
            ),
          ),
        if (_showIndex)
          SlideTransition(
            position: _indexSlide,
            child: Align(
              alignment: Alignment.centerLeft,
              child: _buildIndexPanel(primary, isDark, textColor),
            ),
          ),
      ],
    );
  }

  // ─── Panel de índice ──────────────────────────────────────────────────────
  Widget _buildIndexPanel(Color primary, bool isDark, Color textColor) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topRight: Radius.circular(24),
        bottomRight: Radius.circular(24),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.78,
          height: double.infinity,
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF1C1C1E).withOpacity(0.96)
                : Colors.white.withOpacity(0.96),
            border: Border(
              right: BorderSide(
                color: isDark
                    ? Colors.white.withOpacity(0.08)
                    : Colors.black.withOpacity(0.07),
                width: 0.5,
              ),
            ),
          ),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                  child: Row(
                    children: [
                      Icon(CupertinoIcons.book_fill,
                          color: primary, size: 22),
                      const SizedBox(width: 10),
                      Text(
                        'Índice',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: textColor,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const Spacer(),
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: _closeIndex,
                        child: Icon(CupertinoIcons.xmark_circle_fill,
                            color: isDark
                                ? Colors.white38
                                : Colors.black26,
                            size: 26),
                      ),
                    ],
                  ),
                ),

                // Divider
                Container(
                  height: 0.5,
                  color: isDark
                      ? Colors.white.withOpacity(0.08)
                      : Colors.black.withOpacity(0.07),
                ),

                // Lista de capítulos
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    physics: const BouncingScrollPhysics(),
                    itemCount: _chapters.length,
                    itemBuilder: (context, i) {
                      final isActive = i == _currentChapter;
                      return GestureDetector(
                        onTap: () => _goToChapter(i),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          margin: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 2),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: isActive
                                ? primary.withOpacity(0.12)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              // Número
                              Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: isActive
                                      ? primary
                                      : (isDark
                                          ? Colors.white.withOpacity(0.08)
                                          : Colors.black.withOpacity(0.06)),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    '${i + 1}',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: isActive
                                          ? Colors.white
                                          : (isDark
                                              ? Colors.white54
                                              : Colors.black45),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Título
                              Expanded(
                                child: Text(
                                  _chapters[i].title,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: isActive
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                    color: isActive
                                        ? primary
                                        : textColor,
                                    height: 1.3,
                                  ),
                                ),
                              ),
                              if (isActive)
                                Icon(CupertinoIcons.checkmark,
                                    color: primary, size: 14),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── Modal opciones de lectura ────────────────────────────────────────────
  void _showReaderOptions(BuildContext context, Color primary, bool isDark) {
    showCupertinoModalPopup(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Container(
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF1C1C1E)
                : CupertinoColors.systemBackground,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 36),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.black12,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // ── Tamaño de fuente ────────────────────────────────
              Row(
                children: [
                  Text(
                    'A',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.white60 : Colors.black45,
                      decoration: TextDecoration.none,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        color: isDark
                            ? Colors.white.withOpacity(0.06)
                            : Colors.black.withOpacity(0.05),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            CupertinoButton(
                              padding: const EdgeInsets.all(14),
                              onPressed: () {
                                _changeFontSize(-1);
                                setModalState(() {});
                              },
                              child: Icon(CupertinoIcons.minus,
                                  color: primary, size: 20),
                            ),
                            Text(
                              '${_fontSize.toInt()}pt',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                decoration: TextDecoration.none,
                                color: isDark ? Colors.white : Colors.black,
                              ),
                            ),
                            CupertinoButton(
                              padding: const EdgeInsets.all(14),
                              onPressed: () {
                                _changeFontSize(1);
                                setModalState(() {});
                              },
                              child: Icon(CupertinoIcons.plus,
                                  color: primary, size: 20),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'A',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white60 : Colors.black45,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // ── Tema de fondo ────────────────────────────────────
              Row(
                children: [
                  _themeBtn(0, 'Auto', _kCream, Colors.black87,
                      primary, setModalState),
                  const SizedBox(width: 10),
                  _themeBtn(1, 'Sepia', _kSepia, const Color(0xFF3B2A1A),
                      primary, setModalState),
                  const SizedBox(width: 10),
                  _themeBtn(2, 'Noche', _kDarkBg,
                      const Color(0xFFE8E0D5), primary, setModalState),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _themeBtn(int index, String label, Color bg, Color fg,
      Color primary, StateSetter setModalState) {
    final isSelected = _theme == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() => _theme = index);
          setModalState(() {});
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: 64,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? primary : Colors.transparent,
              width: 2.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Aa',
                style: TextStyle(
                  color: fg,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.none,
                  fontFamily: 'Times New Roman',
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  color: fg.withOpacity(0.6),
                  fontSize: 11,
                  decoration: TextDecoration.none,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
