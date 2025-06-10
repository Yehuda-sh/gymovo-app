import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class UserInfoModal extends StatefulWidget {
  final Future<void> Function({
    required String name,
    required String nickname,
    required int? age,
    required String? gender,
    required String? avatarPath,
  }) onSave;
  final VoidCallback onClose;
  final Future<String> Function() onNicknameGenerate;
  final Future<String?> Function() onAvatarPick;
  final String? initialName;
  final String? initialNickname;
  final String? initialGender;
  final int? initialAge;
  final String? initialAvatarPath;

  const UserInfoModal({
    super.key,
    required this.onClose,
    required this.onSave,
    required this.onNicknameGenerate,
    required this.onAvatarPick,
    this.initialName,
    this.initialNickname,
    this.initialGender,
    this.initialAge,
    this.initialAvatarPath,
  });

  @override
  State<UserInfoModal> createState() => _UserInfoModalState();
}

class _UserInfoModalState extends State<UserInfoModal> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _nicknameController;
  late TextEditingController _ageController;
  String? _gender;
  String? _avatarPath;
  bool _saving = false;
  bool _generatingNickname = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName ?? '');
    _nicknameController =
        TextEditingController(text: widget.initialNickname ?? '');
    _ageController =
        TextEditingController(text: widget.initialAge?.toString() ?? '');
    _gender = widget.initialGender;
    _avatarPath = widget.initialAvatarPath;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nicknameController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  Future<void> _handleNicknameGenerate() async {
    setState(() => _generatingNickname = true);
    try {
      final newNickname = await widget.onNicknameGenerate();
      if (newNickname.isNotEmpty) {
        setState(() => _nicknameController.text = newNickname);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('הכינוי החדש שלך: $newNickname'),
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() => _generatingNickname = false);
      }
    }
  }

  Future<void> _handleAvatarPick() async {
    final path = await widget.onAvatarPick();
    if (path != null && path.isNotEmpty) {
      setState(() => _avatarPath = path);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    try {
      await widget.onSave(
        name: _nameController.text.trim(),
        nickname: _nicknameController.text.trim(),
        age: _ageController.text.isEmpty
            ? null
            : int.tryParse(_ageController.text),
        gender: _gender,
        avatarPath: _avatarPath,
      );
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 360;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        child: Padding(
          padding: const EdgeInsets.all(22.0),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'נשמח להכיר אותך!',
                        style: GoogleFonts.assistant(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: colors.primary,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: widget.onClose,
                        tooltip: 'סגור',
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'מלא את הפרטים לקבלת חוויה מותאמת אישית!',
                    style: GoogleFonts.assistant(
                        fontSize: 15, color: colors.secondary),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'שם פרטי *',
                      hintText: 'הכנס שם פרטי',
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'נא להזין שם' : null,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _nicknameController,
                          decoration: const InputDecoration(
                            labelText: 'כינוי (לא חובה)',
                            hintText: 'הכנס כינוי',
                            prefixIcon: Icon(Icons.verified_user_outlined),
                          ),
                          textInputAction: TextInputAction.next,
                        ),
                      ),
                      const SizedBox(width: 6),
                      ElevatedButton(
                        onPressed: _generatingNickname
                            ? null
                            : _handleNicknameGenerate,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(44, 44),
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                        ),
                        child: _generatingNickname
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('🎲 הגרל'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (isSmallScreen) ...[
                    TextFormField(
                      controller: _ageController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'גיל',
                        hintText: 'הכנס גיל',
                        prefixIcon: Icon(Icons.cake_outlined),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return null;
                        final age = int.tryParse(v);
                        if (age == null || age < 7 || age > 110) {
                          return 'הכנס גיל בין 7 ל־110';
                        }
                        return null;
                      },
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _gender,
                      decoration: const InputDecoration(
                        labelText: 'מגדר',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'male', child: Text('זכר')),
                        DropdownMenuItem(value: 'female', child: Text('נקבה')),
                        DropdownMenuItem(value: 'other', child: Text('אחר')),
                      ],
                      onChanged: (val) => setState(() => _gender = val),
                    ),
                  ] else
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _ageController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'גיל',
                              hintText: 'הכנס גיל',
                              prefixIcon: Icon(Icons.cake_outlined),
                            ),
                            validator: (v) {
                              if (v == null || v.isEmpty) return null;
                              final age = int.tryParse(v);
                              if (age == null || age < 7 || age > 110) {
                                return 'הכנס גיל בין 7 ל־110';
                              }
                              return null;
                            },
                            textInputAction: TextInputAction.next,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _gender,
                            decoration: const InputDecoration(
                              labelText: 'מגדר',
                              prefixIcon: Icon(Icons.person_outline),
                            ),
                            items: const [
                              DropdownMenuItem(
                                  value: 'male', child: Text('זכר')),
                              DropdownMenuItem(
                                  value: 'female', child: Text('נקבה')),
                              DropdownMenuItem(
                                  value: 'other', child: Text('אחר')),
                            ],
                            onChanged: (val) => setState(() => _gender = val),
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 34,
                        backgroundColor: colors.secondaryContainer,
                        backgroundImage:
                            _avatarPath != null && _avatarPath!.isNotEmpty
                                ? AssetImage(_avatarPath!) as ImageProvider
                                : const AssetImage(
                                    'assets/avatars/default_avatar.png'),
                      ),
                      const SizedBox(width: 14),
                      ElevatedButton(
                        onPressed: _handleAvatarPick,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(54, 46),
                        ),
                        child: const Text('בחר תמונה'),
                      ),
                      const SizedBox(width: 8),
                      if (_avatarPath != null && _avatarPath!.isNotEmpty)
                        TextButton(
                          onPressed: () => setState(() => _avatarPath = null),
                          child: const Text('הסר'),
                        ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      const Icon(Icons.info_outline, size: 17),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'הפרטים ישמשו רק לזיהוי במשחקים ותחרויות.\nלא יפורסמו מחוץ לאפליקציה.',
                          style: GoogleFonts.assistant(
                              fontSize: 13, color: colors.secondary),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () {
                      // TODO: add privacy policy link/modal
                    },
                    child: const Text('📄 קרא את הסכם הפרטיות'),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      OutlinedButton(
                        onPressed: widget.onClose,
                        child: const Text('לא כעת'),
                      ),
                      ElevatedButton(
                        onPressed: _saving ? null : _submit,
                        child: _saving
                            ? const SizedBox(
                                width: 26,
                                height: 26,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('שמור'),
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
}
