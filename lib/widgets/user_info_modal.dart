// lib/widgets/user_info_modal.dart
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

class _UserInfoModalState extends State<UserInfoModal>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _nicknameController;
  late TextEditingController _ageController;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

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

    // הגדרת אנימציות
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nicknameController.dispose();
    _ageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'נא להזין שם';
    }
    final sanitized =
        value.trim().replaceAll(RegExp(r'[^\u0590-\u05FFa-zA-Z\s]'), '');
    if (sanitized.isEmpty) {
      return 'השם יכול להכיל רק אותיות';
    }
    if (sanitized.length < 2) {
      return 'השם חייב להכיל לפחות 2 תווים';
    }
    if (sanitized.length > 30) {
      return 'השם יכול להכיל עד 30 תווים';
    }
    return null;
  }

  String? _validateAge(String? value) {
    if (value == null || value.isEmpty) return null;

    final age = int.tryParse(value);
    if (age == null) return 'נא להזין מספר תקף';

    if (age < 7) return 'גיל מינימלי: 7 שנים';
    if (age > 110) return 'גיל מקסימלי: 110 שנים';

    // הודעות מיוחדות לגילאים מסוימים
    if (age < 13) {
      return 'לגילאי 7-12 נדרשת הרשאת הורים';
    }
    if (age < 18) {
      return 'לקטינים נדרשת הרשאת הורים';
    }

    return null;
  }

  String? _validateNickname(String? value) {
    if (value == null || value.trim().isEmpty) return null;

    final sanitized =
        value.trim().replaceAll(RegExp(r'[^\u0590-\u05FFa-zA-Z0-9\s]'), '');
    if (sanitized != value.trim()) {
      return 'הכינוי יכול להכיל רק אותיות ומספרים';
    }
    if (sanitized.length > 20) {
      return 'הכינוי יכול להכיל עד 20 תווים';
    }
    return null;
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
              backgroundColor: Theme.of(context).colorScheme.primary,
              action: SnackBarAction(
                label: 'ביטול',
                textColor: Colors.white,
                onPressed: () {
                  setState(() => _nicknameController.clear());
                },
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('שגיאה ביצירת כינוי: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _generatingNickname = false);
      }
    }
  }

  Future<void> _handleAvatarPick() async {
    try {
      final path = await widget.onAvatarPick();
      if (path != null && path.isNotEmpty) {
        setState(() => _avatarPath = path);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('תמונה נבחרה בהצלחה!'),
              duration: Duration(seconds: 1),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('שגיאה בבחירת תמונה: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('נא לתקן את השגיאות בטופס'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _saving = true);

    try {
      // סניטציה של הנתונים
      final sanitizedName = _nameController.text
          .trim()
          .replaceAll(RegExp(r'[^\u0590-\u05FFa-zA-Z\s]'), '');
      final sanitizedNickname = _nicknameController.text
          .trim()
          .replaceAll(RegExp(r'[^\u0590-\u05FFa-zA-Z0-9\s]'), '');

      if (sanitizedName.isEmpty) {
        throw Exception('שם לא תקף');
      }

      await widget.onSave(
        name: sanitizedName,
        nickname: sanitizedNickname.isEmpty ? '' : sanitizedNickname,
        age: _ageController.text.isEmpty
            ? null
            : int.tryParse(_ageController.text),
        gender: _gender,
        avatarPath: _avatarPath,
      );

      // הצגת הודעת הצלחה
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('הפרטים נשמרו בהצלחה!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('שגיאה בשמירה: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
            action: SnackBarAction(
              label: 'נסה שוב',
              onPressed: _submit,
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  Widget _buildFormField({
    required TextEditingController controller,
    required String labelText,
    required String hintText,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    int? maxLength,
  }) {
    return Semantics(
      label: labelText,
      hint: hintText,
      child: TextFormField(
        controller: controller,
        maxLength: maxLength,
        decoration: InputDecoration(
          labelText: labelText,
          hintText: hintText,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.primary,
              width: 2,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.error,
            ),
          ),
          counterText: '',
        ),
        validator: validator,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
      ),
    );
  }

  Widget _buildAvatarSection() {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? colors.surfaceVariant.withOpacity(0.3)
            : colors.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colors.outline.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: colors.primary.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: CircleAvatar(
              radius: 34,
              backgroundColor: colors.secondaryContainer,
              backgroundImage: _avatarPath != null && _avatarPath!.isNotEmpty
                  ? AssetImage(_avatarPath!) as ImageProvider?
                  : const AssetImage('assets/avatars/default_avatar.png'),
              child: _avatarPath == null || _avatarPath!.isEmpty
                  ? Icon(
                      Icons.person,
                      size: 40,
                      color: colors.onSecondaryContainer,
                    )
                  : null,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ElevatedButton.icon(
                  onPressed: _handleAvatarPick,
                  icon: const Icon(Icons.photo_camera, size: 18),
                  label: const Text('בחר תמונה'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 46),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                if (_avatarPath != null && _avatarPath!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: () => setState(() => _avatarPath = null),
                    icon: const Icon(Icons.delete_outline, size: 16),
                    label: const Text('הסר תמונה'),
                    style: TextButton.styleFrom(
                      foregroundColor: colors.error,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 360;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Opacity(
              opacity: _fadeAnimation.value,
              child: Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                ),
                elevation: 16,
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: isSmallScreen ? size.width * 0.95 : 500,
                    maxHeight: size.height * 0.9,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(22.0),
                    child: SingleChildScrollView(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // כותרת וכפתור סגירה
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    'נשמח להכיר אותך! 👋',
                                    style: GoogleFonts.assistant(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: colors.primary,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close),
                                  onPressed: widget.onClose,
                                  tooltip: 'סגור',
                                  style: IconButton.styleFrom(
                                    backgroundColor: colors.surface,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'מלא את הפרטים לקבלת חוויה מותאמת אישית!',
                              style: GoogleFonts.assistant(
                                fontSize: 15,
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 20),

                            // שדה שם
                            _buildFormField(
                              controller: _nameController,
                              labelText: 'שם פרטי *',
                              hintText: 'הכנס שם פרטי',
                              icon: Icons.person,
                              validator: _validateName,
                              textInputAction: TextInputAction.next,
                              maxLength: 30,
                            ),
                            const SizedBox(height: 16),

                            // שדה כינוי עם כפתור הגרלה
                            Row(
                              children: [
                                Expanded(
                                  child: _buildFormField(
                                    controller: _nicknameController,
                                    labelText: 'כינוי (לא חובה)',
                                    hintText: 'הכנס כינוי',
                                    icon: Icons.verified_user_outlined,
                                    validator: _validateNickname,
                                    textInputAction: TextInputAction.next,
                                    maxLength: 20,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton(
                                  onPressed: _generatingNickname
                                      ? null
                                      : _handleNicknameGenerate,
                                  style: ElevatedButton.styleFrom(
                                    minimumSize: const Size(50, 58),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: _generatingNickname
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                              strokeWidth: 2),
                                        )
                                      : const Text('🎲'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // שדות גיל ומגדר
                            if (isSmallScreen) ...[
                              _buildFormField(
                                controller: _ageController,
                                labelText: 'גיל',
                                hintText: 'הכנס גיל',
                                icon: Icons.cake_outlined,
                                validator: _validateAge,
                                keyboardType: TextInputType.number,
                                textInputAction: TextInputAction.next,
                                maxLength: 3,
                              ),
                              const SizedBox(height: 16),
                              DropdownButtonFormField<String>(
                                value: _gender,
                                decoration: InputDecoration(
                                  labelText: 'מגדר',
                                  prefixIcon: const Icon(Icons.person_outline),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                items: const [
                                  DropdownMenuItem(
                                      value: 'male', child: Text('זכר')),
                                  DropdownMenuItem(
                                      value: 'female', child: Text('נקבה')),
                                  DropdownMenuItem(
                                      value: 'other', child: Text('אחר')),
                                ],
                                onChanged: (val) =>
                                    setState(() => _gender = val),
                              ),
                            ] else
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildFormField(
                                      controller: _ageController,
                                      labelText: 'גיל',
                                      hintText: 'הכנס גיל',
                                      icon: Icons.cake_outlined,
                                      validator: _validateAge,
                                      keyboardType: TextInputType.number,
                                      textInputAction: TextInputAction.next,
                                      maxLength: 3,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: DropdownButtonFormField<String>(
                                      value: _gender,
                                      decoration: InputDecoration(
                                        labelText: 'מגדר',
                                        prefixIcon:
                                            const Icon(Icons.person_outline),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                      ),
                                      items: const [
                                        DropdownMenuItem(
                                            value: 'male', child: Text('זכר')),
                                        DropdownMenuItem(
                                            value: 'female',
                                            child: Text('נקבה')),
                                        DropdownMenuItem(
                                            value: 'other', child: Text('אחר')),
                                      ],
                                      onChanged: (val) =>
                                          setState(() => _gender = val),
                                    ),
                                  ),
                                ],
                              ),
                            const SizedBox(height: 20),

                            // בחירת אווטר
                            _buildAvatarSection(),
                            const SizedBox(height: 16),

                            // הודעת פרטיות
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: colors.primaryContainer.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: colors.primary.withOpacity(0.2),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    size: 18,
                                    color: colors.primary,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'הפרטים ישמשו רק לזיהוי במשחקים ותחרויות.\nלא יפורסמו מחוץ לאפליקציה.',
                                      style: GoogleFonts.assistant(
                                        fontSize: 13,
                                        color: colors.onSurfaceVariant,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),

                            // לינק למדיניות פרטיות
                            TextButton.icon(
                              onPressed: () {
                                // TODO: add privacy policy link/modal
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content:
                                        Text('מדיניות הפרטיות תיפתח בקרוב'),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.description_outlined,
                                  size: 16),
                              label: const Text('קרא את מדיניות הפרטיות'),
                              style: TextButton.styleFrom(
                                foregroundColor: colors.primary,
                              ),
                            ),
                            const SizedBox(height: 20),

                            // כפתורי פעולה
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                OutlinedButton(
                                  onPressed: _saving ? null : widget.onClose,
                                  style: OutlinedButton.styleFrom(
                                    minimumSize: const Size(100, 48),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Text('לא כעת'),
                                ),
                                ElevatedButton(
                                  onPressed: _saving ? null : _submit,
                                  style: ElevatedButton.styleFrom(
                                    minimumSize: const Size(120, 48),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: _saving
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
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
              ),
            ),
          );
        },
      ),
    );
  }
}
