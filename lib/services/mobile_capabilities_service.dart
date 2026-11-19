import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

/// Week 8: Mobile Capabilities & Permissions with Fallback Service.
/// Implements justified mobile device capabilities with graceful fallback when permissions
/// or hardware features are denied, restricted, or unavailable.
class MobileCapabilitiesService {
  /// Mobile Capability 1: Direct Phone Dialer with Clipboard Fallback
  /// Used for 112 Emergency and TUL Campus Security (+48 42 631 29 99).
  ///
  /// If phone dialer capability is unavailable or denied by the system/user,
  /// it gracefully copies the number to the system clipboard and displays a helpful SnackBar.
  static Future<void> dialOrCopyEmergencyNumber({
    required BuildContext context,
    required String phoneNumber,
    required String serviceLabel,
  }) async {
    final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^0-9+]'), '');
    final uri = Uri.parse('tel:$cleanNumber');

    try {
      if (await canLaunchUrl(uri)) {
        final launched = await launchUrl(uri);
        if (launched) return;
      }
    } catch (_) {
      // Permission denied or platform has no telephony stack (e.g., tablet, web, desktop)
    }

    // Graceful Fallback: Copy to clipboard and inform the user
    await Clipboard.setData(ClipboardData(text: cleanNumber));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Dialer unavailable. $serviceLabel number ($cleanNumber) copied to clipboard.',
          ),
          action: SnackBarAction(
            label: 'OK',
            onPressed: () {},
          ),
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  /// Mobile Capability 2: Interactive Campus Navigation with Web Browser Fallback
  /// Launches native map applications; falls back safely to web-based Google Maps.
  static Future<void> openMapOrWebFallback({
    required BuildContext context,
    required String query,
    required String placeName,
  }) async {
    final encodedQuery = Uri.encodeComponent(query);
    final webUrl = Uri.parse('https://www.google.com/maps/search/?api=1&query=$encodedQuery');

    try {
      if (await canLaunchUrl(webUrl)) {
        await launchUrl(webUrl, mode: LaunchMode.externalApplication);
        return;
      }
    } catch (_) {}

    // Fallback: Copy coordinates/address to clipboard
    await Clipboard.setData(ClipboardData(text: query));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not open map. Address for $placeName copied to clipboard.'),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}
