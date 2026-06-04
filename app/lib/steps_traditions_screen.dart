import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:ui';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_colors.dart';

const _kCream    = Color(0xFFFFFBF5);
const _kSepia    = Color(0xFFF8F0E3);
const _kDarkBg   = Color(0xFF1A1A1A);
const _kTextPrim = Color(0xFF431407);

const _pasos = [
  'Admitimos que éramos impotentes ante el alcohol, que nuestras vidas se habían vuelto ingobernables.',
  'Llegamos a creer que un Poder superior a nosotros mismos podría devolvernos el sano juicio.',
  'Decidimos poner nuestras voluntades y nuestras vidas al cuidado de Dios, como nosotros lo concebimos.',
  'Sin miedo hicimos un minucioso inventario moral de nosotros mismos.',
  'Admitimos ante Dios, ante nosotros mismos, y ante otro ser humano, la naturaleza exacta de nuestros defectos.',
  'Estuvimos enteramente dispuestos a dejar que Dios nos liberase de todos estos defectos de carácter.',
  'Humildemente le pedimos que nos liberase de nuestros defectos.',
  'Hicimos una lista de todas aquellas personas a quienes habíamos ofendido y estuvimos dispuestos a reparar el daño que les causamos.',
  'Reparamos directamente a cuantos nos fue posible el daño causado, excepto cuando el hacerlo implicaba perjuicio para ellos o para otros.',
  'Continuamos haciendo nuestro inventario personal y cuando nos equivocábamos lo admitíamos inmediatamente.',
  'Buscamos a través de la oración y la meditación mejorar nuestro contacto consciente con Dios, como nosotros lo concebimos, pidiéndole solamente que nos dejase conocer su voluntad para con nosotros y nos diese la fortaleza para cumplirla.',
  'Habiendo obtenido un despertar espiritual como resultado de estos pasos, tratamos de llevar este mensaje a otros alcohólicos y de practicar estos principios en todos nuestros asuntos.',
];

const _tradiciones = [
  'Nuestro bienestar común debe tener la preferencia; la recuperación personal depende de la unidad de A.A.',
  'Para el propósito de nuestro grupo solo existe una autoridad fundamental: un Dios amoroso tal como se exprese en la conciencia de nuestro grupo. Nuestros líderes no son sino servidores de confianza; no gobiernan.',
  'El único requisito para ser miembro de A.A. es querer dejar de beber.',
  'Cada grupo debe ser autónomo, excepto en asuntos que afecten a otros grupos o a Alcohólicos Anónimos considerado como un todo.',
  'Cada grupo tiene un solo objetivo primordial: llevar el mensaje al alcohólico que aún está sufriendo.',
  'Un grupo de A.A. nunca debe respaldar, financiar o prestar el nombre de A.A. a ninguna entidad allegada o empresa ajena, para evitar que los problemas de dinero, propiedad y prestigio nos desvíen de nuestro objetivo primordial.',
  'Cada grupo de A.A. debe mantenerse completamente a sí mismo, negándose a recibir contribuciones de afuera.',
  'Alcohólicos Anónimos nunca tendrá carácter profesional, pero nuestros centros de servicio pueden emplear trabajadores especiales.',
  'A.A. como tal nunca debe ser organizada; pero podemos crear juntas o comités de servicio que sean directamente responsables ante aquellos a quienes sirven.',
  'Alcohólicos Anónimos no tiene opinión acerca de asuntos ajenos a sus actividades; por consiguiente su nombre nunca debe mezclarse en polémicas públicas.',
  'Nuestra política de relaciones públicas se basa más bien en la atracción que en la promoción; necesitamos mantener siempre el anonimato personal ante la prensa, la radio y el cine.',
  'El anonimato es la base espiritual de todas nuestras Tradiciones, recordándonos siempre anteponer los principios a las personalidades.',
];

class StepsTraditionsScreen extends StatefulWidget {
  const StepsTraditionsScreen({super.key});
  @override
  _StepsTraditionsScreenState createState() => _StepsTraditionsScreenState();
}

class _StepsTraditionsScreenState extends State<StepsTraditionsScreen>
    with TickerProviderStateMixin {

  late TabController _tabController;
  late AnimationController _bgBreathController;
  late Animation<double> _bgBreath;

  int   _readingTheme = 0; // 0=auto, 1=sepia, 2=dark
  double _fontSize    = 17.0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
      _fontSize     = (p.getDouble('st_fontsize') ?? 17.0);
      _readingTheme = (p.getInt('st_theme') ?? 0);
    });
  }

  Future<void> _savePrefs() async {
    final p = await SharedPreferences.getInstance();
    await p.setDouble('st_fontsize', _fontSize);
    await p.setInt('st_theme', _readingTheme);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _bgBreathController.dispose();
    super.dispose();
  }

  Color _bgColor(bool isSystemDark) {
    if (_readingTheme == 1) return _kSepia;
    if (_readingTheme == 2) return _kDarkBg;
    return isSystemDark ? _kDarkBg : _kCream;
  }

  Color _textColor(bool isSystemDark) {
    final dark = _readingTheme == 2 || (_readingTheme == 0 && isSystemDark);
    return dark ? Colors.white.withOpacity(0.9) : _kTextPrim;
  }

  bool _isDark(bool isSystemDark) =>
      _readingTheme == 2 || (_readingTheme == 0 && isSystemDark);

  void _showSettings(Color primary, bool isSystemDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModal) {
          final dark = _isDark(isSystemDark);
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
                // Font size
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _iconBtn(CupertinoIcons.minus_circle, primary, () {
                      setModal(() => setState(() {
                        _fontSize = (_fontSize - 1).clamp(13.0, 26.0);
                        _savePrefs();
                      }));
                    }),
                    const SizedBox(width: 8),
                    Text('${_fontSize.toInt()} pt',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: dark ? Colors.white : _kTextPrim)),
                    const SizedBox(width: 8),
                    _iconBtn(CupertinoIcons.plus_circle, primary, () {
                      setModal(() => setState(() {
                        _fontSize = (_fontSize + 1).clamp(13.0, 26.0);
                        _savePrefs();
                      }));
                    }),
                  ],
                ),
                const SizedBox(height: 20),
                // Theme selector
                Row(
                  children: [
                    _themeBtn('Auto', 0, primary, dark, setModal),
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

  Widget _iconBtn(IconData icon, Color color, VoidCallback onTap) =>
      CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: onTap,
        child: Icon(icon, color: color, size: 28),
      );

  Widget _themeBtn(String label, int idx, Color primary, bool dark,
      StateSetter setModal) {
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
        final isSystemDark = Theme.of(context).brightness == Brightness.dark;
        final bgColor  = _bgColor(isSystemDark);
        final textColor = _textColor(isSystemDark);
        final dark = _isDark(isSystemDark);

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
            child: NestedScrollView(
              headerSliverBuilder: (ctx, innerBoxIsScrolled) => [
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
                      onPressed: () => _showSettings(primary, isSystemDark),
                      child: Icon(CupertinoIcons.textformat_size,
                          color: primary, size: 22),
                    ),
                  ],
                  flexibleSpace: FlexibleSpaceBar(
                    titlePadding: const EdgeInsets.only(left: 20, bottom: 56),
                    title: Text(
                      '12 Pasos y Tradiciones',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                      ),
                    ),
                    stretchModes: const [StretchMode.fadeTitle],
                  ),
                  bottom: PreferredSize(
                    preferredSize: const Size.fromHeight(44),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      height: 36,
                      decoration: BoxDecoration(
                        color: dark
                            ? Colors.white.withOpacity(0.1)
                            : Colors.black.withOpacity(0.07),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: TabBar(
                        controller: _tabController,
                        indicator: BoxDecoration(
                          color: primary,
                          borderRadius: BorderRadius.circular(9),
                        ),
                        indicatorSize: TabBarIndicatorSize.tab,
                        dividerColor: Colors.transparent,
                        labelColor: Colors.white,
                        unselectedLabelColor:
                            dark ? Colors.white60 : _kTextPrim.withOpacity(0.6),
                        labelStyle: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 13),
                        tabs: const [
                          Tab(text: '12 Pasos'),
                          Tab(text: '12 Tradiciones'),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
              body: TabBarView(
                controller: _tabController,
                children: [
                  _buildList(_pasos, primary, textColor, dark),
                  _buildList(_tradiciones, primary, textColor, dark),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildList(List<String> items, Color primary, Color textColor, bool dark) {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 60),
      itemCount: items.length + 1,
      itemBuilder: (ctx, i) {
        if (i < items.length) {
          return _buildCard(
            number: i + 1,
            text: items[i],
            primary: primary,
            textColor: textColor,
            dark: dark,
          );
        }
        return _buildCreditFooter(textColor, dark);
      },
    );
  }

  Widget _buildCreditFooter(Color textColor, bool dark) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 16),
      child: Text(
        'Los Doce Pasos y las Doce Tradiciones son reimpresos y adaptados con permiso de Alcoholics Anonymous World Services, Inc. El permiso para reimprimir este material no significa que A.A. haya revisado o aprobado el contenido de esta publicación, ni que A.A. esté de acuerdo con los puntos de vista aquí expresados. A.A. es un programa de recuperación del alcoholismo únicamente.',
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

  Widget _buildCard({
    required int number,
    required String text,
    required Color primary,
    required Color textColor,
    required bool dark,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            padding: const EdgeInsets.all(20),
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
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Number badge
                Container(
                  width: 36,
                  height: 36,
                  margin: const EdgeInsets.only(right: 14, top: 2),
                  decoration: BoxDecoration(
                    color: primary.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '$number',
                    style: TextStyle(
                      color: primary,
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                ),
                // Text
                Expanded(
                  child: Text(
                    text,
                    style: TextStyle(
                      fontSize: _fontSize,
                      color: textColor,
                      height: 1.55,
                      fontFamily: 'Georgia',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
