// lib/screens/exercises/exercises_screen.dart
// --------------------------------------------------
// מסך תרגילים משופר - ללא שגיאות null safety
// --------------------------------------------------

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/exercise.dart';
import '../../widgets/exercise_card.dart';
import '../../features/exercises/screens/exercise_details_screen.dart';

enum ExerciseFilter { all, strength, cardio, flexibility, balance }

enum SortOption { name, difficulty, muscle }

class ExercisesScreen extends StatefulWidget {
  const ExercisesScreen({super.key});

  @override
  State<ExercisesScreen> createState() => _ExercisesScreenState();
}

class _ExercisesScreenState extends State<ExercisesScreen>
    with TickerProviderStateMixin {
  // נתונים
  List<Exercise> _allExercises = [];
  List<Exercise> _filteredExercises = [];

  // מצבים
  bool _isLoading = true;
  String? _error;

  // חיפוש ופילטרים
  final _searchController = TextEditingController();
  ExerciseFilter _currentFilter = ExerciseFilter.all;
  SortOption _currentSort = SortOption.name;
  bool _isSearchVisible = false;

  // אנימציות
  late AnimationController _searchAnimationController;
  late Animation<double> _searchAnimation;

  // קטגוריות שרירים פופולריות לפילטר מהיר
  final List<String> _popularMuscles = [
    'חזה',
    'גב',
    'כתפיים',
    'רגליים',
    'ביצפים',
    'זרועות'
  ];
  String? _selectedMuscle;

  @override
  void initState() {
    super.initState();
    _loadExercises();
    _searchController.addListener(_onSearchChanged);

    // הגדרת אנימציית חיפוש
    _searchAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _searchAnimation = CurvedAnimation(
      parent: _searchAnimationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchAnimationController.dispose();
    super.dispose();
  }

  Future<void> _loadExercises() async {
    if (!mounted) return;
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

      if (!mounted) return;
      setState(() {
        _allExercises = exercises;
        _isLoading = false;
      });
      _applyFilters();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _onSearchChanged() {
    _applyFilters();
  }

  void _applyFilters() {
    List<Exercise> filtered = List.from(_allExercises);

    // חיפוש טקסט
    final searchTerm = _searchController.text.toLowerCase().trim();
    if (searchTerm.isNotEmpty) {
      filtered = filtered.where((exercise) {
        final name = exercise.name.toLowerCase();
        final nameHe = exercise.nameHe.toLowerCase();
        final description = exercise.description?.toLowerCase() ?? '';
        final descriptionHe = exercise.descriptionHe?.toLowerCase() ?? '';
        final category = exercise.category?.toLowerCase() ?? '';
        final equipment = exercise.equipment?.toLowerCase() ?? '';

        final muscleGroupsMatch = exercise.muscleGroups
                ?.any((muscle) => muscle.toLowerCase().contains(searchTerm)) ??
            false;

        return name.contains(searchTerm) ||
            nameHe.contains(searchTerm) ||
            description.contains(searchTerm) ||
            descriptionHe.contains(searchTerm) ||
            category.contains(searchTerm) ||
            equipment.contains(searchTerm) ||
            muscleGroupsMatch;
      }).toList();
    }

    // פילטר לפי סוג תרגיל
    if (_currentFilter != ExerciseFilter.all) {
      filtered = filtered.where((exercise) {
        final exerciseType = exercise.type?.toLowerCase() ?? '';
        switch (_currentFilter) {
          case ExerciseFilter.strength:
            return exerciseType == 'strength' ||
                exerciseType == 'resistance' ||
                exerciseType == 'weight';
          case ExerciseFilter.cardio:
            return exerciseType == 'cardio' ||
                exerciseType == 'aerobic' ||
                exerciseType == 'endurance';
          case ExerciseFilter.flexibility:
            return exerciseType == 'flexibility' ||
                exerciseType == 'stretching' ||
                exerciseType == 'mobility';
          case ExerciseFilter.balance:
            return exerciseType == 'balance' ||
                exerciseType == 'stability' ||
                exerciseType == 'core';
          default:
            return true;
        }
      }).toList();
    }

    // פילטר לפי קבוצת שרירים
    if (_selectedMuscle != null) {
      filtered = filtered.where((exercise) {
        final muscleGroupsMatch = exercise.muscleGroups
                ?.any((muscle) => muscle.contains(_selectedMuscle!)) ??
            false;
        final mainMusclesMatch = exercise.mainMuscles
                ?.any((muscle) => muscle.contains(_selectedMuscle!)) ??
            false;
        final secondaryMusclesMatch = exercise.secondaryMuscles
                ?.any((muscle) => muscle.contains(_selectedMuscle!)) ??
            false;

        return muscleGroupsMatch || mainMusclesMatch || secondaryMusclesMatch;
      }).toList();
    }

    // מיון
    filtered.sort((a, b) {
      switch (_currentSort) {
        case SortOption.name:
          return a.nameHe.compareTo(b.nameHe); // מיון לפי שם עברי
        case SortOption.difficulty:
          final aDiff = _getDifficultyValue(a.difficulty);
          final bDiff = _getDifficultyValue(b.difficulty);
          return aDiff.compareTo(bDiff);
        case SortOption.muscle:
          final aMuscle = _getFirstMuscle(a);
          final bMuscle = _getFirstMuscle(b);
          return aMuscle.compareTo(bMuscle);
      }
    });

    setState(() {
      _filteredExercises = filtered;
    });
  }

  String _getFirstMuscle(Exercise exercise) {
    if (exercise.muscleGroups?.isNotEmpty == true) {
      return exercise.muscleGroups!.first;
    }
    if (exercise.mainMuscles?.isNotEmpty == true) {
      return exercise.mainMuscles!.first;
    }
    return '';
  }

  int _getDifficultyValue(String? difficulty) {
    if (difficulty == null) return 3; // ברירת מחדל - בינוני

    switch (difficulty.toLowerCase()) {
      case 'beginner':
      case 'מתחילים':
        return 1;
      case 'easy':
      case 'קל':
        return 2;
      case 'medium':
      case 'בינוני':
        return 3;
      case 'hard':
      case 'קשה':
        return 4;
      case 'advanced':
      case 'מתקדם':
        return 5;
      default:
        return 3;
    }
  }

  void _toggleSearch() {
    setState(() {
      _isSearchVisible = !_isSearchVisible;
    });

    if (_isSearchVisible) {
      _searchAnimationController.forward();
    } else {
      _searchAnimationController.reverse();
      _searchController.clear();
    }
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _buildFilterBottomSheet(),
    );
  }

  Widget _buildFilterBottomSheet() {
    return StatefulBuilder(
      builder: (context, setModalState) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // כותרת
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'פילטרים ומיון',
                    style: GoogleFonts.assistant(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // פילטר לפי סוג
              Text(
                'סוג תרגיל',
                style: GoogleFonts.assistant(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                children: ExerciseFilter.values.map((filter) {
                  final isSelected = _currentFilter == filter;
                  return FilterChip(
                    label: Text(_getFilterLabel(filter)),
                    selected: isSelected,
                    onSelected: (selected) {
                      setModalState(() {
                        _currentFilter = selected ? filter : ExerciseFilter.all;
                      });
                      setState(() {
                        _currentFilter = selected ? filter : ExerciseFilter.all;
                      });
                      _applyFilters();
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // פילטר לפי קבוצת שרירים
              Text(
                'קבוצת שרירים',
                style: GoogleFonts.assistant(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                children: [
                  FilterChip(
                    label: const Text('הכל'),
                    selected: _selectedMuscle == null,
                    onSelected: (selected) {
                      setModalState(() {
                        _selectedMuscle = null;
                      });
                      setState(() {
                        _selectedMuscle = null;
                      });
                      _applyFilters();
                    },
                  ),
                  ..._popularMuscles.map((muscle) {
                    final isSelected = _selectedMuscle == muscle;
                    return FilterChip(
                      label: Text(muscle),
                      selected: isSelected,
                      onSelected: (selected) {
                        setModalState(() {
                          _selectedMuscle = selected ? muscle : null;
                        });
                        setState(() {
                          _selectedMuscle = selected ? muscle : null;
                        });
                        _applyFilters();
                      },
                    );
                  }).toList(),
                ],
              ),
              const SizedBox(height: 20),

              // מיון
              Text(
                'מיון לפי',
                style: GoogleFonts.assistant(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                children: SortOption.values.map((sort) {
                  final isSelected = _currentSort == sort;
                  return ChoiceChip(
                    label: Text(_getSortLabel(sort)),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        setModalState(() {
                          _currentSort = sort;
                        });
                        setState(() {
                          _currentSort = sort;
                        });
                        _applyFilters();
                      }
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // כפתור איפוס
              OutlinedButton(
                onPressed: () {
                  setModalState(() {
                    _currentFilter = ExerciseFilter.all;
                    _selectedMuscle = null;
                    _currentSort = SortOption.name;
                  });
                  setState(() {
                    _currentFilter = ExerciseFilter.all;
                    _selectedMuscle = null;
                    _currentSort = SortOption.name;
                  });
                  _applyFilters();
                },
                child: const Text('איפוס פילטרים'),
              ),
              SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
            ],
          ),
        );
      },
    );
  }

  String _getFilterLabel(ExerciseFilter filter) {
    switch (filter) {
      case ExerciseFilter.all:
        return 'הכל';
      case ExerciseFilter.strength:
        return 'כוח';
      case ExerciseFilter.cardio:
        return 'קרדיו';
      case ExerciseFilter.flexibility:
        return 'גמישות';
      case ExerciseFilter.balance:
        return 'איזון';
    }
  }

  String _getSortLabel(SortOption sort) {
    switch (sort) {
      case SortOption.name:
        return 'שם';
      case SortOption.difficulty:
        return 'רמת קושי';
      case SortOption.muscle:
        return 'קבוצת שרירים';
    }
  }

  void _navigateToExerciseDetails(Exercise exercise) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExerciseDetailsScreen(exercise: exercise),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'תרגילי כושר',
            style: GoogleFonts.assistant(fontWeight: FontWeight.bold),
          ),
          actions: [
            // כפתור חיפוש
            IconButton(
              icon: Icon(_isSearchVisible ? Icons.search_off : Icons.search),
              onPressed: _toggleSearch,
              tooltip: _isSearchVisible ? 'סגור חיפוש' : 'חיפוש',
            ),
            // כפתור פילטרים
            IconButton(
              icon: Stack(
                children: [
                  const Icon(Icons.filter_list),
                  if (_hasActiveFilters())
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
              onPressed: _showFilterBottomSheet,
              tooltip: 'פילטרים',
            ),
            // כפתור רענון
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadExercises,
              tooltip: 'רענן רשימה',
            ),
          ],
          backgroundColor: colorScheme.surface,
          elevation: 0,
          bottom: _isSearchVisible
              ? PreferredSize(
                  preferredSize: const Size.fromHeight(60),
                  child: SizeTransition(
                    sizeFactor: _searchAnimation,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: TextField(
                        controller: _searchController,
                        autofocus: true,
                        decoration: InputDecoration(
                          hintText: 'חפש תרגילים...',
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () => _searchController.clear(),
                                )
                              : null,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: colorScheme.surface,
                        ),
                      ),
                    ),
                  ),
                )
              : null,
        ),
        body: _buildBody(),
        floatingActionButton: _filteredExercises.isNotEmpty
            ? FloatingActionButton.extended(
                onPressed: () {
                  // TODO: הוספת תרגיל חדש או פתיחת מסך תוכניות אימון
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('תכונה זו תהיה זמינה בקרוב'),
                    ),
                  );
                },
                icon: const Icon(Icons.add),
                label: const Text('תוכנית אימון'),
              )
            : null,
      ),
    );
  }

  bool _hasActiveFilters() {
    return _currentFilter != ExerciseFilter.all || _selectedMuscle != null;
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'טוען תרגילים...',
              style: GoogleFonts.assistant(
                fontSize: 16,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.error_outline,
                  color: Theme.of(context).colorScheme.onErrorContainer,
                  size: 48,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'שגיאה בטעינת התרגילים',
                style: GoogleFonts.assistant(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                _error!,
                style: GoogleFonts.assistant(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _loadExercises,
                icon: const Icon(Icons.refresh),
                label: const Text('נסה שוב'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_allExercises.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.fitness_center,
                size: 64,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'לא נמצאו תרגילים',
              style: GoogleFonts.assistant(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'משוך למטה לרענון',
              style: GoogleFonts.assistant(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    if (_filteredExercises.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.search_off,
                size: 48,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'לא נמצאו תוצאות',
              style: GoogleFonts.assistant(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'נסה לשנות את הפילטרים או החיפוש',
              style: GoogleFonts.assistant(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () {
                _searchController.clear();
                setState(() {
                  _currentFilter = ExerciseFilter.all;
                  _selectedMuscle = null;
                });
                _applyFilters();
              },
              child: const Text('איפוס חיפוש'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // מציג מספר תוצאות ופילטרים פעילים
        if (_searchController.text.isNotEmpty || _hasActiveFilters())
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color:
                Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  '${_filteredExercises.length} תרגילים נמצאו',
                  style: GoogleFonts.assistant(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (_hasActiveFilters())
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _currentFilter = ExerciseFilter.all;
                        _selectedMuscle = null;
                      });
                      _applyFilters();
                    },
                    icon: const Icon(Icons.clear, size: 16),
                    label: const Text('נקה פילטרים'),
                    style: TextButton.styleFrom(
                      minimumSize: Size.zero,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
              ],
            ),
          ),

        // רשימת התרגילים
        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadExercises,
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: _filteredExercises.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final exercise = _filteredExercises[index];
                return AnimatedContainer(
                  duration: Duration(milliseconds: 100 + (index * 50)),
                  curve: Curves.easeOutCubic,
                  child: Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.1),
                        child: Icon(
                          Icons.fitness_center,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      title: Text(
                        exercise.nameHe,
                        style:
                            GoogleFonts.assistant(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        exercise.descriptionHe ?? exercise.description ?? '',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.assistant(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      trailing: Icon(
                        Icons.chevron_left,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      onTap: () => _navigateToExerciseDetails(exercise),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
