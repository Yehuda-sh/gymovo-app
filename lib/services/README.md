# שירותי תמונות תרגילים

## סקירה כללית

השירות מספק גישה לתמונות תרגילים ממספר מקורות:

1. **WGER API** - חינמי, לא צריך API key
2. **Pexels API** - חינמי עם API key
3. **Unsplash API** - חינמי עם API key

## הגדרת API Keys

### Pexels API

1. היכנס ל-[Pexels API](https://www.pexels.com/api/)
2. צור חשבון חינמי
3. קבל API key
4. החלף את `YOUR_PEXELS_API_KEY` בקובץ `exercise_image_service.dart`

### Unsplash API

1. היכנס ל-[Unsplash Developers](https://unsplash.com/developers)
2. צור חשבון חינמי
3. צור אפליקציה חדשה
4. קבל Access Key
5. החלף את `YOUR_UNSPLASH_API_KEY` בקובץ `exercise_image_service.dart`

## שימוש

```dart
// טעינת תמונות מ-WGER
final wgerImages = await ExerciseImageService.getWgerExerciseImages('squat');

// טעינת תמונות מ-Pexels
final pexelsImages = await ExerciseImageService.getPexelsExerciseImages('squat');

// טעינת תמונות מ-Unsplash
final unsplashImages = await ExerciseImageService.getUnsplashExerciseImages('squat');

// קבלת תמונת ברירת מחדל
final defaultImage = ExerciseImageService.getDefaultExerciseImage('strength', 'chest');

// בדיקת תקינות URL
final isValid = await ExerciseImageService.isImageUrlValid('https://example.com/image.jpg');
```

## תמונות ברירת מחדל

השירות כולל תמונות ברירת מחדל לפי סוג התרגיל:

- `cardio` - תרגילי לב-ריאה
- `strength` - תרגילי כוח
- `flexibility` - תרגילי גמישות
- `bodyweight` - תרגילי משקל גוף

## הערות חשובות

1. **WGER API** - זמין מיד ללא הגדרה נוספת
2. **Pexels & Unsplash** - דורשים API keys חינמיים
3. **תמונות מקומיות** - יש להוסיף תמונות ברירת מחדל לתיקיית `assets/images/`
4. **Caching** - התמונות נשמרות במטמון אוטומטית באמצעות `CachedNetworkImage`

## הוספת תמונות מקומיות

הוסף תמונות ברירת מחדל לתיקייה `assets/images/`:

```
assets/images/
├── cardio_default.png
├── strength_default.png
├── flexibility_default.png
├── bodyweight_default.png
├── chest_exercise.png
├── back_exercise.png
├── legs_exercise.png
├── shoulders_exercise.png
├── arms_exercise.png
└── core_exercise.png
```

אל תשכח להוסיף אותן ל-`pubspec.yaml`:

```yaml
flutter:
  assets:
    - assets/images/
```
