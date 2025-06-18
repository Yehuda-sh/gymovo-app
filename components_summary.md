# Components & Classes Summary

This table summarizes the main classes, widgets, and functions in each major Dart file, with descriptions, import usage, duplication notes, and recommendations for refactoring or reorganization.

---

| Filename | Component/Class/Function | Description | Imports (used/unused) | Duplication/Similarity | Recommendation |
| -------- | ------------------------ | ----------- | --------------------- | ---------------------- | -------------- |

<!-- ===================== main.dart ===================== -->

| `lib/main.dart` | `MyApp` | Root widget, sets up MaterialApp, theme, routes. | All imports used. | None. | Keep as is. |
| | `SplashScreenWrapper` / `_SplashScreenWrapperState` | Handles splash logic and navigation based on auth state. | All imports used. | None. | Consider moving splash logic to its own file. |
| | (main function) | Initializes providers and runs app. | All imports used. | None. | Keep as is. |

<!-- ===================== screens/auth/login/login_screen.dart ===================== -->

| `lib/screens/auth/login/login_screen.dart` | `LoginScreen` / `_LoginScreenState` | Full login UI, form validation, social login, navigation. | All imports used. | **Duplicate of `features/auth/screens/login_screen.dart`** | Merge with features version, extract form logic to reusable widget. |
| | (various form/validation methods) | Email/password validation, login logic. | All imports used. | Duplicated in features version. | Extract validation to shared helper. |

<!-- ===================== features/auth/screens/login_screen.dart ===================== -->

| `lib/features/auth/screens/login_screen.dart` | `LoginScreen` / `_LoginScreenState` | Login UI, form, social login, demo user logic. | All imports used. | **Duplicate of screens version** | Merge with screens version, extract shared logic. |
| | (callbacks: \_onLogin, \_onGoogleLogin, etc.) | Handles login actions and state. | All imports used. | Duplicated in screens version. | Extract to shared logic/helper. |

<!-- ===================== features/workouts/screens/workout_details_screen.dart ===================== -->

| `lib/features/workouts/screens/workout_details_screen.dart` | `WorkoutDetailsScreen` | Displays workout details, exercises, sets, info chips. | All imports used. | **Duplicate of workout_details/workout_details_screen.dart** | Merge with the other version, extract header/list to widgets. |
| | `_buildHeader`, `_buildInfoChip`, `_buildExercisesList`, `_buildSetsTable` | Helper methods for UI sections. | All imports used. | Similar logic in other file. | Extract to widgets if reused. |

<!-- ===================== features/workouts/screens/workout_details/workout_details_screen.dart ===================== -->

| `lib/features/workouts/screens/workout_details/workout_details_screen.dart` | `WorkoutDetailsScreen` | Displays workout details using header, list, actions widgets. | All imports used. | **Duplicate of parent workout_details_screen.dart** | Merge with parent, keep only one. |

<!-- ===================== screens/questionnaire/questionnaire_intro_screen.dart ===================== -->

| `lib/screens/questionnaire/questionnaire_intro_screen.dart` | `QuestionnaireScreen` / `_QuestionnaireScreenState` | **LARGE**. Handles onboarding questionnaire, state, validation, autosave, UI. | All imports used. | Similar to `questionnaire_screen.dart`. | **Split into multiple files:** state, UI, validation, autosave. Extract question widgets. |
| | (various helper methods) | Animation, state, validation, autosave, dialog logic. | All imports used. | Duplicated logic in `questionnaire_screen.dart`. | Extract to managers/helpers. |

<!-- ===================== screens/questionnaire/questionnaire_screen.dart ===================== -->

| `lib/screens/questionnaire/questionnaire_screen.dart` | `QuestionnaireScreen` / `_QuestionnaireScreenState` | **LARGE**. Handles main questionnaire, form, validation, navigation, feedback. | All imports used. | Similar to `questionnaire_intro_screen.dart`. | **Split into smaller widgets/components.** Extract validation, feedback, navigation logic. |
| | (helper methods: \_getVisibleQuestions, \_setAnswer, etc.) | Handles question visibility, answer setting, feedback. | All imports used. | Duplicated logic in intro screen. | Move to shared manager/helper. |

<!-- ===================== screens/questionnaire_results/questionnaire_results_screen.dart ===================== -->

| `lib/screens/questionnaire_results/questionnaire_results_screen.dart` | `QuestionnaireResultsScreen` | **LARGE**. Displays questionnaire results, stats, debug info. | All imports used. | None. | Split into smaller widgets: stats, debug, summary. Remove debug code from production. |

<!-- ===================== models/exercise_model.dart & models/exercise.dart ===================== -->

| `lib/models/exercise_model.dart` | `ExerciseModel` | Data model for exercises. | All imports used. | **Possible duplicate of `exercise.dart`** | Compare and merge with `exercise.dart`. |
| `lib/models/exercise.dart` | `Exercise` | Data model for exercises. | All imports used. | **Possible duplicate of `exercise_model.dart`** | Compare and merge with `exercise_model.dart`. |

<!-- ===================== config/api_config.dart ===================== -->

| `lib/config/api_config.dart` | `ApiConfig` | API endpoints and config. | No imports used. | Not referenced in code. | Remove if not used, or document for future use. |

<!-- ===================== scripts/create_placeholder_avatars.dart & scripts/generate_avatars.dart ===================== -->

| `lib/scripts/create_placeholder_avatars.dart` | (script) | Generates placeholder avatars. | Logging import used. | Not used in app runtime. | Move to `/tools` or document as dev-only. |
| `lib/scripts/generate_avatars.dart` | (script) | Generates avatars. | Path provider, file IO. | Not used in app runtime. | Move to `/tools` or document as dev-only. |

<!-- ===================== screens/auth/create_demo_users.js, package.json, package-lock.json ===================== -->

| `lib/screens/auth/create_demo_users.js` | (script) | JS script for demo users. | N/A | Not used in Dart/Flutter. | Remove or move to `/tools` if needed. |
| `lib/screens/auth/package.json` | (config) | Node package config. | N/A | Not used in Dart/Flutter. | Remove. |
| `lib/screens/auth/package-lock.json` | (config) | Node package lock. | N/A | Not used in Dart/Flutter. | Remove. |

---

## Notes on Imports

- Most major files use all their imports, but some (like `api_config.dart`) are not referenced anywhere.
- Many files use relative imports (`../`), which can cause fragility. Prefer absolute imports for maintainability.
- Duplicated files (login screens, workout details, exercise models) import similar dependencies and have similar logic.

---

## Recommendations

- **Merge duplicate files**: login screens, workout details screens, exercise models.
- **Split large files**: questionnaire screens and results into smaller widgets/components.
- **Extract shared logic**: validation, feedback, autosave, and state management into helpers or managers.
- **Move scripts and non-Dart files**: to `/tools` or document as dev-only.
- **Remove unused configs/scripts**: JS and Node files not used in Flutter.
- **Standardize imports**: use absolute imports throughout the codebase.

---

_This summary is intended for review and planning. No files have been changed or deleted._
