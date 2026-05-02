# Flutter Reminders — Material You

A clean Material You Android app, built with Flutter, for setting reminders that fire on a periodic interval (every X minutes / hours / days).

## Features

- **Material You theming** — adapts to the user's wallpaper-derived color palette on Android 12+, with a graceful purple fallback on older devices.
- **Periodic notifications** — pick any interval in minutes, hours, or days. Quick-pick chips for common intervals (15 min, 30 min, 1 hr, 2 hr, 4 hr, daily).
- **Add / edit / delete** with confirmation dialog.
- **Per-reminder enable switch** — pause without losing the entry.
- **Empty-state illustration**, large `SliverAppBar`, extended FAB, filled cards.
- **Persistence** via `shared_preferences`.
- **Light + dark mode** following system setting.
- **Reboot-resilient** — notifications are rescheduled after device restart.

## Setup

1. **Create a fresh Flutter project**, then drop these files in. From a terminal:

   ```bash
   flutter create flutter_reminders --platforms=android
   cd flutter_reminders
   ```

2. **Replace** the generated files with the ones from this project:
   - `pubspec.yaml`
   - everything under `lib/`
   - `android/app/src/main/AndroidManifest.xml`

3. **Set the minimum SDK** in `android/app/build.gradle` (or `build.gradle.kts`) so dynamic colors and modern notification APIs work:

   ```gradle
   defaultConfig {
       minSdkVersion 21
       targetSdkVersion 34
       compileSdkVersion 34
   }
   ```

4. **Install dependencies and run:**

   ```bash
   flutter pub get
   flutter run
   ```

## Project structure

```
lib/
├── main.dart                          # App entry + Material You theme
├── models/
│   └── reminder.dart                  # Reminder model + JSON
├── services/
│   ├── notification_service.dart      # flutter_local_notifications wrapper
│   └── storage_service.dart           # SharedPreferences persistence
├── screens/
│   ├── home_screen.dart               # List + FAB + empty state
│   └── reminder_form.dart             # Add / edit form
└── widgets/
    └── reminder_card.dart             # Reminder list-item card
```

## Notes

- **Battery optimizations.** On some OEMs (Xiaomi, Samsung, Huawei...) aggressive battery savers can delay or kill scheduled notifications. The app uses `AndroidScheduleMode.exactAllowWhileIdle` to minimize this, but for short intervals on those phones you may need to whitelist the app from battery optimization manually.
- **Minimum interval.** `periodicallyShowWithDuration` uses Android's alarm manager; intervals shorter than ~1 minute are not reliable.
- **Permissions.** On Android 13+ the user is prompted for notification permission; on Android 12+ they may be asked for exact alarm permission. Both are requested at app start.
- **Dynamic color** requires Android 12 (API 31). Older devices fall back to the seeded purple Material 3 scheme.
