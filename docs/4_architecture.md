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

> **Note:** v1.0 uses a single global schedule applied across all days.
> Per-day scheduling is a planned future enhancement — see [3.3 Usability](#33-usability)
> and [3.5 Maintainability](#35-maintainability).

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

v1.0 keeps the structure minimal — one file per responsibility, no
unused subfolders. Layers remain logically separated (per [4.1](#41-overview)),
so new files can be added under the same folders later (e.g. a
`day_schedule.dart` model or a `weekday_picker.dart` widget) without
restructuring.

```
lib/
├── models/
│   ├── schedule.dart          ← Schedule (global)
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
│   ├── time_formatter.dart    ← TimeOfDay → "3:00 PM"
│   └── time_generator.dart    ← generateTimes(start, end, interval)
│
└── screens/
    ├── home_screen.dart       ← Includes schedule editor + Quick Setup
    └── settings_screen.dart   ← TTS + permissions + about
```

> **Future extension:** a `widgets/` folder can be introduced once UI
> pieces (e.g. schedule editor, time range picker) need to be reused
> across multiple screens — no need to pre-create it for v1.0.

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

---
## 4.4 Data Model

### Schedule
Represents the global announcement schedule, applied every day.

| Field | Type | Description |
|-------|------|-------------|
| isEnabled | bool | Whether announcements are active |
| announceTimes | List\<TimeOfDay\> | List of times to announce, applied daily |

Example:
```
isEnabled=true, announceTimes=[9:00, 12:30, 17:00]
```

> **Future (v2.0+):** `Schedule` may be extended to a `Map<Weekday, Schedule>`
> to support per-day customization without breaking existing global-schedule data.

### TtsSettings
Represents the user's TTS preferences.

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| language | String | "system" | TTS language code. "system" = match device language |
| speed | double | 0.5 | Speech rate. 0.25=slow / 0.5=normal / 1.0=fast |
| followSystem | bool | true | If true, ignores appVolume and follows device volume |
| appVolume | double | 1.0 | Custom volume 0.0~1.0. Only used if followSystem=false |

---

## 4.5 Data Flow

### Quick Setup
User wants to set announcements every hour from 9 AM to 6 PM.

1. User opens the schedule and fills in Quick Setup:
   From: 9:00 AM / To: 6:00 PM / Every: 1 hour
2. App instantly previews the generated times:
   9:00, 10:00, ... 6:00 PM
3. User taps Apply
4. If times already exist, a confirmation dialog appears:
   "This will replace your current times. Continue?"
5. TimeGenerator calculates the full list of TimeOfDay values
6. The new list is saved to local storage via StorageService
7. For each time in the list, SchedulerService creates a
   repeating daily notification. The notification title
   is pre-filled with the announcement text
   (e.g. "9:00 AM") via TimeFormatter
8. UI updates to show the new time list

---

### Add Single Time
User wants to add one specific time (e.g. 2:23 PM) to the schedule.

1. User taps "+ Add time" on the schedule screen
2. Native TimePicker opens
3. User selects 2:23 PM
4. App checks for duplicates — if 2:23 PM already exists,
   an error snackbar appears and nothing is added
5. The new time is added to the global announceTimes list
6. StorageService saves the updated schedule
7. SchedulerService creates a new repeating daily notification
   for 2:23 PM
8. UI updates to show the new time

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
3. The global schedule is loaded from storage
4. If global is ON, the schedule is rescheduled
   (notifications may have been cleared when app was killed)
5. TTS settings (language, speed, volume) are loaded
   and applied to TtsService
6. Home Screen is displayed with the current state

---

### First Launch
User opens the app for the very first time.

1. App detects no saved data exists
2. Notification permission is requested from the user
3. Background execution permission is requested
4. Default schedule is applied:
   disabled, with no announce times
5. Default TTS settings are applied:
   language matches the device system language
   (falls back to en-US if the system language is
   not supported by the device TTS engine)
   speed is set to normal, volume follows system
6. Default global state is saved as ON
7. Home Screen is displayed

---

## 4.6 Storage Schema

```json
{
  "global_enabled": true,

  "schedule": {
    "isEnabled": true,
    "times": ["9:0", "10:0", "14:23", "17:0"]
  },

  "tts_language":      "system",
  "tts_speed":         0.5,
  "tts_follow_system": true,
  "tts_app_volume":    1.0
}
```

---

## 4.7 Future Architecture (v2.0)

When Firebase is added:

```
LocalStorageService     →  FirebaseStorageService
SharedPreferences       →  Firestore
No auth                 →  Firebase Authentication
Local only              →  Multi-device sync
No privacy policy       →  Privacy policy required
No analytics            →  Firebase Analytics (opt-in)
```

> Per-day scheduling may also be introduced in a future release,
> restructuring `schedule` into a per-weekday map while preserving
> existing global-schedule data (see [4.4 Data Model](#44-data-model)).