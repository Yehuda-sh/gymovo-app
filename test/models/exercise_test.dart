import 'package:flutter_test/flutter_test.dart';
import 'package:gymovo_app/models/exercise.dart';

void main() {
  group('ExerciseDifficulty Tests', () {
    test('All enum values have translations', () {
      for (final difficulty in ExerciseDifficulty.values) {
        expect(
          ExerciseDifficultyExtension._translations[difficulty.name],
          isNotNull,
          reason: 'Missing translations for ${difficulty.name}',
        );
      }
    });

    test('All translations are non-empty', () {
      for (final translations
          in ExerciseDifficultyExtension._translations.values) {
        for (final languageCode in translations.keys) {
          expect(
            translations[languageCode],
            isNotEmpty,
            reason: 'Empty translation for language $languageCode',
          );
        }
      }
    });

    test('No extra translations exist', () {
      final enumNames = ExerciseDifficulty.values.map((e) => e.name).toSet();
      final translationNames =
          ExerciseDifficultyExtension._translations.keys.toSet();
      expect(
        translationNames,
        equals(enumNames),
        reason:
            'Extra translations found: ${translationNames.difference(enumNames)}',
      );
    });

    test('getDisplayName returns correct translation', () {
      final difficulty = ExerciseDifficulty.medium;
      expect(
        difficulty.getDisplayName('he'),
        equals('בינוני'),
      );
      expect(
        difficulty.getDisplayName('en'),
        equals('Medium'),
      );
    });

    test('getDisplayName falls back to name when translation missing', () {
      final difficulty = ExerciseDifficulty.medium;
      expect(
        difficulty.getDisplayName('fr'),
        equals('medium'),
      );
    });

    test('fromNumericValue returns correct difficulty', () {
      expect(ExerciseDifficultyStaticExtension.fromNumericValue(1),
          equals(ExerciseDifficulty.beginner));
      expect(ExerciseDifficultyStaticExtension.fromNumericValue(2),
          equals(ExerciseDifficulty.easy));
      expect(ExerciseDifficultyStaticExtension.fromNumericValue(3),
          equals(ExerciseDifficulty.medium));
      expect(ExerciseDifficultyStaticExtension.fromNumericValue(4),
          equals(ExerciseDifficulty.hard));
      expect(ExerciseDifficultyStaticExtension.fromNumericValue(5),
          equals(ExerciseDifficulty.advanced));
      expect(ExerciseDifficultyStaticExtension.fromNumericValue(6),
          equals(ExerciseDifficulty.medium)); // fallback
    });

    test('numericValue returns correct number', () {
      expect(ExerciseDifficulty.beginner.numericValue, equals(1));
      expect(ExerciseDifficulty.easy.numericValue, equals(2));
      expect(ExerciseDifficulty.medium.numericValue, equals(3));
      expect(ExerciseDifficulty.hard.numericValue, equals(4));
      expect(ExerciseDifficulty.advanced.numericValue, equals(5));
    });
  });

  group('ExerciseEquipment Tests', () {
    test('All enum values have translations', () {
      for (final equipment in ExerciseEquipment.values) {
        expect(
          ExerciseEquipmentExtension._translations[equipment.name],
          isNotNull,
          reason: 'Missing translations for ${equipment.name}',
        );
      }
    });

    test('All translations are non-empty', () {
      for (final translations
          in ExerciseEquipmentExtension._translations.values) {
        for (final languageCode in translations.keys) {
          expect(
            translations[languageCode],
            isNotEmpty,
            reason: 'Empty translation for language $languageCode',
          );
        }
      }
    });

    test('No extra translations exist', () {
      final enumNames = ExerciseEquipment.values.map((e) => e.name).toSet();
      final translationNames =
          ExerciseEquipmentExtension._translations.keys.toSet();
      expect(
        translationNames,
        equals(enumNames),
        reason:
            'Extra translations found: ${translationNames.difference(enumNames)}',
      );
    });

    test('getDisplayName returns correct translation', () {
      final equipment = ExerciseEquipment.dumbbell;
      expect(
        equipment.getDisplayName('he'),
        equals('דמבל'),
      );
      expect(
        equipment.getDisplayName('en'),
        equals('Dumbbell'),
      );
    });

    test('getDisplayName falls back to name when translation missing', () {
      final equipment = ExerciseEquipment.dumbbell;
      expect(
        equipment.getDisplayName('fr'),
        equals('dumbbell'),
      );
    });

    test('suitableDifficulties returns correct difficulties', () {
      // Test beginner-friendly equipment
      expect(
        ExerciseEquipment.bodyweight.suitableDifficulties,
        containsAll([
          ExerciseDifficulty.beginner,
          ExerciseDifficulty.easy,
          ExerciseDifficulty.medium
        ]),
      );

      // Test intermediate equipment
      expect(
        ExerciseEquipment.dumbbell.suitableDifficulties,
        containsAll([
          ExerciseDifficulty.easy,
          ExerciseDifficulty.medium,
          ExerciseDifficulty.hard
        ]),
      );

      // Test advanced equipment
      expect(
        ExerciseEquipment.barbell.suitableDifficulties,
        containsAll([
          ExerciseDifficulty.medium,
          ExerciseDifficulty.hard,
          ExerciseDifficulty.advanced
        ]),
      );

      // Test other equipment
      expect(
        ExerciseEquipment.other.suitableDifficulties,
        equals(ExerciseDifficulty.values),
      );
    });
  });
}
