# Pendientes de la App de Sobriedad

Lista de trabajo después de la revisión a fondo del 15 de octubre de 2026. La revisión la hicieron 5 agentes especialistas (código, arquitectura móvil, experiencia de usuario, accesibilidad y cumplimiento legal) y se verificó contra el código.

- **Cómo usar este archivo:** marca `[x]` lo que se termine. Cada punto dice dónde está el problema y cómo se arregla.
- **Estado actual:** la app corre en el simulador con iOS 27 y el **build 7 ya está en TestFlight** para uso interno, **sin estos arreglos**.
- **Prioridades:** 🔴 urgente antes de publicar · 🟠 importante · 🟡 accesibilidad · 🔵 técnico y publicación · 💡 ideas nuevas.

---

## Fase 1: arreglos rápidos y seguros

Son cambios pequeños, de bajo riesgo y de alto impacto. Caben en una sesión.

- [ ] 🔴 **Llamar y mandar SMS a los contactos de apoyo no funciona en iPhone.** `support_contacts_screen.dart:89` y `:96` usan `canLaunchUrl`, y `Info.plist` no declara `LSApplicationQueriesSchemes`. El botón no hace nada y no avisa.
  - **Arreglo:** llamar a `launchUrl` directamente, mostrar un aviso si falla y agregar `tel`/`sms` a `LSApplicationQueriesSchemes`.
- [ ] 🔴 **Un registro dañado borra el diario completo.** Pasa en `journal_screen.dart:77-93`, `gratitude_journal_screen.dart:68-84`, `support_contacts_screen.dart:70-85` y `sobriety_counter_screen.dart:220-227`. Si una entrada no se puede leer, la lista sale vacía, y al guardar una entrada nueva se sobrescribe todo lo anterior.
  - **Arreglo:** leer cada entrada con try/catch y saltar las inválidas. Nunca sobrescribir si la lectura falló. Generar ids únicos.
- [ ] 🔴 **"Donaciones y membresías" en Mi Historia** (`support_screen.dart:~410`). Apple rechaza pedir dinero por fuera de su sistema de pagos (reglas 3.1.1 y 3.2.1) y además contradice la Séptima Tradición.
  - **Arreglo:** quitar la frase.
- [ ] 🟠 **Apagar la notificación de reflexión también apaga la de gratitud** (`settings_screen.dart:108-114`, usa `cancelAllNotifications()`).
  - **Arreglo:** crear `cancelDailyNotification()` con `cancel(0)`.
- [ ] 🟠 **Tocar la notificación de gratitud no hace nada** (`notification_service.dart:43`, TODO).
  - **Arreglo:** abrir el diario de gratitud.
- [ ] 🟠 **Los selectores de fecha y hora y el menú copiar/pegar salen en inglés** (`main.dart`).
  - **Arreglo:** agregar `flutter_localizations`, los `GlobalMaterial/Cupertino/WidgetsLocalizations` y `locale: Locale('es', 'MX')`.
- [ ] 🟠 **El permiso de notificaciones se pide antes del onboarding** y aparece con el nombre "App" (`notification_service.dart:25-27`, `requestAlertPermission: true` en `init()`).
  - **Arreglo:** pedirlo cuando el usuario active un recordatorio.
- [ ] 🟠 **El arranque es frágil.** Si la zona horaria no se encuentra, la app se queda en la pantalla de carga (`main.dart:42-46`, `notification_service.dart:48-52`). Además, la zona horaria se configura dos veces.
  - **Arreglo:** usar try/catch con `tz.UTC` como respaldo y configurar la zona una sola vez.
- [ ] 🟠 **Agregar avisos.** Faltan dos en Ajustes → Acerca de: que la app **no está afiliada** a A.A., AAWS ni Central Mexicana, y un **aviso médico**: la app no sustituye atención médica y dejar el alcohol de golpe puede ser peligroso. Agregar también la versión de la app.
- [ ] 🔵 **Quitar archivos que no se usan (unos 6 MB).**
  - Archivos: `images/*_bg.png`, `libro_azul.pdf`, `libro_azul.epub`, `12_pasos.pdf`, `12_tradiciones.pdf` (estos dos son de AAWS), la fuente Times New Roman (licencia de Monotype) y `assets/logo/` del bundle.
  - Código: `lib/menu_item.dart`, `libroazultexto.pdf` y `libro_azul.json` (vacío).
  - Paquetes: `flutter_colorpicker` y `path_provider`.
- [ ] 🔵 **Quitar capacidades que no se usan.** `aps-environment` en `Runner.entitlements`, `remote-notification` y `fetch` en `UIBackgroundModes` (regla 2.5.4). Agregar `ITSAppUsesNonExemptEncryption = NO` para que TestFlight no pregunte por cifrado en cada build.
- [ ] 🔵 **Agregar `if (!mounted) return;` después de cada `await`.**
  - En `settings_screen.dart:80`, `libro_azul_screen.dart:136`, `prayers_screen.dart:311`, `literature_extras_screens.dart:57`, `steps_traditions_screen.dart:71` y `sobriety_counter_screen.dart:285,291`.
  - En `sobriety_counter_screen.dart:212` y `achievements_screen.dart:139`, usar `DateTime.tryParse`.

## Fase 2: decisiones tuyas (contenido y legal)

Estos puntos no se pueden resolver solo con código. Los marcados **[ABOGADO]** necesitan la opinión de un especialista en propiedad intelectual en México.

- [ ] 🔴 **Verificar el teléfono del SOS.** "800 290 0024 · Línea Nacional A.A. · Gratuita 24/7" (`sobriety_counter_screen.dart:570,586`) **no está verificado**: lo agregó Claude y no se encontró ninguna fuente que lo respalde. Un número equivocado en un botón de crisis es el error más grave posible.
  - Confirmarlo por escrito con la oficina de A.A. que corresponda (aa.org.mx se presenta como "Alcohólicos Anónimos, Sección México, A.C.") y anotar la fecha. Si no se confirma, quitarlo.
  - Agregar **911** y **Línea de la Vida (800 911 2000)**, también verificando que estén vigentes.
- [ ] 🔴 **Reflexiones Diarias.** Las 366 completas (`assets/daily_readings.json`) son de AAWS, y el aviso dice "Reimpresos con permiso de A.A.W.S." (`daily_readings.dart:441`). Si no hay permiso por escrito, el aviso es falso.
  - **Opciones:**
    - (a) pedir licencia a AAWS;
    - (b) reemplazar las reflexiones con contenido propio;
    - (c) mostrar solo la cita y la página de referencia, sin el texto.
  - Mientras tanto, quitar el botón de compartir el texto completo.
- [ ] 🔴 **Corregir avisos falsos en la literatura** (`literature_menu.dart`).
  - [ ] **Promesas:** dice "1ª edición (dominio público)" pero el texto no viene de la traducción de 1997 que ya está en la app. Reemplazarlo con el texto exacto del capítulo 6 del JSON.
  - [ ] **Cómo Funciona:** no incluye los 12 Pasos y mezcla la cita de Spencer del Apéndice II, que no existía en 1939. Reemplazarlo con el texto exacto del capítulo 5 del JSON.
  - [ ] **Preámbulo:** su derecho de autor es de **The A.A. Grapevine, Inc.**, no de AAWS. Corregir la atribución o pedir permiso.
  - [ ] **12 Conceptos:** son una paráfrasis inexacta (los conceptos 6, 8, 9, 11 y 12 no coinciden con la redacción oficial) con un aviso de "con permiso". Usar el texto exacto con permiso, o quitarlos.
  - [ ] **Doce Pasos y Doce Tradiciones** (`steps_traditions_screen.dart:346`): dice "reimpresos y adaptados con permiso". Pedir permiso a AAWS (suele darlo para las versiones cortas) o cambiar el aviso.
  - [ ] **Oraciones:** las del 3er y 7º Paso deben tomarse de la traducción de 1997. "Oración de la Noche" no es literatura de A.A., así que hay que etiquetarla correctamente.
  - [ ] **Glosario:** dice "Dominio público", pero es un texto escrito por nosotros. Cambiar la etiqueta.
- [ ] 🟠 **Libro Azul:** agregar la página del EPUB (`index_split_018.html`) donde los traductores (AA BBSG, 1996/97) declaran la obra de dominio público, y citar la fuente. Quitar la sección "Servicios AA", que tiene directorios y teléfonos de 1997 que ya no sirven. **[ABOGADO]** Revisar si la obra original sigue protegida en México (vida del autor + 100 años).
- [ ] 🟠 **Marcas:** no usar "AA" ni "Alcohólicos Anónimos" en el nombre ni en el subtítulo de la tienda. Quitar "®" hasta verificar el registro en el IMPI. **[ABOGADO]** ¿Quién es el titular de las marcas en México?
- [ ] 🟠 **Redacción**
  - Género mezclado ("Bienvenido", "sobrio/a", "agradecido"): usar frases neutras como "días de sobriedad", "Te damos la bienvenida", "¿Qué agradeces hoy?".
  - En `_kQuotes`:
    - "La recovery es un maratón" (spanglish).
    - "Primero lo primero" está repetida.
    - "Tú no causaste esto…" es un lema de Al-Anon.
    - Hay traducciones literales: "Deja ir y deja a Dios" en México se dice "Suéltalo y déjaselo a Dios".
  - Unificar "Libro Azul" y "Libro Grande".
  - Cambiar "Contactos de emergencia" por "Contactos de apoyo".

## Fase 3: experiencia de usuario

- [ ] 🟠 **SOS siempre visible.** Hoy solo aparece al final de Inicio, **no existe si no hay fecha registrada** y el onboarding no lo menciona.
  - **Arreglo:** un botón fijo de "Ayuda" en todas las pantallas, también en el estado vacío.
- [ ] 🟠 **Mejorar el contenido del SOS.**
  - Agregar scroll (con 4 o más contactos se desborda).
  - Agregar SMS y WhatsApp, además de llamar.
  - Mostrar la nota del contacto y permitir marcar al padrino o madrina como principal.
  - Agregar una respiración guiada de 60 segundos y el chequeo HALT (Hambre, Enojo, Soledad, Cansancio).
  - Agregar un ícono de ancla en lugar del check.
- [ ] 🟠 **Flujo compasivo ante una recaída.** Separar "Corregir fecha", que no debe guardarse en el historial, de "Volver a empezar", que debe mostrar un mensaje como "Regresar es parte del camino. Hoy cuenta." y ofrecer llamar al padrino o escribir en el diario.
  - Hoy, cualquier "Listo" en el selector guarda un periodo en `sobriety_history` (`sobriety_counter_screen.dart:275-288`).
  - En Logros, con 0 días, mostrar "Tu primer logro está a 24 horas" sin candados dobles.
- [ ] 🟠 **Corregir las fechas.** Crear una sola función de fechas de calendario y usarla en Inicio y Logros. Resuelve estos casos:
  - El contador cambia de día a la hora en que se guardó la fecha, no a medianoche. Al guardar hay que normalizar con `DateTime(y, m, d)` (`sobriety_counter_screen.dart:240,290,204`).
  - Muestra "1 mes, -2 días" (`sobriety_counter_screen.dart:198-205`, `achievements_screen.dart:121-127`).
  - Los logros usan 30 o 365 días fijos, y "1 Año" se desbloquea un día antes en años bisiestos (`achievements_screen.dart:69-80`).
  - El cambio de horario resta un día.
- [ ] 🟠 **La racha 🔥 cuenta aperturas de la app, no lecturas.** `IndexedStack` construye la pestaña al arrancar (`daily_readings.dart:120-137`).
  - Contar la lectura cuando la pestaña está visible.
  - Usar `DateTime(y, m, d - 1)` para "ayer" (`:96`), porque el cambio de horario reinicia la racha.
  - Mostrar un mensaje suave cuando la racha se rompe.
- [ ] 🟠 **No hay reflexión el 29 de febrero.** La clave `2025-02-29` se convierte en el 1 de marzo (`daily_readings.dart:121-126`).
  - **Arreglo:** usar `"MM-dd"` como clave.
- [ ] 🟠 **Abrir la app desde la notificación puede no llevar a la reflexión** con la app cerrada en iOS 27. Falta guardar el payload pendiente y consumirlo después de `runApp`. Hay que probarlo en un iPhone real.
- [ ] 🟠 **Diario:**
  - Que el título sea opcional, con la fecha como título por defecto. Hoy "Guardar" no hace nada si falta el título (`journal_screen.dart:412`).
  - Confirmar al cancelar si hay texto escrito.
  - Ofrecer "Deshacer" al borrar (también en contactos).
  - Permitir exportar a PDF o texto.
- [ ] 🟠 **Onboarding de 3 pasos que configure la app:**
  1. Bienvenida + "toca Ayuda en cualquier momento".
  2. Fecha de sobriedad (con "Lo haré después").
  3. Padrino o madrina (importar desde Contactos).
  - Arreglar el botón invisible `'      '` en la última diapositiva.
- [ ] 🟠 **Navegación:**
  - Pasar de 6 a 5 pestañas, juntando Logros con Inicio ("Hoy").
  - Usar etiquetas de al menos 11 pt (hoy son de 9.5 pt).
  - Ajustes accesible desde más lugares.
  - En Apoyo, poner Contactos primero.
- [ ] 🟠 **Ajustes → Acerca de:** agregar versión, aviso de privacidad, aviso de no afiliación y "Borrar mis datos".

## Fase 4: accesibilidad

La app no cumple WCAG 2.2 AA. En todo `lib/` no se usa ni una vez `Semantics`, `semanticLabel`, `tooltip`, `textScaler` ni `disableAnimations`.

- [ ] 🟡 **Nombre accesible en los botones de solo ícono.**
  - Botones afectados: engrane, llamar, SMS, "…", "+", compartir, −/+ de letra y los controles del Libro Azul.
  - **Arreglo:** usar `Semantics(label: …, button: true)` o `Tooltip`.
- [ ] 🟡 **Rol de botón y estado seleccionado en los controles hechos con `GestureDetector`.**
  - **Tarjeta SOS:** `sobriety_counter_screen.dart:481-520`.
  - **Muestras de color:** `settings_screen.dart:616-646`. No tienen nombre; usar `option.name`.
  - **Segmentos de tema y temas de lectura.**
- [ ] 🟡 **Contraste del texto blanco sobre el color de acento.**
  - Solo pasan Violeta (5.70) e Índigo (6.29).
  - Fallan Naranja (el de default, 2.80), Verde (2.54), Rosa (3.53), Azul y Teal (3.68) y Rojo (3.76).
  - **Arreglo:** un token `onPrimary` o `primaryFill` más oscuro por cada color (por ejemplo, Naranja `#C2410C`).
- [ ] 🟡 **Opacidad del texto secundario.**
  - Hoy está al 35-50%, con contrastes de 1.95 a 3.5.
  - **Arreglo:** usar colores sólidos con al menos 4.5:1.
  - El número de la línea de A.A. a 12 pt en color de acento es información de crisis y tiene que leerse bien.
- [ ] 🟡 **Dynamic Type.** Hay alturas fijas que cortan el texto con letra grande: la tarjeta de 240 pt, la barra de 64 pt y las hojas de 340 pt con filas sin `Flexible`.
  - **Arreglo:** usar `ConstrainedBox(minHeight)` y `FittedBox` para el número grande.
- [ ] 🟡 **Respetar "Reducir movimiento".**
  - Si `MediaQuery.disableAnimationsOf` está activo, detener los orbes, el brillo giratorio, el pulso y el fondo que "respira".
  - Considerar un interruptor de animaciones en Ajustes.
- [ ] 🟡 **La barra de pestañas no anuncia la pestaña seleccionada.**
  - **Arreglo:** usar `Semantics(selected:, label: 'Inicio, pestaña 1 de 6')` o `CupertinoTabBar`.
- [ ] 🟡 **VoiceOver lee el contador en pedazos y la racha como "fuego 5".**
  - **Arreglo:** envolver el contador en `MergeSemantics` y darle a la racha la etiqueta "Racha de lectura: N días".
- [ ] 🟡 **Reflexiones Diarias no tiene control de tamaño de letra** (está fija en 17 pt). En los otros lectores el máximo es 26 pt.
  - **Arreglo:** usar un panel de lectura compartido y subir el máximo a 34-40 pt.
- [ ] 🟡 **Áreas de toque pequeñas.**
  - "Eliminar" subrayado mide unos 15 pt (`libro_azul_screen.dart:762`).
  - Las muestras de color miden unos 30 pt en un iPhone SE.
- [ ] 🟡 **La pestaña Escritura usa el mismo ícono activa e inactiva.** La tarjeta de hora deshabilitada solo se distingue por la opacidad.

## Fase 5: técnico y publicación en la App Store

- [ ] 🔵 **Pantalla de arranque (launch screen).** Sigue siendo la de Flutter por defecto; `flutter build ipa` lo avisa. Hay que diseñar una con el logo y los colores de la app en `ios/Runner/Assets.xcassets/LaunchImage.imageset` / `LaunchScreen.storyboard`.
- [ ] 🟠 **Probar el build 7 en un iPhone real.** Revisar que la app abra (arreglo de UIScene para iOS 27), que lleguen las notificaciones, que al tocarlas se abra la reflexión y que el botón SOS llame.
- [ ] 🔴 **Nombre y bundle ID definitivos.** Hoy `CFBundleDisplayName` es "App", `pubspec` se llama `nombre_de_tu_app` y el bundle es `com.version2.app`. El bundle **no se puede cambiar después de publicar** en la App Store. Usar un nombre de 12 caracteres o menos y sin "AA".
- [ ] 🔴 **URL de política o aviso de privacidad.** La pide Apple aunque la app no recoja datos (regla 5.1.1). En la etiqueta de privacidad, marcar "Data Not Collected".
- [ ] 🔴 **`PrivacyInfo.xcprivacy` en Runner.** Debe llevar `NSPrivacyTracking=false` y `NSPrivacyAccessedAPICategoryUserDefaults` con `CA92.1`. Revisar el Privacy Report del Archive.
- [ ] 🟠 **Migrar Flutter a una versión reciente con soporte oficial de escenas (UIScene).**
  - El arreglo para iOS 27 (FlutterEngine propio + SceneDelegate en `AppDelegate.swift`) funciona, pero es un parche.
  - Subir `sdk` a `">=3.5.0 <4.0.0"`.
  - Hacerlo en una rama aparte y probarlo en un iPhone físico.
- [ ] 🟠 **Paquetes.**
  - Reemplazar `flutter_native_timezone` (abandonado) por `flutter_timezone`.
  - Subir `flutter_local_notifications` (16 → actual) y `share_plus` (7 → actual).
- [ ] 🟠 **Regenerar los lockfiles.** `pubspec.lock` y `Podfile.lock` todavía tienen syncfusion, vocsy y Realm.
- [ ] 🟠 **Rendimiento y batería.**
  - Usar `TickerMode` para pausar las animaciones de las pestañas que no se ven (hoy hay unas 25 animaciones en `.repeat()`).
  - Cambiar los dos `Timer.periodic(1s)` por uno solo a medianoche.
  - Dejar el desenfoque solo en la barra de pestañas (hoy hay 30 `BackdropFilter`).
  - Pausar todo cuando la app pasa a segundo plano.
- [ ] 🟠 **Privacidad del diario.**
  - Cifrar con la clave guardada en el Keychain (`flutter_secure_storage`).
  - Bloqueo opcional con Face ID.
  - Desenfocar la vista en el selector de apps.
  - Botón "Borrar mis datos".
  - Explicarlo en el aviso de privacidad.
- [ ] 🟠 **iPad y orientación horizontal.** La app no está diseñada para ninguno de los dos.
  - **Arreglo:** `TARGETED_DEVICE_FAMILY = 1` y solo orientación vertical.
  - **Alternativa:** si se quiere iPad, pasar `sharePositionOrigin` a `Share.share` y probar los layouts.
- [ ] 🔵 **Cargar los JSON grandes con `compute()`** y crear la pestaña de Reflexiones solo cuando se abre.
- [ ] 🔵 **Código duplicado.**
  - Colores repetidos en 16 archivos → `ThemeExtension`.
  - Fondo animado repetido en 14 archivos → widgets `AmbientBackground` y `GlassCard`.
  - 31 llamadas sueltas a `SharedPreferences` → repositorio con las claves como constantes.
  - Dividir `settings_screen.dart` (1192 líneas).
- [ ] 🔵 **Pruebas automáticas.**
  - El único test (`test/widget_test.dart`) no compila.
  - Agregar pruebas unitarias de fechas, racha y lecturas, y un smoke test con `SharedPreferences.setMockInitialValues`.
- [ ] 🔵 **Clasificación por edad.** Responder con honestidad que hay referencias frecuentes a alcohol e información médica.

## Ideas nuevas 💡

Ordenadas por valor y esfuerzo.

1. [ ] **SOS en todas partes y padrino a un toque.** Acción rápida al mantener presionado el ícono ("Necesito apoyo"), padrino marcado, SMS y WhatsApp, respiración y HALT. *Valor muy alto, esfuerzo bajo.*
2. [ ] **"Sólo por hoy".** Compromiso diario en la mañana ("Sólo por hoy no voy a beber") y mini inventario de 10º Paso en la noche que se guarda en el diario. *Valor alto, esfuerzo bajo-medio.*
3. [ ] **Mis juntas.** Enlace al buscador de grupos, guardar "mis grupos" con día, hora y dirección (abrir en Mapas), recordatorio y "Fui a una junta hoy". *Valor alto, esfuerzo medio.*
4. [ ] **Privacidad y respaldo del diario.** Face ID, exportar y borrar datos. *Valor alto, esfuerzo medio.*
5. [ ] **Beneficios visibles.** Pesos ahorrados, copas no tomadas y horas recuperadas, más los hitos tradicionales de A.A. México (24 h; 1, 2, 3, 6 y 9 meses; 1 año; año y medio) con celebración. *Valor medio-alto, esfuerzo bajo.*
6. [ ] **Activar el widget de iOS** (`app/ios/SobrietyWidget/`).
7. [ ] **Modo "Letra grande".**

## Para consultar con un abogado [ABOGADO]

- [ ] ¿La 1ª edición del Libro Grande sigue protegida en México? ¿Qué efecto tiene la dedicación al dominio público de los traductores, si en México los derechos morales no se pueden renunciar?
- [ ] ¿Quién es el titular de las marcas de A.A. en México? ¿Se puede usar "A.A." de forma nominativa en la descripción de la tienda?
- [ ] ¿Aplica la LFPDPPP (ley de 2025) si los datos nunca salen del teléfono?

## Mantenimiento del repositorio

- [ ] Configurar claude-seo-ai (`/plugin configure claude-seo-ai@claude-seo-ai`).
- [ ] Correr `graphify update .` después de cada cambio grande y regenerar la vista 3D.
- [ ] Corregir el MANUAL (secciones 2 y 19), que hoy afirma cosas sobre los avisos de no afiliación que el código no cumple.
