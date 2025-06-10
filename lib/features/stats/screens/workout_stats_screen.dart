import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../providers/workouts_provider.dart';
import '../widgets/stats_charts.dart';
import '../widgets/stats_summary.dart';
import '../services/stats_export_service.dart';

class WorkoutStatsScreen extends StatefulWidget {
  const WorkoutStatsScreen({super.key});

  @override
  State<WorkoutStatsScreen> createState() => _WorkoutStatsScreenState();
}

class _WorkoutStatsScreenState extends State<WorkoutStatsScreen> {
  String _selectedPeriod = 'שבוע';
  final List<String> _periods = ['שבוע', 'חודש', 'שנה'];
  bool _isExporting = false;

  Future<void> _exportStats() async {
    if (_isExporting) return;

    setState(() => _isExporting = true);

    try {
      final workouts = context.read<WorkoutsProvider>().workouts;
      final workoutsData = workouts.map((w) => w.toMap()).toList();
      await StatsExportService.exportStats(workoutsData);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('שגיאה בייצוא הנתונים: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('סטטיסטיקות אימונים'),
          actions: [
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: _isExporting ? null : _exportStats,
              tooltip: 'ייצוא נתונים',
            ),
          ],
        ),
        body: Consumer<WorkoutsProvider>(
          builder: (context, provider, child) {
            final workouts = provider.workouts;
            if (workouts.isEmpty) {
              return const Center(
                child: Text('אין נתונים להצגה'),
              );
            }

            final workoutsData = workouts.map((w) => w.toMap()).toList();

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPeriodSelector(context),
                  const SizedBox(height: 16),
                  SummaryCard(
                    workouts: workoutsData,
                    period: _selectedPeriod,
                  ),
                  const SizedBox(height: 16),
                  WorkoutsChart(
                    workouts: workoutsData,
                    period: _selectedPeriod,
                  ),
                  const SizedBox(height: 16),
                  DurationChart(
                    workouts: workoutsData,
                    period: _selectedPeriod,
                  ),
                  const SizedBox(height: 16),
                  ExerciseProgressChart(
                    workouts: workoutsData,
                  ),
                  const SizedBox(height: 16),
                  AchievementsCard(
                    workouts: workoutsData,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPeriodSelector(BuildContext context) {
    final theme = Theme.of(context);
    return Directionality(
      textDirection: TextDirection.rtl,
      child: SegmentedButton<String>(
        segments: const [
          ButtonSegment(
            value: 'שבוע',
            label: Text('שבוע'),
            icon: Icon(Icons.calendar_today),
          ),
          ButtonSegment(
            value: 'חודש',
            label: Text('חודש'),
            icon: Icon(Icons.calendar_month),
          ),
          ButtonSegment(
            value: 'שנה',
            label: Text('שנה'),
            icon: Icon(Icons.calendar_view_month),
          ),
        ],
        selected: {_selectedPeriod},
        onSelectionChanged: (Set<String> newSelection) {
          setState(() {
            _selectedPeriod = newSelection.first;
          });
        },
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.resolveWith<Color?>(
            (Set<MaterialState> states) {
              if (states.contains(MaterialState.selected)) {
                return theme.colorScheme.primary;
              }
              return null;
            },
          ),
          foregroundColor: MaterialStateProperty.resolveWith<Color?>(
            (Set<MaterialState> states) {
              if (states.contains(MaterialState.selected)) {
                return theme.colorScheme.onPrimary;
              }
              return theme.colorScheme.primary;
            },
          ),
        ),
      ),
    );
  }
}
