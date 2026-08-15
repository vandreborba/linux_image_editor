import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UpdateCheckResult {
  final bool hasUpdate;
  final String currentVersion;
  final String? latestVersion;
  final String releasesUrl;
  final bool networkError;

  const UpdateCheckResult({
    required this.hasUpdate,
    required this.currentVersion,
    this.latestVersion,
    required this.releasesUrl,
    this.networkError = false,
  });
}

class UpdateService {
  static const String repo = 'vandreborba/linux_image_editor';
  static const String releasesUrl =
      'https://github.com/vandreborba/linux_image_editor/releases/latest';

  static const String _keyDismissedVersion = 'update_dismissed_version';
  static const String _keyNotificationsDisabled =
      'update_notifications_disabled';

  Future<UpdateCheckResult> checkForUpdate() async {
    final packageInfo = await PackageInfo.fromPlatform();
    final currentVersion = packageInfo.version;

    try {
      final response = await http.get(
        Uri.parse('https://api.github.com/repos/$repo/releases/latest'),
        headers: {'User-Agent': 'linux-image-editor'},
      );

      if (response.statusCode != 200) {
        return UpdateCheckResult(
          hasUpdate: false,
          currentVersion: currentVersion,
          releasesUrl: releasesUrl,
          networkError: true,
        );
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final tagName = data['tag_name'] as String? ?? '';
      final latestVersion = tagName.startsWith('v')
          ? tagName.substring(1)
          : tagName;

      if (latestVersion.isEmpty) {
        return UpdateCheckResult(
          hasUpdate: false,
          currentVersion: currentVersion,
          releasesUrl: releasesUrl,
          networkError: true,
        );
      }

      final hasUpdate = isVersionGreater(latestVersion, currentVersion);

      return UpdateCheckResult(
        hasUpdate: hasUpdate,
        currentVersion: currentVersion,
        latestVersion: latestVersion,
        releasesUrl: releasesUrl,
      );
    } catch (_) {
      return UpdateCheckResult(
        hasUpdate: false,
        currentVersion: currentVersion,
        releasesUrl: releasesUrl,
        networkError: true,
      );
    }
  }

  Future<bool> shouldShowAutomaticNotification(UpdateCheckResult result) async {
    if (!result.hasUpdate || result.latestVersion == null) {
      return false;
    }

    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_keyNotificationsDisabled) ?? false) {
      return false;
    }

    final dismissed = prefs.getString(_keyDismissedVersion);
    if (dismissed == result.latestVersion) {
      return false;
    }

    return true;
  }

  Future<void> dismissForVersion(String version) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyDismissedVersion, version);
  }

  Future<void> disableNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyNotificationsDisabled, true);
  }

  Future<void> reenableNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyNotificationsDisabled, false);
  }

  Future<bool> isNotificationsDisabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyNotificationsDisabled) ?? false;
  }

  static bool isVersionGreater(String a, String b) {
    final partsA = _parseVersionParts(a);
    final partsB = _parseVersionParts(b);

    for (var i = 0; i < 3; i++) {
      final ai = i < partsA.length ? partsA[i] : 0;
      final bi = i < partsB.length ? partsB[i] : 0;
      if (ai > bi) return true;
      if (ai < bi) return false;
    }
    return false;
  }

  static List<int> _parseVersionParts(String version) {
    return version.split('.').map((part) {
      final match = RegExp(r'^\d+').firstMatch(part);
      return match != null ? int.parse(match.group(0)!) : 0;
    }).toList();
  }
}
