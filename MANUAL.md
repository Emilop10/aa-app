# Manual de la App de Sobriedad (A.A.)

Manual completo de la aplicación: qué hace, cómo está construida, cómo se desarrolla y publica, y la historia de su creación.

> Repositorio: `emilop10/aa-app` · Carpeta del proyecto Flutter: `app/` · Versión actual: `1.0.0+6`

---

## Índice

1. [Qué es la app](#1-qué-es-la-app)
2. [Principios y propósito](#2-principios-y-propósito)
3. [Stack tecnológico](#3-stack-tecnológico)
4. [Estructura del repositorio](#4-estructura-del-repositorio)
5. [Arranque de la app](#5-arranque-de-la-app)
6. [Navegación principal](#6-navegación-principal)
7. [Instructivo inicial (Onboarding)](#7-instructivo-inicial-onboarding)
8. [Inicio — Contador de sobriedad](#8-inicio--contador-de-sobriedad)
9. [Botón SOS / Apoyo inmediato](#9-botón-sos--apoyo-inmediato)
10. [Logros](#10-logros)
11. [Literatura](#11-literatura)
12. [Reflexiones diarias](#12-reflexiones-diarias)
13. [Escritura (Diario y Gratitud)](#13-escritura-diario-y-gratitud)
14. [Apoyo (Contactos y Mi Historia)](#14-apoyo-contactos-y-mi-historia)
15. [Ajustes](#15-ajustes)
16. [Notificaciones](#16-notificaciones)
17. [Sistema de diseño](#17-sistema-de-diseño)
18. [Almacenamiento de datos y privacidad](#18-almacenamiento-de-datos-y-privacidad)
19. [Derechos de autor y disclaimers](#19-derechos-de-autor-y-disclaimers)
20. [Widget de iOS (pendiente)](#20-widget-de-ios-pendiente)
21. [Desarrollo local](#21-desarrollo-local)
22. [Publicación en TestFlight](#22-publicación-en-testflight)
23. [Errores conocidos y soluciones](#23-errores-conocidos-y-soluciones)
24. [Historia del desarrollo](#24-historia-del-desarrollo)
25. [Pendientes e ideas futuras](#25-pendientes-e-ideas-futuras)
26. [Referencias](#26-referencias)

---

## 1. Qué es la app

Una aplicación móvil en español (enfocada en iOS) que acompaña a personas en recuperación dentro del programa de Alcohólicos Anónimos. Reúne en un solo lugar:

- Un **contador de sobriedad** con logros por hitos.
- Un **botón SOS** con frases de anclaje, la línea de A.A. México y tus contactos de apoyo.
- **Literatura** de A.A.: Libro Azul, 12 Pasos y 12 Tradiciones, oraciones y textos breves.
- **Reflexiones diarias** con calendario y racha de lectura.
- **Escritura**: diario personal y diario de gratitud.
- **Contactos de apoyo** (padrino/madrina, compañeros) con llamada y SMS directos.
- Personalización de color y tema, y recordatorios diarios.

Todo funciona **sin cuenta, sin servidor y sin conexión**: los datos viven solo en el teléfono.

## 2. Principios y propósito

- **Privacidad absoluta**: nada sale del dispositivo. Ni analíticas ni registro.
- **Calidez**: paleta cálida (naranja por defecto), tipografía legible y animaciones suaves.
- **Estética iOS nativa**: íconos Cupertino, glassmorphism, barras grandes, física de rebote.
- **No contraproducente**: se evita lo que pueda desanimar (por eso se quitó la sección "Etapas anteriores" de la pantalla principal).
- **Respeto a A.A.**: textos con atribución oficial a A.A. World Services y aclaración de que la app no está afiliada.

## 3. Stack tecnológico

| Área | Tecnología |
|---|---|
| Framework | Flutter (Dart SDK `>=2.17.0 <3.0.0`) |
| Plataforma objetivo | iOS (iPhone), distribuido vía TestFlight |
| Persistencia | `shared_preferences` |
| Notificaciones | `flutter_local_notifications`, `timezone`, `flutter_native_timezone` |
| Calendario | `table_calendar` |
| Fechas / idioma | `intl` (`es_ES`) |
| Llamadas y SMS | `url_launcher` (`tel:` y `sms:`) |
| Compartir | `share_plus` |
| Progreso circular | `percent_indicator` |
| Selector de color | `flutter_colorpicker` |
| Archivos | `path_provider` |
| Ícono | `flutter_launcher_icons` (`assets/logo/mi_logo.png`) |
| Íconos UI | `cupertino_icons ^1.0.8` |

> ⚠️ El SDK `<3.0.0` impide usar *records* de Dart 3 y paquetes recientes (por ejemplo `home_widget`).

## 4. Estructura del repositorio

```
aa-app/
├── MANUAL.md                       ← este documento
└── app/
    ├── pubspec.yaml                ← dependencias, versión, assets
    ├── assets/
    │   ├── daily_readings.json     ← reflexiones por fecha (365 días)
    │   ├── libro_azul_content.json ← Libro Azul extraído por capítulos
    │   ├── libro_azul.epub / .pdf  ← fuentes originales
    │   ├── 12_pasos.pdf, 12_tradiciones.pdf
    │   ├── fonts/                  ← Times New Roman (ya casi no se usa)
    │   ├── images/                 ← fondos antiguos del menú
    │   └── logo/                   ← ícono de la app
    ├── ios/
    │   ├── Runner/                 ← proyecto iOS
    │   └── SobrietyWidget/         ← widget WidgetKit (sin activar)
    └── lib/                        ← código Dart (≈9,500 líneas)
```

### Archivos de `lib/`

| Archivo | Función |
|---|---|
| `main.dart` | Arranque, zona horaria, notificaciones, temas claro/oscuro, onboarding |
| `app_colors.dart` | Color primario y modo de tema globales (`ValueNotifier`), 8 colores |
| `sobriety_counter.dart` | Contenedor con barra de pestañas flotante (6 pestañas) |
| `sobriety_counter_screen.dart` | Pantalla de Inicio: contador, frase del día, SOS |
| `achievements_screen.dart` | Logros por hitos |
| `literature_menu.dart` | Menú de literatura (8 entradas) |
| `libro_azul_screen.dart` | Lector del Libro Azul con subrayado |
| `steps_traditions_screen.dart` | Lector de 12 Pasos y 12 Tradiciones |
| `prayers_screen.dart` | Oraciones |
| `literature_extras_screens.dart` | Lector genérico + Cómo Funciona, Promesas, Preámbulo, 12 Conceptos, Glosario |
| `daily_readings.dart` | Reflexiones diarias, calendario y racha |
| `journal_menu.dart` | Menú de escritura |
| `journal_screen.dart` | Diario personal |
| `gratitude_journal_screen.dart` | Diario de gratitud |
| `support_screen.dart` | Menú de apoyo + "Mi Historia" |
| `support_contacts_screen.dart` | Contactos de apoyo |
| `settings_screen.dart` | Ajustes |
| `notification_service.dart` | Programación de notificaciones |
| `onboarding_screen.dart` | Instructivo inicial |
| `menu_item.dart` | Widget heredado de tarjetas con imagen |

## 5. Arranque de la app

Secuencia de `main()`:

1. Inicializa Flutter.
2. Configura la zona horaria local (para que las notificaciones lleguen a la hora correcta).
3. Inicializa el servicio de notificaciones.
4. Carga formatos de fecha en español.
5. Carga color primario y modo de tema guardados.
6. Lee `onboarding_done`: si es `false`, muestra el instructivo; si no, la app.
7. Si la app se abrió tocando la notificación de reflexión (`payload == 'daily_reflection'`), abre directamente Reflexiones Diarias.

## 6. Navegación principal

Barra de pestañas flotante con 6 secciones (íconos Cupertino, versión rellena al seleccionarse):

| # | Pestaña | Ícono |
|---|---|---|
| 1 | Inicio | `house` |
| 2 | Logros | `star` |
| 3 | Literatura | `book` |
| 4 | Reflexiones | `sun_max` |
| 5 | Escritura | `pencil` |
| 6 | Apoyo | `person_2` |

El ícono de engrane (Ajustes) está en la esquina superior izquierda de Inicio.

## 7. Instructivo inicial (Onboarding)

Se muestra solo la primera vez. Seis diapositivas con contador "n / 6":

1. **Bienvenido**
2. **Contador**
3. **Reflexión Diaria**
4. **Literatura**
5. **Escritura**
6. **Contactos de Apoyo**

Al terminar guarda `onboarding_done = true`. Se puede volver a ver desde **Ajustes → Acerca de → Ver instrucciones** (modo `isReplay`: muestra botón X y el último botón dice "Cerrar").

## 8. Inicio — Contador de sobriedad

- **Tarjeta principal** con el tiempo sobrio (años, meses, días) y animaciones ambientales (respiración de fondo, orbes flotantes).
- **Frase del día**: 50 frases de A.A. (`_kQuotes`) que rotan según el día del año.
- **Fecha de inicio** con botón para editarla.
- **Reinicio**: al cambiar la fecha, el periodo anterior se guarda internamente en `sobriety_history` (no se muestra en pantalla por decisión de diseño).
- **Botón SOS** al final (padding inferior de 120 px para quedar por encima de la barra flotante).
- Entrada escalonada de tarjetas con curvas `Interval`.

## 9. Botón SOS / Apoyo inmediato

Abre un `CupertinoModalPopup` con:

- **Frases de anclaje** para el momento de crisis.
- **Línea de A.A. México: 800 290 0024** (llamada directa).
- **Tus contactos de apoyo** (de `support_contacts`) con botón de llamar.

## 10. Logros

12 hitos con ícono y progreso hacia el siguiente:

| Hito | Días |
|---|---|
| 24 Horas | 1 |
| 1 Semana | 7 |
| 1 Mes | 30 |
| 3 Meses | 90 |
| 6 Meses | 180 |
| 1 Año | 365 |
| 2 Años | 730 |
| 3 Años | 1,095 |
| 5 Años | 1,825 |
| 10 Años | 3,650 |
| 15 Años | 5,475 |
| 20 Años | 7,300 |

## 11. Literatura

Menú con 8 tarjetas glassmorphism:

| Entrada | Descripción | Implementación |
|---|---|---|
| Libro Azul | Texto básico de A.A. (1ª edición) | `LibroAzulScreen` |
| 12 Pasos y Tradiciones | El programa de recuperación | `StepsTraditionsScreen` |
| Oraciones | Serenidad, San Francisco y más | `PrayersScreen` |
| Cómo Funciona | Capítulo 5 del Libro Grande | `LitTextScreen` |
| Las Promesas | Del Capítulo 6 | `LitTextScreen` |
| El Preámbulo | Leído en cada reunión | `LitTextScreen` |
| 12 Conceptos | Servicio mundial de A.A. | `LitTextScreen` |
| Glosario | Términos comunes de A.A. | `GlossaryScreen` (acordeón) |

### 11.1 Libro Azul
- Texto extraído del EPUB a `libro_azul_content.json` (17 secciones, incluye prólogo).
- Lector estilo Apple Books: índice de capítulos, tamaño de letra ajustable (`libro_azul_fontsize`), recuerda el capítulo (`libro_azul_chapter`).
- **Subrayado persistente** por capítulo; se puede borrar.
- Pie con aviso de derechos de autor.

### 11.2 12 Pasos y 12 Tradiciones
- Lector nativo (reemplazó al visor PDF que fallaba en iPhone físico).
- Tipografía **Georgia** para mostrar bien acentos y la Ñ.
- Tema de lectura guardado en `st_theme`.

### 11.3 Oraciones
Serenidad (corta y completa), San Francisco de Asís, Tercer Paso, Séptimo Paso y Oración de la Noche. Título centrado en el detalle; tema guardado en `prayers_theme`.

### 11.4 Textos breves
`LitTextScreen` es un lector reutilizable con controles de letra/tema; cada texto guarda sus preferencias (`lit_como`, `lit_prom`, `lit_pream`, `lit_conc`).

## 12. Reflexiones diarias

- Fuente: `assets/daily_readings.json`, una reflexión por fecha (título + contenido + cita).
- **Calendario** (`table_calendar`) para elegir cualquier fecha (botón "Fecha").
- **Racha de lectura 🔥**: al abrir la reflexión del día suma 1 si leíste ayer, reinicia a 1 si no; no cuenta dos veces el mismo día (`reading_streak`, `last_reading_date`).
- El título "Reflexiones" vive en el `title` del `SliverAppBar` para que la racha no se encime al hacer scroll; fondo transparente para mantener la estética.
- Disclaimer de derechos al pie.

## 13. Escritura (Diario y Gratitud)

**Menú** con dos tarjetas: Diario (`pencil_outline`) y Gratitud (`sun_min_fill`).

- **Diario personal** (`journal_entries`): lista de entradas y editor a pantalla completa.
- **Diario de gratitud** (`gratitude_entries`): banner diario "¿Por qué estás agradecido hoy?" que cambia a "¡Gratitud de hoy registrada!" cuando ya escribiste.

## 14. Apoyo (Contactos y Mi Historia)

- **Contactos de apoyo** (`support_contacts`, JSON): avatar con inicial, botones de llamar y SMS, hoja de acciones para editar/borrar, editor con nota opcional.
- **Mi Historia**: el origen de la app.

## 15. Ajustes

Secciones:

- **APARIENCIA**: 8 colores (Naranja, Azul, Verde, Violeta, Rosa, Teal, Rojo, Índigo) y modo claro / oscuro / automático.
- **NOTIFICACIONES**: activar recordatorio de reflexión diaria y su hora.
- **GRATITUD**: activar recordatorio de gratitud y su hora.
- **ACERCA DE**: información, disclaimers y "Ver instrucciones".

## 16. Notificaciones

| ID | Nombre | Canal | Al tocarla |
|---|---|---|---|
| 0 | Reflexión Diaria | "Reflexiones Diarias" | Abre Reflexiones |
| 1 | Diario de Gratitud | "Recordatorio de Gratitud" | Abre la app |

Se programan con `zonedSchedule` y `DateTimeComponents.time` (se repiten diario a la misma hora local).

## 17. Sistema de diseño

- **Color primario** global en `appPrimaryColor` (`ValueNotifier<Color>`); todas las pantallas lo escuchan con `ValueListenableBuilder`. Derivados: `appPrimaryDeep` y `appPrimaryDark`.
- **Tema claro**: fondo crema `#FFFBF5`, superficies `#FFF7ED`, texto café `#431407`.
- **Tema oscuro**: fondo `#1A0800`, superficies `#2D1506`.
- **Glassmorphism**: `ClipRRect` + `BackdropFilter(ImageFilter.blur)` + fondo semitransparente.
- **Barras**: `SliverAppBar` grandes, transparentes, `BouncingScrollPhysics`.
- **Animaciones**: entrada escalonada, gradiente radial que "respira", orbes flotantes.
- **Tipografía de lectura**: Georgia (soporte completo de español).
- **Íconos**: solo `CupertinoIcons` disponibles en `^1.0.8`.

## 18. Almacenamiento de datos y privacidad

Todo en `SharedPreferences`, local al dispositivo:

| Clave | Contenido |
|---|---|
| `onboarding_done` | Instructivo visto |
| `app_primary_color` | Color (hex) |
| `app_theme_mode` | `light` / `dark` / `system` |
| `notifications_enabled` | Recordatorio de reflexión |
| `gratitude_notif_enabled`, `gratitude_notif_time` | Recordatorio de gratitud |
| `reading_streak`, `last_reading_date` | Racha de lectura |
| `sobriety_history` | Periodos anteriores (JSON) |
| `support_contacts` | Contactos (JSON) |
| `journal_entries`, `gratitude_entries` | Diarios (JSON) |
| `libro_azul_chapter`, `libro_azul_fontsize` | Lector del Libro Azul |
| `st_theme`, `prayers_theme`, `lit_*` | Preferencias de lectura |

> Borrar la app borra todos los datos. No hay respaldo en la nube.

## 19. Derechos de autor y disclaimers

- Los textos de A.A. llevan pie con atribución a **Alcoholics Anonymous World Services, Inc. (AAWS)**, en el lenguaje oficial estandarizado.
- Se aclara que la app **no está afiliada ni respaldada** por A.A.
- El Libro Azul usado es la **primera edición** (1939).
- Revisión profunda de todos los disclaimers hecha antes de TestFlight.

## 20. Widget de iOS (pendiente)

`app/ios/SobrietyWidget/SobrietyWidget.swift` (WidgetKit, tamaños pequeño y mediano) lee `sobriety_days` y `sobriety_start_date` del App Group `group.com.tuapp.sobriety`.

**No está activo** porque `home_widget` es incompatible con el SDK actual. Para activarlo:
1. Subir el SDK a Dart 3 o escribir la información al App Group con un canal nativo propio.
2. En Xcode: crear target *Widget Extension* y activar *App Groups* en Runner y en el widget.

## 21. Desarrollo local

```bash
git clone https://github.com/emilop10/aa-app.git
cd aa-app
git checkout claude/sharp-meitner-7SiNa
cd app
flutter pub get
flutter run            # o: flutter run --release en iPhone conectado
```

Para actualizar: `git pull origin claude/sharp-meitner-7SiNa`.

## 22. Publicación en TestFlight

1. Subir el número de build en `pubspec.yaml` (`1.0.0+6` → `1.0.0+7`).
2. `flutter pub get` y `open ios/Runner.xcworkspace` (nunca `.xcodeproj`).
3. En Runner → *Signing & Capabilities*: equipo y firma automática.
4. Destino: **Any iOS Device (arm64)**.
5. **Product → Archive**.
6. Organizer → **Distribute App → TestFlight & App Store → Upload**.
7. En App Store Connect → TestFlight: esperar procesamiento, responder cifrado ("No") y asignar testers.

## 23. Errores conocidos y soluciones

| Error | Causa | Solución |
|---|---|---|
| `Member not found: 'hands_sparkles_fill'`, `clock_arrow_circlepath`, `crown`, `flame`… | Ícono no existe en `cupertino_icons ^1.0.8` | Usar un ícono existente |
| Records de Dart 3 no compilan | SDK `<3.0.0` | Listas separadas |
| `home_widget`: `No named parameter 'size'` | Paquete incompatible | Se eliminó el paquete |
| PDF no abre en iPhone físico | Visores PDF (syncfusion, vocsy, pdfview) | Lectores nativos con texto |
| Acentos/Ñ raros | Times New Roman embebida | Fuente Georgia |
| Botón SOS inalcanzable | Poco padding inferior | Padding 120 |
| 🔥 encima del título | Título en `FlexibleSpaceBar` | Título en `SliverAppBar.title` |
| Subrayados amarillos en textos | Texto sin `Material` | `TextDecoration.none` |

## 24. Historia del desarrollo

**Abril 2026 — Inicio**
- Primera versión: contador, reflexiones diarias y menú con imágenes.

**3 de junio 2026 — Rediseño iOS**
- Rediseño completo estilo iOS: barra flotante, Logros, reflexiones, literatura, escritura y apoyo.
- Arreglos de compatibilidad (records, íconos).
- Calendario de reflexiones pulido.
- Animaciones ambientales en todas las pantallas.
- Colores personalizables y modo claro/oscuro/auto.
- Libro Azul: de PDF a lector EPUB propio estilo Apple Books con subrayado.
- Limpieza de paquetes (syncfusion, vocsy).

**4 de junio 2026 — Literatura y legalidad**
- 12 Pasos y Tradiciones en lector nativo; cambio a Georgia por acentos.
- Disclaimers de AAWS en todas las secciones, estandarizados al texto oficial.
- Pantalla de Oraciones y rediseño del menú de literatura (sin imágenes).

**9 de junio 2026 — Funciones de acompañamiento**
- Nuevas secciones: Cómo Funciona, Promesas, Preámbulo, 12 Conceptos, Glosario.
- Onboarding de 6 pasos, repetible desde Ajustes.
- Rediseño de Escritura y Contactos de Apoyo.
- SOS, racha de lectura, historial, frase del día y notificación de gratitud.
- Se retiró `home_widget`; widget queda pendiente.
- Ajustes previos a TestFlight: SOS alcanzable, racha sin encimarse, se quitó "Etapas anteriores".

**Octubre 2026** — Se documenta todo en este manual.

## 25. Pendientes e ideas futuras

- [ ] Subir build 7 a TestFlight y recoger retroalimentación.
- [ ] Cambiar `CFBundleDisplayName` (hoy dice "App") y el `name` de `pubspec.yaml`.
- [ ] Activar el widget de iOS.
- [ ] Respaldo/exportación de diarios (con `share_plus`).
- [ ] Borrar assets que ya no se usan (`images/*_bg.png`, PDFs, fuentes Times) para aligerar la app.
- [ ] Buscador de reunión cercana / enlaces oficiales.
- [ ] Pruebas automatizadas básicas en `app/test/`.

## 26. Referencias

- Alcohólicos Anónimos (sitio oficial): https://www.aa.org
- Central Mexicana de Servicios Generales de A.A.: https://www.aa.org.mx
- Flutter: https://docs.flutter.dev
- `flutter_local_notifications`: https://pub.dev/packages/flutter_local_notifications
- `shared_preferences`: https://pub.dev/packages/shared_preferences
- `table_calendar`: https://pub.dev/packages/table_calendar
- `url_launcher`: https://pub.dev/packages/url_launcher
- Apple TestFlight: https://developer.apple.com/testflight/
- Human Interface Guidelines: https://developer.apple.com/design/human-interface-guidelines/
- WidgetKit: https://developer.apple.com/documentation/widgetkit
