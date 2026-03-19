import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../l10n/app_localizations.dart';
import '../../models/dns_preset.dart';

String _resolveKey(AppLocalizations l10n, String key) => switch (key) {
      'dnsPresetAliName' => l10n.dnsPresetAliName,
      'dnsPresetAliDesc' => l10n.dnsPresetAliDesc,
      'dnsPresetTencentName' => l10n.dnsPresetTencentName,
      'dnsPresetTencentDesc' => l10n.dnsPresetTencentDesc,
      'dnsPresetGoogleName' => l10n.dnsPresetGoogleName,
      'dnsPresetGoogleDesc' => l10n.dnsPresetGoogleDesc,
      'dnsPresetCloudflareName' => l10n.dnsPresetCloudflareName,
      'dnsPresetCloudflareDesc' => l10n.dnsPresetCloudflareDesc,
      'dnsPreset114Name' => l10n.dnsPreset114Name,
      'dnsPreset114Desc' => l10n.dnsPreset114Desc,
      'dnsPresetAutoName' => l10n.dnsPresetAutoName,
      'dnsPresetAutoDesc' => l10n.dnsPresetAutoDesc,
      _ => key,
    };

class DnsPresetCard extends ConsumerWidget {
  final DnsPreset preset;
  final bool isActive;
  final VoidCallback onSwitch;
  final bool isLoading;

  const DnsPresetCard({
    super.key,
    required this.preset,
    required this.isActive,
    required this.onSwitch,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActive
              ? theme.colorScheme.primary
              : theme.colorScheme.outlineVariant,
          width: isActive ? 2 : 1,
        ),
        color: isActive
            ? theme.colorScheme.primaryContainer.withValues(alpha: 0.3)
            : theme.colorScheme.surfaceContainerLow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onSwitch,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _resolveKey(l10n, preset.nameKey),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: isActive
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                    if (isActive)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.check_circle,
                              size: 11,
                              color: theme.colorScheme.onPrimary,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              '当前',
                              style: TextStyle(
                                color: theme.colorScheme.onPrimary,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                if (!preset.isAuto) ...[
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.dns,
                              size: 13,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                preset.primary,
                                style: TextStyle(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (preset.secondary.isNotEmpty) ...[
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              Icon(
                                Icons.dns,
                                size: 13,
                                color: theme.colorScheme.primary.withValues(alpha: 0.7),
                              ),
                              const SizedBox(width: 5),
                              Expanded(
                                child: Text(
                                  preset.secondary,
                                  style: TextStyle(
                                    color: theme.colorScheme.primary.withValues(alpha: 0.7),
                                    fontWeight: FontWeight.w500,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ] else ...[
                  const SizedBox(height: 46),
                ],
                const SizedBox(height: 8),
                Text(
                  _resolveKey(l10n, preset.descriptionKey),
                  style: TextStyle(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: 11,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 38,
                  child: FilledButton(
                    onPressed: isLoading || isActive ? null : onSwitch,
                    style: FilledButton.styleFrom(
                      backgroundColor: isActive
                          ? theme.colorScheme.surfaceContainerHighest
                          : theme.colorScheme.primary,
                      foregroundColor: isActive
                          ? theme.colorScheme.onSurfaceVariant
                          : theme.colorScheme.onPrimary,
                    ),
                    child: isLoading
                        ? SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: theme.colorScheme.primary,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                isActive ? Icons.check : Icons.swap_horiz,
                                size: 16,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                isActive ? l10n.dnsActive : l10n.dnsSwitch,
                                style: const TextStyle(fontSize: 13),
                              ),
                            ],
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
