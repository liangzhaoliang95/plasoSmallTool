import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/dns_constants.dart';
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
    final selectedInterface = ref.read(selectedInterfaceProvider);
    if (selectedInterface == null) {
      _showError('请先选择网络接口');
      return;
    }

    final preset = DnsConstants.presets.firstWhere((p) => p.name == presetName);

    setState(() {
      _loadingPresetName = presetName;
    });

    try {
      final service = ref.read(dnsServiceProvider);
      final result = preset.isAuto
          ? await service.clearDns(selectedInterface.name)
          : await service.setDns(
              selectedInterface.name,
              preset.dnsServers,
            );

      if (result.success) {
        _showSuccess('DNS 切换成功');
        ref.invalidate(currentDnsProvider);
        ref.invalidate(networkInterfacesProvider);
      } else if (result.requiresElevation) {
        _showError('需要管理员权限，请以管理员身份运行应用');
      } else {
        _showError(result.error ?? '切换失败');
      }
    } catch (e) {
      _showError('切换失败: $e');
    } finally {
      setState(() {
        _loadingPresetName = null;
      });
    }
  }

  void _showSuccess(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _refresh() {
    ref.invalidate(networkInterfacesProvider);
    ref.invalidate(currentDnsProvider);
  }

  Widget _buildPresetGrid(List<String> currentDns) {
    return GridView.builder(
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
        final isActive = preset.matches(currentDns);
        final isLoading = _loadingPresetName == preset.name;

        return DnsPresetCard(
          preset: preset,
          isActive: isActive,
          isLoading: isLoading,
          onSwitch: () => _switchDns(preset.name),
        );
      },
    );
  }

  int _getColumnCount(double width) {
    return 3;
  }

  @override
  Widget build(BuildContext context) {
    final currentDnsAsync = ref.watch(currentDnsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('DNS 检测与切换'),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('选择网络接口后，点击预设卡片即可快速切换 DNS'),
                  duration: Duration(seconds: 3),
                ),
              );
            },
            tooltip: '帮助',
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
                Icon(
                  Icons.grid_view_rounded,
                  size: 24,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  '快速切换预设',
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
              data: (currentDns) => _buildPresetGrid(currentDns),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Text('加载失败: $error'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
