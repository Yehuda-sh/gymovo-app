# Project Files Audit

This document lists all files in the project, with comments on their purpose, usage, redundancy, and refactoring suggestions.

---

## Root Directory

| File                        | Purpose & Usage                        | Notes / Suggestions          |
| --------------------------- | -------------------------------------- | ---------------------------- |
| `README.md`                 | Project overview and instructions.     | Actively used. Keep updated. |
| `pubspec.yaml`              | Flutter/Dart dependencies and assets.  | Actively used.               |
| `pubspec.lock`              | Locked dependency versions.            | Auto-generated.              |
| `analysis_options.yaml`     | Linting and analysis rules.            | Actively used.               |
| `devtools_options.yaml`     | Devtools config.                       | Used for debugging.          |
| `.gitignore`                | Git ignore rules.                      | Actively used.               |
| `.metadata`                 | Flutter project metadata.              | Auto-generated.              |
| `gymovo.iml`                | IDE project file.                      | Auto-generated.              |
| `summary.txt`               | Appears to be a change log or summary. | Not required for production. |
| `project_audit_summary.txt` | Audit report (generated).              | For review only.             |
| `project_files_audit.md`    | This audit file.                       | For review only.             |

---

## `/lib` (Main Source Directory)

### General

| File                                       | Purpose & Usage                                | Notes / Suggestions                                                    |
| ------------------------------------------ | ---------------------------------------------- | ---------------------------------------------------------------------- |
| `main.dart`                                | App entry point, sets up providers and routes. | Actively used.                                                         |
| `theme/app_theme.dart`                     | Centralized theming/colors.                    | Actively used.                                                         |
| `config/api_config.dart`                   | API endpoints/config.                          | Not actively used (no API calls). Candidate for removal or future use. |
| `questionnaire/questions.dart`             | Questionnaire data.                            | Used in questionnaire screens.                                         |
| `scripts/create_placeholder_avatars.dart`  | Script for avatar generation.                  | Not used in app runtime. Keep for dev, move to `/tools` or document.   |
| `scripts/generate_avatars.dart`            | Script for avatar generation.                  | Same as above.                                                         |
| `data/exercise_data_store.dart`            | Data store for exercises.                      | Check if used; if not, candidate for removal.                          |
| `data/local_data_store.dart`               | Local storage logic.                           | Actively used.                                                         |
| `models/exercise.dart`                     | Exercise data model.                           | Actively used.                                                         |
| `models/exercise_history.dart`             | Exercise history model.                        | Actively used.                                                         |
| `models/exercise_model.dart`               | Possibly duplicate of `exercise.dart`.         | Check for redundancy; consider merging.                                |
| `models/question_model.dart`               | Questionnaire model.                           | Actively used.                                                         |
| `models/user_model.dart`                   | User data model.                               | Actively used.                                                         |
| `models/week_plan_model.dart`              | Week plan model.                               | Actively used.                                                         |
| `models/workout_model.dart`                | Workout model.                                 | Actively used.                                                         |
| `providers/auth_provider.dart`             | Auth state management.                         | Actively used.                                                         |
| `providers/exercise_history_provider.dart` | Exercise history state.                        | Actively used.                                                         |
| `providers/exercise_provider.dart`         | Exercise state.                                | Actively used.                                                         |
| `providers/settings_provider.dart`         | App settings state.                            | Actively used.                                                         |
| `providers/week_plan_provider.dart`        | Week plan state.                               | Actively used.                                                         |
| `providers/workouts_provider.dart`         | Workouts state.                                | Actively used.                                                         |
| `services/plan_builder_service.dart`       | Plan building logic.                           | Actively used.                                                         |
| `services/workout_plan_builder.dart`       | Workout plan builder.                          | Actively used.                                                         |
| `services/workout_service.dart`            | Workout-related services.                      | Actively used.                                                         |
| `widgets/exercise_card.dart`               | Exercise card widget.                          | Actively used.                                                         |
| `widgets/exercise_form.dart`               | Exercise form widget.                          | Actively used.                                                         |
| `widgets/greeting_header.dart`             | Greeting header widget.                        | Actively used.                                                         |
| `widgets/profile_avatar.dart`              | Profile avatar widget.                         | Actively used.                                                         |
| `widgets/quick_action_button.dart`         | Quick action button.                           | Actively used.                                                         |
| `widgets/user_info_modal.dart`             | User info modal.                               | Actively used.                                                         |
| `widgets/workout/`                         | Workout-related widgets.                       | Actively used.                                                         |

---

### `/lib/features/`

#### `/auth/`

| File                                | Purpose & Usage                  | Notes / Suggestions                                                            |
| ----------------------------------- | -------------------------------- | ------------------------------------------------------------------------------ |
| `helpers/validation.dart`           | Validation helpers.              | Used in auth forms.                                                            |
| `screens/login_screen.dart`         | Login screen (features version). | **Duplicate** of `lib/screens/auth/login/login_screen.dart`. Consider merging. |
| `widgets/login_button.dart`         | Login button widget.             | Used in login screen.                                                          |
| `widgets/login_divider.dart`        | Divider for login UI.            | Used in login screen.                                                          |
| `widgets/login_form.dart`           | Login form widget.               | Used in login screen.                                                          |
| `widgets/login_form_field.dart`     | Login form field.                | Used in login form.                                                            |
| `widgets/login_header.dart`         | Login header.                    | Used in login screen.                                                          |
| `widgets/social_login_button.dart`  | Social login button.             | Used in login screen.                                                          |
| `widgets/social_login_section.dart` | Social login section.            | Used in login screen.                                                          |

#### `/exercises/`

| File                                   | Purpose & Usage             | Notes / Suggestions     |
| -------------------------------------- | --------------------------- | ----------------------- |
| `screens/exercise_details_screen.dart` | Exercise details UI.        | Actively used.          |
| `widgets/exercise_history_graph.dart`  | Exercise history graph.     | Used in details screen. |
| `widgets/exercise_media_section.dart`  | Media section for exercise. | Used in details screen. |
| `widgets/exercise_set_form.dart`       | Set form for exercise.      | Used in details screen. |
| `widgets/exercise_set_list.dart`       | Set list for exercise.      | Used in details screen. |

#### `/home/`

| File                                   | Purpose & Usage          | Notes / Suggestions |
| -------------------------------------- | ------------------------ | ------------------- |
| `screens/home_tab.dart`                | Home tab UI.             | Actively used.      |
| `widgets/greeting_widget.dart`         | Greeting widget.         | Used in home tab.   |
| `widgets/quick_action_card.dart`       | Quick action card.       | Used in home tab.   |
| `widgets/quick_actions_grid.dart`      | Quick actions grid.      | Used in home tab.   |
| `widgets/quick_start_section.dart`     | Quick start section.     | Used in home tab.   |
| `widgets/stats_section.dart`           | Stats section.           | Used in home tab.   |
| `widgets/workout_progress_widget.dart` | Workout progress widget. | Used in home tab.   |

#### `/motivation/`

| File                           | Purpose & Usage         | Notes / Suggestions      |
| ------------------------------ | ----------------------- | ------------------------ |
| `widgets/motivation_card.dart` | Motivation card widget. | Used in home/motivation. |

#### `/stats/`

| File                                 | Purpose & Usage          | Notes / Suggestions |
| ------------------------------------ | ------------------------ | ------------------- |
| `models/achievement_card.dart`       | Achievement card model.  | Used in stats.      |
| `models/achievement.dart`            | Achievement model.       | Used in stats.      |
| `models/achievements_list.dart`      | Achievements list model. | Used in stats.      |
| `screens/workout_stats_screen.dart`  | Workout stats UI.        | Actively used.      |
| `services/stats_export_service.dart` | Export stats service.    | Used in stats.      |
| `widgets/stats_charts.dart`          | Stats charts widget.     | Used in stats.      |
| `widgets/stats_summary.dart`         | Stats summary widget.    | Used in stats.      |

#### `/workouts/`

| File                                   | Purpose & Usage                   | Notes / Suggestions                                                               |
| -------------------------------------- | --------------------------------- | --------------------------------------------------------------------------------- |
| `providers/workout_mode_provider.dart` | Workout mode state.               | Used in workout mode.                                                             |
| `providers/workouts_provider.dart`     | Workouts state.                   | Used in workouts.                                                                 |
| `screens/new_workout_screen.dart`      | New workout UI.                   | Actively used.                                                                    |
| `screens/week_plan_screen.dart`        | Week plan UI.                     | Actively used.                                                                    |
| `screens/workout_details_screen.dart`  | Workout details UI.               | **Duplicate** of `workout_details/workout_details_screen.dart`. Consider merging. |
| `screens/workout_details/`             | Widgets for workout details.      | Used in workout details.                                                          |
| `screens/workout_mode/`                | Workout mode screens and widgets. | Used in workout mode.                                                             |
| `screens/workouts_screen.dart`         | Workouts list UI.                 | Actively used.                                                                    |

---

### `/lib/screens/`

#### `/auth/`

| File                      | Purpose & Usage                 | Notes / Suggestions                                                           |
| ------------------------- | ------------------------------- | ----------------------------------------------------------------------------- |
| `auth_wrapper.dart`       | Auth state wrapper.             | Used in app entry.                                                            |
| `create_demo_users.js`    | JS script for demo users.       | Not used in Dart/Flutter. Candidate for removal or move to `/tools`.          |
| `login/login_screen.dart` | Login screen (screens version). | **Duplicate** of `features/auth/screens/login_screen.dart`. Consider merging. |
| `package-lock.json`       | Node package lock.              | Not used in Flutter. Candidate for removal.                                   |
| `package.json`            | Node package config.            | Not used in Flutter. Candidate for removal.                                   |

#### `/exercise_search/`

| File                          | Purpose & Usage     | Notes / Suggestions |
| ----------------------------- | ------------------- | ------------------- |
| `exercise_search_screen.dart` | Exercise search UI. | Actively used.      |

#### `/exercises/`

| File                    | Purpose & Usage    | Notes / Suggestions |
| ----------------------- | ------------------ | ------------------- |
| `exercises_screen.dart` | Exercises list UI. | Actively used.      |

#### `/home/`

| File               | Purpose & Usage | Notes / Suggestions |
| ------------------ | --------------- | ------------------- |
| `home_screen.dart` | Home screen UI. | Actively used.      |

#### `/profile/`

| File                              | Purpose & Usage         | Notes / Suggestions |
| --------------------------------- | ----------------------- | ------------------- |
| `profile_screen.dart`             | Profile UI.             | Actively used.      |
| `widgets/account_section.dart`    | Account section widget. | Used in profile.    |
| `widgets/profile_header.dart`     | Profile header widget.  | Used in profile.    |
| `widgets/quick_actions_card.dart` | Quick actions card.     | Used in profile.    |
| `widgets/settings_section.dart`   | Settings section.       | Used in profile.    |
| `widgets/user_stats_card.dart`    | User stats card.        | Used in profile.    |

#### `/questionnaire/`

| File                                                 | Purpose & Usage              | Notes / Suggestions                                               |
| ---------------------------------------------------- | ---------------------------- | ----------------------------------------------------------------- |
| `questionnaire_intro_screen.dart`                    | Questionnaire intro UI.      | **LARGE FILE (1641 lines)**. Used in onboarding. Needs splitting. |
| `questionnaire_screen.dart`                          | Questionnaire UI.            | **LARGE FILE (1100 lines)**. Used in onboarding. Needs splitting. |
| `components/`                                        | Widgets for questionnaire.   | Used in questionnaire.                                            |
| `managers/`                                          | State/validation managers.   | Used in questionnaire.                                            |
| `screens/enhanced_questionnaire_results_screen.dart` | Enhanced results UI.         | Used in questionnaire.                                            |
| `screens/enhanced_questionnaire_screen.dart`         | Enhanced questionnaire UI.   | Used in questionnaire.                                            |
| `services/questionnaire_analytics.dart`              | Analytics for questionnaire. | Used in questionnaire.                                            |

#### `/questionnaire_results/`

| File                                | Purpose & Usage           | Notes / Suggestions                                           |
| ----------------------------------- | ------------------------- | ------------------------------------------------------------- |
| `questionnaire_results_screen.dart` | Questionnaire results UI. | **LARGE FILE (746 lines)**. Used in results. Needs splitting. |

#### `/register/`

| File                   | Purpose & Usage  | Notes / Suggestions |
| ---------------------- | ---------------- | ------------------- |
| `register_screen.dart` | Registration UI. | Actively used.      |

#### `/select_exercises/`

| File                           | Purpose & Usage      | Notes / Suggestions |
| ------------------------------ | -------------------- | ------------------- |
| `select_exercises_screen.dart` | Select exercises UI. | Actively used.      |

#### `/settings/`

| File                   | Purpose & Usage | Notes / Suggestions |
| ---------------------- | --------------- | ------------------- |
| `settings_screen.dart` | Settings UI.    | Actively used.      |

#### `/splash/`

| File                 | Purpose & Usage   | Notes / Suggestions |
| -------------------- | ----------------- | ------------------- |
| `splash_screen.dart` | Splash screen UI. | Actively used.      |

#### `/welcome/`

| File                  | Purpose & Usage | Notes / Suggestions |
| --------------------- | --------------- | ------------------- |
| `welcome_screen.dart` | Welcome UI.     | Actively used.      |

---

## `/assets/`

| File/Folder                   | Purpose & Usage         | Notes / Suggestions           |
| ----------------------------- | ----------------------- | ----------------------------- |
| `avatars/`                    | Avatar images.          | Used in profile/screens.      |
| `data/demo_plans.json`        | Demo plans data.        | Used for demo users.          |
| `data/demo_users.json`        | Demo users data.        | Used for demo users.          |
| `data/workout_exercises.json` | Exercise data.          | Used in exercise screens.     |
| `fonts/Assistant-Regular.ttf` | Font file.              | Used in theming.              |
| `icons/`                      | Social and app icons.   | Used in login/social screens. |
| `images/`                     | App images and avatars. | Used in UI.                   |

---

## `/android/` and `/ios/`

| File/Folder | Purpose & Usage                     | Notes / Suggestions                  |
| ----------- | ----------------------------------- | ------------------------------------ |
| All files   | Platform-specific build and config. | Required for Flutter. Do not delete. |

---

## `/test/`

| File                                         | Purpose & Usage           | Notes / Suggestions        |
| -------------------------------------------- | ------------------------- | -------------------------- |
| `local_data_store_guest_migration_test.dart` | Test for guest migration. | Actively used for testing. |
| `models/exercise_test.dart`                  | Test for exercise model.  | Actively used for testing. |

---

# Summary

## Candidates for Deletion or Merging

- **Duplicate Login Screens**:

  - `lib/screens/auth/login/login_screen.dart`
  - `lib/features/auth/screens/login_screen.dart`  
    _→ Merge into one, delete the other._

- **Duplicate Workout Details Screens**:

  - `lib/features/workouts/screens/workout_details_screen.dart`
  - `lib/features/workouts/screens/workout_details/workout_details_screen.dart`  
    _→ Merge into one, delete the other._

- **Duplicate/Unused Models**:

  - `lib/models/exercise_model.dart` vs `lib/models/exercise.dart`  
    _→ Merge if redundant._

- **Unused Config/Script Files**:
  - `lib/config/api_config.dart` (if not used)
  - `lib/scripts/create_placeholder_avatars.dart`, `lib/scripts/generate_avatars.dart` (move to `/tools` or document as dev-only)
  - `lib/screens/auth/create_demo_users.js`, `package.json`, `package-lock.json` (not used in Dart/Flutter)

## Files Too Large (Need Splitting)

- `lib/screens/questionnaire/questionnaire_intro_screen.dart` (**1641 lines**)
- `lib/screens/questionnaire/questionnaire_screen.dart` (**1100 lines**)
- `lib/screens/questionnaire_results/questionnaire_results_screen.dart` (**746 lines**)

## Immediate Refactoring Opportunities

- **Merge duplicate screens and models.**
- **Split large files into smaller widgets/components.**
- **Move dev-only scripts to a dedicated `/tools` or `/scripts` folder, outside of main app code.**
- **Remove or archive unused config/scripts.**
- **Standardize import style (prefer absolute imports).**
- **Centralize constants and validation logic.**
- **Document or remove any files not referenced in the app.**

---

**This list is intended for review and planning. No files have been deleted or changed.**
