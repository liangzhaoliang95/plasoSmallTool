import 'dart:io';
import '../models/network_interface_info.dart';
import 'dns_service_macos.dart';
import 'dns_service_windows.dart';

abstract class DnsService {
  Future<List<NetworkInterfaceInfo>> getNetworkInterfaces();
  Future<List<String>> getCurrentDns(String interfaceName);
  Future<DnsResult> setDns(String interfaceName, List<String> dnsServers);
  Future<DnsResult> clearDns(String interfaceName);

  factory DnsService() {
    if (Platform.isMacOS) return DnsServiceMacOS();
    if (Platform.isWindows) return DnsServiceWindows();
    throw UnsupportedError('Platform ${Platform.operatingSystem} not supported');
  }
}

class DnsResult {
  final bool success;
  final String? error;
  final bool requiresElevation;

  const DnsResult({
    required this.success,
    this.error,
    this.requiresElevation = false,
  });

  factory DnsResult.success() => const DnsResult(success: true);

  factory DnsResult.failure(String error) => DnsResult(
        success: false,
        error: error,
      );

  factory DnsResult.needsElevation() => const DnsResult(
        success: false,
        requiresElevation: true,
      );
}
