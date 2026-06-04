import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:ui';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_colors.dart';

const _kCream    = Color(0xFFFFFBF5);
const _kSepia    = Color(0xFFF8F0E3);
const _kDarkBg   = Color(0xFF1A1A1A);
const _kTextPrim = Color(0xFF431407);

// ─── Datos ────────────────────────────────────────────────────────────────────

class _Prayer {
  final String title;
  final String body;
  const _Prayer({required this.title, required this.body});
}

const _prayers = [
  _Prayer(
    title: 'Oración de la Serenidad',
    body:
        'Dios, concédeme la serenidad\n'
        'para aceptar las cosas que no puedo cambiar,\n'
        'el valor para cambiar las cosas que puedo,\n'
        'y la sabiduría para reconocer la diferencia.',
  ),
  _Prayer(
    title: 'Oración de la Serenidad (versión completa)',
    body:
        'Dios, concédeme la serenidad\n'
        'para aceptar las cosas que no puedo cambiar,\n'
        'el valor para cambiar las cosas que puedo,\n'
        'y la sabiduría para reconocer la diferencia.\n\n'
        'Viviendo un día a la vez,\n'
        'disfrutando un momento a la vez;\n'
        'aceptando las dificultades como un camino hacia la paz;\n'
        'tomando, como lo hizo Jesús,\n'
        'este mundo pecador tal como es,\n'
        'no como yo quisiera que fuera;\n'
        'confiando en que Tú harás que todo esté bien\n'
        'si me entrego a Tu voluntad;\n'
        'para que pueda ser razonablemente feliz en esta vida\n'
        'y supremamente feliz contigo para siempre en la próxima.\n\n'
        'Amén.',
  ),
  _Prayer(
    title: 'Oración de San Francisco de Asís',
    body:
        'Señor, hazme un instrumento de Tu paz.\n'
        'Donde haya odio, que yo siembre amor;\n'
        'donde haya ofensa, perdón;\n'
        'donde haya duda, fe;\n'
        'donde haya desesperación, esperanza;\n'
        'donde haya oscuridad, luz;\n'
        'donde haya tristeza, alegría.\n\n'
        'Oh Divino Maestro,\n'
        'concédeme que no busque tanto\n'
        'ser consolado como consolar,\n'
        'ser comprendido como comprender,\n'
        'ser amado como amar.\n\n'
        'Porque es dando que recibimos,\n'
        'es perdonando que somos perdonados,\n'
        'y es muriendo que nacemos a la vida eterna.\n\n'
        'Amén.',
  ),
  _Prayer(
    title: 'Oración del Tercer Paso',
    body:
        'Dios, me ofrezco a Ti — para que construyas conmigo\n'
        'y hagas de mí lo que quieras.\n'
        'Líbrame de mi propio encarcelamiento para que pueda\n'
        'cumplir mejor Tu voluntad.\n'
        'Quita de mí mis dificultades, para que la victoria sobre ellas\n'
        'dé testimonio a aquellos a quienes ayude\n'
        'de Tu poder, Tu amor y Tu camino de vida.\n'
        'Que yo haga Tu voluntad siempre.\n\n'
        'Amén.',
  ),
  _Prayer(
    title: 'Oración del Séptimo Paso',
    body:
        'Dios mío, estoy dispuesto a que tomes\n'
        'todo lo que soy, bueno y malo.\n'
        'Te ruego que elimines de mí cada uno\n'
        'de los defectos de carácter que obstaculizan\n'
        'mi utilidad para Ti y para mis semejantes.\n'
        'Concédeme la fortaleza para que al salir de aquí\n'
        'pueda hacer Tu voluntad.\n\n'
        'Amén.',
  ),
  _Prayer(
    title: 'Oración de la Noche',
    body:
        'Relájate y acepta esta situación.\n'
        'Mira solo el día de hoy.\n'
        'Por cada problema que surge, existe una solución.\n'
        'Nada es tan importante como parece ahora mismo.\n\n'
        'Mañana todo será diferente.\n'
        'Esta noche descansa en los brazos\n'
        'de un Poder Superior que jamás te abandona.',
  ),
];

// ─── Pantalla ─────────────────────────────────────────────────────────────────

class PrayersScreen extends StatefulWidget {
  const PrayersScreen({super.key});
  @override
  _PrayersScreenState createState() => _PrayersScreenState();
}

class _PrayersScreenState extends State<PrayersScreen>
    with TickerProviderStateMixin {

  late AnimationController _bgBreathController;
  late Animation<double>   _bgBreath;

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

  Future<void> _loadPrefs() async {
    final p = await SharedPreferences.getInstance();
    setState(() {
      _fontSize     = p.getDouble('prayers_fontsize') ?? 17.0;
      _readingTheme = p.getInt('prayers_theme') ?? 0;
    });
  }

  Future<void> _savePrefs() async {
    final p = await SharedPreferences.getInstance();
    await p.setDouble('prayers_fontsize', _fontSize);
    await p.setInt('prayers_theme', _readingTheme);
  }

  @override
  void dispose() {
    _bgBreathController.dispose();
    super.dispose();
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
                      onPressed: () {
                        setModal(() => setState(() {
                          _fontSize = (_fontSize - 1).clamp(13.0, 26.0);
                          _savePrefs();
                        }));
                      },
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
                      onPressed: () {
                        setModal(() => setState(() {
                          _fontSize = (_fontSize + 1).clamp(13.0, 26.0);
                          _savePrefs();
                        }));
                      },
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
        onTap: () {
          setModal(() => setState(() {
            _readingTheme = idx;
            _savePrefs();
          }));
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? primary : (dark ? Colors.white12 : Colors.black12),
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : (dark ? Colors.white70 : _kTextPrim),
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
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
        final dark     = _isDark(sysDark);

        return Scaffold(
          backgroundColor: bgColor,
          body: AnimatedBuilder(
            animation: _bgBreath,
            builder: (context, child) => Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.topCenter,
                  radius: 1.4,
                  colors: [
                    primary.withOpacity(_bgBreath.value * 0.6),
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
                  actions: [
                    CupertinoButton(
                      padding: const EdgeInsets.only(right: 16),
                      onPressed: () => _showSettings(primary, sysDark),
                      child: Icon(CupertinoIcons.textformat_size,
                          color: primary, size: 22),
                    ),
                  ],
                  flexibleSpace: FlexibleSpaceBar(
                    titlePadding: const EdgeInsets.only(left: 20, bottom: 14),
                    title: Text(
                      'Oraciones',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                      ),
                    ),
                    stretchModes: const [StretchMode.fadeTitle],
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 60),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (ctx, i) {
                        if (i < _prayers.length) {
                          return _buildPrayerCard(
                            prayer: _prayers[i],
                            primary: primary,
                            textColor: textColor,
                            dark: dark,
                          );
                        }
                        return _buildFooter(textColor);
                      },
                      childCount: _prayers.length + 1,
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

  Widget _buildPrayerCard({
    required _Prayer prayer,
    required Color primary,
    required Color textColor,
    required bool dark,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: ClipRRect(
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(
                        color: primary.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(CupertinoIcons.hands_sparkles_fill,
                          color: primary, size: 18),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        prayer.title,
                        style: TextStyle(
                          fontSize: _fontSize - 1,
                          fontWeight: FontWeight.w700,
                          color: primary,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  prayer.body,
                  style: TextStyle(
                    fontSize: _fontSize,
                    color: textColor,
                    height: 1.7,
                    fontFamily: 'Georgia',
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFooter(Color textColor) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 16),
      child: Text(
        'La Oración de la Serenidad y las oraciones de los pasos son de dominio público y forman parte de la tradición de Alcohólicos Anónimos. La Oración de San Francisco de Asís es de dominio público (siglo XIII).',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 11,
          color: textColor.withOpacity(0.4),
          height: 1.5,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }
}
