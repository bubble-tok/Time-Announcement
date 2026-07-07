# 4. Architecture & Data Model

## Table of Contents
- [4.1 Overview](#41-overview)
- [4.2 Folder Structure](#42-folder-structure)
- [4.3 Layer Description](#43-layer-description)
- [4.4 Data Model](#44-data-model)
- [4.5 Data Flow](#45-data-flow)
- [4.6 Storage Schema](#46-storage-schema)
- [4.7 Future Architecture](#47-future-architecture-v20)

---

## 4.1 Overview

Time Announcement follows a clean layered architecture.
Each layer has a single responsibility and communicates
only with adjacent layers.

> **Note:** Beta uses a **hardcoded** announce-time list, defined in code rather than
> edited by the user. There is no schedule editor UI in beta. A user-editable global
> schedule (Quick Setup, Add/Delete Time) and per-day scheduling are both planned future
> enhancements — see [3.3 Usability](#33-usability), [3.5 Maintainability](#35-maintainability),
> and [4.7 Future Architecture](#47-future-architecture-v20).

| Layer | Description |
|-------|-------------|
| Screens | Full-page UI (Home, Settings) |
| Widgets | Reusable UI components |
| Services | Business logic (TTS, Storage) |
| Triggers | Notification scheduling |
| Utils | Pure helper functions |
| Models | Data structures |

---

## 4.2 Folder Structure

Beta keeps the structure minimal — one file per responsibility, no
unused subfolders. Layers remain logically separated (per [4.1](#41-overview)),
so new files can be added under the same folders later (e.g. a
`day_schedule.dart` model, a `time_generator.dart` util, or a
`weekday_picker.dart` widget) without restructuring.

```
lib/
├── models/
│   ├── schedule.dart          ← Schedule (hardcoded list wrapper)
│   └── tts_settings.dart      ← TtsSettings
│
├── services/
│   ├── storage_service.dart   ← Abstract interface
│   ├── local_storage_service.dart
│   └── tts_service.dart       ← flutter_tts wrapper
│
├── triggers/
│   └── scheduler_service.dart ← Schedule/cancel notifications
│
├── utils/
│   └── time_formatter.dart    ← TimeOfDay → "3:00 PM"
│
└── screens/
    ├── home_screen.dart       ← Global ON/OFF toggle only
    └── settings_screen.dart   ← Volume + permissions + about
```

> **Deferred to future extension:** `time_generator.dart` (Quick Setup interval
> calculation) and a `widgets/` folder for the schedule editor UI (time list,
> time range picker) are not needed for beta and are not pre-created.

---

## 4.3 Layer Description

### Models
Pure data classes with no business logic.
Only responsible for data structure and JSON serialization.

### Services
Business logic layer.
- **StorageService** — abstract interface for data persistence
- **LocalStorageService** — SharedPreferences implementation
- **TtsService** — wraps flutter_tts for audio playback

### Triggers
Notification scheduling logic.
- **SchedulerService** — schedules and cancels repeating **daily**
  notifications using UNCalendarNotificationTrigger (iOS)
  and AndroidScheduleMode (Android)

### Utils
Pure helper functions with no state or dependencies.

### Screens
Full-page UI components.
Depend on Services, Triggers, and Utils.
Never depend directly on each other.

### Widgets
Reusable UI components used inside Screens.
Stateless where possible.

*(Not used in beta — introduced once a schedule editor UI is built. See 4.2.)*

---
## 4.4 Data Model

### Schedule
Represents the announcement schedule, applied every day. In beta, `announceTimes` is
a **fixed list hardcoded in code** (not user-editable), but the model itself is kept
generic so it can later be populated from user input or storage without changing its
shape.

| Field | Type | Description |
|-------|------|-------------|
| isEnabled | bool | Whether announcements are active (tied to the global toggle) |
| announceTimes | List\<TimeOfDay\> | Hardcoded list of times to announce, applied daily |

Example:
```
isEnabled=true, announceTimes=[9:00, 12:30, 17:00]
```

> **Future (v2.0+):** `announceTimes` becomes user-editable (Quick Setup, Add/Delete Time),
> and `Schedule` may be extended to a `Map<Weekday, Schedule>` to support per-day
> customization without breaking existing global-schedule data.

### TtsSettings
Represents the user's TTS preferences. In beta, only `followSystem`/`appVolume` are
user-adjustable; `language` and `speed` are fixed at their defaults.

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| language | String | "system" | TTS language code. "system" = match device language. **Not user-adjustable in beta.** |
| speed | double | 0.5 | Speech rate. **Not user-adjustable in beta** — fixed at normal (0.5). |
| followSystem | bool | true | If true, ignores appVolume and follows device volume. **User-adjustable.** |
| appVolume | double | 1.0 | Custom volume 0.0~1.0. Only used if followSystem=false. **User-adjustable.** |

---

## 4.5 Data Flow

### Hardcoded Schedule Initialization
App starts (first launch or relaunch) and needs to schedule the fixed announce times.

1. App reads the hardcoded `announceTimes` list from `schedule.dart` (not from storage)
2. Global ON/OFF state is loaded from storage
3. If global is ON, SchedulerService creates a repeating daily notification for each
   hardcoded time. Each notification title is pre-filled via TimeFormatter (e.g. "9:00 AM")
4. If global is OFF, no notifications are scheduled
5. Home Screen displays the current global state

> Because the time list is hardcoded, there is no save/load step for the schedule itself —
> only `global_enabled` and TTS volume settings are persisted (see 4.6).

---

### Announcement Firing
2:23 PM — the OS fires the scheduled notification.

1. The device OS triggers the notification at exactly 2:23 PM
2. The app's notification callback fires in the background
3. TtsService reads the notification title "2:23 PM"
   and plays it via the device TTS engine
4. The user hears "2:23 PM"

> The announcement text is pre-calculated and stored in the
> notification title at scheduling time — not at firing time.
> This means the correct text plays even if the app is fully killed.

---

### App Relaunch
User reopens the app after it was killed.

1. App checks if this is a first launch or a relaunch
2. Global ON/OFF state is loaded from storage
3. TTS volume setting is loaded and applied to TtsService
4. If global is ON, the hardcoded schedule is rescheduled
   (notifications may have been cleared when app was killed)
5. Home Screen is displayed with the current state

---

### First Launch
User opens the app for the very first time.

1. App detects no saved data exists
2. Notification permission is requested from the user
3. Background execution permission is requested
4. Default TTS settings are applied:
   volume follows system (language/speed fixed at defaults — not user-facing in beta)
5. Default global state is saved as ON
6. The hardcoded announce-time list is scheduled
7. Home Screen is displayed

---

## 4.6 Storage Schema

Only the global toggle and volume setting are persisted in beta — the announce-time
list is not stored, since it's hardcoded in code.

```json
{
  "global_enabled": true,

  "tts_follow_system": true,
  "tts_app_volume":    1.0
}
```

> `tts_language` and `tts_speed` are omitted from storage in beta since they're not
> user-adjustable — they're applied from fixed defaults at runtime. `schedule.times`
> is likewise omitted; see [4.4 Data Model](#44-data-model).

---

## 4.7 Future Architecture (v2.0)

When the schedule becomes user-editable and Firebase is added:

```
Hardcoded announceTimes →  User-editable via Quick Setup / Add / Delete Time
LocalStorageService      →  FirebaseStorageService
SharedPreferences        →  Firestore
No auth                  →  Firebase Authentication
Local only               →  Multi-device sync
No privacy policy        →  Privacy policy required
No analytics              →  Firebase Analytics (opt-in)
```

> Per-day scheduling may also be introduced in a future release,
> restructuring `schedule` into a per-weekday map while preserving
> existing global-schedule data (see [4.4 Data Model](#44-data-model)).