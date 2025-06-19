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
    // טען תמונות מ-wger
    setState(() => _isLoadingWger = true);
    try {
      final images =
          await ExerciseImageService.getWgerExerciseImages(widget.exerciseName);
      setState(() {
        _wgerImages = images;
        _isLoadingWger = false;
      });
    } catch (e) {
      setState(() => _isLoadingWger = false);
    }

    // טען תמונות מ-Pexels
    setState(() => _isLoadingPexels = true);
    try {
      final images = await ExerciseImageService.getPexelsExerciseImages(
          widget.exerciseName);
      setState(() {
        _pexelsImages = images;
        _isLoadingPexels = false;
      });
    } catch (e) {
      setState(() => _isLoadingPexels = false);
    }

    // טען תמונות מ-Unsplash
    setState(() => _isLoadingUnsplash = true);
    try {
      final images = await ExerciseImageService.getUnsplashExerciseImages(
          widget.exerciseName);
      setState(() {
        _unsplashImages = images;
        _isLoadingUnsplash = false;
      });
    } catch (e) {
      setState(() => _isLoadingUnsplash = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('בחר תמונה ל${widget.exerciseName}'),
        actions: [
          if (_selectedImageUrl != null)
            TextButton(
              onPressed: () => Navigator.of(context).pop(_selectedImageUrl),
              child: const Text('בחר'),
            ),
        ],
      ),
      body: Column(
        children: [
          // תמונה נבחרת
          if (_selectedImageUrl != null)
            Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: colorScheme.primary, width: 3),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(13),
                child: _buildImageWidget(_selectedImageUrl!, 200, 150),
              ),
            ),

          // תמונות מומלצות
          _buildImageSection(
            'תמונות מומלצות',
            ExerciseImageService.getRecommendedImages(widget.exerciseType),
            isLoading: false,
          ),

          // תמונות מ-WGER
          _buildImageSection(
            'תמונות מ-WGER',
            _wgerImages,
            isLoading: _isLoadingWger,
          ),

          // תמונות מ-Pexels
          _buildImageSection(
            'תמונות מ-Pexels',
            _pexelsImages,
            isLoading: _isLoadingPexels,
          ),

          // תמונות מ-Unsplash
          _buildImageSection(
            'תמונות מ-Unsplash',
            _unsplashImages,
            isLoading: _isLoadingUnsplash,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadImages,
        child: const Icon(Icons.refresh),
      ),
    );
  }

  Widget _buildImageSection(String title, List<String> images,
      {required bool isLoading}) {
    if (isLoading) {
      return Card(
        margin: const EdgeInsets.all(8),
        child: const Padding(
          padding: EdgeInsets.all(16),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (images.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            itemCount: images.length,
            itemBuilder: (context, index) {
              final imageUrl = images[index];
              final isSelected = _selectedImageUrl == imageUrl;

              return GestureDetector(
                onTap: () => setState(() => _selectedImageUrl = imageUrl),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Colors.transparent,
                      width: 3,
                    ),
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

    // אם זו תמונה מקומית
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
          child: Icon(
            Icons.fitness_center,
            color: colorScheme.onSurfaceVariant,
            size: 32,
          ),
        ),
      );
    }

    // אם זו תמונה מהאינטרנט
    return CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(
        width: width,
        height: height,
        color: colorScheme.surfaceVariant,
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
      errorWidget: (context, url, error) => Container(
        width: width,
        height: height,
        color: colorScheme.surfaceVariant,
        child: Icon(
          Icons.fitness_center,
          color: colorScheme.onSurfaceVariant,
          size: 32,
        ),
      ),
    );
  }
}
