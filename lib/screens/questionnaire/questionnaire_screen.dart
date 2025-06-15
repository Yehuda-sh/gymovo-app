// lib/screens/questionnaire_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../questionnaire/questions.dart';
import '../services/plan_builder_service.dart';
import '../models/week_plan_model.dart';
import '../data/local_data_store.dart';
import '../screens/register_screen.dart';
import '../providers/week_plan_provider.dart';

class QuestionnaireScreen extends StatefulWidget {
  const QuestionnaireScreen({super.key});
  @override
  State<QuestionnaireScreen> createState() => _QuestionnaireScreenState();
}

class _QuestionnaireScreenState extends State<QuestionnaireScreen> {
  final Map<String, dynamic> _answers = {};
  int _pageIndex = 0;
  late List<Question> _visibleQuestions;
  late DateTime _pageStartTime;
  bool _showInfoBanner = true;
  bool _isSaving = false;

  final Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    _visibleQuestions = _getVisibleQuestions();
    _pageStartTime = DateTime.now();

    for (var q in allQuestions.where((q) => q.inputType == 'number')) {
      _controllers[q.id] = TextEditingController();
    }
  }

  @override
  void dispose() {
    for (var c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  List<Question> _getVisibleQuestions() =>
      allQuestions.where((q) => q.showIf(_answers)).toList();

  void _setAnswer(String qId, dynamic value) {
    setState(() {
      _answers[qId] = value;
      _visibleQuestions = _getVisibleQuestions();
    });

    final q = allQuestions.firstWhere((q) => q.id == qId);
    final fb = q.feedback?.call(value);
    if (fb != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(fb), duration: const Duration(seconds: 2)),
      );
    }
  }

  void _nextPage() {
    const questionsPerPage = 3;
    for (int i = 0; i < questionsPerPage; i++) {
      final absIndex = _pageIndex * questionsPerPage + i;
      if (absIndex >= _visibleQuestions.length) break;
      final q = _visibleQuestions[absIndex];
      if (_answers[q.id] == null ||
          (q.inputType == 'number' &&
              (_controllers[q.id]?.text.isEmpty ?? true))) {
        return;
      }
    }

    if ((_pageIndex + 1) * questionsPerPage >= _visibleQuestions.length) {
      _finishQuestionnaire();
    } else {
      setState(() {
        _pageIndex++;
        _pageStartTime = DateTime.now();
      });
    }
  }

  void _previousPage() {
    if (_pageIndex > 0) {
      setState(() {
        _pageIndex--;
        _pageStartTime = DateTime.now();
      });
    }
  }

  Future<void> _finishQuestionnaire() async {
    setState(() => _isSaving = true);

    try {
      var user = await LocalDataStore.getCurrentUser();
      bool isGuest = false;
      if (user == null) {
        user = await LocalDataStore.createGuestUser();
        isGuest = true;
      } else if (user.isGuest ?? false) {
        isGuest = true;
      }

      // TODO: ניתן להעביר _answers ל־PlanBuilder לשיפור ההתאמה

      final weekPlan = await PlanBuilderService.buildPlansForUser(user!);
      final plan = WeekPlanModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: user.id,
        title: 'תוכנית שבועית',
        description: 'תוכנית אימונים שבועית',
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 7)),
        workouts: weekPlan,
        isActive: true,
        lastUpdated: DateTime.now(),
      );

      if (isGuest && mounted) {
        await Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const RegisterScreen()),
        );
        user = await LocalDataStore.getCurrentUser();
      }

      if (user != null) {
        await LocalDataStore.saveUserPlan(user.id, plan);
      }

      if (mounted) {
        await context.read<WeekPlanProvider>().refreshPlan();
        Navigator.of(context).pushReplacementNamed('/home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('שגיאה בשמירת התוכנית: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
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
            color: colors.headline,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
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
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
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
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _showInfoBanner
                    ? Container(
                        key: const ValueKey('info'),
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: colors.primary.withOpacity(0.2)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.info, color: Colors.amber),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'כמשתמש רשום, תמיד תוכל לעדכן את השאלון ולרענן את התוכנית שלך.',
                                style: GoogleFonts.assistant(
                                  color: Colors.white70,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close,
                                  color: Colors.white70),
                              onPressed: () =>
                                  setState(() => _showInfoBanner = false),
                            ),
                          ],
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
              LinearProgressIndicator(
                value: (_pageIndex * perPage) /
                    (_visibleQuestions.length == 0
                        ? 1
                        : _visibleQuestions.length),
                minHeight: 8,
                backgroundColor: colors.surface.withOpacity(0.2),
                valueColor: AlwaysStoppedAnimation<Color>(colors.primary),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.separated(
                  itemCount: questionsOnPage.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 30),
                  itemBuilder: (ctx, idx) {
                    final q = questionsOnPage[idx];
                    if (q.inputType == 'number') {
                      final controller = _controllers[q.id]!;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(q.title,
                              style: GoogleFonts.assistant(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: colors.text)),
                          const SizedBox(height: 8),
                          if (q.id == 'height')
                            Slider(
                              value: (controller.text.isEmpty
                                      ? 170
                                      : double.parse(controller.text))
                                  .clamp(100, 220),
                              min: 100,
                              max: 220,
                              divisions: 120,
                              label:
                                  '${controller.text.isNotEmpty ? controller.text : '170'} ס"מ',
                              onChanged: (v) {
                                controller.text = v.toInt().toString();
                                _setAnswer(q.id, v.toInt());
                              },
                            ),
                          TextField(
                            controller: controller,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: q.id == 'age'
                                  ? 'גיל בשנים'
                                  : q.id == 'weight'
                                      ? 'משקל בק"ג'
                                      : 'הזן ערך',
                              filled: true,
                              fillColor: colors.surface,
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide.none),
                            ),
                            onChanged: (text) {
                              final val = int.tryParse(text);
                              if (val != null) {
                                _setAnswer(q.id, val);
                              }
                            },
                          ),
                        ],
                      );
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(q.title,
                            style: GoogleFonts.assistant(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: colors.text)),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: q.options.map((opt) {
                            final sel = _answers[q.id] == opt;
                            return ChoiceChip(
                              label: Text(opt,
                                  style: TextStyle(
                                      color: sel ? Colors.white : colors.text)),
                              selected: sel,
                              selectedColor: colors.primary,
                              backgroundColor: colors.surface,
                              onSelected: (_) => _setAnswer(q.id, opt),
                            );
                          }).toList(),
                        ),
                      ],
                    );
                  },
                ),
              ),
              Row(
                children: [
                  if (_pageIndex > 0)
                    TextButton(
                      onPressed: _previousPage,
                      child: Text('חזור',
                          style: GoogleFonts.assistant(color: colors.text)),
                    ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: _isSaving ? null : _nextPage,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: colors.primary),
                    child: _isSaving
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2),
                          )
                        : Text(
                            (_pageIndex + 1) * perPage >=
                                    _visibleQuestions.length
                                ? 'סיום'
                                : 'המשך',
                            style: GoogleFonts.assistant(color: Colors.white),
                          ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
