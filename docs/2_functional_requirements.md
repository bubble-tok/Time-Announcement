# 2. Functional Requirements

## Table of Contents
- [2.1 Functionality](#21-functionality)
  - [2.1.1 Required Functionality](#211-required-functionality)
  - [2.1.2 Future Extensions](#212-future-extensions)
- [2.2 Scenario Model](#22-scenario-model)
  - [2.2.1 Actor - User](#221-actor---user)
  - [2.2.2 Actor - System](#222-actor---system)
- [2.3 Use Cases](#23-use-cases)
  - [2.3.1 Quick Setup](#231-quick-setup)
  - [2.3.2 Add Time](#232-add-time)
  - [2.3.3 Delete Time](#233-delete-time)
  - [2.3.4 Toggle Day Schedule](#234-toggle-day-schedule)
  - [2.3.5 Global Toggle](#235-global-toggle)
  - [2.3.6 TTS Settings](#236-tts-settings)
  - [2.3.7 First Launch](#237-first-launch)
- [2.4 Activity Diagrams](#24-activity-diagrams)

---

## 2.1 Functionality

### 2.1.1 Required Functionality

#### Time Announcement
The app runs in the background, and at each user-defined time, announces the current time via TTS. The announcement format is "It's 12:23 PM". Announcements fire at the exact hour and minute the user set, and work even when the app is backgrounded or killed.

#### Schedule Management
Each day of the week has an independent schedule. A schedule is simply a list of announce times. Users can:
- Use **Quick Setup** to auto-generate times from a time range and interval
- Add individual times via **+ Add time**
- Delete any time individually via **✕**

There is no mode concept — just a single list of times per day.

#### Global Controls
The app provides a global ON/OFF toggle that instantly silences or restores all announcements. Each day also has its own enable/disable toggle. Turning a day OFF cancels all its scheduled notifications immediately. Turning it back ON reschedules them.

#### TTS Settings
Users can customize the TTS experience through the Settings screen:

| Setting | Options |
|---------|---------|
| Language | en-US |
| Volume | Follow system volume or custom app volume |

#### Data Persistence
All schedules and TTS settings are stored locally on the device using shared_preferences. All data persists after app restart or force kill. On relaunch, all notifications are automatically rescheduled.

#### Permissions
The app requires notification and background execution permissions. On first launch, the app requests these permissions. Permission status is shown in the Settings screen with a direct link to device settings if denied.

---

### 2.1.2 Future Extensions

| Feature | Description |
|---------|-------------|
| Cloud sync | Sync schedules across multiple devices via Firebase |
| Widget | Home screen widget for quick ON/OFF toggle |
| Custom messages | User-defined announcement text instead of time |
| Custom voices | Additional voice packs |

| Setting | Options |
|---------|---------|
| Speech speed | Slow / Normal / Fast |
| Test | Play a sample announcement with current settings |


---

## 2.2 Scenario Model

### 2.2.1 Actor - User

| Field | Detail |
|-------|--------|
| Description | The end user toggles the global ON/OFF to turn the time announcement on and off |
| Aliases | User |
| Actor Type | Person |
| Relationships | Interacts with the global ON/OFF toggle button |

### 2.2.2 Actor - System

| Field | Detail |
|-------|--------|
| Description | The device OS that manages scheduled notifications and triggers TTS announcements at the correct time |
| Aliases | OS, Device |
| Actor Type | External System |
| Relationships | Receives notification schedules from the app and fires them at the correct time |

---

## 2.3 Use Cases

---
### 2.3.1 First Launch

| Field | Detail |
|-------|--------|
| Name | First Launch |
| Primary Actor | User |
| Goal | Set up permissions and default settings on first app launch |
| Preconditions | App is installed and launched for the first time |
| Trigger | User opens the app for the first time |

**Scenario:**
1. App launches for the first time
2. App requests notification permission 
   
   → User grants → continue

   → User denies → show warning banner on Home Screen
3. App requests background execution permission
  
   → User grants → continue
   → User denies → show warning banner on Home Screen
4. Default TTS settings applied:
   
   → Language: match system language
     (Set to en-US)
   
   → Speed: Normal
   
   → Volume: Follow system volume

5. Home Screen displayed

**Alternatives:** 
- User denies all permissions → app still opens but announcements won't work
- User can fix permissions later via Settings Screen

**Exceptions:**
- Permission request dialog fails → retry on next launch
- Default data fails to save → retry on next launch
---

### 2.3.2 Global Toggle

| Field | Detail |
|-------|--------|
| Name | Global Toggle |
| Primary Actor | User |
| Goal | Instantly silence or restore all announcements |
| Preconditions | App is running |
| Trigger | User taps the global toggle on Home Screen |

**Scenario — Toggle OFF:**
1. User taps global toggle → OFF
2. StorageService saves globalEnabled = false
3. SchedulerService cancels ALL notifications across all 7 days
4. UI reflects global OFF state

**Scenario — Toggle ON:**
1. User taps global toggle → ON
2. StorageService saves globalEnabled = true
3. SchedulerService reschedules ALL enabled days and their times
4. UI reflects global ON state

**Exceptions:**
- Storage write fails → state reverted
- Rescheduling fails → user informed via snackbar

---

### 2.4.5 TTS Settings

| Field | Detail |
|-------|--------|
| Name | TTS Settings |
| Primary Actor | User |
| Goal | Customize TTS volume |
| Preconditions | App is running. User pressed volume |
| Trigger | User adjusts volume |

**Scenario:**
1. User opens the app
2. User changes volume
3. StorageService saves new settings
4. TtsService applies new settings immediately

**Exceptions:**
- TTS engine unavailable → error message shown
---

## 2.4 Use Cases (Future Extension)


### 2.4.1 Quick Setup

| Field | Detail |
|-------|--------|
| Name | Quick Setup |
| Primary Actor | User |
| Goal | Auto-generate announce times from a time range and interval |
| Preconditions | App is running. Day schedule screen is open |
| Trigger | User sets From / To / Every and taps Apply |

**Scenario:**
1. User sets From time (e.g. 9:00 AM)
2. User sets To time (e.g. 6:00 PM)
3. User selects interval (30 min / 1 hr / 2 hr / 3 hr)
4. Preview of generated times shown instantly
5. User taps Apply
6. If times already exist → confirmation dialog
   "This will replace your current times. Continue?"
7. generateTimes() creates List\<TimeOfDay\>
8. StorageService saves updated schedule
9. SchedulerService schedules all generated times
10. UI updates to show new times list

**Alternatives:** User cancels → nothing happens

**Exceptions:**
- From time > To time → error "Start time must be before end time"
- From == To → single time generated
- Storage write fails → old data preserved

---

### 2.4.2 Add Time

| Field | Detail |
|-------|--------|
| Name | Add Time |
| Primary Actor | User |
| Goal | Add a specific time to a day's announce schedule |
| Preconditions | App is running. Day schedule screen is open |
| Trigger | User taps "+ Add time" |

**Scenario:**
1. User taps "+ Add time"
2. Native TimePicker opens
3. User selects hour and minute
4. System checks for duplicates → error snackbar if duplicate
5. Time added to announceTimes list
6. StorageService saves updated schedule
7. SchedulerService schedules notification for that time
8. UI updates to show new time

**Alternatives:** User cancels TimePicker → nothing happens

**Exceptions:**
- Duplicate time → error snackbar, time not added
- Storage write fails → old data preserved

---

### 2.4.3 Delete Time

| Field | Detail |
|-------|--------|
| Name | Delete Time |
| Primary Actor | User |
| Goal | Remove a specific time from a day's schedule |
| Preconditions | App is running. At least one announce time exists |
| Trigger | User taps ✕ on a time entry |

**Scenario:**
1. User taps ✕ on a time entry
2. Time removed from announceTimes list
3. StorageService saves updated schedule
4. SchedulerService cancels that notification
5. UI updates to remove the time

**Exceptions:**
- Storage write fails → old data preserved
- Notification cancel fails → logged, user informed

---

### 2.4.4 Toggle Day Schedule

| Field | Detail |
|-------|--------|
| Name | Toggle Day Schedule |
| Primary Actor | User |
| Goal | Enable or disable all announcements for a specific day |
| Preconditions | App is running |
| Trigger | User taps the toggle on a day row |

**Scenario — Toggle OFF:**
1. User taps toggle → OFF
2. StorageService saves isEnabled = false
3. SchedulerService cancels all notifications for that day
4. UI reflects disabled state

**Scenario — Toggle ON:**
1. User taps toggle → ON
2. StorageService saves isEnabled = true
3. SchedulerService reschedules all notifications for that day
4. UI reflects enabled state

**Exceptions:**
- No announce times set → toggle ON has no effect
- Storage write fails → state reverted


---

### 2.4.5 TTS Settings

| Field | Detail |
|-------|--------|
| Name | TTS Settings |
| Primary Actor | User |
| Goal | Customize TTS language, speed, and volume |
| Preconditions | App is running. User is on Settings Screen |
| Trigger | User adjusts any TTS setting |

**Scenario:**
1. User opens Settings Screen
2. User changes language / speed / volume
3. StorageService saves new settings
4. TtsService applies new settings immediately
5. User taps "Test Voice" → "It's 3:00 PM" plays

**Exceptions:**
- Selected language not supported on device → fallback to en-US
- TTS engine unavailable → error message shown
- System language not supported 
  → fallback to en-US automatically
- User can manually override system language in Settings Screen

