// lib/providers/exercise_provider.dart
import 'package:flutter/foundation.dart';
import '../models/exercise.dart';
import '../data/exercise_data_store.dart';

enum SortBy {
  nameAsc('שם (א-ת)'),
  nameDesc('שם (ת-א)'),
  difficultyAsc('קושי (קל-קשה)'),
  difficultyDesc('קושי (קשה-קל)'),
  ratingDesc('דירוג (גבוה-נמוך)'),
  ratingAsc('דירוג (נמוך-גבוה)'),
  createdDesc('נוסף לאחרונה'),
  createdAsc('נוסף ראשון'),
  popularityDesc('פופולריות');

  const SortBy(this.displayName);
  final String displayName;
}

class ExerciseFilter {
  final List<MuscleGroup> muscleGroups;
  final List<ExerciseEquipment> equipment;
  final List<ExerciseDifficulty> difficulties;
  final List<ExerciseType> types;
  final bool favoritesOnly;
  final bool verifiedOnly;
  final double? minRating;
  final String? query;
  final SortBy sortBy;
  final bool isFavorite;

  const ExerciseFilter({
    this.muscleGroups = const [],
    this.equipment = const [],
    this.difficulties = const [],
    this.types = const [],
    this.favoritesOnly = false,
    this.verifiedOnly = false,
    this.minRating,
    this.query,
    this.sortBy = SortBy.nameAsc,
    this.isFavorite = false,
  });

  ExerciseFilter copyWith({
    List<MuscleGroup>? muscleGroups,
    List<ExerciseEquipment>? equipment,
    List<ExerciseDifficulty>? difficulties,
    List<ExerciseType>? types,
    bool? favoritesOnly,
    bool? verifiedOnly,
    double? minRating,
    String? query,
    SortBy? sortBy,
    bool? isFavorite,
  }) {
    return ExerciseFilter(
      muscleGroups: muscleGroups ?? this.muscleGroups,
      equipment: equipment ?? this.equipment,
      difficulties: difficulties ?? this.difficulties,
      types: types ?? this.types,
      favoritesOnly: favoritesOnly ?? this.favoritesOnly,
      verifiedOnly: verifiedOnly ?? this.verifiedOnly,
      minRating: minRating ?? this.minRating,
      query: query ?? this.query,
      sortBy: sortBy ?? this.sortBy,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  bool get hasActiveFilters {
    return muscleGroups.isNotEmpty ||
        equipment.isNotEmpty ||
        difficulties.isNotEmpty ||
        types.isNotEmpty ||
        favoritesOnly ||
        verifiedOnly ||
        minRating != null ||
        (query != null && query!.isNotEmpty);
  }

  int get activeFilterCount {
    int count = 0;
    if (muscleGroups.isNotEmpty) count++;
    if (equipment.isNotEmpty) count++;
    if (difficulties.isNotEmpty) count++;
    if (types.isNotEmpty) count++;
    if (favoritesOnly) count++;
    if (verifiedOnly) count++;
    if (minRating != null) count++;
    if (query != null && query!.isNotEmpty) count++;
    return count;
  }
}

class ExerciseProvider with ChangeNotifier {
  List<Exercise> _exercises = [];
  List<Exercise> _filteredExercises = [];
  List<Exercise> _favoriteExercises = [];
  bool _isLoading = false;
  String? _error;
  ExerciseFilter _currentFilter = const ExerciseFilter();
  String _languageCode = 'he';

  // Statistics
  Map<MuscleGroup, int> _muscleGroupCounts = {};
  Map<ExerciseEquipment, int> _equipmentCounts = {};
  Map<ExerciseDifficulty, int> _difficultyCounts = {};

  // Getters
  List<Exercise> get exercises => _exercises;
  List<Exercise> get filteredExercises => _filteredExercises;
  List<Exercise> get favoriteExercises => _favoriteExercises;
  bool get isLoading => _isLoading;
  String? get error => _error;
  ExerciseFilter get currentFilter => _currentFilter;
  String get languageCode => _languageCode;
  Map<MuscleGroup, int> get muscleGroupCounts => _muscleGroupCounts;
  Map<ExerciseEquipment, int> get equipmentCounts => _equipmentCounts;
  Map<ExerciseDifficulty, int> get difficultyCounts => _difficultyCounts;

  // Quick access maps
  Map<String, Exercise> get exerciseDetailsMap =>
      {for (final ex in _exercises) ex.id: ex};

  Map<String, Exercise> get exercisesByName =>
      {for (final ex in _exercises) ex.name: ex};

  // Statistics
  int get totalExercises => _exercises.length;
  int get verifiedExercises => _exercises.where((e) => e.isVerified).length;
  double get averageRating => _exercises.isNotEmpty
      ? _exercises.fold(0.0, (sum, e) => sum + e.rating) / _exercises.length
      : 0.0;

  // Language
  void setLanguage(String languageCode) {
    _languageCode = languageCode;
    _applyFilter(); // Re-apply filter with new language
    notifyListeners();
  }

  // Loading exercises
  Future<void> loadExercises() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _exercises = await ExerciseDataStore.loadExercises();
      await _loadFavorites();
      _calculateStatistics();
      _applyFilter();
      _error = null;
    } catch (e) {
      _error = 'שגיאה בטעינת התרגילים: $e';
      _exercises = [];
      _filteredExercises = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadFavorites() async {
    try {
      // For now, we'll use a simple in-memory approach
      // This can be replaced with SharedPreferences or database later
      _favoriteExercises = _exercises.where((e) => e.isFavorite).toList();
    } catch (e) {
      debugPrint('Error loading favorites: $e');
    }
  }

  void _calculateStatistics() {
    _muscleGroupCounts.clear();
    _equipmentCounts.clear();
    _difficultyCounts.clear();

    for (final exercise in _exercises) {
      // Count muscle groups
      for (final muscle in exercise.primaryMuscles) {
        _muscleGroupCounts[muscle] = (_muscleGroupCounts[muscle] ?? 0) + 1;
      }
      for (final muscle in exercise.secondaryMuscles) {
        _muscleGroupCounts[muscle] = (_muscleGroupCounts[muscle] ?? 0) + 1;
      }

      // Count equipment
      _equipmentCounts[exercise.equipment] =
          (_equipmentCounts[exercise.equipment] ?? 0) + 1;

      // Count difficulties
      _difficultyCounts[exercise.difficulty] =
          (_difficultyCounts[exercise.difficulty] ?? 0) + 1;
    }
  }

  // Filtering and searching
  void applyFilter(ExerciseFilter filter) {
    _currentFilter = filter;
    _applyFilter();
    notifyListeners();
  }

  void _applyFilter() {
    var filtered = List<Exercise>.from(_exercises);

    // Apply muscle group filter
    if (_currentFilter.muscleGroups.isNotEmpty) {
      filtered = filtered.where((exercise) {
        return exercise.primaryMuscles.any(
                (muscle) => _currentFilter.muscleGroups.contains(muscle)) ||
            exercise.secondaryMuscles
                .any((muscle) => _currentFilter.muscleGroups.contains(muscle));
      }).toList();
    }

    // Apply equipment filter
    if (_currentFilter.equipment.isNotEmpty) {
      filtered = filtered.where((exercise) {
        return _currentFilter.equipment.contains(exercise.equipment);
      }).toList();
    }

    // Apply difficulty filter
    if (_currentFilter.difficulties.isNotEmpty) {
      filtered = filtered.where((exercise) {
        return _currentFilter.difficulties.contains(exercise.difficulty);
      }).toList();
    }

    // Apply type filter
    if (_currentFilter.types.isNotEmpty) {
      filtered = filtered.where((exercise) {
        return _currentFilter.types.contains(exercise.type);
      }).toList();
    }

    // Apply favorites filter
    if (_currentFilter.favoritesOnly) {
      filtered = filtered.where((exercise) => exercise.isFavorite).toList();
    }

    // Apply verified filter
    if (_currentFilter.verifiedOnly) {
      filtered = filtered.where((exercise) => exercise.isVerified).toList();
    }

    // Apply rating filter
    if (_currentFilter.minRating != null) {
      filtered = filtered.where((exercise) {
        return exercise.rating >= _currentFilter.minRating!;
      }).toList();
    }

    // Apply text search
    if (_currentFilter.query != null && _currentFilter.query!.isNotEmpty) {
      filtered = filtered.where((exercise) {
        return exercise.matchesQuery(_currentFilter.query!, _languageCode);
      }).toList();
    }

    // Apply sorting
    _sortExercises(filtered, _currentFilter.sortBy);

    _filteredExercises = filtered;
  }

  void _sortExercises(List<Exercise> exercises, SortBy sortBy) {
    switch (sortBy) {
      case SortBy.nameAsc:
        exercises.sort((a, b) => a.name.compareTo(b.name));
        break;
      case SortBy.nameDesc:
        exercises.sort((a, b) => b.name.compareTo(a.name));
        break;
      case SortBy.difficultyAsc:
        exercises
            .sort((a, b) => a.difficulty.level.compareTo(b.difficulty.level));
        break;
      case SortBy.difficultyDesc:
        exercises
            .sort((a, b) => b.difficulty.level.compareTo(a.difficulty.level));
        break;
      case SortBy.ratingDesc:
        exercises.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case SortBy.ratingAsc:
        exercises.sort((a, b) => a.rating.compareTo(b.rating));
        break;
      case SortBy.createdDesc:
        exercises.sort((a, b) => b.createdAt!.compareTo(a.createdAt!));
        break;
      case SortBy.createdAsc:
        exercises.sort((a, b) => a.createdAt!.compareTo(b.createdAt!));
        break;
      case SortBy.popularityDesc:
        exercises.sort((a, b) => b.ratingCount.compareTo(a.ratingCount));
        break;
    }
  }

  // Quick search methods
  List<Exercise> searchByText(String query) {
    return _exercises.where((exercise) {
      return exercise.matchesQuery(query, _languageCode);
    }).toList();
  }

  List<Exercise> getByMuscleGroup(MuscleGroup muscleGroup) {
    return _exercises.where((exercise) {
      return exercise.primaryMuscles.contains(muscleGroup) ||
          exercise.secondaryMuscles.contains(muscleGroup);
    }).toList();
  }

  List<Exercise> getByEquipment(ExerciseEquipment equipment) {
    return _exercises.where((exercise) {
      return exercise.equipment == equipment;
    }).toList();
  }

  List<Exercise> getByDifficulty(ExerciseDifficulty difficulty) {
    return _exercises.where((exercise) {
      return exercise.difficulty == difficulty;
    }).toList();
  }

  List<Exercise> getByType(ExerciseType type) {
    return _exercises.where((exercise) {
      return exercise.type == type;
    }).toList();
  }

  // Favorites management
  Future<void> toggleFavorite(String exerciseId) async {
    try {
      final exerciseIndex = _exercises.indexWhere((e) => e.id == exerciseId);
      if (exerciseIndex == -1) return;

      final exercise = _exercises[exerciseIndex];
      final newFavoriteStatus = !exercise.isFavorite;

      // Update in memory
      _exercises[exerciseIndex] =
          exercise.copyWith(isFavorite: newFavoriteStatus);

      // Update favorites list
      if (newFavoriteStatus) {
        _favoriteExercises.add(_exercises[exerciseIndex]);
      } else {
        _favoriteExercises.removeWhere((e) => e.id == exerciseId);
      }

      // TODO: Save to storage when ExerciseDataStore supports it
      // await ExerciseDataStore.saveFavoriteStatus(exerciseId, newFavoriteStatus);

      // Re-apply current filter
      _applyFilter();

      notifyListeners();
    } catch (e) {
      _error = 'שגיאה בעדכון מועדפים: $e';
      notifyListeners();
    }
  }

  // Clear all filters
  void clearFilters() {
    _currentFilter = const ExerciseFilter();
    _applyFilter();
    notifyListeners();
  }

  // Get exercise by ID
  Exercise? getExerciseById(String id) {
    try {
      return _exercises.firstWhere((exercise) => exercise.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get recommended exercises based on user preferences
  List<Exercise> getRecommendedExercises({
    List<MuscleGroup>? preferredMuscles,
    List<ExerciseEquipment>? availableEquipment,
    ExerciseDifficulty? userLevel,
    int limit = 10,
  }) {
    var recommended = List<Exercise>.from(_exercises);

    // Filter by user preferences
    if (preferredMuscles != null && preferredMuscles.isNotEmpty) {
      recommended = recommended.where((exercise) {
        return exercise.primaryMuscles
            .any((muscle) => preferredMuscles.contains(muscle));
      }).toList();
    }

    if (availableEquipment != null && availableEquipment.isNotEmpty) {
      recommended = recommended.where((exercise) {
        return availableEquipment.contains(exercise.equipment);
      }).toList();
    }

    if (userLevel != null) {
      recommended = recommended.where((exercise) {
        return exercise.difficulty.level <= userLevel.level + 1;
      }).toList();
    }

    // Sort by rating and take top exercises
    recommended.sort((a, b) => b.rating.compareTo(a.rating));

    return recommended.take(limit).toList();
  }

  // Get random exercise
  Exercise? getRandomExercise({
    List<MuscleGroup>? muscleGroups,
    ExerciseEquipment? equipment,
    ExerciseDifficulty? difficulty,
  }) {
    var available = List<Exercise>.from(_exercises);

    if (muscleGroups != null && muscleGroups.isNotEmpty) {
      available = available.where((exercise) {
        return exercise.primaryMuscles
            .any((muscle) => muscleGroups.contains(muscle));
      }).toList();
    }

    if (equipment != null) {
      available = available
          .where((exercise) => exercise.equipment == equipment)
          .toList();
    }

    if (difficulty != null) {
      available = available
          .where((exercise) => exercise.difficulty == difficulty)
          .toList();
    }

    if (available.isEmpty) return null;

    final random = DateTime.now().millisecondsSinceEpoch % available.length;
    return available[random];
  }

  // Refresh data
  Future<void> refresh() async {
    await loadExercises();
  }

  // Add new exercise
  Future<void> addExercise(Exercise exercise) async {
    try {
      // For now, add to memory only
      // TODO: Implement when ExerciseDataStore supports saving
      // await ExerciseDataStore.saveExercise(exercise);

      _exercises.add(exercise);
      _calculateStatistics();
      _applyFilter();
      notifyListeners();
    } catch (e) {
      _error = 'שגיאה בהוספת התרגיל: $e';
      notifyListeners();
    }
  }

  // Update exercise
  Future<void> updateExercise(Exercise exercise) async {
    try {
      // For now, update in memory only
      // TODO: Implement when ExerciseDataStore supports saving
      // await ExerciseDataStore.saveExercise(exercise);

      final index = _exercises.indexWhere((e) => e.id == exercise.id);
      if (index != -1) {
        _exercises[index] = exercise;
        _calculateStatistics();
        _applyFilter();
        notifyListeners();
      }
    } catch (e) {
      _error = 'שגיאה בעדכון התרגיל: $e';
      notifyListeners();
    }
  }

  // Delete exercise
  Future<void> deleteExercise(String exerciseId) async {
    try {
      // For now, remove from memory only
      // TODO: Implement when ExerciseDataStore supports deletion
      // await ExerciseDataStore.deleteExercise(exerciseId);

      _exercises.removeWhere((e) => e.id == exerciseId);
      _favoriteExercises.removeWhere((e) => e.id == exerciseId);
      _calculateStatistics();
      _applyFilter();
      notifyListeners();
    } catch (e) {
      _error = 'שגיאה במחיקת התרגיל: $e';
      notifyListeners();
    }
  }

  // Rate exercise
  Future<void> rateExercise(String exerciseId, double rating) async {
    try {
      // For now, update in memory only
      // TODO: Implement when ExerciseDataStore supports rating
      // await ExerciseDataStore.rateExercise(exerciseId, rating);

      final index = _exercises.indexWhere((e) => e.id == exerciseId);
      if (index != -1) {
        final exercise = _exercises[index];
        final newRatingCount = exercise.ratingCount + 1;
        final newRating = ((exercise.rating * exercise.ratingCount) + rating) /
            newRatingCount;

        _exercises[index] = exercise.copyWith(
          rating: newRating,
          ratingCount: newRatingCount,
        );

        _applyFilter();
        notifyListeners();
      }
    } catch (e) {
      _error = 'שגיאה בדירוג התרגיל: $e';
      notifyListeners();
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Dispose
  @override
  void dispose() {
    super.dispose();
  }
}
