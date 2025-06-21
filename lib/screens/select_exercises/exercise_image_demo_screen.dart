// lib/screens/select_exercises/exercise_image_demo_screen.dart
import 'package:flutter/material.dart';
import '../../services/exercise_image_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../config/api_keys.dart';

class ExerciseImageDemoScreen extends StatefulWidget {
  const ExerciseImageDemoScreen({super.key});

  @override
  State<ExerciseImageDemoScreen> createState() =>
      _ExerciseImageDemoScreenState();
}

class _ExerciseImageDemoScreenState extends State<ExerciseImageDemoScreen> {
  List<String> _wgerImages = [];
  List<String> _pexelsImages = [];
  List<String> _unsplashImages = [];
  bool _isLoading = false;
  String _searchQuery = 'squat';

  @override
  void initState() {
    super.initState();
    _loadAllImages();
  }

  Future<void> _loadAllImages() async {
    if (_searchQuery.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('אנא הזן מונח חיפוש')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // טען תמונות מכל המקורות במקביל
      final futures = await Future.wait([
        ExerciseImageService.getWgerExerciseImages(_searchQuery),
        if (ApiKeys.pexelsApiKey != 'YOUR_PEXELS_API_KEY')
          ExerciseImageService.getPexelsExerciseImages(_searchQuery)
        else
          Future.value([]),
        if (ApiKeys.unsplashApiKey != 'YOUR_UNSPLASH_API_KEY')
          ExerciseImageService.getUnsplashExerciseImages(_searchQuery)
        else
          Future.value([]),
      ]);

      setState(() {
        _wgerImages = futures[0] as List<String>;
        _pexelsImages = futures.length > 1 ? futures[1] as List<String> : [];
        _unsplashImages = futures.length > 2 ? futures[2] as List<String> : [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('שגיאה בטעינת תמונות: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('דוגמה - תמונות תרגילים'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAllImages,
          ),
        ],
      ),
      body: Column(
        children: [
          // חיפוש
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'חפש תרגיל...',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) => setState(() => _searchQuery = value),
                    onSubmitted: (_) => _loadAllImages(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _loadAllImages,
                  child: const Text('חפש'),
                ),
              ],
            ),
          ),

          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // תמונות ברירת מחדל
                  _buildSection(
                    'תמונות ברירת מחדל',
                    [
                      ExerciseImageService.getDefaultExerciseImage(
                          'strength', 'chest'),
                      ExerciseImageService.getDefaultExerciseImage(
                          'cardio', 'legs'),
                      ExerciseImageService.getDefaultExerciseImage(
                          'flexibility', 'back'),
                    ],
                  ),

                  // תמונות מ-WGER
                  _buildSection(
                    'תמונות מ-WGER (${_wgerImages.length})',
                    _wgerImages,
                    showApiStatus: true,
                    apiName: 'WGER',
                  ),

                  // תמונות מ-Pexels
                  _buildSection(
                    'תמונות מ-Pexels (${_pexelsImages.length})',
                    _pexelsImages,
                    showApiStatus: true,
                    apiName: 'Pexels',
                  ),

                  // תמונות מ-Unsplash
                  _buildSection(
                    'תמונות מ-Unsplash (${_unsplashImages.length})',
                    _unsplashImages,
                    showApiStatus: true,
                    apiName: 'Unsplash',
                  ),

                  // תמונות מומלצות
                  _buildSection(
                    'תמונות מומלצות',
                    [], // או רשימת תמונות סטטית/ריקה
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSection(
    String title,
    List<String> images, {
    bool showApiStatus = false,
    String? apiName,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (showApiStatus && apiName != null) _buildApiStatus(apiName),
              ],
            ),
          ),
          if (images.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('לא נמצאו תמונות'),
            )
          else
            SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                itemCount: images.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: _buildImageWidget(images[index], 100, 120),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildApiStatus(String apiName) {
    bool isConfigured = false;

    switch (apiName) {
      case 'WGER':
        isConfigured = true; // WGER לא דורש API key
        break;
      case 'Pexels':
        isConfigured = ApiKeys.pexelsApiKey != 'YOUR_PEXELS_API_KEY';
        break;
      case 'Unsplash':
        isConfigured = ApiKeys.unsplashApiKey != 'YOUR_UNSPLASH_API_KEY';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isConfigured ? Colors.green : Colors.orange,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        isConfigured ? 'פעיל' : 'לא מוגדר',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
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
