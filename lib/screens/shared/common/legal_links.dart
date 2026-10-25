import 'package:flutter/gestures.dart';
import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:nahpu/services/localization/l10n.dart';

/// Where the published legal documents live.
///
/// NAHPU links to the website rather than bundling a copy. The documents are
/// revised when features or third-party services change, and a bundled copy
/// left behind by an old install would be worse than no copy at all.
const String nahpuTermsUrl = 'https://nahpu.app/en/terms/';
const String nahpuPrivacyUrl = 'https://nahpu.app/en/privacy/';

/// Opens a legal document in the system browser.
Future<void> launchLegalUrl(String url) async {
  final Uri uri = Uri.parse(url);
  if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
    throw FormatException('Could not open $uri');
  }
}

/// Points a new user at the Terms and Privacy Policy before they set up.
///
/// This sits ahead of the setup action on the home screen so it is read
/// before the first project exists, not after a field season of records.
class LegalNotice extends StatefulWidget {
  const LegalNotice({super.key});

  @override
  State<LegalNotice> createState() => _LegalNoticeState();
}

class _LegalNoticeState extends State<LegalNotice> {
  late final TapGestureRecognizer _termsRecognizer;
  late final TapGestureRecognizer _privacyRecognizer;

  @override
  void initState() {
    super.initState();
    _termsRecognizer = TapGestureRecognizer()
      ..onTap = () => launchLegalUrl(nahpuTermsUrl);
    _privacyRecognizer = TapGestureRecognizer()
      ..onTap = () => launchLegalUrl(nahpuPrivacyUrl);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final baseStyle = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    final linkStyle = baseStyle?.copyWith(
      color: theme.colorScheme.primary,
      decoration: TextDecoration.underline,
      decorationColor: theme.colorScheme.primary,
    );
    return Text.rich(
      TextSpan(
        style: baseStyle,
        children: [
          TextSpan(text: context.l10n.legalReadThe),
          TextSpan(
            text: context.l10n.legalTermsAndConditions,
            style: linkStyle,
            recognizer: _termsRecognizer,
          ),
          TextSpan(text: context.l10n.legalAndThe),
          TextSpan(
            text: context.l10n.legalPrivacyPolicy,
            style: linkStyle,
            recognizer: _privacyRecognizer,
          ),
          TextSpan(text: context.l10n.legalBeforeYouStart),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }

  @override
  void dispose() {
    _termsRecognizer.dispose();
    _privacyRecognizer.dispose();
    super.dispose();
  }
}

/// Opens the Terms and Conditions on the NAHPU website.
class TermsTile extends StatelessWidget {
  const TermsTile({super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.gavel_outlined),
      title: Text(context.l10n.legalTermsTile),
      onTap: () => launchLegalUrl(nahpuTermsUrl),
    );
  }
}

/// Opens the Privacy Policy on the NAHPU website.
class PrivacyPolicyTile extends StatelessWidget {
  const PrivacyPolicyTile({super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.privacy_tip_outlined),
      title: Text(context.l10n.legalPrivacyTile),
      onTap: () => launchLegalUrl(nahpuPrivacyUrl),
    );
  }
}
