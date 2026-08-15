import 'dart:io';

class DefaultAppResult {
  final bool success;
  final String? errorMessage;

  const DefaultAppResult({required this.success, this.errorMessage});
}

class DefaultAppService {
  static const String desktopFile = 'linux-image-editor.desktop';
  static const String desktopPath =
      '/usr/share/applications/linux-image-editor.desktop';
  static const String installedScriptPath =
      '/opt/linux-image-editor/set-default.sh';

  static const List<String> mimeTypes = [
    'image/png',
    'image/jpeg',
    'image/jpg',
    'image/bmp',
    'image/gif',
    'image/webp',
    'image/tiff',
    'image/svg+xml',
    'image/x-bmp',
    'image/x-png',
    'image/x-ico',
  ];

  bool get isLinux => Platform.isLinux;

  Future<bool> isInstalled() async {
    if (!isLinux) return false;
    return File(desktopPath).exists();
  }

  Future<DefaultAppResult> setAsDefaultImageViewer() async {
    if (!isLinux) {
      return const DefaultAppResult(
        success: false,
        errorMessage: 'not_linux',
      );
    }

    if (!await isInstalled()) {
      return const DefaultAppResult(
        success: false,
        errorMessage: 'not_installed',
      );
    }

    final script = File(installedScriptPath);
    if (script.existsSync()) {
      final result = await Process.run('bash', [installedScriptPath]);
      if (result.exitCode == 0) {
        return const DefaultAppResult(success: true);
      }
    }

    for (final mimeType in mimeTypes) {
      final result = await Process.run('xdg-mime', [
        'default',
        desktopFile,
        mimeType,
      ]);
      if (result.exitCode != 0) {
        return DefaultAppResult(
          success: false,
          errorMessage: 'xdg_mime_failed',
        );
      }
    }

    return const DefaultAppResult(success: true);
  }
}
