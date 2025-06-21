// lib/screens/exercise_search_screen.dart
// --------------------------------------------------
// מסך חיפוש תרגילים ראשי - גרסה משופרת
// --------------------------------------------------

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/exercise_provider.dart';
import '../../models/exercise.dart';

class ExerciseSearchScreen extends StatefulWidget {
  const ExerciseSearchScreen({super.key});

  @override
  State<ExerciseSearchScreen> createState() => _ExerciseSearchScreenState();
}

class _ExerciseSearchScreenState extends State<ExerciseSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String? selectedMuscle;
  String? selectedEquipment;
  String? selectedType;
  String? query;

  @override
  void initState() {
    super.initState();
    _loadExercisesIfNeeded();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadExercisesIfNeeded() {
    final provider = Provider.of<ExerciseProvider>(context, listen: false);
    if (provider.exercises.isEmpty) {
      provider.loadExercises();
    }
  }

  void _clearFilters() {
    setState(() {
      selectedMuscle = null;
      selectedEquipment = null;
      selectedType = null;
      query = null;
      _searchController.clear();
    });
  }

  void _showExerciseDetails(Exercise exercise) {
    showDialog(
      context: context,
      builder: (context) => _ExerciseDetailDialog(exercise: exercise),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ExerciseProvider>(
      builder: (context, provider, child) {
        // Use the correct provider methods for filtering
        List<Exercise> exercises = provider.exercises;

        // Apply text search
        if (query != null && query!.isNotEmpty) {
          exercises = provider.searchByText(query!);
        }

        // Apply muscle filter
        if (selectedMuscle != null) {
          exercises = exercises.where((exercise) {
            return exercise.primaryMuscles
                .any((muscle) => muscle.hebrewName.contains(selectedMuscle!));
          }).toList();
        }

        // Apply equipment filter
        if (selectedEquipment != null) {
          exercises = exercises.where((exercise) {
            return exercise.equipment.hebrewName.contains(selectedEquipment!);
          }).toList();
        }

        // Apply type filter
        if (selectedType != null) {
          exercises = exercises.where((exercise) {
            return exercise.type.hebrewName.contains(selectedType!);
          }).toList();
        }

        return Scaffold(
          appBar: _buildAppBar(),
          body: provider.isLoading
              ? const _LoadingWidget()
              : Column(
                  children: [
                    _buildSearchSection(provider),
                    _buildFiltersSection(provider),
                    if (_hasActiveFilters()) _buildClearFiltersButton(),
                    const Divider(),
                    _buildResultsSection(exercises),
                  ],
                ),
        );
      },
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text('חיפוש תרגילים'),
      elevation: 0,
    );
  }

  Widget _buildSearchSection(ExerciseProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          labelText: 'חפש לפי שם תרגיל',
          hintText: 'הקלד שם התרגיל...',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          prefixIcon: const Icon(Icons.search),
          suffixIcon: query?.isNotEmpty == true
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => query = null);
                  },
                )
              : null,
        ),
        onChanged: (val) {
          final trimmedVal = val.trim();
          setState(() => query = trimmedVal.isEmpty ? null : trimmedVal);
        },
      ),
    );
  }

  Widget _buildFiltersSection(ExerciseProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'סינון תוצאות:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildDropdown(
                  hint: 'שריר עיקרי',
                  value: selectedMuscle,
                  items: _muscleOptions(provider.exercises),
                  onChanged: (val) => setState(() => selectedMuscle = val),
                  icon: Icons.fitness_center,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildDropdown(
                  hint: 'ציוד',
                  value: selectedEquipment,
                  items: _equipmentOptions(provider.exercises),
                  onChanged: (val) => setState(() => selectedEquipment = val),
                  icon: Icons.sports_gymnastics,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: _buildDropdown(
              hint: 'סוג תרגיל',
              value: selectedType,
              items: _typeOptions(provider.exercises),
              onChanged: (val) => setState(() => selectedType = val),
              icon: Icons.category,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required String hint,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    required IconData icon,
  }) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: hint,
        prefixIcon: Icon(icon, size: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      value: value,
      isExpanded: true,
      items: [
        DropdownMenuItem<String>(
          value: null,
          child: Text('הכל', style: TextStyle(color: Colors.grey[600])),
        ),
        ...items.map((item) => DropdownMenuItem(
              value: item,
              child: Text(item),
            )),
      ],
      onChanged: onChanged,
    );
  }

  bool _hasActiveFilters() {
    return selectedMuscle != null ||
        selectedEquipment != null ||
        selectedType != null ||
        query != null;
  }

  Widget _buildClearFiltersButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: _clearFilters,
          icon: const Icon(Icons.clear_all),
          label: const Text('נקה את כל הסינונים'),
        ),
      ),
    );
  }

  Widget _buildResultsSection(List<Exercise> exercises) {
    return Expanded(
      child: exercises.isEmpty
          ? _buildEmptyState()
          : _buildExercisesList(exercises),
    );
  }

  Widget _buildEmptyState() {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            'לא נמצאו תרגילים תואמים',
            style: TextStyle(
              fontSize: 18,
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'נסה לשנות את הסינונים או מילות החיפוש',
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExercisesList(List<Exercise> exercises) {
    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: exercises.length,
      itemBuilder: (context, index) {
        final exercise = exercises[index];
        return _ExerciseCard(
          exercise: exercise,
          onTap: () => _showExerciseDetails(exercise),
        );
      },
    );
  }

  List<String> _muscleOptions(List<Exercise> exercises) {
    final set = <String>{};
    for (final ex in exercises) {
      for (final muscle in ex.primaryMuscles) {
        set.add(muscle.hebrewName);
      }
    }
    final list = set.toList()..sort();
    return list;
  }

  List<String> _equipmentOptions(List<Exercise> exercises) {
    final set = <String>{};
    for (final ex in exercises) {
      set.add(ex.equipment.hebrewName);
    }
    final list = set.toList()..sort();
    return list;
  }

  List<String> _typeOptions(List<Exercise> exercises) {
    final set = <String>{};
    for (final ex in exercises) {
      set.add(ex.type.hebrewName);
    }
    final list = set.toList()..sort();
    return list;
  }
}

// ויג'ט נפרד לכרטיס תרגיל
class _ExerciseCard extends StatelessWidget {
  final Exercise exercise;
  final VoidCallback onTap;

  const _ExerciseCard({
    required this.exercise,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: _buildExerciseImage(),
        title: Text(
          exercise.nameHe,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: _buildSubtitle(),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  Widget _buildExerciseImage() {
    if (exercise.displayImage?.isNotEmpty == true) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          exercise.displayImage!,
          width: 56,
          height: 56,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) => Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.fitness_center, color: Colors.grey),
          ),
        ),
      );
    }
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(Icons.fitness_center, color: Colors.grey),
    );
  }

  Widget _buildSubtitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 4),
        Text(
          'שרירים: ${exercise.primaryMuscles.map((m) => m.hebrewName).join(", ")}',
          style: const TextStyle(fontSize: 13),
        ),
        const SizedBox(height: 2),
        Text(
          'ציוד: ${exercise.equipment.hebrewName}',
          style: const TextStyle(fontSize: 13),
        ),
        const SizedBox(height: 2),
        Text(
          'סוג: ${exercise.type.hebrewName}',
          style: const TextStyle(fontSize: 13),
        ),
      ],
    );
  }
}

// ויג'ט נפרד לטעינה
class _LoadingWidget extends StatelessWidget {
  const _LoadingWidget();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('טוען תרגילים...'),
        ],
      ),
    );
  }
}

// דיאלוג נפרד לפרטי התרגיל
class _ExerciseDetailDialog extends StatelessWidget {
  final Exercise exercise;

  const _ExerciseDetailDialog({required this.exercise});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Text(
        exercise.nameHe,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (exercise.displayImage?.isNotEmpty == true) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    exercise.displayImage!,
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        Container(height: 200, color: Colors.grey[200]),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              _buildDetailSection('שרירים עיקריים',
                  exercise.primaryMuscles.map((m) => m.hebrewName).join(', ')),
              _buildDetailSection('ציוד נדרש', exercise.equipment.hebrewName),
              _buildDetailSection('סוג התרגיל', exercise.type.hebrewName),
              if (exercise.instructionsHe.isNotEmpty) ...[
                const Text(
                  'הוראות ביצוע:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                ...exercise.instructionsHe.asMap().entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${entry.key + 1}. ',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        Expanded(child: Text(entry.value)),
                      ],
                    ),
                  );
                }),
              ],
              if (exercise.videoUrl?.isNotEmpty == true) ...[
                const SizedBox(height: 16),
                InkWell(
                  onTap: () {
                    // כאן אפשר להוסיף פתיחת הווידאו
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text('פותח וידאו: ${exercise.videoUrl}')),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.play_circle, color: Colors.blue),
                        SizedBox(width: 8),
                        Text(
                          'צפה בוידאו הדרכה',
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          child: const Text('סגור'),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }

  Widget _buildDetailSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$title:',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(content),
        ],
      ),
    );
  }
}
