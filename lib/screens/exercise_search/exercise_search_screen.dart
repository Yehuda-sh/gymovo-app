// lib/screens/exercise_search_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/exercise_provider.dart';
import '../models/exercise.dart';

class ExerciseSearchScreen extends StatefulWidget {
  const ExerciseSearchScreen({Key? key}) : super(key: key);

  @override
  State<ExerciseSearchScreen> createState() => _ExerciseSearchScreenState();
}

class _ExerciseSearchScreenState extends State<ExerciseSearchScreen> {
  String? selectedMuscle;
  String? selectedEquipment;
  String? selectedType;
  String? query;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<ExerciseProvider>(context, listen: false);
    if (provider.exercises.isEmpty) {
      provider.loadExercises();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Consumer<ExerciseProvider>(
      builder: (context, provider, child) {
        final exercises = provider.search(
          muscle: selectedMuscle,
          equipment: selectedEquipment,
          type: selectedType,
          query: query,
        );
        return Scaffold(
          appBar: AppBar(title: const Text('חיפוש תרגילים')),
          body: provider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        decoration: const InputDecoration(
                          labelText: 'חפש לפי שם',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.search),
                        ),
                        onChanged: (val) => setState(() => query = val.trim()),
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            hint: const Text('שריר עיקרי'),
                            value: selectedMuscle,
                            items: _muscleOptions(provider.exercises)
                                .map((m) => DropdownMenuItem(
                                      value: m,
                                      child: Text(m),
                                    ))
                                .toList(),
                            onChanged: (val) =>
                                setState(() => selectedMuscle = val),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            hint: const Text('ציוד'),
                            value: selectedEquipment,
                            items: _equipmentOptions(provider.exercises)
                                .map((e) => DropdownMenuItem(
                                      value: e,
                                      child: Text(e),
                                    ))
                                .toList(),
                            onChanged: (val) =>
                                setState(() => selectedEquipment = val),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            hint: const Text('סוג תרגיל'),
                            value: selectedType,
                            items: _typeOptions(provider.exercises)
                                .map((t) => DropdownMenuItem(
                                      value: t,
                                      child: Text(t),
                                    ))
                                .toList(),
                            onChanged: (val) =>
                                setState(() => selectedType = val),
                          ),
                        ),
                      ],
                    ),
                    const Divider(),
                    Expanded(
                      child: exercises.isEmpty
                          ? Center(
                              child: Text(
                                'לא נמצאו תרגילים תואמים',
                                style: TextStyle(
                                  color: colorScheme.error,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            )
                          : ListView.builder(
                              itemCount: exercises.length,
                              itemBuilder: (context, index) {
                                final ex = exercises[index];
                                return Card(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  child: ListTile(
                                    leading: ex.imageUrl != null &&
                                            ex.imageUrl!.isNotEmpty
                                        ? ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            child: Image.network(
                                              ex.imageUrl!,
                                              width: 48,
                                              height: 48,
                                              fit: BoxFit.cover,
                                              errorBuilder: (c, e, st) =>
                                                  const Icon(
                                                      Icons.fitness_center),
                                            ),
                                          )
                                        : const Icon(Icons.fitness_center),
                                    title: Text(ex.nameHe),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                            'שרירים: ${ex.mainMuscles.join(", ")}'),
                                        if (ex.equipment.isNotEmpty)
                                          Text(
                                              'ציוד: ${ex.equipment.join(", ")}'),
                                      ],
                                    ),
                                    onTap: () {
                                      showDialog(
                                        context: context,
                                        builder: (_) => AlertDialog(
                                          title: Text(ex.nameHe),
                                          content: SingleChildScrollView(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                if (ex
                                                    .instructionsHe.isNotEmpty)
                                                  Text(
                                                    ex.instructionsHe
                                                        .join('\n'),
                                                    style: const TextStyle(
                                                        fontSize: 15),
                                                  ),
                                                if (ex.videoUrl != null &&
                                                    ex.videoUrl!.isNotEmpty)
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 10),
                                                    child: Text(
                                                      'וידאו: ${ex.videoUrl}',
                                                      style: const TextStyle(
                                                          color: Colors.blue),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ),
                                          actions: [
                                            TextButton(
                                              child: const Text('סגור'),
                                              onPressed: () =>
                                                  Navigator.pop(context),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
        );
      },
    );
  }

  List<String> _muscleOptions(List<Exercise> exercises) {
    final set = <String>{};
    for (final ex in exercises) {
      set.addAll(ex.mainMuscles);
    }
    return set.toList()..sort();
  }

  List<String> _equipmentOptions(List<Exercise> exercises) {
    final set = <String>{};
    for (final ex in exercises) {
      set.addAll(ex.equipment);
    }
    return set.toList()..sort();
  }

  List<String> _typeOptions(List<Exercise> exercises) {
    final set = <String>{};
    for (final ex in exercises) {
      set.add(ex.type);
    }
    set.removeWhere((e) => e.isEmpty);
    return set.toList()..sort();
  }
}
