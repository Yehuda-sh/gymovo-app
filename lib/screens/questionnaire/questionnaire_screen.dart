// lib/screens/questionnaire_screen.dart
// --------------------------------------------------
// מסך שאלון ראשי
// --------------------------------------------------

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../questionnaire/questions.dart';
import '../../services/plan_builder_service.dart';
import '../../models/week_plan_model.dart';
import '../../data/local_data_store.dart';
import '../register/register_screen.dart';
import '../../providers/week_plan_provider.dart';
import '../welcome/welcome_screen.dart';
import '../questionnaire_results/questionnaire_results_screen.dart';
import '../home/home_screen.dart';

// Constants for validation ranges
class ValidationConstants {
  // Age limits
  static const int minAge = 16;
  static const int maxAge = 90;
  static const String ageRestrictionMessage =
      'מצטערים, האפליקציה מיועדת לגילאי 16 ומעלה. תוכניות האימון שלנו מותאמות לבוגרים ודורשות בגרות גופנית ונפשית.';

  // Weight limits (in kg)
  static const double minWeight = 30.0;
  static const double maxWeight = 200.0;

  // Height limits
  static const double minHeight = 140.0;
  static const double maxHeight = 210.0;
  static const double defaultMaleHeight = 177.0;
  static const double defaultFemaleHeight = 163.0;
  static const double defaultHeight = 170.0;

  static double getDefaultHeight(String? gender) {
    if (gender == null) return defaultHeight;
    switch (gender.toLowerCase()) {
      case 'זכר':
      case 'גבר':
        return defaultMaleHeight;
      case 'נקבה':
      case 'אישה':
        return defaultFemaleHeight;
      default:
        return defaultHeight;
    }
  }

  static bool isValidAge(int age) => age >= minAge && age <= maxAge;
  static bool isValidWeight(double weight) =>
      weight >= minWeight && weight <= maxWeight;
  static bool isValidHeight(double height) =>
      height >= minHeight && height <= maxHeight;
}

class QuestionnaireScreen extends StatefulWidget {
  const QuestionnaireScreen({super.key});

  @override
  State<QuestionnaireScreen> createState() => _QuestionnaireScreenState();
}

class _QuestionnaireScreenState extends State<QuestionnaireScreen> {
  final Map<String, dynamic> _answers = {};
  int _pageIndex = 0;
  late List<Question> _visibleQuestions;
  bool _showInfoBanner = true;
  bool _isSaving = false;

  final Map<String, TextEditingController> _controllers = {};
  final Map<String, FocusNode> _focusNodes = {};

  @override
  void initState() {
    super.initState();
    _visibleQuestions = _getVisibleQuestions();

    // Initialize controllers and focus nodes for number inputs
    for (var q in allQuestions.where((q) => q.inputType == 'number')) {
      _controllers[q.id] = TextEditingController();
      _focusNodes[q.id] = FocusNode();

      // Add focus listener for age validation
      if (q.id == 'age') {
        _focusNodes[q.id]!.addListener(() {
          if (!_focusNodes[q.id]!.hasFocus) {
            // User left the age field, validate now
            final text = _controllers['age']!.text;
            if (text.isNotEmpty) {
              final age = int.tryParse(text);
              if (age != null && !ValidationConstants.isValidAge(age)) {
                if (mounted) {
                  _showAgeRestrictionDialog(age);
                }
              }
            }
          }
        });
      }

      // Set default values
      if (q.id == 'height') {
        final defaultHeight =
            ValidationConstants.getDefaultHeight(_answers['gender']);
        _controllers[q.id]!.text = defaultHeight.toInt().toString();
        _answers[q.id] = defaultHeight.toInt();
      }
    }
  }

  @override
  void dispose() {
    for (var c in _controllers.values) {
      c.dispose();
    }
    for (var f in _focusNodes.values) {
      f.dispose();
    }
    super.dispose();
  }

  List<Question> _getVisibleQuestions() =>
      allQuestions.where((q) => q.showIf(_answers)).toList();

  void _setAnswer(String qId, dynamic value) {
    setState(() {
      _answers[qId] = value;
      _visibleQuestions = _getVisibleQuestions();

      // Update height default when gender changes
      if (qId == 'gender' && _controllers.containsKey('height')) {
        final newDefaultHeight = ValidationConstants.getDefaultHeight(value);
        if (_controllers['height']!.text.isEmpty ||
            _answers['height'] == null ||
            _answers['height'] == ValidationConstants.defaultHeight.toInt()) {
          _controllers['height']!.text = newDefaultHeight.toInt().toString();
          _answers['height'] = newDefaultHeight.toInt();
        }
      }
    });

    final q = allQuestions.firstWhere((q) => q.id == qId);
    final fb = q.feedback?.call(value);
    if (fb != null && mounted) {
      final scaffoldMessenger = ScaffoldMessenger.of(context);
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(fb),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showAgeRestrictionDialog(int enteredAge) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: Colors.orange,
              size: 28,
            ),
            const SizedBox(width: 8),
            Text(
              'הגבלת גיל',
              style: GoogleFonts.assistant(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              ValidationConstants.ageRestrictionMessage,
              style: GoogleFonts.assistant(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'למה דרושה הגבלת גיל?',
                    style: GoogleFonts.assistant(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[700],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '• בטיחות: תוכניות מותאמות לגוף בוגר\n'
                    '• אחריות משפטית: נדרש גיל בגרות\n'
                    '• התפתחות גופנית: עצמות ושרירים עדיין בגדילה',
                    style: GoogleFonts.assistant(
                      fontSize: 12,
                      color: Colors.blue[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Clear the age field
              if (_controllers.containsKey('age')) {
                _controllers['age']!.clear();
              }
              _answers.remove('age');
              setState(() {});
            },
            child: Text(
              'הבנתי',
              style: GoogleFonts.assistant(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (enteredAge < ValidationConstants.minAge)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                  (_) => false,
                );
              },
              style: TextButton.styleFrom(
                backgroundColor: Colors.red.withValues(alpha: 0.1),
              ),
              child: Text(
                'חזור למסך הראשי',
                style: GoogleFonts.assistant(
                  fontSize: 16,
                  color: Colors.red[700],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _getGenderAwareAgeLabel() {
    final gender = _answers['gender'];
    if (gender == null)
      return 'בן/בת כמה את/ה? (${ValidationConstants.minAge}-${ValidationConstants.maxAge})';

    switch (gender.toString().toLowerCase()) {
      case 'זכר':
      case 'גבר':
        return 'בן כמה אתה? (${ValidationConstants.minAge}-${ValidationConstants.maxAge})';
      case 'נקבה':
      case 'אישה':
        return 'בת כמה את? (${ValidationConstants.minAge}-${ValidationConstants.maxAge})';
      default:
        return 'בן/בת כמה את/ה? (${ValidationConstants.minAge}-${ValidationConstants.maxAge})';
    }
  }

  void _nextPage() {
    const questionsPerPage = 3;

    // Validate current page
    for (int i = 0; i < questionsPerPage; i++) {
      final absIndex = _pageIndex * questionsPerPage + i;
      if (absIndex >= _visibleQuestions.length) break;

      final q = _visibleQuestions[absIndex];

      // Check if question has an answer
      bool hasAnswer = false;

      if (q.inputType == 'number') {
        hasAnswer = _controllers[q.id]?.text.isNotEmpty ?? false;
      } else if (q.multi) {
        final answers = _answers[q.id] as List<String>?;
        hasAnswer = answers != null && answers.isNotEmpty;
      } else {
        hasAnswer = _answers[q.id] != null;
      }

      if (!hasAnswer) {
        // Show validation message
        final scaffoldMessenger = ScaffoldMessenger.of(context);
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text('אנא ענה על השאלה: ${q.title}'),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
    }

    if ((_pageIndex + 1) * questionsPerPage >= _visibleQuestions.length) {
      _finishQuestionnaire();
    } else {
      setState(() {
        _pageIndex++;
      });
    }
  }

  void _previousPage() {
    if (_pageIndex > 0) {
      setState(() {
        _pageIndex--;
      });
    }
  }

  Future<void> _finishQuestionnaire() async {
    setState(() => _isSaving = true);

    try {
      debugPrint('=== DEBUG: _finishQuestionnaire ===');
      debugPrint('Answers to save: $_answers');
      debugPrint('Answers keys: ${_answers.keys.toList()}');
      debugPrint(
          'Answers types: ${_answers.map((k, v) => MapEntry(k, '${v.runtimeType}'))}');

      var user = await LocalDataStore.getCurrentUser();
      bool isGuest = false;

      if (user == null) {
        debugPrint('No current user found, creating guest user');
        user = await LocalDataStore.createGuestUser();
        isGuest = true;
      } else if (user.isGuest == true) {
        debugPrint('Current user is guest');
        isGuest = true;
      }

      debugPrint(
          'User before copyWith: ${user.id}, questionnaireAnswers: ${user.questionnaireAnswers}');

      // Save questionnaire answers to user model
      user = user.copyWith(
        questionnaireAnswers: Map<String, dynamic>.from(_answers),
        profileLastUpdated: DateTime.now(),
      );

      debugPrint(
          'User after copyWith questionnaireAnswers: ${user.questionnaireAnswers}');
      debugPrint(
          'User after copyWith questionnaireAnswers keys: ${user.questionnaireAnswers?.keys.toList()}');

      // Save updated user with answers
      debugPrint('About to save user with LocalDataStore.saveUser');
      await LocalDataStore.saveUser(user);

      // וידוא נוסף אחרי שמירה
      debugPrint('Retrieving user after save to verify...');
      final savedUser = await LocalDataStore.getCurrentUser();
      debugPrint(
          'User retrieved after save: ${savedUser?.questionnaireAnswers}');
      debugPrint(
          'User retrieved after save keys: ${savedUser?.questionnaireAnswers?.keys.toList()}');

      if (savedUser?.questionnaireAnswers == null ||
          savedUser!.questionnaireAnswers!.isEmpty) {
        debugPrint(
            'ERROR: User questionnaireAnswers is null or empty after save!');
      } else {
        debugPrint('SUCCESS: User questionnaireAnswers saved correctly');
      }

      // Build plan from answers
      final weekPlan =
          await PlanBuilderService.buildFromAnswers(user, _answers);

      final plan = WeekPlanModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: user.id,
        title: 'תוכנית שבועית',
        description: 'תוכנית אימונים שבועית מותאמת אישית',
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 7)),
        workouts: weekPlan,
        isActive: true,
        lastUpdated: DateTime.now(),
      );

      // Handle guest user registration
      if (isGuest && mounted) {
        debugPrint('Handling guest user registration...');
        final navigator = Navigator.of(context);
        await navigator.push(
          MaterialPageRoute(builder: (_) => const RegisterScreen()),
        );
        // Get updated user after registration
        user = await LocalDataStore.getCurrentUser();
        debugPrint(
            'User after registration: ${user?.id}, isGuest: ${user?.isGuest}');

        // Update user with questionnaire answers if registration completed
        if (user != null && !user.isGuest) {
          debugPrint(
              'User is no longer guest, updating with questionnaire answers again...');
          user = user.copyWith(
            questionnaireAnswers: Map<String, dynamic>.from(_answers),
            profileLastUpdated: DateTime.now(),
          );
          await LocalDataStore.saveUser(user);
        }
      }

      // Save plan
      if (user != null) {
        debugPrint('Saving user plan...');
        await LocalDataStore.saveUserPlan(user.id, plan);
      }

      debugPrint('====================================');

      if (mounted) {
        final weekPlanProvider = context.read<WeekPlanProvider>();
        await weekPlanProvider.refreshPlan();

        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
        }
      }
    } catch (e, stackTrace) {
      debugPrint('שגיאה בשמירת התוכנית: $e');
      debugPrint('$stackTrace');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('שגיאה בשמירת התוכנית: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Widget _buildHeightInput(Question q) {
    final controller = _controllers[q.id]!;
    final currentValue = controller.text.isEmpty
        ? ValidationConstants.getDefaultHeight(_answers['gender'])
        : double.tryParse(controller.text) ??
            ValidationConstants.getDefaultHeight(_answers['gender']);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          q.title,
          style: GoogleFonts.assistant(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.colors.text,
          ),
        ),
        const SizedBox(height: 16),

        // Display current height prominently
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.colors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.colors.primary.withValues(alpha: 0.3),
            ),
          ),
          child: Text(
            '${currentValue.toInt()} ס"מ',
            textAlign: TextAlign.center,
            style: GoogleFonts.assistant(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.colors.primary,
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Height slider
        Slider(
          value: currentValue.clamp(
              ValidationConstants.minHeight, ValidationConstants.maxHeight),
          min: ValidationConstants.minHeight,
          max: ValidationConstants.maxHeight,
          divisions:
              (ValidationConstants.maxHeight - ValidationConstants.minHeight)
                  .toInt(),
          label: '${currentValue.toInt()} ס"מ',
          activeColor: AppTheme.colors.primary,
          onChanged: (value) {
            setState(() {
              controller.text = value.toInt().toString();
              _setAnswer(q.id, value.toInt());
            });
          },
        ),

        // Height range indicators
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${ValidationConstants.minHeight.toInt()} ס"מ',
              style: GoogleFonts.assistant(
                fontSize: 12,
                color: AppTheme.colors.text.withValues(alpha: 0.6),
              ),
            ),
            Text(
              '${ValidationConstants.maxHeight.toInt()} ס"מ',
              style: GoogleFonts.assistant(
                fontSize: 12,
                color: AppTheme.colors.text.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Manual input field
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: GoogleFonts.assistant(
            color: AppTheme.colors.text,
            fontSize: 16,
          ),
          decoration: InputDecoration(
            labelText: 'גובה בס"מ',
            hintText: 'הכנס גובה...',
            helperText:
                'טווח תקין: ${ValidationConstants.minHeight.toInt()}-${ValidationConstants.maxHeight.toInt()} ס"מ',
            helperStyle: GoogleFonts.assistant(
              color: AppTheme.colors.text.withValues(alpha: 0.6),
              fontSize: 12,
            ),
            hintStyle: GoogleFonts.assistant(
              color: AppTheme.colors.text.withValues(alpha: 0.5),
            ),
            labelStyle: GoogleFonts.assistant(
              color: AppTheme.colors.text.withValues(alpha: 0.7),
            ),
            filled: true,
            fillColor: AppTheme.colors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppTheme.colors.primary,
                width: 2,
              ),
            ),
          ),
          onChanged: (text) {
            final val = double.tryParse(text);
            if (val != null && ValidationConstants.isValidHeight(val)) {
              setState(() {
                _setAnswer(q.id, val.toInt());
              });
            }
          },
        ),
      ],
    );
  }

  Widget _buildWeightInput(Question q) {
    final controller = _controllers[q.id]!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'מה המשקל שלך? (${ValidationConstants.minWeight.toInt()}-${ValidationConstants.maxWeight.toInt()} ק"ג)',
          style: GoogleFonts.assistant(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.colors.text,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: GoogleFonts.assistant(
            color: AppTheme.colors.text,
            fontSize: 16,
          ),
          decoration: InputDecoration(
            hintText: 'משקל בק"ג',
            helperText:
                'טווח תקין: ${ValidationConstants.minWeight.toInt()}-${ValidationConstants.maxWeight.toInt()} ק"ג',
            helperStyle: GoogleFonts.assistant(
              color: AppTheme.colors.text.withValues(alpha: 0.6),
              fontSize: 12,
            ),
            hintStyle: GoogleFonts.assistant(
              color: AppTheme.colors.text.withValues(alpha: 0.5),
            ),
            filled: true,
            fillColor: AppTheme.colors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppTheme.colors.primary,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.red,
                width: 2,
              ),
            ),
          ),
          onChanged: (text) {
            final val = double.tryParse(text);
            if (val != null) {
              if (ValidationConstants.isValidWeight(val)) {
                _setAnswer(q.id, val.toInt());
              } else {
                // Show validation message
                final scaffoldMessenger = ScaffoldMessenger.of(context);
                scaffoldMessenger.hideCurrentSnackBar();
                scaffoldMessenger.showSnackBar(
                  SnackBar(
                    content: Text(
                      'משקל חייב להיות בין ${ValidationConstants.minWeight.toInt()}-${ValidationConstants.maxWeight.toInt()} ק"ג',
                    ),
                    backgroundColor: Colors.orange,
                    behavior: SnackBarBehavior.floating,
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            }
          },
        ),
      ],
    );
  }

  Widget _buildNumberInput(Question q) {
    if (q.id == 'height') {
      return _buildHeightInput(q);
    } else if (q.id == 'weight') {
      return _buildWeightInput(q);
    }

    final controller = _controllers[q.id]!;
    final focusNode = _focusNodes[q.id]!;

    // Dynamic question title based on gender for age
    final questionTitle = q.id == 'age' ? _getGenderAwareAgeLabel() : q.title;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          questionTitle,
          style: GoogleFonts.assistant(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.colors.text,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          focusNode: focusNode,
          keyboardType: TextInputType.number,
          style: GoogleFonts.assistant(
            color: AppTheme.colors.text,
            fontSize: 16,
          ),
          decoration: InputDecoration(
            hintText: q.id == 'age' ? 'גיל בשנים' : 'הזן ערך',
            hintStyle: GoogleFonts.assistant(
              color: AppTheme.colors.text.withValues(alpha: 0.5),
            ),
            filled: true,
            fillColor: AppTheme.colors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppTheme.colors.primary,
                width: 2,
              ),
            ),
          ),
          onChanged: (text) {
            // Only save valid numbers, but don't validate age restrictions here
            final val = int.tryParse(text);
            if (val != null) {
              _setAnswer(q.id, val);
            }
          },
        ),
      ],
    );
  }

  Widget _buildChoiceQuestion(Question q) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          q.title,
          style: GoogleFonts.assistant(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.colors.text,
          ),
        ),
        const SizedBox(height: 12),

        // Multi-select questions
        if (q.multi) ...[
          if (q.maxSelections != null)
            Text(
              'בחר עד ${q.maxSelections} אפשרויות',
              style: GoogleFonts.assistant(
                fontSize: 14,
                color: AppTheme.colors.text.withValues(alpha: 0.6),
              ),
            ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: q.options.map((opt) {
              final currentAnswers = _answers[q.id] as List<String>? ?? [];
              final isSelected = currentAnswers.contains(opt);
              final canSelect = isSelected ||
                  (q.maxSelections == null ||
                      currentAnswers.length < q.maxSelections!);

              return FilterChip(
                label: Text(
                  opt,
                  style: GoogleFonts.assistant(
                    color: isSelected ? Colors.white : AppTheme.colors.text,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                selected: isSelected,
                selectedColor: AppTheme.colors.primary,
                backgroundColor: AppTheme.colors.surface,
                disabledColor: AppTheme.colors.surface.withValues(alpha: 0.5),
                checkmarkColor: Colors.white,
                side: BorderSide(
                  color: isSelected
                      ? AppTheme.colors.primary
                      : AppTheme.colors.text.withValues(alpha: 0.2),
                ),
                onSelected: canSelect
                    ? (selected) {
                        setState(() {
                          final currentList =
                              List<String>.from(_answers[q.id] ?? []);
                          if (selected) {
                            currentList.add(opt);
                          } else {
                            currentList.remove(opt);
                          }
                          _setAnswer(q.id, currentList);
                        });
                      }
                    : null,
              );
            }).toList(),
          ),
        ] else ...[
          // Single select questions
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: q.options.map((opt) {
              final isSelected = _answers[q.id] == opt;
              return FilterChip(
                label: Text(
                  opt,
                  style: GoogleFonts.assistant(
                    color: isSelected ? Colors.white : AppTheme.colors.text,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                selected: isSelected,
                selectedColor: AppTheme.colors.primary,
                backgroundColor: AppTheme.colors.surface,
                checkmarkColor: Colors.white,
                side: BorderSide(
                  color: isSelected
                      ? AppTheme.colors.primary
                      : AppTheme.colors.text.withValues(alpha: 0.2),
                ),
                onSelected: (_) => _setAnswer(q.id, opt),
              );
            }).toList(),
          ),
        ],

        // Add explanation if exists
        if (q.explanation != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.colors.primary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppTheme.colors.primary.withValues(alpha: 0.1),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline,
                  size: 18,
                  color: AppTheme.colors.primary.withValues(alpha: 0.7),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    q.explanation!,
                    style: GoogleFonts.assistant(
                      fontSize: 13,
                      color: AppTheme.colors.text.withValues(alpha: 0.8),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colors;
    const perPage = 3;
    final start = _pageIndex * perPage;
    final questionsOnPage =
        _visibleQuestions.skip(start).take(perPage).toList();

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'שאלון התאמה אישי',
          style: GoogleFonts.assistant(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: colors.text,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.close, color: colors.text),
          tooltip: 'יציאה מהשאלון',
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const WelcomeScreen()),
              (_) => false,
            );
          },
        ),
        actions: _pageIndex > 0
            ? [
                IconButton(
                  icon: Icon(Icons.arrow_back, color: colors.text),
                  tooltip: 'חזור',
                  onPressed: _previousPage,
                )
              ]
            : null,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Info banner
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _showInfoBanner
                    ? Container(
                        key: const ValueKey('info'),
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: colors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: colors.primary.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info, color: colors.primary),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'כמשתמש רשום, תמיד תוכל לעדכן את השאלון ולרענן את התוכנית שלך.',
                                style: GoogleFonts.assistant(
                                  color: colors.text.withValues(alpha: 0.8),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.close,
                                color: colors.text.withValues(alpha: 0.6),
                              ),
                              onPressed: () =>
                                  setState(() => _showInfoBanner = false),
                            ),
                          ],
                        ),
                      )
                    : const SizedBox.shrink(),
              ),

              // Progress bar
              Container(
                height: 8,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: colors.surface.withValues(alpha: 0.3),
                ),
                child: LinearProgressIndicator(
                  value: (_pageIndex * perPage) /
                      (_visibleQuestions.isEmpty ? 1 : _visibleQuestions.length)
                          .toDouble(),
                  backgroundColor: Colors.transparent,
                  valueColor: AlwaysStoppedAnimation<Color>(colors.primary),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),

              const SizedBox(height: 24),

              // Questions
              Expanded(
                child: questionsOnPage.isEmpty
                    ? Center(
                        child: Text(
                          'אין שאלות להצגה',
                          style: GoogleFonts.assistant(
                            fontSize: 16,
                            color: colors.text.withValues(alpha: 0.6),
                          ),
                        ),
                      )
                    : ListView.separated(
                        itemCount: questionsOnPage.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 30),
                        itemBuilder: (ctx, idx) {
                          final q = questionsOnPage[idx];

                          if (q.inputType == 'number') {
                            return _buildNumberInput(q);
                          } else {
                            return _buildChoiceQuestion(q);
                          }
                        },
                      ),
              ),

              // Navigation buttons
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Row(
                  children: [
                    if (_pageIndex > 0)
                      TextButton.icon(
                        onPressed: _previousPage,
                        icon: const Icon(Icons.arrow_back),
                        label: Text(
                          'חזור',
                          style: GoogleFonts.assistant(fontSize: 16),
                        ),
                      ),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: _isSaving ? null : _nextPage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  (_pageIndex + 1) * perPage >=
                                          _visibleQuestions.length
                                      ? 'סיום'
                                      : 'המשך',
                                  style: GoogleFonts.assistant(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  (_pageIndex + 1) * perPage >=
                                          _visibleQuestions.length
                                      ? Icons.check
                                      : Icons.arrow_forward,
                                ),
                              ],
                            ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
