import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:ui';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_colors.dart';

const _kCream    = Color(0xFFFFFBF5);
const _kSepia    = Color(0xFFF8F0E3);
const _kDarkBg   = Color(0xFF1A1A1A);
const _kTextPrim = Color(0xFF431407);

// ─── Reusable text reader screen ────────────────────────────────────────────

class LitTextScreen extends StatefulWidget {
  final String title;
  final String body;
  final String footer;
  final String prefsKey;

  const LitTextScreen({
    super.key,
    required this.title,
    required this.body,
    required this.footer,
    required this.prefsKey,
  });

  @override
  _LitTextScreenState createState() => _LitTextScreenState();
}

class _LitTextScreenState extends State<LitTextScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _bgBreathController;
  late Animation<double> _bgBreath;
  int    _readingTheme = 0;
  double _fontSize     = 17.0;

  @override
  void initState() {
    super.initState();
    _bgBreathController = AnimationController(
        vsync: this, duration: const Duration(seconds: 7))
      ..repeat(reverse: true);
    _bgBreath = Tween<double>(begin: 0.03, end: 0.09).animate(
        CurvedAnimation(parent: _bgBreathController, curve: Curves.easeInOut));
    _loadPrefs();
  }

  @override
  void dispose() {
    _bgBreathController.dispose();
    super.dispose();
  }

  Future<void> _loadPrefs() async {
    final p = await SharedPreferences.getInstance();
    setState(() {
      _fontSize     = p.getDouble('${widget.prefsKey}_fs') ?? 17.0;
      _readingTheme = p.getInt('${widget.prefsKey}_theme') ?? 0;
    });
  }

  Future<void> _savePrefs() async {
    final p = await SharedPreferences.getInstance();
    await p.setDouble('${widget.prefsKey}_fs', _fontSize);
    await p.setInt('${widget.prefsKey}_theme', _readingTheme);
  }

  Color _bgColor(bool sysDark) {
    if (_readingTheme == 1) return _kSepia;
    if (_readingTheme == 2) return _kDarkBg;
    return sysDark ? _kDarkBg : _kCream;
  }

  Color _textColor(bool sysDark) {
    final dark = _readingTheme == 2 || (_readingTheme == 0 && sysDark);
    return dark ? Colors.white.withOpacity(0.9) : _kTextPrim;
  }

  bool _isDark(bool sysDark) =>
      _readingTheme == 2 || (_readingTheme == 0 && sysDark);

  void _showSettings(Color primary, bool sysDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModal) {
          final dark = _isDark(sysDark);
          return Container(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
            decoration: BoxDecoration(
              color: dark ? const Color(0xFF2A2A2A) : Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 36, height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () => setModal(() => setState(() {
                        _fontSize = (_fontSize - 1).clamp(13.0, 26.0);
                        _savePrefs();
                      })),
                      child: Icon(CupertinoIcons.minus_circle, color: primary, size: 28),
                    ),
                    const SizedBox(width: 8),
                    Text('${_fontSize.toInt()} pt',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: dark ? Colors.white : _kTextPrim)),
                    const SizedBox(width: 8),
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () => setModal(() => setState(() {
                        _fontSize = (_fontSize + 1).clamp(13.0, 26.0);
                        _savePrefs();
                      })),
                      child: Icon(CupertinoIcons.plus_circle, color: primary, size: 28),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    _themeBtn('Auto',  0, primary, dark, setModal),
                    const SizedBox(width: 10),
                    _themeBtn('Sepia', 1, primary, dark, setModal),
                    const SizedBox(width: 10),
                    _themeBtn('Noche', 2, primary, dark, setModal),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _themeBtn(String label, int idx, Color primary, bool dark, StateSetter setModal) {
    final selected = _readingTheme == idx;
    return Expanded(
      child: GestureDetector(
        onTap: () => setModal(() => setState(() {
          _readingTheme = idx;
          _savePrefs();
        })),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? primary : (dark ? Colors.white12 : Colors.black12),
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: Text(label,
              style: TextStyle(
                color: selected ? Colors.white : (dark ? Colors.white70 : _kTextPrim),
                fontWeight: FontWeight.w600,
                fontSize: 14,
              )),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Color>(
      valueListenable: appPrimaryColor,
      builder: (context, primary, _) {
        final sysDark  = Theme.of(context).brightness == Brightness.dark;
        final bgColor  = _bgColor(sysDark);
        final textColor = _textColor(sysDark);
        final dark = _isDark(sysDark);

        return Scaffold(
          backgroundColor: bgColor,
          body: AnimatedBuilder(
            animation: _bgBreath,
            builder: (context, child) => Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.topCenter,
                  radius: 1.4,
                  colors: [primary.withOpacity(_bgBreath.value * 0.6), bgColor],
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
                    CupertinoButton(
                      padding: const EdgeInsets.only(right: 16),
                      onPressed: () => _showSettings(primary, sysDark),
                      child: Icon(CupertinoIcons.textformat_size, color: primary, size: 22),
                    ),
                  ],
                  flexibleSpace: FlexibleSpaceBar(
                    titlePadding: const EdgeInsets.only(left: 20, bottom: 14),
                    title: Text(
                      widget.title,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                      ),
                    ),
                    stretchModes: const [StretchMode.fadeTitle],
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 60),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                            child: Container(
                              padding: const EdgeInsets.all(22),
                              decoration: BoxDecoration(
                                color: dark
                                    ? Colors.white.withOpacity(0.06)
                                    : Colors.white.withOpacity(0.72),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: dark
                                      ? Colors.white.withOpacity(0.08)
                                      : Colors.white.withOpacity(0.9),
                                  width: 0.8,
                                ),
                              ),
                              child: SelectableText(
                                widget.body,
                                style: TextStyle(
                                  fontSize: _fontSize,
                                  color: textColor,
                                  height: 1.65,
                                  fontFamily: 'Georgia',
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          widget.footer,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 11,
                            color: textColor.withOpacity(0.35),
                            height: 1.5,
                            fontStyle: FontStyle.italic,
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

// ─── Glosario ────────────────────────────────────────────────────────────────

const _glossaryTerms = [
  _GlossTerm('Aceptación',
      'Reconocer la realidad de una situación sin intentar cambiarla ni resistirla. Principio fundamental de la serenidad en A.A.'),
  _GlossTerm('Alcohólico',
      'Persona que sufre de alcoholismo: una enfermedad física, mental y espiritual caracterizada por la obsesión por beber y la pérdida del control una vez que se empieza.'),
  _GlossTerm('Anonymato / Anonimato',
      'Base espiritual de todas las Tradiciones. Significa anteponer los principios a las personalidades y proteger la identidad de los miembros ante el público.'),
  _GlossTerm('Comité de servicio',
      'Grupo de miembros que coordinan servicios específicos (hospitalaria, instituciones, literatura, etc.) dentro de A.A.'),
  _GlossTerm('Despertar espiritual',
      'Cambio profundo en la forma de pensar, sentir y actuar que resulta de trabajar los Doce Pasos; no necesariamente una experiencia religiosa.'),
  _GlossTerm('Doce Pasos',
      'Guía de acción espiritual y práctica para la recuperación del alcoholismo, formulada por los primeros miembros de A.A. y publicada en el Libro Grande.'),
  _GlossTerm('Doce Tradiciones',
      'Principios que rigen la unidad y el funcionamiento de los grupos y de A.A. como conjunto, para proteger su misión primordial.'),
  _GlossTerm('Grupo base',
      'El grupo de A.A. al que un miembro asiste regularmente y donde desempeña servicio. Se considera la unidad fundamental de A.A.'),
  _GlossTerm('Inventario',
      'Examen honesto de los propios defectos de carácter, resentimientos, miedos y daños causados a otros (Paso 4 y Paso 10).'),
  _GlossTerm('Madrina / Padrino',
      'Miembro de A.A. con tiempo de sobriedad que guía a un recién llegado a través de los Doce Pasos y el programa.'),
  _GlossTerm('Poder Superior',
      'Concepto personal de una fuerza mayor que uno mismo, no necesariamente religiosa, que puede devolver el sano juicio al alcohólico (Pasos 2 y 3).'),
  _GlossTerm('Reunión',
      'Encuentro de miembros de A.A. para compartir experiencias, fortaleza y esperanza. Pueden ser abiertas (para cualquier persona) o cerradas (solo alcohólicos).'),
  _GlossTerm('Sobriedad',
      'Estado de abstinencia total del alcohol, acompañado de un crecimiento espiritual y emocional a través de los Pasos.'),
  _GlossTerm('Sponsor',
      'Ver Madrina / Padrino.'),
  _GlossTerm('Tiempo de sobriedad',
      'Período continuo sin beber alcohol. A.A. celebra hitos con fichas o medallas como recordatorio del progreso.'),
];

class _GlossTerm {
  final String term;
  final String definition;
  const _GlossTerm(this.term, this.definition);
}

class GlossaryScreen extends StatefulWidget {
  const GlossaryScreen({super.key});
  @override
  _GlossaryScreenState createState() => _GlossaryScreenState();
}

class _GlossaryScreenState extends State<GlossaryScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _bgBreathController;
  late Animation<double> _bgBreath;
  final Set<int> _expanded = {};

  @override
  void initState() {
    super.initState();
    _bgBreathController = AnimationController(
        vsync: this, duration: const Duration(seconds: 7))
      ..repeat(reverse: true);
    _bgBreath = Tween<double>(begin: 0.03, end: 0.09).animate(
        CurvedAnimation(parent: _bgBreathController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _bgBreathController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Color>(
      valueListenable: appPrimaryColor,
      builder: (context, primary, _) {
        final isDark   = Theme.of(context).brightness == Brightness.dark;
        final bgColor  = isDark ? const Color(0xFF1A0800) : const Color(0xFFFFFBF5);
        final textPrim = isDark ? Colors.white : _kTextPrim;

        return Scaffold(
          backgroundColor: bgColor,
          body: AnimatedBuilder(
            animation: _bgBreath,
            builder: (context, child) => Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.topCenter,
                  radius: 1.4,
                  colors: [primary.withOpacity(_bgBreath.value * 0.6), bgColor],
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
                      'Glosario de A.A.',
                      style: TextStyle(
                        color: textPrim,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                      ),
                    ),
                    stretchModes: const [StretchMode.fadeTitle],
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (ctx, i) {
                        if (i == _glossaryTerms.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: Text(
                              'Definiciones de uso común en la comunidad de A.A. · Dominio público',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 11,
                                fontStyle: FontStyle.italic,
                                color: textPrim.withOpacity(0.35),
                                height: 1.5,
                              ),
                            ),
                          );
                        }
                        final term = _glossaryTerms[i];
                        final isOpen = _expanded.contains(i);
                        return GestureDetector(
                          onTap: () => setState(() {
                            isOpen ? _expanded.remove(i) : _expanded.add(i);
                          }),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 18, vertical: 14),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? Colors.white.withOpacity(0.06)
                                        : Colors.white.withOpacity(0.72),
                                    borderRadius: BorderRadius.circular(16),
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            term.term,
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                              color: textPrim,
                                              letterSpacing: -0.2,
                                            ),
                                          ),
                                          Icon(
                                            isOpen
                                                ? CupertinoIcons.chevron_up
                                                : CupertinoIcons.chevron_down,
                                            color: primary.withOpacity(0.7),
                                            size: 14,
                                          ),
                                        ],
                                      ),
                                      if (isOpen) ...[
                                        const SizedBox(height: 10),
                                        Container(
                                          height: 0.5,
                                          color: isDark
                                              ? Colors.white12
                                              : Colors.black12,
                                        ),
                                        const SizedBox(height: 10),
                                        Text(
                                          term.definition,
                                          style: TextStyle(
                                            fontSize: 15,
                                            color: textPrim.withOpacity(0.8),
                                            height: 1.55,
                                            fontFamily: 'Georgia',
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                      childCount: _glossaryTerms.length + 1,
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
