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
const _kDarkBg   = Color(0xFF1A0800);

class GratitudeEntry {
  final String   id;
  final String   text;
  final DateTime date;

  GratitudeEntry({required this.id, required this.text, required this.date});

  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        'date': date.toIso8601String(),
      };

  factory GratitudeEntry.fromJson(Map<String, dynamic> json) => GratitudeEntry(
        id:   json['id'] ?? DateTime.now().toIso8601String(),
        text: json['text'],
        date: DateTime.parse(json['date']),
      );
}

// ─── List screen ─────────────────────────────────────────────────────────────

class GratitudeJournalScreen extends StatefulWidget {
  const GratitudeJournalScreen({super.key});
  @override
  _GratitudeJournalScreenState createState() => _GratitudeJournalScreenState();
}

class _GratitudeJournalScreenState extends State<GratitudeJournalScreen>
    with SingleTickerProviderStateMixin {
  List<GratitudeEntry> _entries = [];
  static const _storageKey = 'gratitude_entries';

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
          .map((j) => GratitudeEntry.fromJson(j))
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

  bool get _hasEntryToday {
    final today = DateTime.now();
    return _entries.any((e) =>
        e.date.year == today.year &&
        e.date.month == today.month &&
        e.date.day == today.day);
  }

  void _openEditor({GratitudeEntry? entry}) async {
    final result = await Navigator.push<GratitudeEntry?>(
      context,
      MaterialPageRoute(builder: (_) => _GratitudeEditor(existing: entry)),
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
                      'Gratitud',
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
                // Daily prompt banner
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: _buildDailyPrompt(primary, isDark, textPrim),
                  ),
                ),
                _entries.isEmpty
                    ? SliverFillRemaining(
                        child: _buildEmpty(primary, isDark, textPrim))
                    : SliverPadding(
                        padding: const EdgeInsets.fromLTRB(16, 14, 16, 100),
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

  Widget _buildDailyPrompt(Color primary, bool isDark, Color textPrim) {
    final done = _hasEntryToday;
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: GestureDetector(
          onTap: done ? null : () => _openEditor(),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: done
                  ? primary.withOpacity(isDark ? 0.18 : 0.1)
                  : (isDark
                      ? Colors.white.withOpacity(0.06)
                      : Colors.white.withOpacity(0.72)),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: done
                    ? primary.withOpacity(0.4)
                    : (isDark
                        ? Colors.white.withOpacity(0.08)
                        : Colors.white.withOpacity(0.9)),
                width: 0.8,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: primary.withOpacity(done ? 0.25 : 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    done
                        ? CupertinoIcons.checkmark_circle_fill
                        : CupertinoIcons.sun_min_fill,
                    color: primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        done
                            ? '¡Gratitud de hoy registrada!'
                            : '¿Por qué estás agradecido hoy?',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: textPrim,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        done
                            ? 'Un día más practicando la gratitud'
                            : 'Toca para escribir tu entrada de hoy',
                        style: TextStyle(
                          fontSize: 12,
                          color: textPrim.withOpacity(0.45),
                        ),
                      ),
                    ],
                  ),
                ),
                if (!done)
                  Icon(CupertinoIcons.chevron_right,
                      color: primary.withOpacity(0.5), size: 15),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCard(
      GratitudeEntry e, Color primary, bool isDark, Color textPrim) {
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
        child: const Icon(CupertinoIcons.trash, color: Colors.white, size: 22),
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
                    const SizedBox(height: 10),
                    Text(
                      e.text,
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15,
                        color: textPrim.withOpacity(0.75),
                        height: 1.6,
                        fontFamily: 'Georgia',
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
              child: Icon(CupertinoIcons.sun_min_fill,
                  color: primary, size: 36),
            ),
            const SizedBox(height: 24),
            Text(
              'El poder de la gratitud',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: textPrim,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Enfocarte en lo bueno, por pequeño que sea, transforma tu perspectiva. Empieza escribiendo una cosa por la que estás agradecido hoy.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: textPrim.withOpacity(0.5),
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Full-screen editor ───────────────────────────────────────────────────────

class _GratitudeEditor extends StatefulWidget {
  final GratitudeEntry? existing;
  const _GratitudeEditor({this.existing});
  @override
  _GratitudeEditorState createState() => _GratitudeEditorState();
}

class _GratitudeEditorState extends State<_GratitudeEditor> {
  late TextEditingController _ctrl;
  late FocusNode _focus;

  @override
  void initState() {
    super.initState();
    _ctrl  = TextEditingController(text: widget.existing?.text ?? '');
    _focus = FocusNode();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _focus.requestFocus());
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _save() {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    Navigator.pop(
      context,
      GratitudeEntry(
        id:   widget.existing?.id ?? DateTime.now().toIso8601String(),
        text: text,
        date: widget.existing?.date ?? DateTime.now(),
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
                            ? 'Editar gratitud'
                            : 'Nueva gratitud',
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
                // Prompt header
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hoy estoy agradecido/a por...',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: textPrim,
                          letterSpacing: -0.4,
                        ),
                      ),
                      const SizedBox(height: 4),
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
                          color: isDark
                              ? Colors.white12
                              : Colors.black.withOpacity(0.07)),
                    ],
                  ),
                ),
                // Text field
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
                    child: TextField(
                      controller: _ctrl,
                      focusNode: _focus,
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
