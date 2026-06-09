import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:ui';
import 'libro_azul_screen.dart';
import 'steps_traditions_screen.dart';
import 'prayers_screen.dart';
import 'literature_extras_screens.dart';
import 'app_colors.dart';

const _kCream    = Color(0xFFFFFBF5);
const _kTextPrim = Color(0xFF431407);
const _kDarkBg   = Color(0xFF1A0800);

// ─── Content for static text screens ────────────────────────────────────────

const _preambleBody =
    'Alcohólicos Anónimos es una comunidad de hombres y mujeres que comparten '
    'su mutua experiencia, fortaleza y esperanza para resolver su problema común '
    'y ayudar a otros a recuperarse del alcoholismo.\n\n'
    'El único requisito para ser miembro de A.A. es el deseo de dejar de beber. '
    'Para ser miembro de A.A. no se pagan honorarios ni cuotas; nos mantenemos '
    'con nuestras propias contribuciones.\n\n'
    'A.A. no está afiliada a ninguna secta, religión, partido político, '
    'organización o institución alguna; no desea intervenir en controversias, '
    'no respalda ni se opone a ninguna causa.\n\n'
    'Nuestro objetivo primordial es mantenernos sobrios y ayudar a otros '
    'alcohólicos a alcanzar el estado de sobriedad.';

const _preambleFooter =
    'El Preámbulo de A.A. · Reproducido con fines de recuperación sin ánimo de lucro. '
    'No implica revisión ni aprobación por parte de A.A.W.S., Inc.';

const _promisesBody =
    'Si nos aplicamos a ellos, antes de darnos cuenta nos sorprenderemos de los '
    'resultados. Conoceremos una nueva libertad y una nueva felicidad. No '
    'lamentaremos el pasado ni desearemos cerrar la puerta que lo separa del '
    'presente. Comprenderemos la palabra serenidad y conoceremos la paz.\n\n'
    'Sin importar lo tan bajo que hayamos caído, nos daremos cuenta de que '
    'nuestra experiencia puede beneficiar a otros. Desaparecerá ese sentimiento '
    'de inutilidad y lástima de nosotros mismos. Perderemos el interés en cosas '
    'egoístas y lo ganaremos en nuestros semejantes. Desaparecerá la ambición '
    'personal mezquina.\n\n'
    'Nuestra actitud y nuestra forma de ver la vida cambiarán. Se nos quitará el '
    'miedo a las personas y a la inseguridad económica. Intuitivamente sabremos '
    'cómo manejar situaciones que antes nos desconcertaban. De repente nos '
    'daremos cuenta de que Dios está haciendo por nosotros lo que nosotros no '
    'podíamos hacer por nosotros mismos.\n\n'
    '¿Son estos hechos exagerados? Creemos que no. Se están cumpliendo entre '
    'nosotros, a veces rápidamente, a veces lentamente. Siempre se harán '
    'realidad si trabajamos para lograrlos.';

const _promisesFooter =
    'Las Promesas · Del Capítulo 6 del Libro Grande de Alcohólicos Anónimos, '
    '1ª edición (dominio público en EE. UU.). '
    'Alcohólicos Anónimos® es marca registrada de A.A.W.S., Inc. '
    'Reproducido con fines de recuperación sin ánimo de lucro.';

const _comoFuncionaBody =
    'Rara vez hemos visto fracasar a una persona que haya seguido sinceramente '
    'nuestro camino. A aquellos que no se recuperan les es imposible ser '
    'honestos consigo mismos. Hay hombres y mujeres que son incapaces de '
    'entregarse y practicar nuestros métodos. Sus problemas mentales y emocionales '
    'son tan graves que, en apariencia, nada puede hacerse por ellos. No son '
    'culpables; parecen haber nacido así. Son naturalmente incapaces de entender '
    'y desarrollar una manera de vivir que exige una rigurosa honestidad. Sus '
    'posibilidades de recuperación son inferiores al término medio.\n\n'
    'Hay quienes sufren de enfermedades mentales graves, pero muchos de ellos '
    'se recuperan si tienen la capacidad de ser honestos.\n\n'
    'Nuestras historias revelan de una manera general lo que éramos, lo que '
    'nos ocurrió y lo que somos ahora. Si usted ha tomado la decisión de hacer '
    'lo que nosotros hacemos y está dispuesto a hacer lo que sea necesario, '
    'entonces está listo para dar ciertos pasos.\n\n'
    'En algunos de nosotros han producido algunos resultados asombrosos. Pero '
    'debemos mencionar antes que ha habido casos en que el alcohol no parecía '
    'ser el problema principal. Hay un principio que es una barra en contra de '
    'toda información, que es a prueba de toda argumentación y que no puede '
    'fallar para mantener a un hombre en una ignorancia permanente; ese '
    'principio es el desprecio antes del examen.\n\n'
    'Nuestra descripción del alcohólico, el capítulo para el agnóstico y las '
    'historias personales de las páginas siguientes, deben aclarar tres puntos '
    'importantes para el hombre:\n\n'
    '1. Que él es alcohólico y no puede manejar su propia vida.\n'
    '2. Que probablemente ningún poder humano puede aliviar su alcoholismo.\n'
    '3. Que Dios puede y quiere si se le busca.';

const _comoFuncionaFooter =
    'Cómo Funciona · Del Capítulo 5 del Libro Grande de Alcohólicos Anónimos, '
    '1ª edición (dominio público en EE. UU.). '
    'Alcohólicos Anónimos® es marca registrada de A.A.W.S., Inc. '
    'Reproducido con fines de recuperación sin ánimo de lucro.';

const _conceptosBody =
    '1. La responsabilidad y la autoridad finales de los servicios mundiales '
    'de A.A. deben residir siempre en la conciencia colectiva de toda nuestra '
    'Comunidad.\n\n'
    '2. Los Grupos de A.A. han delegado a la Conferencia de Servicios Generales '
    'la suficiente autoridad de servicio para hacer posible que sus comités, '
    'juntas de servicio y su personal de servicios, lleven a cabo sus '
    'responsabilidades de servicio asignadas.\n\n'
    '3. Para garantizar una dirección de liderazgo efectivo, debemos conceder '
    'a cada elemento principal de la estructura mundial de A.A. —la Conferencia, '
    'la Junta de Servicios Generales y su personal de servicio corporativo, '
    'los administradores y los directores— el "derecho de decisión" apropiado '
    'para cada área de responsabilidad asignada.\n\n'
    '4. La participación en el liderazgo es la forma de gobierno de A.A. El '
    '"derecho de participación" es un privilegio de servicio que el miembro '
    'puede ejercitar únicamente en aquellas áreas de servicio en que se lo '
    'permite su propio conocimiento y experiencia.\n\n'
    '5. A través de su Conferencia, los miembros de A.A. deben lograr un '
    'control efectivo sobre todos sus fondos y propiedades mundiales de '
    'servicio, con la disposición de que los activos de la Junta de Servicios '
    'Generales sean siempre de suficiente valor para garantizar una operación '
    'y una continuidad efectivas.\n\n'
    '6. La Conferencia reconoce que el principal objetivo del liderazgo de A.A. '
    'es servir con un amor verdadero al bienestar de toda la Comunidad de A.A., '
    'que ninguna disposición se utilizará jamás para negar el derecho de apelación '
    'y petición.\n\n'
    '7. Los administradores de la Junta de Servicios Generales son los '
    '"custodios" de los servicios mundiales de A.A.; poseen y administran todo '
    'el fondo de dotación de A.A. y sus propiedades mundiales de servicio; son '
    'los únicos firmantes legales de los contratos de la Junta y son '
    'responsables de las finanzas de la Junta.\n\n'
    '8. Los miembros del Consejo de la Junta de Servicios Generales actuarán '
    'en todo lo posible como efectivos agentes ejecutivos y guardianes del '
    'bienestar de A.A., que actuarán como tales.\n\n'
    '9. Una buena dirección en el nivel del servicio mundial exige un liderazgo '
    'especial. Para ser eficaces, los miembros del Consejo deben estar libres '
    'para manejar los asuntos de A.A. y tomar las decisiones que sean necesarias.\n\n'
    '10. Cada uno de los principales elementos del servicio mundial de A.A. '
    'tiene la responsabilidad de ser plenamente informado de todos los asuntos '
    'de importancia que afecten a A.A. y tiene el derecho de ser consultado al '
    'respecto.\n\n'
    '11. Los administradores de A.A. son directamente responsables ante aquellos '
    'a quienes sirven.\n\n'
    '12. El espíritu de los Doce Conceptos es que los servicios de A.A. se '
    'mantengan siempre sensibles, responsables y completamente eficaces para la '
    'recuperación de los alcohólicos.';

const _conceptosFooter =
    'Los Doce Conceptos para el Servicio Mundial son reimpresos y adaptados con '
    'permiso de Alcoholics Anonymous World Services, Inc. El permiso para '
    'reimprimir este material no significa que A.A. haya revisado o aprobado el '
    'contenido de esta publicación, ni que A.A. esté de acuerdo con los puntos '
    'de vista aquí expresados. A.A. es un programa de recuperación del '
    'alcoholismo únicamente.';

// ─── Menu ────────────────────────────────────────────────────────────────────

class LiteratureMenu extends StatefulWidget {
  const LiteratureMenu({super.key});
  @override
  _LiteratureMenuState createState() => _LiteratureMenuState();
}

class _LiteratureMenuState extends State<LiteratureMenu>
    with TickerProviderStateMixin {

  late AnimationController _bgBreathController;
  late Animation<double>   _bgBreath;
  late AnimationController _entryController;
  late List<Animation<double>>  _fades;
  late List<Animation<Offset>>  _slides;

  static const _itemCount = 8;

  @override
  void initState() {
    super.initState();
    _bgBreathController = AnimationController(
        vsync: this, duration: const Duration(seconds: 7))
      ..repeat(reverse: true);
    _bgBreath = Tween<double>(begin: 0.03, end: 0.09).animate(
        CurvedAnimation(parent: _bgBreathController, curve: Curves.easeInOut));

    _entryController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1400));

    _fades  = [];
    _slides = [];
    for (int i = 0; i < _itemCount; i++) {
      final start = i / (_itemCount + 1);
      final end   = (i + 2) / (_itemCount + 1);
      _fades.add(Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
          parent: _entryController,
          curve: Interval(start, end, curve: Curves.easeOut))));
      _slides.add(Tween<Offset>(
              begin: Offset(0, 0.06 + i * 0.01), end: Offset.zero)
          .animate(CurvedAnimation(
              parent: _entryController,
              curve: Interval(start, end, curve: Curves.easeOut))));
    }

    _entryController.forward();
  }

  @override
  void dispose() {
    _bgBreathController.dispose();
    _entryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Color>(
      valueListenable: appPrimaryColor,
      builder: (context, primary, child) {
        final isDark   = Theme.of(context).brightness == Brightness.dark;
        final bgColor  = isDark ? _kDarkBg : _kCream;
        final textPrim = isDark ? Colors.white : _kTextPrim;

        final items = [
          _MenuItem('Libro Azul',           'Texto básico de A.A.',              CupertinoIcons.book_fill,      const LibroAzulScreen()),
          _MenuItem('12 Pasos y Tradiciones','El programa de recuperación',       CupertinoIcons.list_number,    const StepsTraditionsScreen()),
          _MenuItem('Oraciones',            'Serenidad, San Francisco y más',     CupertinoIcons.heart_fill,     const PrayersScreen()),
          _MenuItem('Cómo Funciona',        'Capítulo 5 del Libro Grande',        CupertinoIcons.arrow_right_circle_fill,
              const LitTextScreen(title: 'Cómo Funciona', body: _comoFuncionaBody, footer: _comoFuncionaFooter, prefsKey: 'lit_como')),
          _MenuItem('Las Promesas',         'Del Capítulo 6 del Libro Grande',   CupertinoIcons.star_fill,
              const LitTextScreen(title: 'Las Promesas', body: _promisesBody, footer: _promisesFooter, prefsKey: 'lit_prom')),
          _MenuItem('El Preámbulo',         'Leído en cada reunión de A.A.',      CupertinoIcons.text_quote,
              const LitTextScreen(title: 'El Preámbulo', body: _preambleBody, footer: _preambleFooter, prefsKey: 'lit_pream')),
          _MenuItem('12 Conceptos',         'Para el servicio mundial de A.A.',   CupertinoIcons.globe,
              const LitTextScreen(title: '12 Conceptos', body: _conceptosBody, footer: _conceptosFooter, prefsKey: 'lit_conc')),
          _MenuItem('Glosario',             'Términos comunes de A.A.',           CupertinoIcons.doc_text_fill,  const GlossaryScreen()),
        ];

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
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                    child: Column(
                      children: [
                        for (int i = 0; i < items.length; i++) ...[
                          FadeTransition(
                            opacity: _fades[i],
                            child: SlideTransition(
                              position: _slides[i],
                              child: _buildMenuItem(
                                context: context,
                                item: items[i],
                                primary: primary,
                                isDark: isDark,
                              ),
                            ),
                          ),
                          if (i < items.length - 1) const SizedBox(height: 14),
                        ],
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

  Widget _buildMenuItem({
    required BuildContext context,
    required _MenuItem item,
    required Color primary,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => item.screen),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 22),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withOpacity(0.06)
                  : Colors.white.withOpacity(0.72),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: isDark
                    ? Colors.white.withOpacity(0.09)
                    : Colors.white.withOpacity(0.9),
                width: 0.8,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: primary.withOpacity(0.13),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(item.icon, color: primary, size: 24),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : _kTextPrim,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        item.subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark
                              ? Colors.white38
                              : _kTextPrim.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(CupertinoIcons.chevron_right,
                    color: primary.withOpacity(0.6), size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MenuItem {
  final String   title;
  final String   subtitle;
  final IconData icon;
  final Widget   screen;
  const _MenuItem(this.title, this.subtitle, this.icon, this.screen);
}
