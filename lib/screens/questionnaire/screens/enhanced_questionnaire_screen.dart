// lib/screens/questionnaire/screens/enhanced_questionnaire_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../theme/app_theme.dart';
import '../../../models/question_model.dart';
import '../components/question_widgets_factory.dart';
import '../managers/questionnaire_state_manager.dart';
import '../managers/questionnaire_validation_manager.dart';
import '../services/questionnaire_analytics.dart';
import '../../../services/plan_builder_service.dart';
import '../../../models/week_plan_model.dart';
import '../../../data/local_data_store.dart';
import '../../../screens/home/home_screen.dart';
import '../../../screens/welcome/welcome_screen.dart';
import '../../../questionnaire/questions.dart';

class EnhancedQuestionnaireScreen extends StatefulWidget {
  const EnhancedQuestionnaireScreen({super.key});

  @override
  State<EnhancedQuestionnaireScreen> createState() =>
      _EnhancedQuestionnaireScreenState();
}

class _EnhancedQuestionnaireScreenState
    extends State<EnhancedQuestionnaireScreen> with TickerProviderStateMixin {
  late QuestionnaireStateManager _stateManager;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final Map<String, TextEditingController> _controllers = {};
  final Map<String, FocusNode> _focusNodes = {};

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeStateManager();
    _setupControllers();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
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

  void _initializeStateManager() {
    _stateManager = QuestionnaireStateManager();
    _stateManager.addListener(_onStateChanged);
    _stateManager.initialize();
  }

  void _setupControllers() {
    // הגדרת controllers לכל שאלות המספר והטקסט
    for (final question in allQuestions) {
      if (question.inputType == 'number' ||
          question.inputType == 'text' ||
          question.inputType == 'slider') {
        _controllers[question.id] = TextEditingController();
        _focusNodes[question.id] = FocusNode();

        // הגדרת ערך ברירת מחדל לגובה
        if (question.id == 'height') {
          final defaultHeight = 163;
          _controllers[question.id]!.text = defaultHeight.toString();
          _stateManager.setAnswer(question.id, defaultHeight);
        }

        // Listener מיוחד לגיל
        if (question.id == 'age') {
          _focusNodes[question.id]!.addListener(() {
            if (!_focusNodes[question.id]!.hasFocus) {
              _validateAgeInput();
            }
          });
        }
      }
    }
  }

  void _onStateChanged() {
    if (mounted) {
      setState(() {});

      // טיפול במצבי שגיאה
      if (_stateManager.hasError && _stateManager.errorMessage != null) {
        _showErrorMessage(_stateManager.errorMessage!);
      }

      // מעבר למסך הבא כשהשאלון הושלם
      if (_stateManager.isCompleted) {
        _navigateToNextScreen();
      }
    }
  }

  void _validateAgeInput() {
    final ageText = _controllers['age']?.text;
    if (ageText != null && ageText.isNotEmpty) {
      final age = int.tryParse(ageText);
      if (age != null) {
        final error = QuestionnaireValidationManager.validateAge(age);
        if (error != null) {
          _showAgeRestrictionDialog(age);
        }
      }
    }
  }

  void _showAgeRestrictionDialog(int age) {
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
              style: GoogleFonts.assistant(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'האפליקציה מיועדת לגילאי 16 ומעלה. תוכניות האימון שלנו מותאמות לבוגרים.',
              style: GoogleFonts.assistant(fontSize: 16, height: 1.4),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'למה דרושה הגבלת גיל?',
                    style: GoogleFonts.assistant(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[700],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '• בטיחות: תוכניות מותאמות לגוף בוגר\n'
                    '• אחריות משפטית: נדרש גיל בגרות\n'
                    '• התפתחות גופנית: מערכות בגדילה',
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
              _controllers['age']?.clear();
              _stateManager.removeAnswer('age');
            },
            child: Text('הבנתי', style: GoogleFonts.assistant()),
          ),
          if (age < 16)
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _navigateToWelcome();
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text('חזור למסך הראשי', style: GoogleFonts.assistant()),
            ),
        ],
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'סגור',
          textColor: Colors.white,
          onPressed: () => _stateManager.clearError(),
        ),
      ),
    );
  }

  void _onAnswerChanged(String questionId, dynamic value) {
    _stateManager.setAnswer(questionId, value);

    // עדכון controller אם קיים
    if (_controllers[questionId] != null && value != null) {
      _controllers[questionId]!.text = value.toString();
    }

    // עדכון ברירת מחדל לגובה לפי מגדר
    if (questionId == 'gender') {
      _updateHeightDefault(value);
    }
  }

  void _updateHeightDefault(String? gender) {
    if (_controllers['height'] != null) {
      final currentHeight = _stateManager.answers['height'];
      if (currentHeight == null || _isDefaultHeight(currentHeight)) {
        final newDefault = _getDefaultHeightForGender(gender);
        _controllers['height']!.text = newDefault.toString();
        _stateManager.setAnswer('height', newDefault);
      }
    }
  }

  bool _isDefaultHeight(dynamic height) {
    final heightNum = int.tryParse(height.toString()) ?? 0;
    return heightNum == 163 || heightNum == 177 || heightNum == 170;
  }

  int _getDefaultHeightForGender(String? gender) {
    switch (gender?.toLowerCase()) {
      case 'זכר':
        return 177;
      case 'נקבה':
        return 163;
      default:
        return 170;
    }
  }

  void _nextPage() {
    final validationError = _stateManager.validateCurrentPage();
    if (validationError != null) {
      HapticFeedback.lightImpact();
      _showErrorMessage(validationError);
      return;
    }

    HapticFeedback.selectionClick();

    if (_stateManager.isLastPage) {
      _completeQuestionnaire();
    } else {
      _slideController.reset();
      _slideController.forward();
      _stateManager.nextPage();
    }
  }

  void _previousPage() {
    if (_stateManager.canNavigatePrevious()) {
      HapticFeedback.selectionClick();
      _slideController.reset();
      _slideController.forward();
      _stateManager.previousPage();
    }
  }

  Future<void> _completeQuestionnaire() async {
    final success = await _stateManager.completeQuestionnaire();

    if (success) {
      HapticFeedback.mediumImpact();
      await _buildAndSavePlan();
    }
  }

  Future<void> _buildAndSavePlan() async {
    try {
      final user = await LocalDataStore.getCurrentUser();
      if (user == null) return;

      // בניית תוכנית מהתשובות
      final weekPlan = await PlanBuilderService.buildFromAnswers(
        user,
        _stateManager.answers,
      );

      final plan = WeekPlanModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: user.id,
        title: 'תוכנית שבועית מותאמת',
        description: _generatePlanDescription(),
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 7)),
        workouts: weekPlan,
        isActive: true,
        lastUpdated: DateTime.now(),
      );

      await LocalDataStore.saveUserPlan(user.id, plan);

      // ניתוח ושמירת המלצות
      final analysis =
          QuestionnaireAnalytics.analyzeAnswers(_stateManager.answers);
      await LocalDataStore.saveUserAnalysis(user.id, analysis);
    } catch (e) {
      _stateManager.setError('שגיאה ביצירת התוכנית: $e');
    }
  }

  String _generatePlanDescription() {
    final answers = _stateManager.answers;
    final goal = answers['goal'] ?? 'שיפור כושר כללי';
    final frequency = answers['frequency'] ?? '3-4 פעמים';
    final experience = answers['experience_level'] ?? 'מתחיל';

    return 'תוכנית $goal מותאמת לרמת $experience, עם תדירות של $frequency בשבוע.';
  }

  void _navigateToNextScreen() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const HomeScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  void _navigateToWelcome() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const WelcomeScreen()),
      (_) => false,
    );
  }

  void _exitQuestionnaire() {
    if (_stateManager.hasUnsavedChanges) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('יציאה מהשאלון?', style: GoogleFonts.assistant()),
          content: Text(
            'יש לך שינויים שלא נשמרו. האם אתה בטוח שאתה רוצה לצאת?',
            style: GoogleFonts.assistant(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('ביטול', style: GoogleFonts.assistant()),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _navigateToWelcome();
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text('צא', style: GoogleFonts.assistant()),
            ),
          ],
        ),
      );
    } else {
      _navigateToWelcome();
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _stateManager.removeListener(_onStateChanged);
    _stateManager.dispose();

    for (var controller in _controllers.values) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes.values) {
      focusNode.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colors;

    if (_stateManager.isLoading) {
      return Scaffold(
        backgroundColor: colors.background,
        body: Center(
          child: CircularProgressIndicator(color: colors.primary),
        ),
      );
    }

    return Scaffold(
      backgroundColor: colors.background,
      appBar: _buildAppBar(colors),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Column(
              children: [
                _buildProgressSection(colors),
                Expanded(
                  child: _buildQuestionsSection(colors),
                ),
                _buildNavigationSection(colors),
              ],
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(AppColors colors) {
    return AppBar(
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
        onPressed: _stateManager.isSaving ? null : _exitQuestionnaire,
      ),
      actions: [
        if (_stateManager.hasUnsavedChanges)
          Container(
            margin: const EdgeInsets.only(left: 16),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.save_outlined, size: 16, color: Colors.orange),
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
    );
  }

  Widget _buildProgressSection(AppColors colors) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // מחוון התקדמות
          Container(
            height: 8,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: colors.surface.withValues(alpha: 0.3),
            ),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOutCubic,
              child: LinearProgressIndicator(
                value: _stateManager.progress,
                backgroundColor: Colors.transparent,
                valueColor: AlwaysStoppedAnimation<Color>(colors.primary),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // מידע על התקדמות
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'שאלה ${(_stateManager.currentPage * 3) + 1}-${((_stateManager.currentPage + 1) * 3).clamp(0, _stateManager.visibleQuestions.length)} מתוך ${_stateManager.visibleQuestions.length}',
                style: GoogleFonts.assistant(
                  fontSize: 14,
                  color: colors.text.withValues(alpha: 0.7),
                ),
              ),
              Text(
                '${(_stateManager.progress * 100).round()}%',
                style: GoogleFonts.assistant(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: colors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionsSection(AppColors colors) {
    final currentQuestions = _stateManager.currentPageQuestions;

    if (currentQuestions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.quiz_outlined,
              size: 64,
              color: colors.text.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'אין שאלות להצגה',
              style: GoogleFonts.assistant(
                fontSize: 18,
                color: colors.text.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      physics: const BouncingScrollPhysics(),
      itemCount: currentQuestions.length,
      separatorBuilder: (_, __) => const SizedBox(height: 32),
      itemBuilder: (context, index) {
        final question = currentQuestions[index];

        return AnimatedContainer(
          duration: Duration(milliseconds: 300 + (index * 100)),
          curve: Curves.easeOutCubic,
          child: QuestionWidgetFactory.buildQuestion(
            question: question,
            answers: _stateManager.answers,
            onAnswerChanged: _onAnswerChanged,
            controller: _controllers[question.id],
            focusNode: _focusNodes[question.id],
          ),
        );
      },
    );
  }

  Widget _buildNavigationSection(AppColors colors) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          if (_stateManager.canNavigatePrevious())
            Expanded(
              flex: 1,
              child: TextButton.icon(
                onPressed: _stateManager.isSaving ? null : _previousPage,
                icon: const Icon(Icons.arrow_back_ios, size: 18),
                label: Text(
                  'חזור',
                  style: GoogleFonts.assistant(fontSize: 16),
                ),
              ),
            ),
          if (_stateManager.canNavigatePrevious()) const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _stateManager.isSaving ? null : _nextPage,
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
              ),
              child: _stateManager.isSaving
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
                          _stateManager.isLastPage ? 'סיום השאלון' : 'המשך',
                          style: GoogleFonts.assistant(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          _stateManager.isLastPage
                              ? Icons.check_circle
                              : Icons.arrow_forward_ios,
                          size: 18,
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
