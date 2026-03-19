import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/dns_constants.dart';
import '../../../l10n/app_localizations.dart';
import '../providers/dns_provider.dart';
import 'widgets/current_dns_panel.dart';
import 'widgets/dns_preset_card.dart';

class DnsPage extends ConsumerStatefulWidget {
  const DnsPage({super.key});

  @override
  ConsumerState<DnsPage> createState() => _DnsPageState();
}

class _DnsPageState extends ConsumerState<DnsPage> {
  String? _loadingPresetName;

  Future<void> _switchDns(String presetName) async {
    final l10n = AppLocalizations.of(context);
    final selectedInterface = ref.read(selectedInterfaceProvider);
    if (selectedInterface == null) {
      _showError(l10n.dnsSelectInterface);
      return;
    }

    final preset = DnsConstants.presets.firstWhere((p) => p.name == presetName);
    setState(() => _loadingPresetName = presetName);

    try {
      final service = ref.read(dnsServiceProvider);
      final result = preset.isAuto
          ? await service.clearDns(selectedInterface.name)
          : await service.setDns(selectedInterface.name, preset.dnsServers);

      if (!mounted) return;
      final l10nAfter = AppLocalizations.of(context);
      if (result.success) {
        _showSuccess(l10nAfter.dnsSwitchSuccess);
        ref.invalidate(currentDnsProvider);
        ref.invalidate(networkInterfacesProvider);
      } else if (result.requiresElevation) {
        _showError(l10nAfter.dnsNeedAdmin);
      } else {
        _showError(result.error ?? l10nAfter.dnsSwitchFailed);
      }
    } catch (e) {
      if (!mounted) return;
      _showError(AppLocalizations.of(context).dnsSwitchFailedWithError(e.toString()));
    } finally {
      setState(() => _loadingPresetName = null);
    }
  }

  void _showSuccess(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        const Icon(Icons.check_circle, color: Colors.white),
        const SizedBox(width: 12),
        Expanded(child: Text(message)),
      ]),
      backgroundColor: Colors.green.shade600,
      behavior: SnackBarBehavior.floating,
    ));
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        const Icon(Icons.error, color: Colors.white),
        const SizedBox(width: 12),
        Expanded(child: Text(message)),
      ]),
      backgroundColor: Colors.red.shade600,
      behavior: SnackBarBehavior.floating,
    ));
  }

  void _refresh() {
    ref.invalidate(networkInterfacesProvider);
    ref.invalidate(currentDnsProvider);
  }

  @override
  Widget build(BuildContext context) {
    final currentDnsAsync = ref.watch(currentDnsProvider);
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.dnsPageTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(l10n.dnsHelp),
                duration: const Duration(seconds: 3),
              ));
            },
            tooltip: l10n.dnsHelpTooltip,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CurrentDnsPanel(onRefresh: _refresh),
            const SizedBox(height: 32),
            Row(
              children: [
                Icon(Icons.grid_view_rounded,
                    size: 24, color: theme.colorScheme.primary),
                const SizedBox(width: 12),
                Text(
                  l10n.dnsPresets,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            currentDnsAsync.when(
              data: (currentDns) => GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  mainAxisExtent: 200,
                ),
                itemCount: DnsConstants.presets.length,
                itemBuilder: (context, index) {
                  final preset = DnsConstants.presets[index];
                  return DnsPresetCard(
                    preset: preset,
                    isActive: preset.matches(currentDns),
                    isLoading: _loadingPresetName == preset.name,
                    onSwitch: () => _switchDns(preset.name),
                  );
                },
              ),
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (error, stack) =>
                  Center(child: Text(l10n.dnsLoadFailed(error.toString()))),
            ),
          ],
        ),
      ),
    );
  }
}
