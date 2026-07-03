# 3. Non-Functional Requirements

## Table of Contents
- [3.1 Performance](#31-performance)
- [3.2 Reliability](#32-reliability)
- [3.3 Usability](#33-usability)
- [3.4 Compatibility](#34-compatibility)
- [3.5 Maintainability](#35-maintainability)
- [3.6 Security](#36-security)
- [3.7 Accessibility](#37-accessibility)

---

## 3.1 Performance

- App shall launch and display Home Screen within 2 seconds
- TTS announcement shall begin within 1 second of scheduled time
- App shall not run continuous background processes
---

## 3.2 Reliability

## 3.2 Reliability

- All scheduled announcements shall fire at exact time even when app is killed
- All data shall persist after app restart or force kill
- All notifications shall be rescheduled automatically on app relaunch
- App shall not crash on any supported OS version
- Schedule changes shall not result in duplicate notifications
- App shall handle missing or corrupted data gracefully with default fallback
- Changing the global schedule shall apply consistently across all days
---

## 3.3 Usability

- New user shall be able to set up first announcement within 1 minute
- Global ON/OFF toggle shall be reachable within 1 tap from Home Screen
- All error messages shall be clear and actionable
- Quick Setup shall preview generated times before applying
- Replacing existing times via Quick Setup shall warn user before clearing
- Permission denied state shall provide direct link to device settings
- App shall display last announced time on Home Screen
- App shall support migration from global to per-day scheduling in a future update without data loss

---

## 3.4 Compatibility

- App shall support Android 8.0 (API 26) and above
- App shall support iOS 13.0 and above
- App shall support both phone and tablet screen sizes
- App shall support both light and dark mode
- App shall function correctly after OS timezone change
- App shall function correctly after DST transition

---

## 3.5 Maintainability

- Code shall follow clean architecture (models / services / triggers / screens / widgets)
- StorageService shall be abstract to allow future backend swap (e.g. Firebase)
- All services shall be independently testable
- Code shall follow Dart/Flutter style guidelines
- All public methods shall have documentation comments
- No hardcoded strings — all user-facing text in constants file

---

## 3.6 Security

### v1.0 (Local Storage)
- All data stored locally — no user data sent to external servers
- App shall only request necessary permissions (notifications, background)
- App shall not collect or transmit any personal data
- No third-party analytics or tracking SDKs included in v1.0

### v2.0 (Firebase — Future)
- All data transmitted to Firebase shall be encrypted via HTTPS
- Firebase Authentication required before accessing user data
- Firestore security rules shall restrict each user to their own data only
- No other users' data shall be accessible
- Firebase Analytics may be added with user consent only
- Privacy policy shall be updated before v2.0 release
- App Store / Google Play privacy disclosure shall be updated accordingly

---

## 3.7 Accessibility

- App shall be compatible with iOS VoiceOver and Android TalkBack
- All interactive elements shall have descriptive labels
- Toggle states shall be announced by screen readers
- Color shall not be the only indicator of state
- Minimum touch target size: 44x44 points

---

## 3.8 Localization

- App UI language shall match system language where supported
- Supported UI languages for v1.0: English only
- TTS language shall match system language by default
- If system language not supported by device TTS engine → fallback to en-US
- User can manually override TTS language in Settings Screen
- All user-facing strings shall be stored in constants file
  to support future localization without code changes

### TTS Language Support
> flutter_tts uses the device's native TTS engine.
> Supported languages vary by device and OS version.
> The app dynamically loads available languages from the device
> using flutterTts.getLanguages at runtime.

> Note: We will use en-US for now. Adding languages would be included in the future extensions.


Common languages typically available on most devices:
| Language | Code |
|----------|------|
| English (US) | en-US |
