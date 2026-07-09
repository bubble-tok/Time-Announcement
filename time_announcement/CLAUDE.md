# Time Announcement — Project Context for Claude Code

## What this project is

A Flutter mobile app (Android/iOS) that announces the current time out loud via TTS
at pre-set times throughout the day — so the user knows what time it is without
looking at their phone. Portfolio/learning project; the person building it is
learning Flutter and intentionally practicing a full SDLC (functional requirements,
architecture docs, UML, Jira backlog) alongside the code, not just writing code.

**Important: the person is still learning.** When making changes, prefer clear,
well-commented code over clever/terse code, and briefly explain non-obvious choices
in code comments (e.g. why a particular API is used). Don't silently refactor things
into patterns they haven't been introduced to yet without a comment explaining why.

## Current scope: BETA (intentionally minimal)

This is a deliberate scope cut to ship something working first:

- **Announce times are hardcoded in code**, not user-editable. No schedule editor UI.
- Only a **global ON/OFF toggle** exists — no per-day scheduling.
- TTS: only **volume** is user-adjustable (via device hardware volume, synced through
  the `volume_controller` package). Language and speed are fixed at defaults, not
  exposed in the UI.
- Deferred to a future version (do NOT build unless explicitly asked): Quick Setup,
  Add/Delete individual times, per-day toggles, language/speed settings, Test Voice
  button, cloud sync, home screen widget, custom messages, custom voices.

## Tech stack / dependencies (pubspec.yaml)

- `flutter_tts` — text-to-speech playback
- `flutter_local_notifications` — OS-level scheduled notifications (use `zonedSchedule`
  with `matchDateTimeComponents: DateTimeComponents.time` for repeating daily alarms —
  event-driven, not a polling background timer, to avoid battery drain)
- `shared_preferences` — persists only: global ON/OFF state, volume settings
- `provider` — state management
- `volume_controller` — reads/listens to device hardware volume for the
  "follow system volume" TTS setting

## Folder structure (already scaffolded)

```
lib/
├── main.dart                       # App entry point, first-launch/relaunch flow (TODO)
├── models/
│   ├── schedule.dart                # Hardcoded announceTimes list, NOT persisted
│   └── tts_settings.dart            # language/speed fixed; followSystem/appVolume adjustable
├── services/
│   ├── storage_service.dart         # Abstract interface — 6 methods only (see below)
│   ├── local_storage_service.dart   # SharedPreferences implementation
│   └── tts_service.dart             # flutter_tts wrapper + volume_controller integration
├── triggers/
│   └── scheduler_service.dart       # Notification scheduling, no per-day param (global only)
├── utils/
│   └── time_formatter.dart          # TimeOfDay -> "3:00 PM" string, handles AM/PM edge cases
└── screens/
    ├── home_screen.dart             # ON/OFF toggle only, no schedule UI
    └── settings_screen.dart         # Volume control only, no language/speed/test button
```

`StorageService` in beta only has: `saveGlobalEnabled`, `loadGlobalEnabled`,
`saveFollowSystem`, `loadFollowSystem`, `saveAppVolume`, `loadAppVolume`. Do not add
schedule/language/speed persistence methods — those come with the future
user-editable-schedule version.

## What's already done

- Flutter project created, folder structure above scaffolded with stub classes
  (most method bodies are `// TODO` placeholders, not real implementations yet)
- `pubspec.yaml` dependencies added and resolved
- App runs successfully (`flutter run -d chrome` and on Android emulator confirmed
  working) showing the Home Screen with just the ON/OFF toggle
- GitHub repo created and pushed with the above

## What's NOT done yet (current focus)

**Currently in progress: permissions (notification + background execution).**
Need to add the `permission_handler` package (not yet in pubspec.yaml) and implement:
- Check/request `Permission.notification` (and Android 12+ exact alarm permission if
  relevant) on first launch
- Handle three states: granted / denied (can re-ask) / permanentlyDenied (must direct
  user to device Settings — show a banner + a button that calls `openAppSettings()`)
- Show permission status in the Settings screen with a "fix" link to device settings
  if denied

After permissions, still TODO in rough order:
1. Fill in `SchedulerService.scheduleAnnouncement()` with real `zonedSchedule` logic
2. Wire the notification-fired callback to actually call `TtsService.speak()`
3. Wire `main.dart`'s first-launch vs. relaunch flow (load stored state, reschedule
   if enabled)
4. Basic unit tests for `TimeFormatter` (AM/PM/midnight/noon edge cases) and the
   announcement condition-checker logic

## Jira

Backlog is tracked in Jira (project key `TA`, site: mikhaylajung.atlassian.net).
Tickets have already been re-scoped for beta (e.g. TA-8 Configure Permissions is the
current in-progress ticket; TA-16/17/19/32/33 and similar schedule-editor tickets are
deferred to Future Extensions). If you complete a ticket's worth of work, mention
which Jira ticket ID it corresponds to in your summary so it can be manually marked
done — you don't have Jira write access.

## Docs that exist (functional requirements, architecture, UML)

There are three reference docs (functional requirements, architecture & data model,
UML class diagram) that were revised to match the beta scope described above. If
asked to implement something, check whether it matches what those docs describe
before adding scope beyond what's listed here.
