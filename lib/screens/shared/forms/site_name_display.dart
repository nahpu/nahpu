import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nahpu/screens/shared/layout/layout.dart';
import 'package:nahpu/services/database/database.dart';
import 'package:nahpu/services/providers/sites.dart';
import 'package:nahpu/styles/design_tokens.dart';

class SiteNameDisplay extends ConsumerWidget {
  const SiteNameDisplay({super.key, required this.siteId});

  final int? siteId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (siteId == null) {
      return const SizedBox.shrink();
    }

    return ref
        .watch(siteEntryProvider)
        .maybeWhen(
          data: (sites) {
            final matches = sites.where((site) => site.id == siteId);
            if (matches.isEmpty) {
              return const SizedBox.shrink();
            }

            final siteName = _formatSiteName(matches.first);
            if (siteName.isEmpty) {
              return const SizedBox.shrink();
            }

            final theme = Theme.of(context);
            return CommonPadding(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: NahpuSpacing.sm),
                child: SizedBox(
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Site name',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: NahpuSpacing.xxs),
                      SelectableText(
                        siteName,
                        style: theme.textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
          orElse: () => const SizedBox.shrink(),
        );
  }

  String _formatSiteName(SiteData site) {
    return [
          site.country,
          site.stateProvince,
          site.county,
          site.municipality,
          site.locality,
        ]
        .whereType<String>()
        .map((part) => part.trim())
        .where((part) {
          return part.isNotEmpty;
        })
        .join(', ');
  }
}
