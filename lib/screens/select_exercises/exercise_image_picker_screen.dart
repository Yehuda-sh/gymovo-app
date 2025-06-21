// lib/screens/select_exercises/exercise_image_picker_screen.dart
import 'package:flutter/material.dart';
import '../../services/exercise_image_service.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ExerciseImagePickerScreen extends StatefulWidget {
  final String exerciseName;
  final String exerciseType;
  final String mainMuscle;
  final String? currentImageUrl;

  const ExerciseImagePickerScreen({
    super.key,
    required this.exerciseName,
    required this.exerciseType,
    required this.mainMuscle,
    this.currentImageUrl,
  });

  @override
  State<ExerciseImagePickerScreen> createState() =>
      _ExerciseImagePickerScreenState();
}

class _ExerciseImagePickerScreenState extends State<ExerciseImagePickerScreen> {
  List<String> _wgerImages = [];
  List<String> _pexelsImages = [];
  List<String> _unsplashImages = [];
  bool _isLoadingWger = false;
  bool _isLoadingPexels = false;
  bool _isLoadingUnsplash = false;
  String? _selectedImageUrl;

  @override
  void initState() {
    super.initState();
    _selectedImageUrl = widget.currentImageUrl;
    _loadImages();
  }

  Future<void> _loadImages() async {
    setState(() {
      _isLoadingWger = true;
      _isLoadingPexels = true;
      _isLoadingUnsplash = true;
    });

    // Load all image sources in parallel
    try {
      final futures = await Future.wait([
        ExerciseImageService.getWgerExerciseImages(widget.exerciseName),
        ExerciseImageService.getPexelsExerciseImages(widget.exerciseName),
        ExerciseImageService.getUnsplashExerciseImages(widget.exerciseName),
      ]);

      setState(() {
        _wgerImages = futures[0];
        _pexelsImages = futures[1];
        _unsplashImages = futures[2];
      });
    } catch (e) {
      // אפשר להראות שגיאה פה או להתעלם
      debugPrint('Error loading images: $e');
    } finally {
      setState(() {
        _isLoadingWger = false;
        _isLoadingPexels = false;
        _isLoadingUnsplash = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('בחר תמונה ל־${widget.exerciseName}'),
        actions: [
          if (_selectedImageUrl != null)
            TextButton(
              onPressed: () => Navigator.of(context).pop(_selectedImageUrl),
              child: const Text('בחר', style: TextStyle(color: Colors.white)),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          if (_selectedImageUrl != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Container(
                height: 180,
                decoration: BoxDecoration(
                  border: Border.all(color: colorScheme.primary, width: 3),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(13),
                  child: _buildImageWidget(
                      _selectedImageUrl!, double.infinity, 180),
                ),
              ),
            ),

          _buildImageSection(
            'תמונות מ-WGER',
            _wgerImages,
            isLoading: _isLoadingWger,
          ),
          _buildImageSection(
            'תמונות מ-Pexels',
            _pexelsImages,
            isLoading: _isLoadingPexels,
          ),
          _buildImageSection(
            'תמונות מ-Unsplash',
            _unsplashImages,
            isLoading: _isLoadingUnsplash,
          ),
          const SizedBox(height: 80), // רווח לסיום למטה
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadImages,
        child: const Icon(Icons.refresh),
        tooltip: 'טען תמונות מחדש',
      ),
    );
  }

  Widget _buildImageSection(String title, List<String> images,
      {required bool isLoading}) {
    if (isLoading) {
      return Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: const Padding(
          padding: EdgeInsets.all(24),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (images.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Text(
          '$title - לא נמצאו תמונות',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: images.length,
            itemBuilder: (context, index) {
              final imageUrl = images[index];
              final isSelected = _selectedImageUrl == imageUrl;

              return GestureDetector(
                onTap: () => setState(() => _selectedImageUrl = imageUrl),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Colors.transparent,
                      width: 3,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            )
                          ]
                        : null,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(9),
                    child: _buildImageWidget(imageUrl, 100, 120),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildImageWidget(String imageUrl, double width, double height) {
    final colorScheme = Theme.of(context).colorScheme;

    if (imageUrl.startsWith('assets/')) {
      return Image.asset(
        imageUrl,
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          width: width,
          height: height,
          color: colorScheme.surfaceVariant,
          child: Icon(Icons.fitness_center,
              color: colorScheme.onSurfaceVariant, size: 32),
        ),
      );
    }

    return CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(
        width: width,
        height: height,
        color: colorScheme.surfaceVariant,
        child: const Center(child: CircularProgressIndicator()),
      ),
      errorWidget: (context, url, error) => Container(
        width: width,
        height: height,
        color: colorScheme.surfaceVariant,
        child: Icon(Icons.fitness_center,
            color: colorScheme.onSurfaceVariant, size: 32),
      ),
    );
  }
}
