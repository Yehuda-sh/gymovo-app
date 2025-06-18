//
import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../models/question_model.dart' as qm;
import '../../../questionnaire/questions.dart' hide Question;
import '../questionnaire_intro_screen.dart';
import '../../../data/local_data_store.dart';

enum QuestionnaireStatus {
  loading,
  ready,
  inProgress,
  saving,
  completed,
  error,
}

class QuestionnaireStateManager extends ChangeNotifier {
  QuestionnaireStatus _status = QuestionnaireStatus.loading;
  Map<String, dynamic> _answers = {};
  List<qm.Question> _visibleQuestions = [];
  int _currentPage = 0;
  String? _errorMessage;
  bool _hasUnsavedChanges = false;
  Timer? _autoSaveTimer;

  static const int questionsPerPage = 3;
  static const Duration autoSaveInterval = Duration(seconds: 15);

  // Getters
  QuestionnaireStatus get status => _status;
  Map<String, dynamic> get answers => Map.unmodifiable(_answers);
  List<qm.Question> get visibleQuestions =>
      List.unmodifiable(_visibleQuestions);
  int get currentPage => _currentPage;
  String? get errorMessage => _errorMessage;
  bool get hasUnsavedChanges => _hasUnsavedChanges;

  bool get isLoading => _status == QuestionnaireStatus.loading;
  bool get isReady => _status == QuestionnaireStatus.ready;
  bool get isInProgress => _status == QuestionnaireStatus.inProgress;
  bool get isSaving => _status == QuestionnaireStatus.saving;
  bool get isCompleted => _status == QuestionnaireStatus.completed;
  bool get hasError => _status == QuestionnaireStatus.error;

  double get progress {
    if (_visibleQuestions.isEmpty) return 0.0;
    return (_currentPage * questionsPerPage) / _visibleQuestions.length;
  }

  bool get isLastPage {
    return (_currentPage + 1) * questionsPerPage >= _visibleQuestions.length;
  }

  List<qm.Question> get currentPageQuestions {
    final start = _currentPage * questionsPerPage;
    return _visibleQuestions.skip(start).take(questionsPerPage).toList();
  }

  // Initialize
  Future<void> initialize() async {
    try {
      _updateStatus(QuestionnaireStatus.loading);

      await _loadExistingAnswers();

      _updateVisibleQuestions();

      _startAutoSave();

      _updateStatus(QuestionnaireStatus.ready);
    } catch (e) {
      _setError('שגיאה באתחול השאלון: $e');
    }
  }

  Future<void> _loadExistingAnswers() async {
    try {
      final savedAnswers = await LocalDataStore.getQuestionnaireProgress();
      if (savedAnswers != null && savedAnswers.isNotEmpty) {
        _answers = savedAnswers;
        _hasUnsavedChanges = false;
      }
    } catch (e) {
      debugPrint('שגיאה בטעינת תשובות קיימות: $e');
    }
  }

  void _updateVisibleQuestions() {
    _visibleQuestions = QuestionnaireManager.getVisibleQuestions(_answers)
        .map((q) => qm.Question(
              id: q.id,
              title: q.title,
              type: qm.QuestionType.values
                  .firstWhere((t) => t.name == q.inputType),
              isRequired: true,
            ))
        .toList();
    notifyListeners();
  }

  void _startAutoSave() {
    _autoSaveTimer?.cancel();
    _autoSaveTimer = Timer.periodic(autoSaveInterval, (_) {
      if (_hasUnsavedChanges) {
        _autoSaveProgress();
      }
    });
  }

  Future<void> _autoSaveProgress() async {
    try {
      await LocalDataStore.saveQuestionnaireProgress(_answers);
      _hasUnsavedChanges = false;
      notifyListeners();
    } catch (e) {
      debugPrint('שגיאה בשמירה אוטומטית: $e');
    }
  }

  void _updateStatus(QuestionnaireStatus newStatus) {
    _status = newStatus;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    _updateStatus(QuestionnaireStatus.error);
  }

  void setError(String error) {
    _setError(error);
  }

  void clearError() {
    _errorMessage = null;
    if (_status == QuestionnaireStatus.error) {
      _updateStatus(QuestionnaireStatus.ready);
    }
  }

  // Answer management
  void setAnswer(String questionId, dynamic value) {
    _answers[questionId] = value;
    final oldVisibleCount = _visibleQuestions.length;
    _updateVisibleQuestions();

    if (_visibleQuestions.length != oldVisibleCount) {
      _validateCurrentPage();
    }

    _hasUnsavedChanges = true;
    notifyListeners();
  }

  void removeAnswer(String questionId) {
    _answers.remove(questionId);
    _updateVisibleQuestions();
    _validateCurrentPage();
    _hasUnsavedChanges = true;
    notifyListeners();
  }

  void clearAnswers() {
    _answers.clear();
    _updateVisibleQuestions();
    _currentPage = 0;
    _hasUnsavedChanges = true;
    notifyListeners();
  }

  // Navigation
  bool canNavigateNext() => _validateCurrentPageAnswers();
  bool canNavigatePrevious() => _currentPage > 0;

  String? validateCurrentPage() {
    final currentQuestions = currentPageQuestions;
    for (final question in currentQuestions) {
      if (!question.isRequired) continue;
      final answer = _answers[question.id];
      if (question.type == qm.QuestionType.multipleChoice) {
        final list = answer as List<String>?;
        if (list == null || list.isEmpty) {
          return 'אנא ענה על השאלה: ${question.title}';
        }
        final validation = question.validation;
        if (validation?.minSelections != null &&
            list.length < validation!.minSelections!) {
          return 'יש לבחור לפחות ${validation.minSelections} אפשרויות ב: ${question.title}';
        }
      } else if (answer == null) {
        return 'אנא ענה על השאלה: ${question.title}';
      }
      if (question.validation?.customValidator != null) {
        final validationError = question.validation!.customValidator!(answer);
        if (validationError != null) {
          return validationError;
        }
      }
    }
    return null;
  }

  bool _validateCurrentPageAnswers() => validateCurrentPage() == null;

  void _validateCurrentPage() {
    final maxPage = (_visibleQuestions.length / questionsPerPage).ceil() - 1;
    if (_currentPage > maxPage) {
      _currentPage = maxPage.clamp(0, maxPage);
    }
  }

  bool nextPage() {
    if (!_validateCurrentPageAnswers()) return false;
    if (isLastPage) return false;
    _currentPage++;
    notifyListeners();
    return true;
  }

  bool previousPage() {
    if (_currentPage <= 0) return false;
    _currentPage--;
    notifyListeners();
    return true;
  }

  void goToPage(int page) {
    final maxPage = (_visibleQuestions.length / questionsPerPage).ceil() - 1;
    _currentPage = page.clamp(0, maxPage);
    notifyListeners();
  }

  // Completion
  Future<bool> completeQuestionnaire() async {
    try {
      _updateStatus(QuestionnaireStatus.saving);

      // ולידציה סופית של כל התשובות
      final missingAnswers = _validateAllAnswers();
      if (missingAnswers.isNotEmpty) {
        _setError('חסרות תשובות לשאלות: ${missingAnswers.join(', ')}');
        return false;
      }

      // שמירת התשובות למשתמש
      await _saveAnswersToUser();

      // ניקוי התקדמות זמנית
      await LocalDataStore.clearQuestionnaireProgress();

      _hasUnsavedChanges = false;
      _updateStatus(QuestionnaireStatus.completed);

      return true;
    } catch (e) {
      _setError('שגיאה בשמירת השאלון: $e');
      return false;
    }
  }

  List<String> _validateAllAnswers() {
    final missingAnswers = <String>[];
    for (final question in _visibleQuestions) {
      if (!question.isRequired) continue;
      final answer = _answers[question.id];
      if (question.type == qm.QuestionType.multipleChoice) {
        final list = answer as List<String>?;
        if (list == null || list.isEmpty) {
          missingAnswers.add(question.title);
        }
      } else if (answer == null) {
        missingAnswers.add(question.title);
      }
    }
    return missingAnswers;
  }

  Future<void> _saveAnswersToUser() async {
    var user = await LocalDataStore.getCurrentUser();
    if (user == null) {
      user = await LocalDataStore.createGuestUser();
    }
    final updatedUser = user.copyWith(
      questionnaireAnswers: Map<String, dynamic>.from(_answers),
      profileLastUpdated: DateTime.now(),
    );
    await LocalDataStore.saveUser(updatedUser);
  }

  @override
  void dispose() {
    _autoSaveTimer?.cancel();
    super.dispose();
  }
}
