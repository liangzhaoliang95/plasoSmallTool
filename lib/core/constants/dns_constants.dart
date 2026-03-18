import '../../features/dns/models/dns_preset.dart';

class DnsConstants {
  static final List<DnsPreset> presets = [
    const DnsPreset(
      name: '阿里 DNS',
      primary: '223.5.5.5',
      secondary: '223.6.6.6',
      description: '国内优化，快速稳定',
    ),
    const DnsPreset(
      name: '腾讯 DNS',
      primary: '119.29.29.29',
      secondary: '182.254.116.116',
      description: '国内优化，DNSPod 提供',
    ),
    const DnsPreset(
      name: 'Google DNS',
      primary: '8.8.8.8',
      secondary: '8.8.4.4',
      description: '全球可靠，隐私保护',
    ),
    const DnsPreset(
      name: 'Cloudflare',
      primary: '1.1.1.1',
      secondary: '1.0.0.1',
      description: '最快的公共 DNS',
    ),
    const DnsPreset(
      name: '114 DNS',
      primary: '114.114.114.114',
      secondary: '114.114.115.115',
      description: '国内常用 DNS',
    ),
    const DnsPreset(
      name: '自动(DHCP)',
      primary: '',
      secondary: '',
      description: '恢复自动获取',
      isAuto: true,
    ),
  ];
}
