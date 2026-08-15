import 'package:flutter/material.dart';
import 'package:linux_image_editor/l10n/app_localizations.dart';
import 'package:linux_image_editor/services/update_service.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> showAppAboutDialog({
  required BuildContext context,
  required String version,
  required UpdateService updateService,
}) async {
  final l10n = AppLocalizations.of(context)!;
  final notificationsDisabled = await updateService.isNotificationsDisabled();
  if (!context.mounted) return;

  await showDialog<void>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: Text(l10n.aboutDialogTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.appTitle),
            const SizedBox(height: 8),
            Text(l10n.aboutVersionLabel(version)),
            const SizedBox(height: 16),
            InkWell(
              onTap: () => _openReleasesPage(),
              child: Text(
                l10n.aboutReleasesLink,
                style: TextStyle(
                  color: Theme.of(dialogContext).colorScheme.primary,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            if (notificationsDisabled) ...[
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () async {
                  await updateService.reenableNotifications();
                  if (dialogContext.mounted) {
                    Navigator.of(dialogContext).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.aboutNotificationsReenabled)),
                    );
                  }
                },
                child: Text(l10n.aboutReenableNotifications),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l10n.okButtonLabel),
          ),
        ],
      );
    },
  );
}

Future<void> openReleasesPage() => _openReleasesPage();

Future<void> _openReleasesPage() async {
  final uri = Uri.parse(UpdateService.releasesUrl);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
