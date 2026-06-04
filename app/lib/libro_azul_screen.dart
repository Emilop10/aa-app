import 'dart:convert';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_colors.dart';

const _kCream  = Color(0xFFFFFBF5);
const _kDarkBg = Color(0xFF1A1A1A);
const _kSepia  = Color(0xFFF8F0E3);

// ─── Modelos ──────────────────────────────────────────────────────────────────
class _Chapter {
  final String title;
  final String content;
  const _Chapter({required this.title, required this.content});
}

class _Highlight {
  final int start;
  final int end;
  const _Highlight({required this.start, required this.end});

  Map<String, dynamic> toJson() => {'s': start, 'e': end};
  factory _Highlight.fromJson(Map<String, dynamic> j) =>
      _Highlight(start: j['s'] as int, end: j['e'] as int);

  String snippet(String text) {
    final s = start.clamp(0, text.length);
    final e = end.clamp(s, text.length);
    final raw = text.substring(s, e).replaceAll('\n', ' ').trim();
    return raw.length > 80 ? '${raw.substring(0, 80)}…' : raw;
  }
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
  int  _currentChapter = 0;
  bool _loading = true;

  // UI state
  bool   _showBars  = true;
  bool   _showIndex = false;
  bool   _showHighlightsPanel = false;
  double _fontSize  = 17.0;
  int    _theme     = 0; // 0=auto 1=sepia 2=dark

  // Selección actual (para subrayar)
  TextSelection _lastSelection = const TextSelection.collapsed(offset: 0);

  // Subrayados por capítulo: clave = índice capítulo
  final Map<int, List<_Highlight>> _highlights = {};

  final ScrollController _scrollController = ScrollController();
  double _readProgress = 0.0;

  // Animaciones
  late AnimationController _barsAnim;
  late Animation<double>   _barsFade;
  late AnimationController _indexAnim;
  late Animation<Offset>   _indexSlide;
  late Animation<double>   _indexFade;

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

    _scrollController.addListener(() {
      if (_scrollController.hasClients) {
        final max = _scrollController.position.maxScrollExtent;
        if (max > 0) setState(() => _readProgress = _scrollController.offset / max);
      }
    });

    _loadAll();
  }

  @override
  void dispose() {
    _barsAnim.dispose();
    _indexAnim.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ─── Carga ────────────────────────────────────────────────────────────────
  Future<void> _loadAll() async {
    final jsonStr = await rootBundle.loadString('assets/libro_azul_content.json');
    final List<dynamic> raw = json.decode(jsonStr);
    final prefs = await SharedPreferences.getInstance();

    final savedChapter  = prefs.getInt('libro_azul_chapter') ?? 0;
    final savedFontSize = prefs.getDouble('libro_azul_fontsize') ?? 17.0;

    final chapters = raw
        .map((e) => _Chapter(
              title:   e['title'] as String,
              content: e['content'] as String,
            ))
        .where((c) => c.content.length > 10)
        .toList();

    // Cargar subrayados guardados
    final Map<int, List<_Highlight>> loaded = {};
    for (int i = 0; i < chapters.length; i++) {
      final raw2 = prefs.getString('libro_hl_$i');
      if (raw2 != null) {
        final List<dynamic> list = json.decode(raw2);
        loaded[i] = list.map((e) => _Highlight.fromJson(e as Map<String, dynamic>)).toList();
      }
    }

    setState(() {
      _chapters       = chapters;
      _currentChapter = savedChapter.clamp(0, chapters.length - 1);
      _fontSize       = savedFontSize;
      _highlights.addAll(loaded);
      _loading        = false;
    });
  }

  Future<void> _saveState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('libro_azul_chapter', _currentChapter);
    await prefs.setDouble('libro_azul_fontsize', _fontSize);
  }

  Future<void> _saveHighlights(int chapterIdx) async {
    final prefs = await SharedPreferences.getInstance();
    final list  = _highlights[chapterIdx] ?? [];
    await prefs.setString('libro_hl_$chapterIdx',
        json.encode(list.map((h) => h.toJson()).toList()));
  }

  // ─── Subrayado ────────────────────────────────────────────────────────────
  void _addHighlight() {
    final sel = _lastSelection;
    if (!sel.isValid || sel.isCollapsed) return;

    final start = sel.start;
    final end   = sel.end;
    if (start >= end) return;

    final list = List<_Highlight>.from(_highlights[_currentChapter] ?? []);

    // Evitar duplicados exactos
    final alreadyExists = list.any((h) => h.start == start && h.end == end);
    if (alreadyExists) return;

    list.add(_Highlight(start: start, end: end));
    setState(() => _highlights[_currentChapter] = list);
    _saveHighlights(_currentChapter);
  }

  void _removeHighlight(int chapterIdx, int highlightIdx) {
    final list = List<_Highlight>.from(_highlights[chapterIdx] ?? []);
    if (highlightIdx < list.length) {
      list.removeAt(highlightIdx);
      setState(() => _highlights[chapterIdx] = list);
      _saveHighlights(chapterIdx);
    }
  }

  // ─── Construcción del texto con highlights ────────────────────────────────
  TextSpan _buildRichText(String text, List<_Highlight> highlights,
      TextStyle base, Color highlightColor) {
    if (highlights.isEmpty) return TextSpan(text: text, style: base);

    // Ordenar y fusionar rangos solapados
    final sorted = List<_Highlight>.from(highlights)
      ..sort((a, b) => a.start.compareTo(b.start));

    final List<_Highlight> merged = [];
    for (final h in sorted) {
      if (merged.isEmpty || h.start > merged.last.end) {
        merged.add(h);
      } else {
        merged[merged.length - 1] = _Highlight(
            start: merged.last.start,
            end:   h.end > merged.last.end ? h.end : merged.last.end);
      }
    }

    final List<InlineSpan> spans = [];
    int cursor = 0;
    for (final h in merged) {
      final s = h.start.clamp(0, text.length);
      final e = h.end.clamp(s, text.length);
      if (s > cursor) {
        spans.add(TextSpan(text: text.substring(cursor, s), style: base));
      }
      spans.add(TextSpan(
        text: text.substring(s, e),
        style: base.copyWith(
          backgroundColor: highlightColor.withOpacity(0.35),
        ),
      ));
      cursor = e;
    }
    if (cursor < text.length) {
      spans.add(TextSpan(text: text.substring(cursor), style: base));
    }
    return TextSpan(children: spans);
  }

  // ─── Navegación ───────────────────────────────────────────────────────────
  void _goToChapter(int index) {
    setState(() {
      _currentChapter = index;
      _readProgress   = 0;
      _lastSelection  = const TextSelection.collapsed(offset: 0);
    });
    _saveState();
    _scrollController.jumpTo(0);
    _closePanel();
  }

  void _toggleBars() {
    setState(() => _showBars = !_showBars);
    _showBars ? _barsAnim.forward() : _barsAnim.reverse();
    if (!_showBars && _showIndex) _closePanel();
  }

  void _openPanel({bool highlights = false}) {
    setState(() {
      _showIndex          = !highlights;
      _showHighlightsPanel = highlights;
    });
    _indexAnim.forward();
  }

  void _closePanel() {
    _indexAnim.reverse().then((_) {
      if (mounted) setState(() {
        _showIndex           = false;
        _showHighlightsPanel = false;
      });
    });
  }

  void _changeFontSize(double delta) {
    setState(() => _fontSize = (_fontSize + delta).clamp(13.0, 26.0));
    _saveState();
  }

  // ─── Colores según tema ───────────────────────────────────────────────────
  Color _bg(bool sysDark) {
    if (_theme == 1) return _kSepia;
    if (_theme == 2) return _kDarkBg;
    return sysDark ? _kDarkBg : _kCream;
  }

  Color _textColor(bool sysDark) {
    if (_theme == 1) return const Color(0xFF3B2A1A);
    if (_theme == 2) return const Color(0xFFE8E0D5);
    return sysDark ? const Color(0xFFE8E0D5) : const Color(0xFF1C1C1E);
  }

  // ─── Build ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Color>(
      valueListenable: appPrimaryColor,
      builder: (context, primary, _) {
        final sysDark   = Theme.of(context).brightness == Brightness.dark;
        final isDark    = _theme == 2 || (_theme == 0 && sysDark);
        final bg        = _bg(sysDark);
        final textColor = _textColor(sysDark);

        return Scaffold(
          backgroundColor: bg,
          body: _loading
              ? _buildLoading(primary, bg)
              : _buildReader(context, primary, isDark, bg, textColor),
        );
      },
    );
  }

  Widget _buildLoading(Color primary, Color bg) => Container(
        color: bg,
        child: Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            CupertinoActivityIndicator(radius: 16, color: primary),
            const SizedBox(height: 16),
            const Text('Cargando libro…',
                style: TextStyle(fontSize: 15, color: Colors.grey)),
          ]),
        ),
      );

  // ─── Reader ───────────────────────────────────────────────────────────────
  Widget _buildReader(BuildContext context, Color primary, bool isDark,
      Color bg, Color textColor) {
    final chapter    = _chapters[_currentChapter];
    final highlights = _highlights[_currentChapter] ?? [];
    final baseStyle  = TextStyle(
      fontSize:   _fontSize,
      height:     1.75,
      color:      textColor,
      letterSpacing: 0.1,
      fontFamily: 'Georgia',
    );
    final richText = _buildRichText(chapter.content, highlights, baseStyle, primary);

    return Stack(children: [
      // ── Contenido ──────────────────────────────────────────────────
      GestureDetector(
        onTap: () => (_showIndex || _showHighlightsPanel)
            ? _closePanel()
            : _toggleBars(),
        child: SingleChildScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.only(
            top:    MediaQuery.of(context).padding.top + 72,
            bottom: MediaQuery.of(context).padding.bottom + 100,
            left: 24, right: 24,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                chapter.title,
                style: TextStyle(
                  fontSize:   _fontSize + 7,
                  fontWeight: FontWeight.w700,
                  color:      primary,
                  height:     1.3,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                width: 48, height: 3,
                decoration: BoxDecoration(
                  color: primary.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 28),
              SelectableText.rich(
                richText,
                onSelectionChanged: (selection, _) =>
                    _lastSelection = selection,
                contextMenuBuilder: (ctx, editableState) {
                  final items = [
                    ...editableState.contextMenuButtonItems,
                    ContextMenuButtonItem(
                      label: 'Subrayar',
                      onPressed: () {
                        ContextMenuController.removeAny();
                        _addHighlight();
                      },
                    ),
                  ];
                  return AdaptiveTextSelectionToolbar.buttonItems(
                    anchors:     editableState.contextMenuAnchors,
                    buttonItems: items,
                  );
                },
              ),
              const SizedBox(height: 40),
              Text(
                'Traducción española del texto básico de la edición de los pioneros de Alcohólicos Anónimos (1ª edición). El texto original en inglés es de dominio público. Esta traducción es reproducida con fines de recuperación sin ánimo de lucro. Alcohólicos Anónimos® es una marca registrada de A.A. World Services, Inc.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  color: textColor.withOpacity(0.35),
                  height: 1.5,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 16),
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
                  top:    MediaQuery.of(context).padding.top + 4,
                  bottom: 10, left: 4, right: 8,
                ),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.black.withOpacity(0.65)
                      : Colors.white.withOpacity(0.85),
                  border: Border(bottom: BorderSide(
                    color: isDark
                        ? Colors.white.withOpacity(0.08)
                        : Colors.black.withOpacity(0.07),
                    width: 0.5,
                  )),
                ),
                child: Row(children: [
                  CupertinoButton(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    onPressed: () => Navigator.pop(context),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(CupertinoIcons.chevron_left, color: primary, size: 18),
                      const SizedBox(width: 2),
                      Text('Literatura', style: TextStyle(color: primary, fontSize: 16)),
                    ]),
                  ),
                  const Spacer(),
                  Text('Libro Azul', style: TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w600, color: textColor)),
                  const Spacer(),
                  // Subrayados guardados
                  CupertinoButton(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    onPressed: () => _openPanel(highlights: true),
                    child: Stack(children: [
                      Icon(CupertinoIcons.pencil_outline, color: primary, size: 22),
                      if (_highlights.values.any((l) => l.isNotEmpty))
                        Positioned(
                          right: 0, top: 0,
                          child: Container(
                            width: 8, height: 8,
                            decoration: BoxDecoration(color: primary, shape: BoxShape.circle),
                          ),
                        ),
                    ]),
                  ),
                  // Índice
                  CupertinoButton(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    onPressed: () => (_showIndex || _showHighlightsPanel)
                        ? _closePanel()
                        : _openPanel(),
                    child: Icon(CupertinoIcons.list_bullet, color: primary, size: 22),
                  ),
                  // Opciones texto
                  CupertinoButton(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    onPressed: () => _showReaderOptions(context, primary, isDark),
                    child: Icon(CupertinoIcons.textformat, color: primary, size: 22),
                  ),
                ]),
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
                  left: 20, right: 20,
                ),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.black.withOpacity(0.65)
                      : Colors.white.withOpacity(0.85),
                  border: Border(top: BorderSide(
                    color: isDark
                        ? Colors.white.withOpacity(0.08)
                        : Colors.black.withOpacity(0.07),
                    width: 0.5,
                  )),
                ),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: LinearProgressIndicator(
                      value: _readProgress,
                      backgroundColor: isDark
                          ? Colors.white.withOpacity(0.1)
                          : Colors.black.withOpacity(0.08),
                      valueColor: AlwaysStoppedAnimation<Color>(primary),
                      minHeight: 3,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: _currentChapter > 0
                            ? () => _goToChapter(_currentChapter - 1)
                            : null,
                        child: Icon(CupertinoIcons.chevron_left,
                          color: _currentChapter > 0
                              ? primary
                              : Colors.grey.withOpacity(0.3),
                          size: 22),
                      ),
                      Expanded(
                        child: Text(
                          chapter.title,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.white54 : Colors.black45),
                        ),
                      ),
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: _currentChapter < _chapters.length - 1
                            ? () => _goToChapter(_currentChapter + 1)
                            : null,
                        child: Icon(CupertinoIcons.chevron_right,
                          color: _currentChapter < _chapters.length - 1
                              ? primary
                              : Colors.grey.withOpacity(0.3),
                          size: 22),
                      ),
                    ],
                  ),
                ]),
              ),
            ),
          ),
        ),
      ),

      // ── Overlay oscuro cuando hay panel abierto ───────────────────
      if (_showIndex || _showHighlightsPanel)
        FadeTransition(
          opacity: _indexFade,
          child: GestureDetector(
            onTap: _closePanel,
            child: Container(color: Colors.black.withOpacity(0.4)),
          ),
        ),

      // ── Panel (índice o highlights) ───────────────────────────────
      if (_showIndex || _showHighlightsPanel)
        SlideTransition(
          position: _indexSlide,
          child: Align(
            alignment: Alignment.centerLeft,
            child: _showHighlightsPanel
                ? _buildHighlightsPanel(primary, isDark, textColor)
                : _buildIndexPanel(primary, isDark, textColor),
          ),
        ),
    ]);
  }

  // ─── Panel índice ─────────────────────────────────────────────────────────
  Widget _buildIndexPanel(Color primary, bool isDark, Color textColor) {
    return _sidePanel(
      isDark: isDark,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _panelHeader(
          icon: CupertinoIcons.book_fill,
          title: 'Índice',
          isDark: isDark,
          textColor: textColor,
          primary: primary,
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            physics: const BouncingScrollPhysics(),
            itemCount: _chapters.length,
            itemBuilder: (context, i) {
              final isActive = i == _currentChapter;
              final hlCount  = (_highlights[i] ?? []).length;
              return GestureDetector(
                onTap: () => _goToChapter(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: isActive ? primary.withOpacity(0.12) : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(children: [
                    Container(
                      width: 28, height: 28,
                      decoration: BoxDecoration(
                        color: isActive
                            ? primary
                            : (isDark
                                ? Colors.white.withOpacity(0.08)
                                : Colors.black.withOpacity(0.06)),
                        shape: BoxShape.circle,
                      ),
                      child: Center(child: Text('${i + 1}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isActive
                              ? Colors.white
                              : (isDark ? Colors.white54 : Colors.black45)))),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Text(_chapters[i].title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                        color: isActive ? primary : textColor,
                        height: 1.3))),
                    if (hlCount > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: primary.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text('$hlCount',
                          style: TextStyle(fontSize: 11, color: primary,
                              fontWeight: FontWeight.w600)),
                      ),
                    if (isActive) ...[
                      const SizedBox(width: 6),
                      Icon(CupertinoIcons.checkmark, color: primary, size: 14),
                    ],
                  ]),
                ),
              );
            },
          ),
        ),
      ]),
    );
  }

  // ─── Panel subrayados ─────────────────────────────────────────────────────
  Widget _buildHighlightsPanel(Color primary, bool isDark, Color textColor) {
    // Aplanar todos los subrayados con su capítulo
    final List<Map<String, dynamic>> all = [];
    for (int ci = 0; ci < _chapters.length; ci++) {
      final list = _highlights[ci] ?? [];
      for (int hi = 0; hi < list.length; hi++) {
        all.add({
          'ci': ci,
          'hi': hi,
          'hl': list[hi],
          'chapter': _chapters[ci],
        });
      }
    }

    return _sidePanel(
      isDark: isDark,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _panelHeader(
          icon: CupertinoIcons.pencil_outline,
          title: 'Subrayados',
          isDark: isDark,
          textColor: textColor,
          primary: primary,
        ),
        Expanded(
          child: all.isEmpty
              ? Center(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Icon(CupertinoIcons.pencil_ellipsis_rectangle,
                        color: isDark ? Colors.white24 : Colors.black26, size: 48),
                    const SizedBox(height: 12),
                    Text(
                      'Selecciona texto y toca\n"Subrayar" para guardarlo',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.white38 : Colors.black38,
                        height: 1.5,
                      ),
                    ),
                  ]),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  physics: const BouncingScrollPhysics(),
                  itemCount: all.length,
                  itemBuilder: (context, idx) {
                    final item    = all[idx];
                    final ci      = item['ci'] as int;
                    final hi      = item['hi'] as int;
                    final hl      = item['hl'] as _Highlight;
                    final chapter = item['chapter'] as _Chapter;

                    return GestureDetector(
                      onTap: () {
                        _goToChapter(ci);
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withOpacity(0.05)
                              : Colors.black.withOpacity(0.04),
                          borderRadius: BorderRadius.circular(12),
                          border: Border(
                            left: BorderSide(
                                color: primary, width: 3),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              chapter.title,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: primary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              hl.snippet(chapter.content),
                              style: TextStyle(
                                fontSize: 13,
                                height: 1.5,
                                color: textColor,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Align(
                              alignment: Alignment.centerRight,
                              child: CupertinoButton(
                                padding: EdgeInsets.zero,
                                minSize: 0,
                                onPressed: () => _removeHighlight(ci, hi),
                                child: Text('Eliminar',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: CupertinoColors.systemRed,
                                  )),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ]),
    );
  }

  // ─── Widgets reutilizables ────────────────────────────────────────────────
  Widget _sidePanel({required bool isDark, required Widget child}) {
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
                ? const Color(0xFF1C1C1E).withOpacity(0.97)
                : Colors.white.withOpacity(0.97),
            border: Border(right: BorderSide(
              color: isDark
                  ? Colors.white.withOpacity(0.08)
                  : Colors.black.withOpacity(0.07),
              width: 0.5,
            )),
          ),
          child: SafeArea(child: child),
        ),
      ),
    );
  }

  Widget _panelHeader({
    required IconData icon,
    required String title,
    required bool isDark,
    required Color textColor,
    required Color primary,
  }) {
    return Column(children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 16, 12),
        child: Row(children: [
          Icon(icon, color: primary, size: 22),
          const SizedBox(width: 10),
          Text(title, style: TextStyle(
            fontSize: 22, fontWeight: FontWeight.w700,
            color: textColor, letterSpacing: -0.3)),
          const Spacer(),
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: _closePanel,
            child: Icon(CupertinoIcons.xmark_circle_fill,
                color: isDark ? Colors.white38 : Colors.black26, size: 26)),
        ]),
      ),
      Container(height: 0.5,
          color: isDark
              ? Colors.white.withOpacity(0.08)
              : Colors.black.withOpacity(0.07)),
    ]);
  }

  // ─── Modal opciones ───────────────────────────────────────────────────────
  void _showReaderOptions(BuildContext context, Color primary, bool isDark) {
    showCupertinoModalPopup(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModal) => Container(
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF1C1C1E)
                : CupertinoColors.systemBackground,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 36),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 36, height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.black12,
                borderRadius: BorderRadius.circular(2)),
            ),
            // Tamaño de fuente
            Row(children: [
              Text('A', style: TextStyle(fontSize: 14, decoration: TextDecoration.none,
                  color: isDark ? Colors.white60 : Colors.black45)),
              const SizedBox(width: 12),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    color: isDark
                        ? Colors.white.withOpacity(0.06)
                        : Colors.black.withOpacity(0.05),
                    child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                      CupertinoButton(
                        padding: const EdgeInsets.all(14),
                        onPressed: () { _changeFontSize(-1); setModal(() {}); },
                        child: Icon(CupertinoIcons.minus, color: primary, size: 20)),
                      Text('${_fontSize.toInt()}pt', style: TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w500,
                        decoration: TextDecoration.none,
                        color: isDark ? Colors.white : Colors.black)),
                      CupertinoButton(
                        padding: const EdgeInsets.all(14),
                        onPressed: () { _changeFontSize(1); setModal(() {}); },
                        child: Icon(CupertinoIcons.plus, color: primary, size: 20)),
                    ]),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text('A', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600,
                  decoration: TextDecoration.none,
                  color: isDark ? Colors.white60 : Colors.black45)),
            ]),
            const SizedBox(height: 20),
            // Temas
            Row(children: [
              _themeBtn(0, 'Auto',  _kCream,  Colors.black87,             primary, setModal),
              const SizedBox(width: 10),
              _themeBtn(1, 'Sepia', _kSepia,  const Color(0xFF3B2A1A),   primary, setModal),
              const SizedBox(width: 10),
              _themeBtn(2, 'Noche', _kDarkBg, const Color(0xFFE8E0D5),   primary, setModal),
            ]),
          ]),
        ),
      ),
    );
  }

  Widget _themeBtn(int index, String label, Color bg, Color fg,
      Color primary, StateSetter setModal) {
    final isSelected = _theme == index;
    return Expanded(
      child: GestureDetector(
        onTap: () { setState(() => _theme = index); setModal(() {}); },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: 64,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: isSelected ? primary : Colors.transparent, width: 2.5),
            boxShadow: [BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 6, offset: const Offset(0, 2))],
          ),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text('Aa', style: TextStyle(
              color: fg, fontSize: 18, fontWeight: FontWeight.w600,
              decoration: TextDecoration.none, fontFamily: 'Georgia')),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(
              color: fg.withOpacity(0.6), fontSize: 11,
              decoration: TextDecoration.none)),
          ]),
        ),
      ),
    );
  }
}
