import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:open_filex/open_filex.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import '../../domain/entities/update_info.dart';

// version.json lives in the public luna-releases repo — source code stays private.
// Replace YOUR_USERNAME with your actual GitHub username.
const _kVersionJsonUrl =
    'https://raw.githubusercontent.com/sachin-19/luna-releases/main/version.json';

class UpdateService {
  UpdateService() : _dio = Dio();

  final Dio _dio;

  /// Fetch remote version manifest. Returns null on network error.
  Future<UpdateInfo?> fetchUpdateInfo() async {
    try {
      // Fetch as String — raw.githubusercontent.com returns text/plain, so Dio
      // won't auto-decode JSON. We decode manually.
      final response = await _dio.get<String>(
        _kVersionJsonUrl,
        options: Options(receiveTimeout: const Duration(seconds: 10)),
      );
      if (response.data == null) return null;
      final json = jsonDecode(response.data!) as Map<String, dynamic>;
      return UpdateInfo.fromJson(json);
    } catch (_) {
      return null;
    }
  }

  /// True if [remoteVersion] is newer than the installed version.
  Future<bool> isUpdateAvailable(String remoteVersion) async {
    final info = await PackageInfo.fromPlatform();
    return _isNewer(remoteVersion, info.version);
  }

  /// Download APK to the external downloads directory and trigger install.
  /// Calls [onProgress] with 0.0–1.0.
  Future<void> downloadAndInstall(
    UpdateInfo update, {
    required void Function(double) onProgress,
  }) async {
    final dir = await getExternalStorageDirectory();
    final savePath = '${dir!.path}/luna_update.apk';

    await _dio.download(
      update.downloadUrl,
      savePath,
      onReceiveProgress: (received, total) {
        if (total > 0) onProgress(received / total);
      },
    );

    await OpenFilex.open(savePath);
  }

  /// Compare semver strings — returns true if [remote] > [current].
  static bool _isNewer(String remote, String current) {
    final r = _parse(remote);
    final c = _parse(current);
    for (var i = 0; i < 3; i++) {
      if (r[i] > c[i]) return true;
      if (r[i] < c[i]) return false;
    }
    return false;
  }

  static List<int> _parse(String v) {
    final parts = v.split('.');
    return List.generate(3, (i) => i < parts.length ? int.tryParse(parts[i]) ?? 0 : 0);
  }
}
