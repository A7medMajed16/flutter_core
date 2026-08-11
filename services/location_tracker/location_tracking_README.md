# 📍 Background Location Tracking Module

A **fully free**, battery-efficient background location tracking system for Flutter. Works on both **Android** and **iOS**, including when the screen is locked. Fires a callback only when the driver moves ≥ a configurable distance threshold.

---

## 🗂️ Files Overview

| File | Role |
|---|---|
| `lib/core/services/location_service.dart` | Core singleton service — manages permissions, streams, persistence |
| `lib/core/services/location_task_handler.dart` | Android foreground task handler — keeps the process alive |
| `lib/core/utils/constants/location_constants.dart` | Tunable thresholds for distance and intervals |

---

## 📦 Dependencies

Add to your `pubspec.yaml`:

```yaml
dependencies:
  geolocator: ^14.0.2              # GPS stream
  flutter_foreground_task: ^9.2.2  # Android background keep-alive
  geocoding: ^4.0.0                # Reverse geocoding (optional helper)
  latlong2: ^0.9.1                 # LatLng type
  injectable: ^2.0.0               # DI (lazySingleton)
  shared_preferences: any          # For persisting the last logged point
  dartz: any                       # Either / functional error handling
```

---

## ⚙️ `location_constants.dart`

Tune these values to control battery usage vs. accuracy:

```dart
abstract class LocationConstants {
  static const double minDistanceMeters = 100.0; // App-level filter: only log if moved ≥ this
  static const int locationIntervalMs   = 10000;  // Android: how often to poll (10s)
  static const int fastestIntervalMs    = 5000;   // Android: fastest accepted rate (5s)
  static const double distanceFilterMeters = 50.0; // OS-level pre-filter (saves battery)
}
```

> **Tip:** `distanceFilterMeters` is the OS-level filter passed to Geolocator — the OS will not even wake your app until the device moves this far. `minDistanceMeters` is your own second-layer check in Dart. Set `distanceFilterMeters` ≤ `minDistanceMeters` so you never miss a threshold crossing.

---

## 🔧 `location_task_handler.dart`

Android only. The foreground task keeps your Dart isolate alive even when the OS would otherwise suspend it.

```dart
import 'dart:async';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';

// REQUIRED annotation — must be top-level and annotated with @pragma
@pragma('vm:entry-point')
void startCallback() {
  FlutterForegroundTask.setTaskHandler(LocationTaskHandler());
}

class LocationTaskHandler extends TaskHandler {
  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {}

  @override
  void onRepeatEvent(DateTime timestamp) {
    // Geolocator handles updates — this just keeps the process alive.
  }

  @override
  Future<void> onDestroy(DateTime timestamp, bool foreground) async {}
}
```

> **Important:** `startCallback` **must be top-level** (not inside a class) and annotated `@pragma('vm:entry-point')`. Without this, Android will crash when starting the background task.

---

## 🧠 `location_service.dart` — Public API

```dart
final locationService = getIt<LocationService>();

// Start tracking (handles permissions internally)
final result = await locationService.startTracking();
result.fold(
  (failure) => print(failure.errorMessage), // permission denied, GPS off, etc.
  (_) => print('Tracking started'),
);

// Stop tracking (cancels stream + Android foreground service)
await locationService.stopTracking();

// Listen to filtered updates (fires ONLY when driver moves ≥ minDistanceMeters)
locationService.loggedPositionStream.listen((position) {
  print('${position.latitude}, ${position.longitude}');
});

// One-shot current location (handles permissions)
final pos = await locationService.getCurrentLocation();

// Reverse geocode a coordinate (static, no instance needed)
final address = await LocationService.getAddressTitle(lat, lng);

// Check tracking state
print(locationService.isTracking); // true / false

// Clean up (call on cubit close or app exit)
await locationService.dispose();
```

---

## 🤖 Android Setup

### `android/app/src/main/AndroidManifest.xml`

Add these permissions **before** the `<application>` tag:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">

    <!-- Required for GPS -->
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />

    <!-- Required for background/locked-screen GPS (Android 10+) -->
    <uses-permission android:name="android.permission.ACCESS_BACKGROUND_LOCATION" />

    <!-- Required to run a foreground service -->
    <uses-permission android:name="android.permission.FOREGROUND_SERVICE" />

    <!-- Required specifically for location foreground services (Android 14+) -->
    <uses-permission android:name="android.permission.FOREGROUND_SERVICE_LOCATION" />

    <!-- Required to show the foreground service notification (Android 13+) -->
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS" />

    <application ...>
      ...
    </application>
</manifest>
```

> **Warning:** `ACCESS_BACKGROUND_LOCATION` triggers a Play Store review. You must justify its use in the Data Safety form. For a driver tracking app, this is expected and acceptable.

> **Note:** `FOREGROUND_SERVICE_LOCATION` is required from **Android 14 (API 34)**. Without it, `startForegroundService()` throws a `SecurityException` on Android 14+ devices.

> **Note:** `flutter_foreground_task` registers its own `<service>` automatically — you do **not** need to add a `<service>` tag manually.

---

## 🍎 iOS Setup

### 1. `ios/Runner/Info.plist`

Add these keys inside the root `<dict>`:

```xml
<!-- Shown to user when requesting "When In Use" -->
<key>NSLocationWhenInUseUsageDescription</key>
<string>We need your location to track delivery routes.</string>

<!-- Shown to user when requesting "Always" (locked-screen tracking) -->
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>We need your location in the background to keep tracking your route.</string>

<!-- Background execution modes -->
<key>UIBackgroundModes</key>
<array>
    <string>location</string>             <!-- Enables CLLocationManager background updates -->
    <string>fetch</string>                <!-- Enables background fetch -->
    <string>processing</string>           <!-- Enables BGTaskScheduler -->
    <string>remote-notification</string>
</array>

<!-- Required for flutter_foreground_task BGTaskScheduler -->
<key>BGTaskSchedulerPermittedIdentifiers</key>
<array>
    <string>com.pravera.flutter_foreground_task.refresh</string>
</array>
```

> **Critical:** `location` inside `UIBackgroundModes` is mandatory. Without it, `allowBackgroundLocationUpdates: true` in `AppleSettings` has **no effect** — iOS stops delivering GPS events the moment the app backgrounds.

### 2. Xcode — Enable Background Modes Capability

Edit `Info.plist` alone is not enough for production/TestFlight builds. You must also enable the capability in Xcode:

1. Open `ios/Runner.xcworkspace` in **Xcode**
2. Select the **Runner** target → **Signing & Capabilities** tab
3. Click **`+` Capability** → search **"Background Modes"** → add it
4. Check the following modes:
   - ✅ **Location updates**
   - ✅ **Background fetch**
   - ✅ **Remote notifications**
   - ✅ **Background processing**

> **Warning:** Skipping the Xcode capability step can cause your app to work in debug but **fail background location delivery in TestFlight/App Store** builds due to missing entitlements.

### 3. iOS Permission Flow

The service requests permissions automatically in two steps:

1. **First request** → "While Using the App" dialog appears
2. **Second request** → "Change to Always Allow?" prompt appears

The user **must grant "Always Allow"** for GPS to continue when the screen is locked. If they grant only "While Using", GPS will suspend a few minutes after the screen locks.

---

## 🔌 Integration Guide

### Step 1 — DI Registration

`LocationService` uses `@lazySingleton`. With `get_it` + `injectable`, it registers automatically after `build_runner`. No extra setup needed.

### Step 2 — Start tracking after login

Call `startTracking()` from the first screen after authentication:

```dart
// In your HomeCubit or LayoutCubit
final result = await getIt<LocationService>().startTracking();
result.fold(
  (failure) => AppLogger.error(failure.errorMessage),
  (_) => AppLogger.success('Tracking started'),
);
```

### Step 3 — Wire the stream to your API call

```dart
StreamSubscription<Position>? _locationStreamSubscription;

void _subscribeToLocationStream() {
  _locationStreamSubscription?.cancel(); // guard: never double-subscribe
  _locationStreamSubscription = getIt<LocationService>()
      .loggedPositionStream
      .listen((position) {
    // Your API call or DB write here
    _updateLocationUseCase(UpdateLocationParam(
      location: LatLng(position.latitude, position.longitude),
    ));
  });
}

void _cancelLocationStreamSubscription() {
  _locationStreamSubscription?.cancel();
  _locationStreamSubscription = null;
}

@override
Future<void> close() {
  _cancelLocationStreamSubscription();
  return super.close();
}
```

### Step 4 — Stop tracking on logout

```dart
// On manual logout button
getIt<LocationService>().stopTracking();

// Also add to your Dio interceptor's _forceLogout() for token expiry/403
void _forceLogout() {
  getIt<LocationService>().stopTracking();
  UserHelper.clearUserData();
}
```

### Step 5 — Respect driver "active" status

Only start tracking if the driver is marked as available:

```dart
if (profile.active == true) {
  getIt<LocationService>().startTracking();
  _subscribeToLocationStream();
} else {
  _cancelLocationStreamSubscription();
  getIt<LocationService>().stopTracking();
}
```

---

## 📊 Platform Behavior Matrix

| App State | Screen State | Permission | Result |
|---|---|---|---|
| Foreground | On | When In Use | ✅ Tracks |
| Background | On | When In Use | ✅ Tracks |
| Background | **Locked** | When In Use | ⚠️ May suspend after a few minutes |
| Background | **Locked** | **Always Allow** | ✅ Tracks |
| Force-killed by user (swipe up) | Any | Any | ❌ Stops — cannot recover |
| Killed by OS memory pressure | Any | Always | ⚠️ iOS may re-launch via significant location change |

---

## 🔁 Data Flow Diagram

```
Driver moves
      │
      ▼ (OS GPS event, filtered by distanceFilterMeters)
LocationService._onPositionUpdate(position)
      │
      ▼ (_shouldLog: checks ≥ minDistanceMeters with Geolocator.distanceBetween)
_saveLastLoggedPosition()  ──►  SharedPreferences (persists across restarts)
      │
      ▼
loggedPositionStream.add(position)  ──►  broadcast stream
      │
      ▼ (your listener)
API call (updateLocation) / local DB write
```

---

## 🛠️ Troubleshooting

| Symptom | Likely Cause | Fix |
|---|---|---|
| No blue pill/arrow on iPhone | `allowBackgroundLocationUpdates: false` or missing `UIBackgroundModes: location` | Verify `AppleSettings` and `Info.plist` |
| Stops tracking on locked screen | Only "While Using" permission granted | User must grant "Always Allow" in Settings |
| Crashes on Android 14 | Missing `FOREGROUND_SERVICE_LOCATION` | Add permission to `AndroidManifest.xml` |
| No updates at all on Android | Foreground service not started, or missing permissions | Check manifest and `startService()` call |
| Updates stop after a while (Android) | Battery optimization killing the service | Ask user to disable battery optimization for the app |
| `startCallback` crash | Not annotated `@pragma('vm:entry-point')` or not top-level | Fix annotation and function placement |
| Distance threshold not working | `distanceFilterMeters` > `minDistanceMeters` | Set OS filter ≤ app-level threshold |
| Last position not persisted across restarts | `_loadLastLoggedPosition()` not called in `startTracking()` | Ensure it's called before subscribing to the stream |
