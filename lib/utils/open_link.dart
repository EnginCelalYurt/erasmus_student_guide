import 'package:url_launcher/url_launcher.dart';

Future<bool> openLink(String raw) async {
  final uri = Uri.parse(raw);
  return launchUrl(uri, mode: LaunchMode.externalApplication);
}
