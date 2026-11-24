import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import '../models/tip.dart';

enum ShareOutcome { shared, copiedToClipboard }

typedef ShareTextFn = Future<ShareResultStatus> Function(
  String text, {
  String? subject,
});

/// Formats a [Tip] into a human-readable message for sharing or copying.
String formatTipForSharing(Tip tip) {
  return '${tip.title} (${tip.category.label})\n\n'
      '${tip.body}\n\n'
      '— Shared via Erasmus Student Guide (TUL)';
}

/// Shares [tip] to other apps using the platform share sheet, falling back to
/// copying the formatted text to the clipboard if sharing is unavailable.
Future<ShareOutcome> shareTip(
  Tip tip, {
  ShareTextFn? shareFn,
}) async {
  final text = formatTipForSharing(tip);
  final doShare = shareFn ??
      (String t, {String? subject}) async {
        final result = await SharePlus.instance.share(
          ShareParams(text: t, subject: subject),
        );
        return result.status;
      };
  try {
    final status = await doShare(text, subject: tip.title);
    if (status == ShareResultStatus.unavailable) {
      await Clipboard.setData(ClipboardData(text: text));
      return ShareOutcome.copiedToClipboard;
    }
    return ShareOutcome.shared;
  } catch (_) {
    await Clipboard.setData(ClipboardData(text: text));
    return ShareOutcome.copiedToClipboard;
  }
}
