// lib/services/exercise_image_service.dart

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

  // === פונקציה מאוחדת שמחזירה תמונת תרגיל טובה (URL), כולל fallback ===
  static Future<String> getBestExerciseImage({
    required String exerciseName,
    required String exerciseType, // לדוג' "strength"
    required String mainMuscle, // לדוג' "chest"
    bool checkUrlValidity = false, // האם לבדוק שה-URL באמת תקין (HEAD)
  }) async {
    debugPrint(
        '== getBestExerciseImage: $exerciseName ($mainMuscle/$exerciseType) ==');

    // 1. נסה Pexels
    try {
      final pexelsImages = await getPexelsExerciseImages(exerciseName);
      for (final url in pexelsImages) {
        if (!checkUrlValidity || await isImageUrlValid(url)) {
          debugPrint('🔗 Using Pexels: $url');
          return url;
        }
      }
    } catch (e) {
      debugPrint('Error loading from Pexels: $e');
    }

    // 2. נסה Unsplash
    try {
      final unsplashImages = await getUnsplashExerciseImages(exerciseName);
      for (final url in unsplashImages) {
        if (!checkUrlValidity || await isImageUrlValid(url)) {
          debugPrint('🔗 Using Unsplash: $url');
          return url;
        }
      }
    } catch (e) {
      debugPrint('Error loading from Unsplash: $e');
    }

    // 3. נסה WGER
    try {
      final wgerImages = await getWgerExerciseImages(exerciseName);
      for (final url in wgerImages) {
        if (!checkUrlValidity || await isImageUrlValid(url)) {
          debugPrint('🔗 Using WGER: $url');
          return url;
        }
      }
    } catch (e) {
      debugPrint('Error loading from WGER: $e');
    }

    // 4. ברירת מחדל לפי שריר עיקרי/סוג תרגיל
    final fallback = getDefaultExerciseImage(exerciseType, mainMuscle);
    debugPrint('🖼️ Using default image: $fallback');
    return fallback;
  }

  // === שאר הפונקציות – מתוך השירות הקיים שלך (משוחזרות לדוגמה) ===

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

  static String getDefaultExerciseImage(
      String exerciseType, String mainMuscle) {
    final Map<String, String> defaultImages = {
      'cardio': 'assets/images/cardio_default.png',
      'strength': 'assets/images/strength_default.png',
      'flexibility': 'assets/images/flexibility_default.png',
      'bodyweight': 'assets/images/bodyweight_default.png',
    };
    final Map<String, String> muscleImages = {
      'chest': 'assets/images/chest_exercise.png',
      'back': 'assets/images/back_exercise.png',
      'legs': 'assets/images/legs_exercise.png',
      'shoulders': 'assets/images/shoulders_exercise.png',
      'arms': 'assets/images/arms_exercise.png',
      'core': 'assets/images/core_exercise.png',
    };
    for (final muscle in muscleImages.keys) {
      if (mainMuscle.toLowerCase().contains(muscle)) {
        return muscleImages[muscle]!;
      }
    }
    return defaultImages[exerciseType] ?? 'assets/images/exercise_default.png';
  }

  static Future<bool> isImageUrlValid(String url) async {
    try {
      final response = await http.head(Uri.parse(url));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
