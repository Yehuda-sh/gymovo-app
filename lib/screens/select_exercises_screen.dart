import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/exercise.dart';
import 'package:flutter/material.dart';

class SelectExercisesScreen extends StatefulWidget {
  final List<Exercise> initiallySelected;
  const SelectExercisesScreen({Key? key, this.initiallySelected = const []})
      : super(key: key);

  @override
  State<SelectExercisesScreen> createState() => _SelectExercisesScreenState();
}

class _SelectExercisesScreenState extends State<SelectExercisesScreen> {
  List<Exercise> _exercises = [];
  Set<String> _selectedIds = {};
  String _search = '';
  String? _selectedMuscle;
  String? _selectedEquipment;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _selectedIds = widget.initiallySelected.map((e) => e.id).toSet();
    _loadExercises();
  }

  Future<void> _loadExercises() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final data =
          await rootBundle.loadString('assets/data/workout_exercises.json');
      final List<dynamic> jsonList = json.decode(data);
      final exercises =
          jsonList.map((json) => Exercise.fromJson(json)).toList();
      setState(() {
        _exercises = exercises;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  List<Exercise> get _filteredExercises {
    return _exercises.where((e) {
      final matchesSearch = _search.isEmpty ||
          e.nameHe.toLowerCase().contains(_search.toLowerCase()) ||
          (e.mainMuscles
              .any((m) => m.toLowerCase().contains(_search.toLowerCase())));
      final matchesMuscle =
          _selectedMuscle == null || e.mainMuscles.contains(_selectedMuscle);
      final matchesEquipment = _selectedEquipment == null ||
          e.equipment.contains(_selectedEquipment);
      return matchesSearch && matchesMuscle && matchesEquipment;
    }).toList();
  }

  void _toggleSelect(Exercise exercise) {
    setState(() {
      if (_selectedIds.contains(exercise.id)) {
        _selectedIds.remove(exercise.id);
      } else {
        _selectedIds.add(exercise.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('בחר תרגילים'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadExercises,
            tooltip: 'רענן',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration:
                  const InputDecoration(hintText: 'חפש תרגיל או שריר...'),
              onChanged: (val) => setState(() => _search = val),
            ),
          ),
          if (_isLoading)
            const Expanded(child: Center(child: CircularProgressIndicator())),
          if (_error != null)
            Expanded(
                child: Center(child: Text('שגיאה בטעינת תרגילים: $_error'))),
          if (!_isLoading && _error == null)
            Expanded(
              child: ListView.builder(
                itemCount: _filteredExercises.length,
                itemBuilder: (context, index) {
                  final exercise = _filteredExercises[index];
                  final selected = _selectedIds.contains(exercise.id);
                  return ListTile(
                    leading: (exercise.imageUrl != null &&
                            exercise.imageUrl!.isNotEmpty)
                        ? Image.network(
                            exercise.imageUrl!,
                            width: 48,
                            height: 48,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) =>
                                loadingProgress == null
                                    ? child
                                    : const CircularProgressIndicator(),
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.broken_image),
                          )
                        : const Icon(Icons.image_not_supported),
                    title: Text(exercise.nameHe),
                    subtitle: Text((exercise.mainMuscles.join(', ')) +
                        (exercise.equipment.isNotEmpty
                            ? ' • ${exercise.equipment.join(", ")}'
                            : '')),
                    trailing: Checkbox(
                      value: selected,
                      onChanged: (_) => _toggleSelect(exercise),
                    ),
                    onTap: () => _toggleSelect(exercise),
                  );
                },
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          final selectedExercises =
              _exercises.where((e) => _selectedIds.contains(e.id)).toList();
          Navigator.of(context).pop(selectedExercises);
        },
        label: const Text('הוסף'),
        icon: const Icon(Icons.check),
      ),
    );
  }
}
