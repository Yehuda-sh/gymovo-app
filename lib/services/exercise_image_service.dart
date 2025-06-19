import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import '../config/api_keys.dart';

class ExerciseImageService {
  // APIs שונים לתמונות תרגילים
  static const Map<String, String> _imageApis = {
    'wger': 'https://wger.de/api/v2/exerciseimage/',
    'pexels': 'https://api.pexels.com/v1/search',
    'unsplash': 'https://api.unsplash.com/search/photos',
  };

  /// טוען תמונות מ-wger API (חינמי, לא צריך API key)
  static Future<List<String>> getWgerExerciseImages(String exerciseName) async {
    try {
      final response = await http.get(
        Uri.parse('${_imageApis['wger']}?exercise_base__uuid=&limit=10'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List;

        return results
            .map((item) => item['image'] as String)
            .where((url) => url.isNotEmpty)
            .toList();
      }
    } catch (e) {
      debugPrint('Error fetching WGER images: $e');
    }
    return [];
  }

  /// טוען תמונות מ-Pexels API
  static Future<List<String>> getPexelsExerciseImages(
      String exerciseName) async {
    if (ApiKeys.pexelsApiKey == 'YOUR_PEXELS_API_KEY') {
      debugPrint('Please add your Pexels API key in lib/config/api_keys.dart');
      return [];
    }

    try {
      final response = await http.get(
        Uri.parse(
            '${_imageApis['pexels']}?query=$exerciseName%20exercise&per_page=10'),
        headers: {
          'Authorization': ApiKeys.pexelsApiKey,
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final photos = data['photos'] as List;

        return photos
            .map((photo) => photo['src']['medium'] as String)
            .where((url) => url.isNotEmpty)
            .toList();
      }
    } catch (e) {
      debugPrint('Error fetching Pexels images: $e');
    }
    return [];
  }

  /// טוען תמונות מ-Unsplash API
  static Future<List<String>> getUnsplashExerciseImages(
      String exerciseName) async {
    if (ApiKeys.unsplashApiKey == 'YOUR_UNSPLASH_API_KEY') {
      debugPrint(
          'Please add your Unsplash API key in lib/config/api_keys.dart');
      return [];
    }

    try {
      final response = await http.get(
        Uri.parse(
            '${_imageApis['unsplash']}?query=$exerciseName%20exercise&per_page=10'),
        headers: {
          'Authorization': 'Client-ID ${ApiKeys.unsplashApiKey}',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List;

        return results
            .map((photo) => photo['urls']['regular'] as String)
            .where((url) => url.isNotEmpty)
            .toList();
      }
    } catch (e) {
      debugPrint('Error fetching Unsplash images: $e');
    }
    return [];
  }

  /// מחזיר תמונת ברירת מחדל לפי סוג התרגיל
  static String getDefaultExerciseImage(
      String exerciseType, String mainMuscle) {
    // מיפוי תמונות ברירת מחדל לפי סוג התרגיל
    final Map<String, String> defaultImages = {
      'cardio': 'assets/images/cardio_default.png',
      'strength': 'assets/images/strength_default.png',
      'flexibility': 'assets/images/flexibility_default.png',
      'bodyweight': 'assets/images/bodyweight_default.png',
    };

    // מיפוי לפי שריר עיקרי
    final Map<String, String> muscleImages = {
      'chest': 'assets/images/chest_exercise.png',
      'back': 'assets/images/back_exercise.png',
      'legs': 'assets/images/legs_exercise.png',
      'shoulders': 'assets/images/shoulders_exercise.png',
      'arms': 'assets/images/arms_exercise.png',
      'core': 'assets/images/core_exercise.png',
    };

    // נסה למצוא תמונה לפי שריר עיקרי
    for (final muscle in muscleImages.keys) {
      if (mainMuscle.toLowerCase().contains(muscle)) {
        return muscleImages[muscle]!;
      }
    }

    // אם לא נמצא, החזר תמונה כללית
    return defaultImages['strength'] ?? 'assets/images/exercise_default.png';
  }

  /// מחזיר URL תמונה מותאם לפי שם התרגיל
  static String getExerciseImageUrl(String exerciseName,
      {String? fallbackUrl}) {
    // אם יש URL קיים, השתמש בו
    if (fallbackUrl != null && fallbackUrl.isNotEmpty) {
      return fallbackUrl;
    }

    // נסה ליצור URL מותאם לפי שם התרגיל
    final cleanName = exerciseName
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s]'), '')
        .replaceAll(' ', '-');

    // אפשרות 1: תמונות מ-wger (אם יש)
    return 'https://wger.de/media/exercise-images/$cleanName.png';
  }

  /// בודק אם URL תמונה תקין
  static Future<bool> isImageUrlValid(String url) async {
    try {
      final response = await http.head(Uri.parse(url));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// מחזיר תמונות מומלצות לפי סוג התרגיל
  static List<String> getRecommendedImages(String exerciseType) {
    final Map<String, List<String>> recommendedImages = {
      'cardio': [
        'assets/images/cardio_1.png',
        'assets/images/cardio_2.png',
        'assets/images/cardio_3.png',
      ],
      'strength': [
        'assets/images/strength_1.png',
        'assets/images/strength_2.png',
        'assets/images/strength_3.png',
      ],
      'flexibility': [
        'assets/images/flexibility_1.png',
        'assets/images/flexibility_2.png',
        'assets/images/flexibility_3.png',
      ],
    };

    return recommendedImages[exerciseType] ?? [];
  }
}
