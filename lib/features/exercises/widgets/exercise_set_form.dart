import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../models/exercise_history.dart';
import '../../../providers/exercise_history_provider.dart';
import '../../../theme/app_theme.dart';
import 'package:provider/provider.dart';

class ExerciseSetForm extends StatefulWidget {
  final Function(ExerciseSet) onSave;
  final ExerciseSet? existingSet;
  final String exerciseId;

  const ExerciseSetForm({
    super.key,
    required this.onSave,
    required this.exerciseId,
    this.existingSet,
  });

  @override
  State<ExerciseSetForm> createState() => _ExerciseSetFormState();
}

class _ExerciseSetFormState extends State<ExerciseSetForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _weightController;
  late final TextEditingController _repsController;
  late final TextEditingController _notesController;
  late final TextEditingController _restTimeController;

  bool _isCompleted = false;
  bool _isLoading = false;
  bool _showAdvanced = false;

  // קבועים פרטיים
  static const double _defaultWeight = 20.0;
  static const int _defaultReps = 10;
  static const int _defaultRestTime = 60;
  static const double _maxWeight = 500.0;
  static const int _maxReps = 100;
  static const int _maxRestTime = 600; // 10 דקות

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _weightController = TextEditingController(
      text: widget.existingSet?.weight.toString() ?? '',
    );
    _repsController = TextEditingController(
      text: widget.existingSet?.reps.toString() ?? '',
    );
    _notesController = TextEditingController(
      text: widget.existingSet?.notes ?? '',
    );
    _restTimeController = TextEditingController(
      text: (widget.existingSet?.restTime ?? _defaultRestTime).toString(),
    );
    _isCompleted = widget.existingSet?.isCompleted ?? false;
  }

  @override
  void dispose() {
    _weightController.dispose();
    _repsController.dispose();
    _notesController.dispose();
    _restTimeController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final set = ExerciseSet(
        id: widget.existingSet?.id ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        exerciseId: widget.exerciseId,
        weight: double.parse(_weightController.text),
        reps: int.parse(_repsController.text),
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        restTime: int.parse(_restTimeController.text),
        isCompleted: _isCompleted,
        date: widget.existingSet?.date ?? DateTime.now(),
        createdAt: widget.existingSet?.createdAt ?? DateTime.now(),
      );

      // הוסף רטט הפטי
      HapticFeedback.lightImpact();

      widget.onSave(set);

      // נקה את הטופס אם זה סט חדש
      if (widget.existingSet == null) {
        _clearForm();
        _showSuccessSnackBar('הסט נוסף בהצלחה!');
      }
    } catch (e) {
      _showErrorSnackBar('שגיאה בשמירת הסט: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _clearForm() {
    _weightController.clear();
    _repsController.clear();
    _notesController.clear();
    _restTimeController.text = _defaultRestTime.toString();
    setState(() {
      _isCompleted = false;
      _showAdvanced = false;
    });
  }

  void _fillWithLastSet() {
    final provider = context.read<ExerciseHistoryProvider>();
    final history = provider.getExerciseHistory(widget.exerciseId);

    if (history != null && history.sets.isNotEmpty) {
      final lastSet = history.sets.last;
      _weightController.text = lastSet.weight.toString() ?? '';
      _repsController.text = lastSet.reps.toString() ?? '';
      _restTimeController.text =
          (lastSet.restTime ?? _defaultRestTime).toString();

      HapticFeedback.selectionClick();
      _showSuccessSnackBar('נתונים מהסט האחרון הועתקו');
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.assistant()),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.assistant()),
        backgroundColor: AppTheme.colors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppTheme.colors;
    final isEditing = widget.existingSet != null;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: colors.text.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          Flexible(
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildHeader(isEditing),
                    const SizedBox(height: 24),
                    _buildMainFields(),
                    const SizedBox(height: 16),
                    _buildAdvancedSection(),
                    const SizedBox(height: 20),
                    _buildCompletionToggle(),
                    const SizedBox(height: 24),
                    _buildActionButtons(isEditing),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isEditing) {
    final colors = AppTheme.colors;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isEditing ? 'עריכת סט' : 'הוספת סט חדש',
                style: GoogleFonts.assistant(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: colors.headline,
                ),
              ),
              if (!isEditing) ...[
                const SizedBox(height: 4),
                Text(
                  'הזן את פרטי הסט שביצעת',
                  style: GoogleFonts.assistant(
                    fontSize: 14,
                    color: colors.text.withOpacity(0.7),
                  ),
                ),
              ],
            ],
          ),
        ),
        if (!isEditing)
          IconButton(
            onPressed: _fillWithLastSet,
            icon: const Icon(Icons.content_copy),
            tooltip: 'העתק מהסט האחרון',
            style: IconButton.styleFrom(
              backgroundColor: colors.primary.withOpacity(0.1),
              foregroundColor: colors.primary,
            ),
          ),
      ],
    );
  }

  Widget _buildMainFields() {
    return Row(
      children: [
        Expanded(
          child: _buildWeightField(),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildRepsField(),
        ),
      ],
    );
  }

  Widget _buildWeightField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'משקל (ק"ג)',
          style: GoogleFonts.assistant(
            fontWeight: FontWeight.w600,
            color: AppTheme.colors.headline,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _weightController,
          decoration: InputDecoration(
            hintText: _defaultWeight.toString(),
            prefixIcon: const Icon(Icons.fitness_center),
            suffixText: 'ק"ג',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: AppTheme.colors.surface,
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,1}')),
          ],
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'נא להזין משקל';
            }
            final weight = double.tryParse(value);
            if (weight == null) {
              return 'נא להזין מספר תקין';
            }
            if (weight <= 0) {
              return 'המשקל חייב להיות חיובי';
            }
            if (weight > _maxWeight) {
              return 'משקל מקסימלי: $_maxWeight ק"ג';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildRepsField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'חזרות',
          style: GoogleFonts.assistant(
            fontWeight: FontWeight.w600,
            color: AppTheme.colors.headline,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _repsController,
          decoration: InputDecoration(
            hintText: _defaultReps.toString(),
            prefixIcon: const Icon(Icons.repeat),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: AppTheme.colors.surface,
          ),
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
          ],
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'נא להזין מספר חזרות';
            }
            final reps = int.tryParse(value);
            if (reps == null) {
              return 'נא להזין מספר תקין';
            }
            if (reps <= 0) {
              return 'מספר החזרות חייב להיות חיובי';
            }
            if (reps > _maxReps) {
              return 'מספר חזרות מקסימלי: $_maxReps';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildAdvancedSection() {
    return Column(
      children: [
        InkWell(
          onTap: () {
            setState(() => _showAdvanced = !_showAdvanced);
            HapticFeedback.selectionClick();
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: AppTheme.colors.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppTheme.colors.primary.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _showAdvanced ? Icons.expand_less : Icons.expand_more,
                  color: AppTheme.colors.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'הגדרות מתקדמות',
                  style: GoogleFonts.assistant(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.colors.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          height: _showAdvanced ? null : 0,
          child: _showAdvanced
              ? Column(
                  children: [
                    const SizedBox(height: 16),
                    _buildRestTimeField(),
                    const SizedBox(height: 16),
                    _buildNotesField(),
                  ],
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildRestTimeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'זמן מנוחה (שניות)',
          style: GoogleFonts.assistant(
            fontWeight: FontWeight.w600,
            color: AppTheme.colors.headline,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _restTimeController,
          decoration: InputDecoration(
            hintText: _defaultRestTime.toString(),
            prefixIcon: const Icon(Icons.timer),
            suffixText: 'שניות',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: AppTheme.colors.surface,
          ),
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          validator: (value) {
            if (value != null && value.isNotEmpty) {
              final restTime = int.tryParse(value);
              if (restTime == null) {
                return 'נא להזין מספר תקין';
              }
              if (restTime < 0) {
                return 'זמן המנוחה חייב להיות חיובי';
              }
              if (restTime > _maxRestTime) {
                return 'זמן מנוחה מקסימלי: $_maxRestTime שניות';
              }
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildNotesField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'הערות',
          style: GoogleFonts.assistant(
            fontWeight: FontWeight.w600,
            color: AppTheme.colors.headline,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _notesController,
          decoration: InputDecoration(
            hintText: 'הערות אופציונליות...',
            prefixIcon: const Icon(Icons.note_alt),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: AppTheme.colors.surface,
          ),
          maxLines: 3,
          maxLength: 200,
          textCapitalization: TextCapitalization.sentences,
        ),
      ],
    );
  }

  Widget _buildCompletionToggle() {
    final colors = AppTheme.colors;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _isCompleted ? Colors.green.withOpacity(0.1) : colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _isCompleted
              ? Colors.green.withOpacity(0.3)
              : colors.primary.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            _isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
            color: _isCompleted ? Colors.green : colors.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'סטטוס הסט',
                  style: GoogleFonts.assistant(
                    fontWeight: FontWeight.w600,
                    color: colors.headline,
                  ),
                ),
                Text(
                  _isCompleted ? 'הסט הושלם בהצלחה' : 'הסט עדיין לא הושלם',
                  style: GoogleFonts.assistant(
                    fontSize: 13,
                    color: colors.text.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _isCompleted,
            onChanged: (value) {
              setState(() => _isCompleted = value);
              HapticFeedback.lightImpact();
            },
            activeColor: Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(bool isEditing) {
    final colors = AppTheme.colors;

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _handleSubmit,
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(isEditing ? Icons.save : Icons.add),
                      const SizedBox(width: 8),
                      Text(
                        isEditing ? 'שמור שינויים' : 'הוסף סט',
                        style: GoogleFonts.assistant(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
        if (isEditing) ...[
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'ביטול',
              style: GoogleFonts.assistant(
                color: colors.text.withOpacity(0.7),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
