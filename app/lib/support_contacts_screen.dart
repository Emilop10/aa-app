import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:ui';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'app_colors.dart';

const _kCream    = Color(0xFFFFFBF5);
const _kTextPrim = Color(0xFF431407);
const _kDarkBg   = Color(0xFF1A0800);

class SupportContact {
  final String id;
  final String name;
  final String phone;
  final String? note;

  SupportContact({
    required this.id,
    required this.name,
    required this.phone,
    this.note,
  });

  Map<String, dynamic> toJson() =>
      {'id': id, 'name': name, 'phone': phone, 'note': note};

  factory SupportContact.fromJson(Map<String, dynamic> json) => SupportContact(
        id:    json['id'],
        name:  json['name'],
        phone: json['phone'],
        note:  json['note'],
      );
}

// ─── List screen ─────────────────────────────────────────────────────────────

class SupportContactsScreen extends StatefulWidget {
  const SupportContactsScreen({super.key});
  @override
  _SupportContactsScreenState createState() => _SupportContactsScreenState();
}

class _SupportContactsScreenState extends State<SupportContactsScreen>
    with SingleTickerProviderStateMixin {
  List<SupportContact> _contacts = [];
  static const _storageKey = 'support_contacts';

  late AnimationController _bgBreathController;
  late Animation<double>   _bgBreath;

  @override
  void initState() {
    super.initState();
    _bgBreathController = AnimationController(
        vsync: this, duration: const Duration(seconds: 7))
      ..repeat(reverse: true);
    _bgBreath = Tween<double>(begin: 0.03, end: 0.09).animate(
        CurvedAnimation(parent: _bgBreathController, curve: Curves.easeInOut));
    _loadContacts();
  }

  @override
  void dispose() {
    _bgBreathController.dispose();
    super.dispose();
  }

  Future<void> _loadContacts() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw != null) {
      final list = (jsonDecode(raw) as List)
          .map((j) => SupportContact.fromJson(j))
          .toList();
      if (mounted) setState(() => _contacts = list);
    }
  }

  Future<void> _saveContacts() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _storageKey, jsonEncode(_contacts.map((c) => c.toJson()).toList()));
  }

  Future<void> _call(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _sms(String phone) async {
    final uri = Uri(scheme: 'sms', path: phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void _openEditor({SupportContact? contact}) async {
    final result = await Navigator.push<SupportContact?>(
      context,
      MaterialPageRoute(builder: (_) => _ContactEditor(existing: contact)),
    );
    if (result == null) return;
    setState(() {
      if (contact != null) {
        final i = _contacts.indexWhere((c) => c.id == contact.id);
        if (i != -1) _contacts[i] = result;
      } else {
        _contacts.add(result);
      }
    });
    _saveContacts();
  }

  void _deleteContact(String id) {
    setState(() => _contacts.removeWhere((c) => c.id == id));
    _saveContacts();
  }

  void _showActions(SupportContact contact, Color primary, bool isDark) {
    showCupertinoModalPopup(
      context: context,
      builder: (ctx) => CupertinoActionSheet(
        title: Text(contact.name),
        message: Text(contact.phone),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(ctx);
              _call(contact.phone);
            },
            child: const Text('Llamar'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(ctx);
              _sms(contact.phone);
            },
            child: const Text('Enviar mensaje'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(ctx);
              _openEditor(contact: contact);
            },
            child: const Text('Editar'),
          ),
          CupertinoActionSheetAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(ctx);
              _deleteContact(contact.id);
            },
            child: const Text('Eliminar contacto'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Cancelar'),
        ),
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
                      'Contactos',
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
                _contacts.isEmpty
                    ? SliverFillRemaining(
                        child: _buildEmpty(primary, isDark, textPrim))
                    : SliverPadding(
                        padding:
                            const EdgeInsets.fromLTRB(16, 8, 16, 100),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (ctx, i) => _buildCard(
                                _contacts[i], primary, isDark, textPrim),
                            childCount: _contacts.length,
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
      SupportContact c, Color primary, bool isDark, Color textPrim) {
    return Dismissible(
      key: Key(c.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => _deleteContact(c.id),
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
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Container(
              padding: const EdgeInsets.all(18),
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
              child: Row(
                children: [
                  // Avatar
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: primary.withOpacity(0.13),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        c.name.isNotEmpty
                            ? c.name[0].toUpperCase()
                            : '?',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  // Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          c.name,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: textPrim,
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          c.phone,
                          style: TextStyle(
                            fontSize: 13,
                            color: textPrim.withOpacity(0.45),
                          ),
                        ),
                        if (c.note != null && c.note!.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            c.note!,
                            style: TextStyle(
                              fontSize: 12,
                              color: primary.withOpacity(0.7),
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  // Action buttons
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _actionBtn(
                        icon: CupertinoIcons.phone_fill,
                        color: primary,
                        isDark: isDark,
                        onTap: () => _call(c.phone),
                      ),
                      const SizedBox(width: 8),
                      _actionBtn(
                        icon: CupertinoIcons.chat_bubble_fill,
                        color: primary,
                        isDark: isDark,
                        onTap: () => _sms(c.phone),
                      ),
                      const SizedBox(width: 8),
                      _actionBtn(
                        icon: CupertinoIcons.ellipsis,
                        color: textPrim.withOpacity(0.4),
                        isDark: isDark,
                        onTap: () => _showActions(c, primary, isDark),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _actionBtn({
    required IconData icon,
    required Color color,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: color.withOpacity(isDark ? 0.15 : 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 16),
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
              child: Icon(CupertinoIcons.person_2_fill,
                  color: primary, size: 36),
            ),
            const SizedBox(height: 24),
            Text(
              'Tu red de apoyo',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: textPrim,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Agrega a tu padrino, madrina, compañeros o personas de confianza. Tenerlos a un toque de distancia puede marcar la diferencia.',
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
                'Agregar primer contacto',
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

class _ContactEditor extends StatefulWidget {
  final SupportContact? existing;
  const _ContactEditor({this.existing});
  @override
  _ContactEditorState createState() => _ContactEditorState();
}

class _ContactEditorState extends State<_ContactEditor> {
  late TextEditingController _nameCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _noteCtrl;
  late FocusNode _nameFocus;
  late FocusNode _phoneFocus;

  @override
  void initState() {
    super.initState();
    _nameCtrl  = TextEditingController(text: widget.existing?.name ?? '');
    _phoneCtrl = TextEditingController(text: widget.existing?.phone ?? '');
    _noteCtrl  = TextEditingController(text: widget.existing?.note ?? '');
    _nameFocus  = FocusNode();
    _phoneFocus = FocusNode();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _nameFocus.requestFocus());
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _noteCtrl.dispose();
    _nameFocus.dispose();
    _phoneFocus.dispose();
    super.dispose();
  }

  void _save() {
    final name  = _nameCtrl.text.trim();
    final phone = _phoneCtrl.text.trim();
    if (name.isEmpty || phone.isEmpty) return;
    Navigator.pop(
      context,
      SupportContact(
        id:    widget.existing?.id ?? DateTime.now().toIso8601String(),
        name:  name,
        phone: phone,
        note:  _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
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
        final borderColor =
            isDark ? Colors.white12 : Colors.black.withOpacity(0.07);

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
                            ? 'Editar contacto'
                            : 'Nuevo contacto',
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
                    color: borderColor),
                // Fields
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 28, 24, 40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _fieldLabel('Nombre', textPrim),
                        const SizedBox(height: 8),
                        _fieldBox(
                          controller: _nameCtrl,
                          focusNode: _nameFocus,
                          hint: 'Ej. Padrino Roberto',
                          textInputAction: TextInputAction.next,
                          onSubmitted: (_) => _phoneFocus.requestFocus(),
                          isDark: isDark,
                          textPrim: textPrim,
                          hintColor: hintColor,
                          primary: primary,
                        ),
                        const SizedBox(height: 22),
                        _fieldLabel('Teléfono', textPrim),
                        const SizedBox(height: 8),
                        _fieldBox(
                          controller: _phoneCtrl,
                          focusNode: _phoneFocus,
                          hint: '+52 55 1234 5678',
                          keyboardType: TextInputType.phone,
                          textInputAction: TextInputAction.next,
                          isDark: isDark,
                          textPrim: textPrim,
                          hintColor: hintColor,
                          primary: primary,
                        ),
                        const SizedBox(height: 22),
                        _fieldLabel('Nota (opcional)', textPrim),
                        const SizedBox(height: 8),
                        _fieldBox(
                          controller: _noteCtrl,
                          hint: 'Ej. Padrino, Grupo Jueves...',
                          isDark: isDark,
                          textPrim: textPrim,
                          hintColor: hintColor,
                          primary: primary,
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

  Widget _fieldLabel(String label, Color textPrim) => Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: textPrim.withOpacity(0.45),
          letterSpacing: 0.3,
        ),
      );

  Widget _fieldBox({
    required TextEditingController controller,
    FocusNode? focusNode,
    required String hint,
    TextInputAction? textInputAction,
    ValueChanged<String>? onSubmitted,
    TextInputType? keyboardType,
    required bool isDark,
    required Color textPrim,
    required Color hintColor,
    required Color primary,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withOpacity(0.06)
                : Colors.white.withOpacity(0.72),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark
                  ? Colors.white.withOpacity(0.08)
                  : Colors.white.withOpacity(0.9),
              width: 0.8,
            ),
          ),
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            textInputAction: textInputAction,
            onSubmitted: onSubmitted,
            keyboardType: keyboardType,
            style: TextStyle(fontSize: 16, color: textPrim),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(fontSize: 16, color: hintColor),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 14),
            ),
          ),
        ),
      ),
    );
  }
}
