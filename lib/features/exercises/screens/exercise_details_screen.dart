import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../models/exercise.dart';
import '../../../models/exercise_history.dart';
import '../../../providers/exercise_history_provider.dart';
import '../widgets/exercise_media_section.dart';
import '../widgets/exercise_history_graph.dart';
import '../widgets/exercise_set_form.dart';
import '../widgets/exercise_set_list.dart';

class ExerciseDetailsScreen extends StatefulWidget {
  final Exercise exercise;

  const ExerciseDetailsScreen({
    Key? key,
    required this.exercise,
  }) : super(key: key);

  @override
  State<ExerciseDetailsScreen> createState() => _ExerciseDetailsScreenState();
}

class _ExerciseDetailsScreenState extends State<ExerciseDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _undoSetId;
  ExerciseSet? _lastDeletedSet;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_handleTabChange);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ExerciseHistoryProvider>().loadExerciseHistories();
    });
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging) {
      // אפשר להוסיף אנימציות או אפקטים נוספים כאן
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  void _handleSetSave(ExerciseSet set) {
    if (set.id == _lastDeletedSet?.id) {
      _lastDeletedSet = null;
    }

    final provider = context.read<ExerciseHistoryProvider>();
    if (set.id == _lastDeletedSet?.id) {
      provider.updateSet(widget.exercise.id, set);
    } else {
      provider.addSet(widget.exercise.id, set);
    }
  }

  void _handleSetDelete(String setId) {
    final provider = context.read<ExerciseHistoryProvider>();
    final history = provider.getExerciseHistory(widget.exercise.id);
    if (history != null) {
      _lastDeletedSet = history.sets.firstWhere((set) => set.id == setId);
      provider.deleteSet(widget.exercise.id, setId);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('הסט נמחק'),
          action: SnackBarAction(
            label: 'בטל',
            onPressed: () => _undoDeleteSet(),
          ),
        ),
      );
    }
  }

  void _undoDeleteSet() {
    if (_lastDeletedSet != null) {
      context.read<ExerciseHistoryProvider>().addSet(
            widget.exercise.id,
            _lastDeletedSet!,
          );
      _lastDeletedSet = null;
    }
  }

  void _handleSetEdit(ExerciseSet set) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: ExerciseSetForm(
          exerciseId: widget.exercise.id,
          existingSet: set,
          onSave: (updatedSet) {
            _handleSetSave(updatedSet);
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  Widget _buildInfoChip(String label, {Color? color, IconData? icon}) {
    return Chip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: color ?? Colors.blueGrey),
            const SizedBox(width: 4),
          ],
          Text(label, style: TextStyle(color: color ?? Colors.blueGrey)),
        ],
      ),
      backgroundColor: (color ?? Colors.blueGrey).withAlpha(30),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ExerciseHistoryProvider>();
    final history = provider.getExerciseHistory(widget.exercise.id);
    final sets = history?.sets ?? [];

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.exercise.name),
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'מידע'),
              Tab(text: 'היסטוריה'),
              Tab(text: 'סטים'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ExerciseMediaSection(exercise: widget.exercise),
                  const SizedBox(height: 16),
                  if (widget.exercise.description?.isNotEmpty ?? false) ...[
                    Text(
                      widget.exercise.description!,
                      style: Theme.of(context).textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (widget.exercise.instructions?.isNotEmpty ?? false) ...[
                    Text(
                      'הוראות ביצוע:',
                      style: Theme.of(context).textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.exercise.instructions!,
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (widget.exercise.tips?.isNotEmpty ?? false) ...[
                    Text(
                      'טיפים:',
                      style: Theme.of(context).textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.exercise.tips!,
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
            if (sets.isNotEmpty)
              ExerciseHistoryGraph(sets: sets)
            else
              const Center(
                child: Text(
                  'אין היסטוריה להצגה',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ),
            ExerciseSetList(
              sets: sets,
              onEdit: _handleSetEdit,
              onDelete: _handleSetDelete,
              showDate: true,
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (context) => Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: ExerciseSetForm(
                  exerciseId: widget.exercise.id,
                  onSave: (set) {
                    _handleSetSave(set);
                    Navigator.pop(context);
                  },
                ),
              ),
            );
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
