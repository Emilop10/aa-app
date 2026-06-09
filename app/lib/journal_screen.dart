import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:ui';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'app_colors.dart';

const _kCream    = Color(0xFFFFFBF5);
const _kTextPrim = Color(0xFF431407);
const _kTextSec  = Color(0xFF92400E);
const _kDarkBg   = Color(0xFF1A0800);

class JournalEntry {
  final String   id;
  final String   title;
  final String   content;
  final DateTime date;

  JournalEntry({
    required this.id,
    required this.title,
    required this.content,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'content': content,
        'date': date.toIso8601String(),
      };

  factory JournalEntry.fromJson(Map<String, dynamic> json) => JournalEntry(
        id: json['id'] ?? DateTime.now().toIso8601String(),
        title: json['title'],
        content: json['content'],
        date: DateTime.parse(json['date']),
      );
}

// ─── List screen ─────────────────────────────────────────────────────────────

class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});
  @override
  _JournalScreenState createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen>
    with SingleTickerProviderStateMixin {
  List<JournalEntry> _entries = [];
  static const _storageKey = 'journal_entries';

  late AnimationController _bgBreathController;
  late Animation<double>   _bgBreath;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('es_ES', null);
    _bgBreathController = AnimationController(
        vsync: this, duration: const Duration(seconds: 7))
      ..repeat(reverse: true);
    _bgBreath = Tween<double>(begin: 0.03, end: 0.09).animate(
        CurvedAnimation(parent: _bgBreathController, curve: Curves.easeInOut));
    _loadEntries();
  }

  @override
  void dispose() {
    _bgBreathController.dispose();
    super.dispose();
  }

  Future<void> _loadEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw != null) {
      final list = (jsonDecode(raw) as List)
          .map((j) => JournalEntry.fromJson(j))
          .toList();
      list.sort((a, b) => b.date.compareTo(a.date));
      if (mounted) setState(() => _entries = list);
    }
  }

  Future<void> _saveEntries() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _storageKey, jsonEncode(_entries.map((e) => e.toJson()).toList()));
  }

  void _openEditor({JournalEntry? entry}) async {
    final result = await Navigator.push<JournalEntry?>(
      context,
      MaterialPageRoute(
          builder: (_) => _JournalEditor(existing: entry)),
    );
    if (result == null) return;
    setState(() {
      if (entry != null) {
        final i = _entries.indexWhere((e) => e.id == entry.id);
        if (i != -1) _entries[i] = result;
      } else {
        _entries.insert(0, result);
      }
    });
    _saveEntries();
  }

  void _deleteEntry(String id) {
    setState(() => _entries.removeWhere((e) => e.id == id));
    _saveEntries();
  }

  String _formatDate(DateTime d) {
    final f = DateFormat('EEEE d \'de\' MMMM', 'es_ES').format(d);
    return f[0].toUpperCase() + f.substring(1);
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
                  colors: [primary.withOpacity(_bgBreath.value), bgColor],
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
                  actions: [
                    Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: () => _openEditor(),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(CupertinoIcons.add,
                              color: Colors.white, size: 20),
                        ),
                      ),
                    ),
                  ],
                  flexibleSpace: FlexibleSpaceBar(
                    titlePadding: const EdgeInsets.only(left: 20, bottom: 14),
                    title: Text(
                      'Mi Diario',
                      style: TextStyle(
                        color: textPrim,
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                      ),
                    ),
                    stretchModes: const [StretchMode.fadeTitle],
                  ),
                ),
                _entries.isEmpty
                    ? SliverFillRemaining(
                        child: _buildEmpty(primary, isDark, textPrim))
                    : SliverPadding(
                        padding:
                            const EdgeInsets.fromLTRB(16, 8, 16, 100),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (ctx, i) => _buildCard(
                                _entries[i], primary, isDark, textPrim),
                            childCount: _entries.length,
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

  Widget _buildCard(
      JournalEntry e, Color primary, bool isDark, Color textPrim) {
    return Dismissible(
      key: Key(e.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => _deleteEntry(e.id),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFEF4444).withOpacity(0.85),
          borderRadius: BorderRadius.circular(20),
        ),
        child:
            const Icon(CupertinoIcons.trash, color: Colors.white, size: 22),
      ),
      child: GestureDetector(
        onTap: () => _openEditor(entry: e),
        child: Container(
          margin: const EdgeInsets.only(bottom: 14),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withOpacity(0.06)
                      : Colors.white.withOpacity(0.72),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withOpacity(0.08)
                        : Colors.white.withOpacity(0.9),
                    width: 0.8,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            e.title,
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: textPrim,
                              letterSpacing: -0.2,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: primary.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _formatDate(e.date),
                            style: TextStyle(
                              fontSize: 11,
                              color: primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      e.content,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        color: textPrim.withOpacity(0.6),
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmpty(Color primary, bool isDark, Color textPrim) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: primary.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(CupertinoIcons.pencil_outline,
                  color: primary, size: 36),
            ),
            const SizedBox(height: 24),
            Text(
              'Tu espacio personal',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: textPrim,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'La escritura es una herramienta poderosa para el autoconocimiento. Escribe tus pensamientos, emociones y reflexiones de tu camino.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: textPrim.withOpacity(0.5),
                height: 1.6,
              ),
            ),
            const SizedBox(height: 32),
            CupertinoButton(
              padding:
                  const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              color: primary,
              borderRadius: BorderRadius.circular(14),
              onPressed: () => _openEditor(),
              child: const Text(
                'Escribir primera entrada',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Full-screen editor ───────────────────────────────────────────────────────

class _JournalEditor extends StatefulWidget {
  final JournalEntry? existing;
  const _JournalEditor({this.existing});

  @override
  _JournalEditorState createState() => _JournalEditorState();
}

class _JournalEditorState extends State<_JournalEditor> {
  late TextEditingController _titleCtrl;
  late TextEditingController _contentCtrl;
  late FocusNode _titleFocus;
  late FocusNode _contentFocus;

  @override
  void initState() {
    super.initState();
    _titleCtrl   = TextEditingController(text: widget.existing?.title ?? '');
    _contentCtrl = TextEditingController(text: widget.existing?.content ?? '');
    _titleFocus   = FocusNode();
    _contentFocus = FocusNode();
    if (widget.existing == null) {
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _titleFocus.requestFocus());
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    _titleFocus.dispose();
    _contentFocus.dispose();
    super.dispose();
  }

  void _save() {
    final title   = _titleCtrl.text.trim();
    final content = _contentCtrl.text.trim();
    if (title.isEmpty || content.isEmpty) return;
    Navigator.pop(
      context,
      JournalEntry(
        id:      widget.existing?.id ?? DateTime.now().toIso8601String(),
        title:   title,
        content: content,
        date:    widget.existing?.date ?? DateTime.now(),
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
        final hintColor = textPrim.withOpacity(0.3);

        return Scaffold(
          backgroundColor: bgColor,
          body: SafeArea(
            child: Column(
              children: [
                // Top bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CupertinoButton(
                        padding: const EdgeInsets.all(8),
                        onPressed: () => Navigator.pop(context),
                        child: Text('Cancelar',
                            style: TextStyle(
                                color: textPrim.withOpacity(0.5),
                                fontSize: 16)),
                      ),
                      Text(
                        widget.existing != null
                            ? 'Editar entrada'
                            : 'Nueva entrada',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: textPrim,
                        ),
                      ),
                      CupertinoButton(
                        padding: const EdgeInsets.all(8),
                        onPressed: _save,
                        child: Text('Guardar',
                            style: TextStyle(
                                color: primary,
                                fontSize: 16,
                                fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                ),
                Container(
                  height: 0.5,
                  margin: const EdgeInsets.only(top: 8),
                  color: isDark ? Colors.white12 : Colors.black12,
                ),
                // Fields
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          controller: _titleCtrl,
                          focusNode: _titleFocus,
                          textInputAction: TextInputAction.next,
                          onSubmitted: (_) => _contentFocus.requestFocus(),
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: textPrim,
                            letterSpacing: -0.4,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Título',
                            hintStyle: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: hintColor,
                              letterSpacing: -0.4,
                            ),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          DateFormat('EEEE d \'de\' MMMM \'de\' y', 'es_ES')
                              .format(widget.existing?.date ?? DateTime.now()),
                          style: TextStyle(
                            fontSize: 13,
                            color: textPrim.withOpacity(0.35),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Container(
                            height: 0.5,
                            color:
                                isDark ? Colors.white12 : Colors.black.withOpacity(0.07)),
                        const SizedBox(height: 20),
                        TextField(
                          controller: _contentCtrl,
                          focusNode: _contentFocus,
                          maxLines: null,
                          keyboardType: TextInputType.multiline,
                          style: TextStyle(
                            fontSize: 17,
                            color: textPrim.withOpacity(0.85),
                            height: 1.7,
                            fontFamily: 'Georgia',
                          ),
                          decoration: InputDecoration(
                            hintText: 'Escribe aquí...',
                            hintStyle: TextStyle(
                              fontSize: 17,
                              color: hintColor,
                              height: 1.7,
                            ),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
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
}
