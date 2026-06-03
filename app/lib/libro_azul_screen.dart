import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:ui';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'app_colors.dart';

const _kCream   = Color(0xFFFFFBF5);
const _kDarkBg  = Color(0xFF1A0800);

class LibroAzulScreen extends StatefulWidget {
  const LibroAzulScreen({super.key});

  @override
  _LibroAzulScreenState createState() => _LibroAzulScreenState();
}

class _LibroAzulScreenState extends State<LibroAzulScreen>
    with TickerProviderStateMixin {

  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();
  final PdfViewerController _pdfController = PdfViewerController();
  final GlobalKey<SfPdfViewerState> _sfKey = GlobalKey();

  int _currentPage = 1;
  int _totalPages  = 0;
  bool _showBars   = true;
  bool _showSearch = false;
  bool _isLoading  = true;

  final TextEditingController _searchController = TextEditingController();
  PdfTextSearchResult _searchResult = PdfTextSearchResult();

  // Fade animado de las barras
  late AnimationController _barsAnim;
  late Animation<double> _barsFade;

  @override
  void initState() {
    super.initState();
    _barsAnim = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 220));
    _barsFade = CurvedAnimation(parent: _barsAnim, curve: Curves.easeInOut);
    _barsAnim.value = 1.0;
  }

  @override
  void dispose() {
    _barsAnim.dispose();
    _searchController.dispose();
    _searchResult.clear();
    super.dispose();
  }

  void _toggleBars() {
    setState(() => _showBars = !_showBars);
    if (_showBars) {
      _barsAnim.forward();
    } else {
      _barsAnim.reverse();
    }
  }

  void _openSearch(Color primary, bool isDark) {
    setState(() => _showSearch = true);
    showCupertinoModalPopup(
      context: context,
      builder: (ctx) => _SearchSheet(
        primary: primary,
        isDark: isDark,
        onSearch: (query) {
          if (query.isNotEmpty) {
            _searchResult = _pdfController.searchText(query,
                searchOption: TextSearchOption.caseSensitive);
          }
          Navigator.pop(ctx);
          setState(() => _showSearch = false);
        },
        onClose: () {
          _searchResult.clear();
          Navigator.pop(ctx);
          setState(() => _showSearch = false);
        },
      ),
    );
  }

  void _showBookmarks(Color primary, bool isDark) {
    _pdfViewerKey.currentState?.openBookmarkView();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Color>(
      valueListenable: appPrimaryColor,
      builder: (context, primary, _) {
        final isDark  = Theme.of(context).brightness == Brightness.dark;
        final bgColor = isDark ? _kDarkBg : _kCream;

        return Scaffold(
          backgroundColor: bgColor,
          body: Stack(
            children: [
              // ── PDF Viewer ──────────────────────────────────────
              GestureDetector(
                onTap: _toggleBars,
                child: SfPdfViewer.asset(
                  'assets/libro_azul.pdf',
                  key: _pdfViewerKey,
                  controller: _pdfController,
                  enableDoubleTapZooming: true,
                  enableTextSelection: true,
                  canShowScrollHead: false,
                  canShowScrollStatus: false,
                  canShowPaginationDialog: false,
                  pageSpacing: 8,
                  onDocumentLoaded: (details) {
                    setState(() {
                      _totalPages = details.document.pages.count;
                      _isLoading  = false;
                    });
                  },
                  onPageChanged: (details) {
                    setState(() => _currentPage = details.newPageNumber);
                  },
                  onTextSelectionChanged: (details) {},
                  currentSearchTextHighlightColor:
                      primary.withOpacity(0.8),
                  otherSearchTextHighlightColor:
                      primary.withOpacity(0.3),
                ),
              ),

              // ── Loading overlay ──────────────────────────────────
              if (_isLoading)
                Container(
                  color: bgColor,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CupertinoActivityIndicator(
                            radius: 16, color: primary),
                        const SizedBox(height: 16),
                        Text(
                          'Cargando libro...',
                          style: TextStyle(
                            fontSize: 15,
                            color: isDark ? Colors.white54 : const Color(0xFF92400E),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // ── Top bar ──────────────────────────────────────────
              FadeTransition(
                opacity: _barsFade,
                child: Align(
                  alignment: Alignment.topCenter,
                  child: ClipRect(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                      child: Container(
                        padding: EdgeInsets.only(
                          top: MediaQuery.of(context).padding.top + 4,
                          bottom: 10,
                          left: 8,
                          right: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.black.withOpacity(0.6)
                              : Colors.white.withOpacity(0.82),
                          border: Border(
                            bottom: BorderSide(
                              color: isDark
                                  ? Colors.white.withOpacity(0.08)
                                  : Colors.black.withOpacity(0.06),
                              width: 0.5,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            // Botón regresar
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
                                  Text(
                                    'Literatura',
                                    style: TextStyle(
                                        color: primary, fontSize: 16),
                                  ),
                                ],
                              ),
                            ),

                            const Spacer(),

                            // Título
                            Text(
                              'Libro Azul',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: isDark ? Colors.white : const Color(0xFF431407),
                              ),
                            ),

                            const Spacer(),

                            // Buscar
                            CupertinoButton(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              onPressed: () => _openSearch(primary, isDark),
                              child: Icon(CupertinoIcons.search,
                                  color: primary, size: 22),
                            ),

                            // Marcadores
                            CupertinoButton(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              onPressed: () => _showBookmarks(primary, isDark),
                              child: Icon(CupertinoIcons.bookmark,
                                  color: primary, size: 22),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // ── Bottom bar (página / progreso) ───────────────────
              if (!_isLoading)
                FadeTransition(
                  opacity: _barsFade,
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: ClipRect(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                        child: Container(
                          padding: EdgeInsets.only(
                            top: 10,
                            bottom:
                                MediaQuery.of(context).padding.bottom + 10,
                            left: 20,
                            right: 20,
                          ),
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.black.withOpacity(0.6)
                                : Colors.white.withOpacity(0.82),
                            border: Border(
                              top: BorderSide(
                                color: isDark
                                    ? Colors.white.withOpacity(0.08)
                                    : Colors.black.withOpacity(0.06),
                                width: 0.5,
                              ),
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Barra de progreso
                              ClipRRect(
                                borderRadius: BorderRadius.circular(2),
                                child: LinearProgressIndicator(
                                  value: _totalPages > 0
                                      ? _currentPage / _totalPages
                                      : 0,
                                  backgroundColor: isDark
                                      ? Colors.white12
                                      : Colors.black12,
                                  valueColor:
                                      AlwaysStoppedAnimation<Color>(primary),
                                  minHeight: 3,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  // Página anterior
                                  CupertinoButton(
                                    padding: EdgeInsets.zero,
                                    onPressed: _currentPage > 1
                                        ? () => _pdfController
                                            .previousPage()
                                        : null,
                                    child: Icon(
                                      CupertinoIcons.chevron_left,
                                      color: _currentPage > 1
                                          ? primary
                                          : Colors.grey.withOpacity(0.4),
                                      size: 22,
                                    ),
                                  ),

                                  // Contador de páginas (toca para ir a página)
                                  GestureDetector(
                                    onTap: () =>
                                        _showGoToPage(primary, isDark),
                                    child: Text(
                                      'Página $_currentPage de $_totalPages',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: isDark
                                            ? Colors.white60
                                            : const Color(0xFF92400E),
                                      ),
                                    ),
                                  ),

                                  // Página siguiente
                                  CupertinoButton(
                                    padding: EdgeInsets.zero,
                                    onPressed: _currentPage < _totalPages
                                        ? () =>
                                            _pdfController.nextPage()
                                        : null,
                                    child: Icon(
                                      CupertinoIcons.chevron_right,
                                      color: _currentPage < _totalPages
                                          ? primary
                                          : Colors.grey.withOpacity(0.4),
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
            ],
          ),
        );
      },
    );
  }

  void _showGoToPage(Color primary, bool isDark) {
    int tempPage = _currentPage;
    showCupertinoModalPopup(
      context: context,
      builder: (ctx) => Container(
        height: 280,
        decoration: BoxDecoration(
          color: isDark
              ? const Color(0xFF1C1C1E)
              : CupertinoColors.systemBackground,
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.black12,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: Text('Cancelar',
                        style: TextStyle(
                            color: isDark
                                ? Colors.white60
                                : Colors.black45,
                            decoration: TextDecoration.none)),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                  Text(
                    'Ir a página',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.none,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: Text('Ir',
                        style: TextStyle(
                            color: primary,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.none)),
                    onPressed: () {
                      Navigator.pop(ctx);
                      _pdfController.jumpToPage(tempPage);
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: CupertinoPicker(
                itemExtent: 40,
                scrollController: FixedExtentScrollController(
                    initialItem: _currentPage - 1),
                onSelectedItemChanged: (i) => tempPage = i + 1,
                children: List.generate(
                  _totalPages,
                  (i) => Center(
                    child: Text(
                      'Página ${i + 1}',
                      style: TextStyle(
                        fontSize: 16,
                        decoration: TextDecoration.none,
                        color: isDark ? Colors.white : Colors.black,
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

// ─── Hoja de búsqueda ─────────────────────────────────────────────────────────
class _SearchSheet extends StatefulWidget {
  final Color primary;
  final bool isDark;
  final void Function(String) onSearch;
  final VoidCallback onClose;

  const _SearchSheet({
    required this.primary,
    required this.isDark,
    required this.onSearch,
    required this.onClose,
  });

  @override
  _SearchSheetState createState() => _SearchSheetState();
}

class _SearchSheetState extends State<_SearchSheet> {
  final TextEditingController _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        color: widget.isDark
            ? const Color(0xFF1C1C1E)
            : CupertinoColors.systemBackground,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: widget.isDark ? Colors.white24 : Colors.black12,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: widget.onClose,
                  child: Text('Cancelar',
                      style: TextStyle(
                          color: widget.isDark
                              ? Colors.white60
                              : Colors.black45,
                          decoration: TextDecoration.none)),
                ),
                Text(
                  'Buscar en el libro',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.none,
                    color: widget.isDark ? Colors.white : Colors.black,
                  ),
                ),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () => widget.onSearch(_ctrl.text.trim()),
                  child: Text('Buscar',
                      style: TextStyle(
                          color: widget.primary,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.none)),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: CupertinoTextField(
              controller: _ctrl,
              autofocus: true,
              placeholder: 'Buscar palabra o frase...',
              placeholderStyle: TextStyle(
                color: widget.isDark ? Colors.white38 : Colors.black38,
              ),
              style: TextStyle(
                color: widget.isDark ? Colors.white : Colors.black,
              ),
              decoration: BoxDecoration(
                color: widget.isDark
                    ? Colors.white.withOpacity(0.08)
                    : Colors.black.withOpacity(0.06),
                borderRadius: BorderRadius.circular(10),
              ),
              prefix: Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Icon(CupertinoIcons.search,
                    size: 16,
                    color: widget.isDark ? Colors.white38 : Colors.black38),
              ),
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
              onSubmitted: (v) => widget.onSearch(v.trim()),
            ),
          ),
        ],
      ),
    );
  }
}
