# In-App Update System
## Luna — Period Tracker

Luna is distributed as a direct APK (not Play Store initially). This document specifies the full update system that allows users to receive and install updates without leaving the app.

---

## Architecture Overview

```
App opens
    │
    ├─ (500ms delay on background isolate)
    │
    ▼
UpdateService.checkForUpdate()
    │
    ├─ Read last-check timestamp from Hive
    │   └─ If checked < 24h ago AND update is not mandatory → skip
    │
    ├─ GET version.json from hosted URL
    │
    ├─ Compare remote build_number with packageInfo.buildNumber
    │
    └─ If remote > local:
           └─ Emit UpdateAvailable event to UpdateNotifier (Riverpod)
                  └─ App shows UpdateBottomSheet
```

---

## Manifest Hosting

**Recommended host: GitHub Releases**

URL pattern:
```
https://raw.githubusercontent.com/[username]/luna/main/update/version.json
```

Or pin to a Firebase Hosting URL for stability:
```
https://luna-app.web.app/update/version.json
```

Keep the URL in one place — `core/constants/app_strings.dart`:
```dart
// core/constants/app_strings.dart
class AppUrls {
  static const updateManifestUrl =
      'https://raw.githubusercontent.com/yourname/luna/main/update/version.json';
}
```

### version.json format

```json
{
  "version_name": "1.2.0",
  "build_number": 12,
  "apk_url": "https://github.com/yourname/luna/releases/download/v1.2.0/luna-v1.2.0.apk",
  "apk_size_mb": 42,
  "release_notes": {
    "en": "• More accurate cycle predictions\n• Hindi keyboard improvements\n• Reduced battery usage",
    "hi": "• बेहतर चक्र भविष्यवाणी\n• हिंदी कीबोर्ड में सुधार\n• बैटरी उपयोग कम हुआ"
  },
  "is_mandatory": false,
  "min_android_sdk": 26
}
```

**Field notes:**
- `build_number` — compared against `packageInfo.buildNumber` (integer). Version name is only for display.
- `is_mandatory: true` — dialog cannot be dismissed. Use only for critical security patches or breaking schema migrations.
- `apk_size_mb` — shown in the dialog so users on limited data know what they're downloading.
- `min_android_sdk` — if device SDK is below this, update dialog is suppressed (the new APK won't install anyway).

---

## Packages Required

Add to `pubspec.yaml`:
```yaml
dependencies:
  package_info_plus: ^8.0.0   # current version/build number
  dio: ^5.5.0                  # file download with progress
  open_filex: ^1.3.4           # trigger Android install dialog
  # path_provider already listed
```

---

## Android Manifest Changes

`android/app/src/main/AndroidManifest.xml`:

```xml
<!-- Required for sideloading: install packages from unknown sources (Android 8+) -->
<uses-permission android:name="android.permission.REQUEST_INSTALL_PACKAGES" />

<!-- Required for writing the APK to external storage (Android ≤ 9) -->
<uses-permission
    android:name="android.permission.WRITE_EXTERNAL_STORAGE"
    android:maxSdkVersion="28" />

<!-- Inside <application> tag: -->
<!-- FileProvider — required to share the downloaded file with the system installer -->
<provider
    android:name="androidx.core.content.FileProvider"
    android:authorities="${applicationId}.fileprovider"
    android:exported="false"
    android:grantUriPermissions="true">
    <meta-data
        android:name="android.support.FILE_PROVIDER_PATHS"
        android:resource="@xml/file_paths" />
</provider>
```

`android/app/src/main/res/xml/file_paths.xml` (create this file):
```xml
<?xml version="1.0" encoding="utf-8"?>
<paths>
    <external-files-path
        name="apk_downloads"
        path="Downloads/" />
</paths>
```

---

## Flutter Implementation

### UpdateInfo Entity

```dart
// domain/entities/update_info.dart

class UpdateInfo {
  final String versionName;
  final int buildNumber;
  final String apkUrl;
  final double apkSizeMb;
  final Map<String, String> releaseNotes;  // locale code → text
  final bool isMandatory;

  const UpdateInfo({
    required this.versionName,
    required this.buildNumber,
    required this.apkUrl,
    required this.apkSizeMb,
    required this.releaseNotes,
    required this.isMandatory,
  });

  String notesFor(String locale) =>
      releaseNotes[locale] ?? releaseNotes['en'] ?? '';
}
```

### UpdateService

```dart
// data/remote/update_service.dart

import 'dart:io';
import 'package:dio/dio.dart';
import 'package:open_filex/open_filex.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';

class UpdateService {
  final Dio _dio;
  final String _manifestUrl;

  UpdateService(this._dio, this._manifestUrl);

  // Returns UpdateInfo if an update is available, null otherwise.
  // Throws on network error — caller handles silently.
  Future<UpdateInfo?> checkForUpdate({bool ignoreCooldown = false}) async {
    final info = await PackageInfo.fromPlatform();
    final currentBuild = int.parse(info.buildNumber);

    final response = await _dio.get<Map<String, dynamic>>(_manifestUrl);
    final remote = response.data!;
    final remoteBuild = remote['build_number'] as int;

    if (remoteBuild <= currentBuild) return null;

    return UpdateInfo(
      versionName:  remote['version_name'] as String,
      buildNumber:  remoteBuild,
      apkUrl:       remote['apk_url'] as String,
      apkSizeMb:    (remote['apk_size_mb'] as num).toDouble(),
      releaseNotes: Map<String, String>.from(remote['release_notes'] as Map),
      isMandatory:  remote['is_mandatory'] as bool,
    );
  }

  // Downloads APK and triggers Android install dialog.
  // [onProgress] receives 0.0 → 1.0.
  Future<void> downloadAndInstall(
    UpdateInfo update, {
    required void Function(double) onProgress,
    required CancelToken cancelToken,
  }) async {
    final dir = await getExternalStorageDirectory();
    final path = '${dir!.path}/luna-update.apk';

    await _dio.download(
      update.apkUrl,
      path,
      cancelToken: cancelToken,
      onReceiveProgress: (received, total) {
        if (total > 0) onProgress(received / total);
      },
    );

    await OpenFilex.open(path);
  }
}
```

### Riverpod Provider

```dart
// presentation/providers/update_provider.dart

@riverpod
class UpdateNotifier extends _$UpdateNotifier {
  static const _cooldownKey = 'last_update_check';

  @override
  Future<UpdateInfo?> build() async {
    // Run check 500ms after app opens — never blocks the UI
    await Future.delayed(const Duration(milliseconds: 500));

    final hive = ref.read(hiveBoxProvider);
    final lastCheck = hive.get(_cooldownKey, defaultValue: 0) as int;
    final now = DateTime.now().millisecondsSinceEpoch;
    final cooldownMs = 24 * 60 * 60 * 1000; // 24 hours

    UpdateInfo? update;
    try {
      update = await ref.read(updateServiceProvider).checkForUpdate();
    } catch (_) {
      return null; // Network error — fail silently
    }

    // Respect 24h cooldown for optional updates
    if (update != null &&
        !update.isMandatory &&
        (now - lastCheck) < cooldownMs) {
      return null;
    }

    if (update != null) {
      hive.put(_cooldownKey, now);
    }

    return update;
  }
}
```

### UpdateBottomSheet UI

```dart
// presentation/widgets/update_bottom_sheet.dart
//
// Called from app.dart whenever updateNotifierProvider has a non-null value:
//
//   ref.listen(updateNotifierProvider, (_, next) {
//     next.whenData((update) {
//       if (update != null) _showUpdateSheet(context, update);
//     });
//   });
//
// Mandatory updates: PopScope(canPop: false) + no "Later" button
// Optional updates: "Later" dismisses for this session (not 24h — notifier already handles that)

class UpdateBottomSheet extends StatefulWidget {
  final UpdateInfo update;
  const UpdateBottomSheet({super.key, required this.update});
  ...
}
```

**UI elements:**
- Luna logo + "Update available" headline
- Version name + size ("v1.2.0 · 42 MB")
- Release notes (locale-aware, scrollable if long)
- Download progress bar (0–100%, hidden until download starts)
- "Download & Install" filled button → starts download, morphs to progress bar
- "Later" text button (hidden for mandatory updates)
- Cancel button appears during download (optional updates only)

---

## Release Workflow (for you, the developer)

When you're ready to release a new version:

1. Increment `version` and `build_number` in `pubspec.yaml`
2. Run `flutter build apk --release`
3. Upload `build/app/outputs/flutter-apk/app-release.apk` to GitHub Releases as `luna-v{version}.apk`
4. Update `version.json` with the new version, build number, APK URL, and release notes
5. Commit `version.json` to the repo (or upload to Firebase Hosting)

Users who open the app within 24 hours will see the update dialog automatically.

---

## File Location in Project

```
lib/
├── domain/
│   └── entities/
│       └── update_info.dart
├── data/
│   └── remote/
│       └── update_service.dart
└── presentation/
    ├── providers/
    │   └── update_provider.dart
    └── widgets/
        └── update_bottom_sheet.dart

android/
├── app/src/main/
│   ├── AndroidManifest.xml    ← add permission + provider
│   └── res/xml/
│       └── file_paths.xml     ← create this

update/
└── version.json               ← hosted on GitHub / Firebase (not in app bundle)
```
