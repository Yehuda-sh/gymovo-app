// lib/screens/questionnaire/questionnaire_intro_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import '../home/home_screen.dart';

// קבועי ולידציה
class ValidationConstants {
  static const int minAge = 16;
  static const int maxAge = 90;
  static const String ageRestrictionMessage =
      'מצטערים, האפליקציה מיועדת לגילאי 16 ומעלה. תוכניות האימון שלנו מותאמות לבוגרים ודורשות בגרות גופנית ונפשית.';

  static const double minWeight = 30.0;
  static const double maxWeight = 200.0;
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

// מצבי השאלון
enum QuestionnaireState {
  loading,
  inProgress,
  saving,
  completed,
  error,
}

// מודל לניהול מצב השאלון
class QuestionnaireScreenState {
  final QuestionnaireState state;
  final Map<String, dynamic> answers;
  final int currentPage;
  final List<Question> visibleQuestions;
  final bool showInfoBanner;
  final String? errorMessage;
  final bool hasUnsavedChanges;

  const QuestionnaireScreenState({
    this.state = QuestionnaireState.loading,
    this.answers = const {},
    this.currentPage = 0,
    this.visibleQuestions = const [],
    this.showInfoBanner = true,
    this.errorMessage,
    this.hasUnsavedChanges = false,
  });

  QuestionnaireScreenState copyWith({
    QuestionnaireState? state,
    Map<String, dynamic>? answers,
    int? currentPage,
    List<Question>? visibleQuestions,
    bool? showInfoBanner,
    String? errorMessage,
    bool? hasUnsavedChanges,
    bool clearError = false,
  }) {
    return QuestionnaireScreenState(
      state: state ?? this.state,
      answers: answers ?? this.answers,
      currentPage: currentPage ?? this.currentPage,
      visibleQuestions: visibleQuestions ?? this.visibleQuestions,
      showInfoBanner: showInfoBanner ?? this.showInfoBanner,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      hasUnsavedChanges: hasUnsavedChanges ?? this.hasUnsavedChanges,
    );
  }

  bool get isLoading => state == QuestionnaireState.loading;
  bool get isInProgress => state == QuestionnaireState.inProgress;
  bool get isSaving => state == QuestionnaireState.saving;
  bool get hasError => state == QuestionnaireState.error;
  bool get isCompleted => state == QuestionnaireState.completed;

  double get progress {
    if (visibleQuestions.isEmpty) return 0.0;
    const questionsPerPage = 3;
    return (currentPage * questionsPerPage) / visibleQuestions.length;
  }

  bool get isLastPage {
    const questionsPerPage = 3;
    return (currentPage + 1) * questionsPerPage >= visibleQuestions.length;
  }

  List<Question> get currentPageQuestions {
    const questionsPerPage = 3;
    final start = currentPage * questionsPerPage;
    return visibleQuestions.skip(start).take(questionsPerPage).toList();
  }
}

// ממשק ניהול השאלון
abstract class QuestionnaireManager {
  static const int questionsPerPage = 3;

  static List<Question> getVisibleQuestions(Map<String, dynamic> answers) {
    return allQuestions.where((q) => q.showIf(answers)).toList();
  }

  static bool validateCurrentPage(
    List<Question> questions,
    Map<String, dynamic> answers,
    Map<String, TextEditingController> controllers,
  ) {
    for (final q in questions) {
      if (!_hasValidAnswer(q, answers, controllers)) {
        return false;
      }
    }
    return true;
  }

  static bool _hasValidAnswer(
    Question q,
    Map<String, dynamic> answers,
    Map<String, TextEditingController> controllers,
  ) {
    if (q.inputType == 'number') {
      return controllers[q.id]?.text.isNotEmpty ?? false;
    } else if (q.multi) {
      final answerList = answers[q.id] as List<String>?;
      return answerList != null && answerList.isNotEmpty;
    } else {
      return answers[q.id] != null;
    }
  }

  static String? validateInput(Question q, String value) {
    if (q.inputType != 'number') return null;

    final numValue = double.tryParse(value);
    if (numValue == null) return 'יש להזין מספר תקין';

    switch (q.id) {
      case 'age':
        final age = numValue.toInt();
        if (!ValidationConstants.isValidAge(age)) {
          if (age < ValidationConstants.minAge) {
            return 'גיל מינימלי: ${ValidationConstants.minAge}';
          } else {
            return 'גיל מקסימלי: ${ValidationConstants.maxAge}';
          }
        }
        break;
      case 'weight':
        if (!ValidationConstants.isValidWeight(numValue)) {
          return 'משקל חייב להיות בין ${ValidationConstants.minWeight.toInt()}-${ValidationConstants.maxWeight.toInt()} ק"ג';
        }
        break;
      case 'height':
        if (!ValidationConstants.isValidHeight(numValue)) {
          return 'גובה חייב להיות בין ${ValidationConstants.minHeight.toInt()}-${ValidationConstants.maxHeight.toInt()} ס"מ';
        }
        break;
    }
    return null;
  }
}

// הודעות חכמות למשתמש
class SmartFeedbackSystem {
  static void showValidationError(BuildContext context, String message) {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  static void showSuccess(BuildContext context, String message) {
    HapticFeedback.selectionClick();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  static void showQuestionFeedback(BuildContext context, String feedback) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(feedback),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppTheme.colors.primary,
      ),
    );
  }
}

class QuestionnaireScreen extends StatefulWidget {
  const QuestionnaireScreen({super.key});

  @override
  State<QuestionnaireScreen> createState() => _QuestionnaireScreenState();
}

class _QuestionnaireScreenState extends State<QuestionnaireScreen>
    with TickerProviderStateMixin {
  late QuestionnaireScreenState _screenState;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final Map<String, TextEditingController> _controllers = {};
  final Map<String, FocusNode> _focusNodes = {};
  Timer? _autoSaveTimer;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeState();
    _setupControllers();
    _setupAutoSave();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0.3, 0), end: Offset.zero).animate(
            CurvedAnimation(
                parent: _slideController, curve: Curves.easeOutCubic));

    _fadeController.forward();
    _slideController.forward();
  }

  void _initializeState() {
    final visibleQuestions = QuestionnaireManager.getVisibleQuestions({});
    _screenState = QuestionnaireScreenState(
      state: QuestionnaireState.inProgress,
      visibleQuestions: visibleQuestions,
    );
  }

  void _setupControllers() {
    for (var q in allQuestions.where((q) => q.inputType == 'number')) {
      _controllers[q.id] = TextEditingController();
      _focusNodes[q.id] = FocusNode();

      if (q.id == 'age') {
        _focusNodes[q.id]!.addListener(_onAgeFocusChange);
      }

      if (q.id == 'height') {
        final defaultHeight = ValidationConstants.getDefaultHeight(null);
        _controllers[q.id]!.text = defaultHeight.toInt().toString();
        _updateAnswer(q.id, defaultHeight.toInt());
      }
    }
  }

  void _setupAutoSave() {
    _autoSaveTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (_screenState.hasUnsavedChanges) {
        _autoSaveProgress();
      }
    });
  }

  void _onAgeFocusChange() {
    if (!_focusNodes['age']!.hasFocus) {
      final text = _controllers['age']!.text;
      if (text.isNotEmpty) {
        final age = int.tryParse(text);
        if (age != null && !ValidationConstants.isValidAge(age)) {
          _showAgeRestrictionDialog(age);
        }
      }
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _autoSaveTimer?.cancel();

    for (var c in _controllers.values) {
      c.dispose();
    }
    for (var f in _focusNodes.values) {
      f.dispose();
    }
    super.dispose();
  }

  void _updateState(QuestionnaireScreenState newState) {
    if (mounted) {
      setState(() => _screenState = newState);
    }
  }

  void _updateAnswer(String questionId, dynamic value) {
    final newAnswers = Map<String, dynamic>.from(_screenState.answers);
    newAnswers[questionId] = value;

    final visibleQuestions =
        QuestionnaireManager.getVisibleQuestions(newAnswers);

    _updateState(_screenState.copyWith(
      answers: newAnswers,
      visibleQuestions: visibleQuestions,
      hasUnsavedChanges: true,
    ));

    // עדכון ברירת מחדל לגובה בהתאם למגדר
    if (questionId == 'gender' && _controllers.containsKey('height')) {
      final newDefaultHeight = ValidationConstants.getDefaultHeight(value);
      if (_controllers['height']!.text.isEmpty ||
          _screenState.answers['height'] == null ||
          _screenState.answers['height'] ==
              ValidationConstants.defaultHeight.toInt()) {
        _controllers['height']!.text = newDefaultHeight.toInt().toString();
        _updateAnswer('height', newDefaultHeight.toInt());
      }
    }

    // הצגת פידבק אם קיים
    final question = allQuestions.firstWhere((q) => q.id == questionId);
    final feedback = question.feedback?.call(value);
    if (feedback != null && mounted) {
      SmartFeedbackSystem.showQuestionFeedback(context, feedback);
    }
  }

  Future<void> _autoSaveProgress() async {
    try {
      // שמירה מקומית של ההתקדמות
      var user = await LocalDataStore.getCurrentUser();
      if (user != null) {
        user = user.copyWith(
          questionnaireAnswers: Map<String, dynamic>.from(_screenState.answers),
          profileLastUpdated: DateTime.now(),
        );
        await LocalDataStore.saveUser(user);
      }

      _updateState(_screenState.copyWith(hasUnsavedChanges: false));
    } catch (e) {
      debugPrint('שגיאה בשמירה אוטומטית: $e');
    }
  }

  void _showAgeRestrictionDialog(int enteredAge) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.warning_amber_rounded,
                  color: Colors.orange, size: 24),
            ),
            const SizedBox(width: 12),
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
              style: GoogleFonts.assistant(fontSize: 16, height: 1.4),
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
                  Row(
                    children: [
                      const Icon(Icons.info_outline,
                          color: Colors.blue, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'למה דרושה הגבלת גיל?',
                        style: GoogleFonts.assistant(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '• בטיחות: תוכניות מותאמות לגוף בוגר\n'
                    '• אחריות משפטית: נדרש גיל בגרות\n'
                    '• התפתחות גופנית: עצמות ושרירים עדיין בגדילה',
                    style: GoogleFonts.assistant(
                      fontSize: 12,
                      color: Colors.blue[600],
                      height: 1.3,
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
              if (_controllers.containsKey('age')) {
                _controllers['age']!.clear();
              }
              final newAnswers =
                  Map<String, dynamic>.from(_screenState.answers);
              newAnswers.remove('age');
              _updateState(_screenState.copyWith(answers: newAnswers));
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
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                  (_) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: Text(
                'חזור למסך הראשי',
                style: GoogleFonts.assistant(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _getGenderAwareAgeLabel() {
    final gender = _screenState.answers['gender'];
    if (gender == null) {
      return 'בן/בת כמה את/ה? (${ValidationConstants.minAge}-${ValidationConstants.maxAge})';
    }

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
    final currentQuestions = _screenState.currentPageQuestions;

    if (!QuestionnaireManager.validateCurrentPage(
        currentQuestions, _screenState.answers, _controllers)) {
      final missingQuestion = currentQuestions.firstWhere((q) {
        if (q.inputType == 'number') {
          return _controllers[q.id]?.text.isEmpty ?? true;
        } else if (q.multi) {
          final answers = _screenState.answers[q.id] as List<String>?;
          return answers == null || answers.isEmpty;
        } else {
          return _screenState.answers[q.id] == null;
        }
      });

      SmartFeedbackSystem.showValidationError(
        context,
        'אנא ענה על השאלה: ${missingQuestion.title}',
      );
      return;
    }

    HapticFeedback.selectionClick();

    if (_screenState.isLastPage) {
      _finishQuestionnaire();
    } else {
      // אנימציית מעבר חלקה
      _slideController.reset();
      _slideController.forward();

      _updateState(_screenState.copyWith(
        currentPage: _screenState.currentPage + 1,
      ));
    }
  }

  void _previousPage() {
    if (_screenState.currentPage > 0) {
      HapticFeedback.selectionClick();

      _slideController.reset();
      _slideController.forward();

      _updateState(_screenState.copyWith(
        currentPage: _screenState.currentPage - 1,
      ));
    }
  }

  Future<void> _finishQuestionnaire() async {
    _updateState(_screenState.copyWith(state: QuestionnaireState.saving));

    try {
      HapticFeedback.mediumImpact();

      var user = await LocalDataStore.getCurrentUser();
      bool isGuest = false;

      if (user == null) {
        user = await LocalDataStore.createGuestUser();
        isGuest = true;
      } else if (user.isGuest == true) {
        isGuest = true;
      }

      // שמירת תשובות השאלון
      user = user.copyWith(
        questionnaireAnswers: Map<String, dynamic>.from(_screenState.answers),
        profileLastUpdated: DateTime.now(),
      );

      await LocalDataStore.saveUser(user);

      // בניית תוכנית
      final weekPlan = await PlanBuilderService.buildFromAnswers(
        user,
        _screenState.answers,
      );

      final plan = WeekPlanModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: user.id,
        title: 'תוכנית שבועית מותאמת',
        description: 'תוכנית אימונים שבועית מותאמת אישית על בסיס השאלון',
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 7)),
        workouts: weekPlan,
        isActive: true,
        lastUpdated: DateTime.now(),
      );

      // טיפול במשתמש אורח
      if (isGuest && mounted) {
        final navigator = Navigator.of(context);
        await navigator.push(
          MaterialPageRoute(builder: (_) => const RegisterScreen()),
        );

        user = await LocalDataStore.getCurrentUser();
        if (user != null && !user.isGuest) {
          user = user.copyWith(
            questionnaireAnswers:
                Map<String, dynamic>.from(_screenState.answers),
            profileLastUpdated: DateTime.now(),
          );
          await LocalDataStore.saveUser(user);
        }
      }

      // שמירת התוכנית
      if (user != null) {
        await LocalDataStore.saveUserPlan(user.id, plan);
      }

      _updateState(_screenState.copyWith(state: QuestionnaireState.completed));

      if (mounted) {
        SmartFeedbackSystem.showSuccess(
            context, 'תוכנית האימונים נוצרה בהצלחה! 🎉');

        final weekPlanProvider = context.read<WeekPlanProvider>();
        await weekPlanProvider.refreshPlan();

        // השהיה קצרה להצגת ההצלחה
        await Future.delayed(const Duration(seconds: 1));

        if (mounted) {
          await _fadeController.reverse();
          Navigator.of(context).pushReplacement(
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  const HomeScreen(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
            ),
          );
        }
      }
    } catch (e, stackTrace) {
      debugPrint('שגיאה בשמירת התוכנית: $e');
      debugPrint('$stackTrace');

      _updateState(_screenState.copyWith(
        state: QuestionnaireState.error,
        errorMessage: 'שגיאה בשמירת התוכנית. אנא נסה שוב.',
      ));

      if (mounted) {
        SmartFeedbackSystem.showValidationError(
          context,
          'שגיאה בשמירת התוכנית. אנא נסה שוב.',
        );
      }
    }
  }

  Widget _buildHeightInput(Question q) {
    final controller = _controllers[q.id]!;
    final currentValue = controller.text.isEmpty
        ? ValidationConstants.getDefaultHeight(_screenState.answers['gender'])
        : double.tryParse(controller.text) ??
            ValidationConstants.getDefaultHeight(
                _screenState.answers['gender']);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            q.title,
            style: GoogleFonts.assistant(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.colors.text,
            ),
          ),
          const SizedBox(height: 20),

          // תצוגת הגובה הנוכחי
          Hero(
            tag: 'height_display',
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.colors.primary.withValues(alpha: 0.1),
                    AppTheme.colors.primary.withValues(alpha: 0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppTheme.colors.primary.withValues(alpha: 0.3),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.colors.primary.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    '${currentValue.toInt()}',
                    style: GoogleFonts.assistant(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.colors.primary,
                    ),
                  ),
                  Text(
                    'ס"מ',
                    style: GoogleFonts.assistant(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.colors.primary.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // סליידר מעוצב
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppTheme.colors.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: AppTheme.colors.primary,
                    inactiveTrackColor:
                        AppTheme.colors.primary.withValues(alpha: 0.2),
                    thumbColor: AppTheme.colors.primary,
                    thumbShape:
                        const RoundSliderThumbShape(enabledThumbRadius: 12),
                    overlayColor:
                        AppTheme.colors.primary.withValues(alpha: 0.2),
                    trackHeight: 6,
                  ),
                  child: Slider(
                    value: currentValue.clamp(
                      ValidationConstants.minHeight,
                      ValidationConstants.maxHeight,
                    ),
                    min: ValidationConstants.minHeight,
                    max: ValidationConstants.maxHeight,
                    divisions: (ValidationConstants.maxHeight -
                            ValidationConstants.minHeight)
                        .toInt(),
                    label: '${currentValue.toInt()} ס"מ',
                    onChanged: (value) {
                      HapticFeedback.selectionClick();
                      setState(() {
                        controller.text = value.toInt().toString();
                        _updateAnswer(q.id, value.toInt());
                      });
                    },
                  ),
                ),

                // תצוגת טווח
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
              ],
            ),
          ),

          const SizedBox(height: 20),

          // שדה הזנה ידנית
          TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: GoogleFonts.assistant(
              color: AppTheme.colors.text,
              fontSize: 16,
              fontWeight: FontWeight.w500,
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
              prefixIcon: Icon(Icons.height, color: AppTheme.colors.primary),
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
                  _updateAnswer(q.id, val.toInt());
                });
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildWeightInput(Question q) {
    final controller = _controllers[q.id]!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'מה המשקל שלך?',
          style: GoogleFonts.assistant(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.colors.text,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'טווח תקין: ${ValidationConstants.minWeight.toInt()}-${ValidationConstants.maxWeight.toInt()} ק"ג',
          style: GoogleFonts.assistant(
            fontSize: 14,
            color: AppTheme.colors.text.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.colors.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,1}')),
            ],
            style: GoogleFonts.assistant(
              color: AppTheme.colors.text,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: 'משקל בק"ג',
              prefixIcon: Container(
                margin: const EdgeInsets.all(12),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.colors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.monitor_weight_outlined,
                  color: AppTheme.colors.primary,
                  size: 20,
                ),
              ),
              suffixText: 'ק"ג',
              suffixStyle: GoogleFonts.assistant(
                color: AppTheme.colors.text.withValues(alpha: 0.6),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              hintStyle: GoogleFonts.assistant(
                color: AppTheme.colors.text.withValues(alpha: 0.5),
              ),
              filled: true,
              fillColor: Colors.transparent,
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
                borderSide: const BorderSide(
                  color: Colors.red,
                  width: 2,
                ),
              ),
            ),
            onChanged: (text) {
              final val = double.tryParse(text);
              if (val != null) {
                if (ValidationConstants.isValidWeight(val)) {
                  _updateAnswer(q.id, val.toInt());
                } else {
                  SmartFeedbackSystem.showValidationError(
                    context,
                    'משקל חייב להיות בין ${ValidationConstants.minWeight.toInt()}-${ValidationConstants.maxWeight.toInt()} ק"ג',
                  );
                }
              }
            },
          ),
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
    final questionTitle = q.id == 'age' ? _getGenderAwareAgeLabel() : q.title;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          questionTitle,
          style: GoogleFonts.assistant(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.colors.text,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.colors.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: GoogleFonts.assistant(
              color: AppTheme.colors.text,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: q.id == 'age' ? 'גיל בשנים' : 'הזן ערך',
              prefixIcon: Icon(
                q.id == 'age' ? Icons.cake_outlined : Icons.numbers,
                color: AppTheme.colors.primary,
              ),
              hintStyle: GoogleFonts.assistant(
                color: AppTheme.colors.text.withValues(alpha: 0.5),
              ),
              filled: true,
              fillColor: Colors.transparent,
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
              final val = int.tryParse(text);
              if (val != null) {
                _updateAnswer(q.id, val);
              }
            },
          ),
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
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.colors.text,
          ),
        ),
        const SizedBox(height: 12),

        if (q.multi) ...[
          if (q.maxSelections != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.colors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'בחר עד ${q.maxSelections} אפשרויות',
                style: GoogleFonts.assistant(
                  fontSize: 14,
                  color: AppTheme.colors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          const SizedBox(height: 12),

          // בחירה מרובה עם אנימציות
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: q.options.asMap().entries.map((entry) {
              final index = entry.key;
              final opt = entry.value;
              final currentAnswers =
                  _screenState.answers[q.id] as List<String>? ?? [];
              final isSelected = currentAnswers.contains(opt);
              final canSelect = isSelected ||
                  (q.maxSelections == null ||
                      currentAnswers.length < q.maxSelections!);

              return AnimatedScale(
                scale: isSelected ? 1.05 : 1.0,
                duration: const Duration(milliseconds: 200),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  child: FilterChip(
                    label: Text(
                      opt,
                      style: GoogleFonts.assistant(
                        color: isSelected ? Colors.white : AppTheme.colors.text,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.w500,
                        fontSize: 15,
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: AppTheme.colors.primary,
                    backgroundColor: AppTheme.colors.surface,
                    disabledColor:
                        AppTheme.colors.surface.withValues(alpha: 0.5),
                    checkmarkColor: Colors.white,
                    elevation: isSelected ? 4 : 1,
                    pressElevation: 8,
                    side: BorderSide(
                      color: isSelected
                          ? AppTheme.colors.primary
                          : AppTheme.colors.text.withValues(alpha: 0.2),
                      width: isSelected ? 2 : 1,
                    ),
                    onSelected: canSelect
                        ? (selected) {
                            HapticFeedback.selectionClick();
                            setState(() {
                              final currentList = List<String>.from(
                                  _screenState.answers[q.id] ?? []);
                              if (selected) {
                                currentList.add(opt);
                              } else {
                                currentList.remove(opt);
                              }
                              _updateAnswer(q.id, currentList);
                            });
                          }
                        : null,
                  ),
                ),
              );
            }).toList(),
          ),
        ] else ...[
          // בחירה יחידה עם אנימציות
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: q.options.map((opt) {
              final isSelected = _screenState.answers[q.id] == opt;

              return AnimatedScale(
                scale: isSelected ? 1.05 : 1.0,
                duration: const Duration(milliseconds: 200),
                child: FilterChip(
                  label: Text(
                    opt,
                    style: GoogleFonts.assistant(
                      color: isSelected ? Colors.white : AppTheme.colors.text,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.w500,
                      fontSize: 15,
                    ),
                  ),
                  selected: isSelected,
                  selectedColor: AppTheme.colors.primary,
                  backgroundColor: AppTheme.colors.surface,
                  checkmarkColor: Colors.white,
                  elevation: isSelected ? 4 : 1,
                  pressElevation: 8,
                  side: BorderSide(
                    color: isSelected
                        ? AppTheme.colors.primary
                        : AppTheme.colors.text.withValues(alpha: 0.2),
                    width: isSelected ? 2 : 1,
                  ),
                  onSelected: (_) {
                    HapticFeedback.selectionClick();
                    _updateAnswer(q.id, opt);
                  },
                ),
              );
            }).toList(),
          ),
        ],

        // הסבר נוסף
        if (q.explanation != null) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.colors.primary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.colors.primary.withValues(alpha: 0.1),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppTheme.colors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    Icons.lightbulb_outline,
                    size: 18,
                    color: AppTheme.colors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    q.explanation!,
                    style: GoogleFonts.assistant(
                      fontSize: 14,
                      color: AppTheme.colors.text.withValues(alpha: 0.8),
                      height: 1.4,
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

  Widget _buildProgressIndicator() {
    return Container(
      height: 8,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: AppTheme.colors.surface.withValues(alpha: 0.3),
      ),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
        child: LinearProgressIndicator(
          value: _screenState.progress,
          backgroundColor: Colors.transparent,
          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.colors.primary),
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        children: [
          // כפתור חזור
          if (_screenState.currentPage > 0)
            Expanded(
              flex: 1,
              child: TextButton.icon(
                onPressed: _screenState.isSaving ? null : _previousPage,
                icon: const Icon(Icons.arrow_back_ios, size: 18),
                label: Text(
                  'חזור',
                  style: GoogleFonts.assistant(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

          if (_screenState.currentPage > 0) const SizedBox(width: 16),

          // כפתור המשך/סיום
          Expanded(
            flex: 2,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: ElevatedButton(
                key: ValueKey(_screenState.isSaving),
                onPressed: _screenState.isSaving ? null : _nextPage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.colors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                  shadowColor: AppTheme.colors.primary.withValues(alpha: 0.3),
                ),
                child: _screenState.isSaving
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'שומר...',
                            style: GoogleFonts.assistant(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _screenState.isLastPage ? 'סיום השאלון' : 'המשך',
                            style: GoogleFonts.assistant(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            _screenState.isLastPage
                                ? Icons.check_circle
                                : Icons.arrow_forward_ios,
                            size: 18,
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colors;

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
          onPressed: _screenState.isSaving
              ? null
              : () {
                  if (_screenState.hasUnsavedChanges) {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(
                          'יציאה מהשאלון?',
                          style: GoogleFonts.assistant(
                              fontWeight: FontWeight.bold),
                        ),
                        content: Text(
                          'יש לך שינויים שלא נשמרו. האם אתה בטוח שאתה רוצה לצאת?',
                          style: GoogleFonts.assistant(),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child:
                                Text('ביטול', style: GoogleFonts.assistant()),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const WelcomeScreen()),
                                (_) => false,
                              );
                            },
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red),
                            child: Text('צא',
                                style:
                                    GoogleFonts.assistant(color: Colors.white)),
                          ),
                        ],
                      ),
                    );
                  } else {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                      (_) => false,
                    );
                  }
                },
        ),
        actions: [
          // אינדיקטור שמירה אוטומטית
          if (_screenState.hasUnsavedChanges)
            Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.save_outlined,
                      size: 16, color: Colors.orange),
                  const SizedBox(width: 4),
                  Text(
                    'טיוטה',
                    style: GoogleFonts.assistant(
                      fontSize: 12,
                      color: Colors.orange,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // באנר מידע עם אנימציה
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _screenState.showInfoBanner
                        ? Container(
                            key: const ValueKey('info'),
                            padding: const EdgeInsets.all(16),
                            margin: const EdgeInsets.only(bottom: 20),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppTheme.colors.primary
                                      .withValues(alpha: 0.1),
                                  AppTheme.colors.primary
                                      .withValues(alpha: 0.05),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppTheme.colors.primary
                                    .withValues(alpha: 0.2),
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppTheme.colors.primary
                                        .withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.tips_and_updates,
                                    color: AppTheme.colors.primary,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'כמשתמש רשום, תמיד תוכל לעדכן את השאלון ולרענן את התוכנית שלך.',
                                    style: GoogleFonts.assistant(
                                      color: AppTheme.colors.text
                                          .withValues(alpha: 0.8),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.close,
                                    color: AppTheme.colors.text
                                        .withValues(alpha: 0.6),
                                    size: 20,
                                  ),
                                  onPressed: () => _updateState(
                                    _screenState.copyWith(
                                        showInfoBanner: false),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),

                  // מחוון התקדמות משופר
                  _buildProgressIndicator(),

                  const SizedBox(height: 24),

                  // תצוגת השאלות
                  Expanded(
                    child: _screenState.currentPageQuestions.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.quiz_outlined,
                                  size: 64,
                                  color: AppTheme.colors.text
                                      .withValues(alpha: 0.3),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'אין שאלות להצגה',
                                  style: GoogleFonts.assistant(
                                    fontSize: 18,
                                    color: AppTheme.colors.text
                                        .withValues(alpha: 0.6),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.separated(
                            physics: const BouncingScrollPhysics(),
                            itemCount: _screenState.currentPageQuestions.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 32),
                            itemBuilder: (ctx, idx) {
                              final q = _screenState.currentPageQuestions[idx];

                              return AnimatedContainer(
                                duration:
                                    Duration(milliseconds: 300 + (idx * 100)),
                                curve: Curves.easeOutCubic,
                                child: q.inputType == 'number'
                                    ? _buildNumberInput(q)
                                    : _buildChoiceQuestion(q),
                              );
                            },
                          ),
                  ),

                  // כפתורי ניווט משופרים
                  _buildNavigationButtons(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
