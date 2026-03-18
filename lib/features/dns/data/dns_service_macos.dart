import 'dart:io';
import '../models/network_interface_info.dart';
import 'dns_service.dart';

class DnsServiceMacOS implements DnsService {
  @override
  Future<List<NetworkInterfaceInfo>> getNetworkInterfaces() async {
    try {
      final result = await Process.run(
        'networksetup',
        ['-listallnetworkservices'],
      );

      if (result.exitCode != 0) {
        return [];
      }

      final lines = result.stdout
          .toString()
          .split('\n')
          .where((l) => l.isNotEmpty && !l.startsWith('*'))
          .skip(1)
          .toList();

      final interfaces = <NetworkInterfaceInfo>[];
      for (final service in lines) {
        final dns = await getCurrentDns(service);
        interfaces.add(NetworkInterfaceInfo(
          name: service,
          displayName: service,
          currentDns: dns,
        ));
      }

      return interfaces;
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<String>> getCurrentDns(String interfaceName) async {
    try {
      final result = await Process.run(
        'networksetup',
        ['-getdnsservers', interfaceName],
      );

      if (result.exitCode != 0) {
        return [];
      }

      final output = result.stdout.toString().trim();
      if (output.contains('There aren\'t any DNS Servers')) {
        return [];
      }

      return output
          .split('\n')
          .where((line) => line.isNotEmpty)
          .map((line) => line.trim())
          .toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<DnsResult> setDns(
    String interfaceName,
    List<String> dnsServers,
  ) async {
    try {
      final args = ['-setdnsservers', interfaceName, ...dnsServers];
      final result = await Process.run('networksetup', args);

      if (result.exitCode == 0) {
        await _flushDnsCache();
        return DnsResult.success();
      }

      final stderr = result.stderr.toString();
      if (stderr.contains('requires administrator') ||
          stderr.contains('not authenticated')) {
        return await _setDnsWithElevation(interfaceName, dnsServers);
      }

      return DnsResult.failure(stderr);
    } catch (e) {
      return DnsResult.failure(e.toString());
    }
  }

  Future<DnsResult> _setDnsWithElevation(
    String interfaceName,
    List<String> dnsServers,
  ) async {
    try {
      final dnsStr = dnsServers.join(' ');
      final script = '''
do shell script "networksetup -setdnsservers \\"$interfaceName\\" $dnsStr" with administrator privileges
''';

      final result = await Process.run('osascript', ['-e', script]);

      if (result.exitCode == 0) {
        await _flushDnsCache();
        return DnsResult.success();
      }

      final stderr = result.stderr.toString();
      if (stderr.contains('User canceled')) {
        return DnsResult.failure('用户取消了授权');
      }

      return DnsResult.failure(stderr);
    } catch (e) {
      return DnsResult.failure(e.toString());
    }
  }

  @override
  Future<DnsResult> clearDns(String interfaceName) async {
    try {
      final result = await Process.run(
        'networksetup',
        ['-setdnsservers', interfaceName, 'empty'],
      );

      if (result.exitCode == 0) {
        await _flushDnsCache();
        return DnsResult.success();
      }

      final stderr = result.stderr.toString();
      if (stderr.contains('requires administrator') ||
          stderr.contains('not authenticated')) {
        return await _clearDnsWithElevation(interfaceName);
      }

      return DnsResult.failure(stderr);
    } catch (e) {
      return DnsResult.failure(e.toString());
    }
  }

  Future<DnsResult> _clearDnsWithElevation(String interfaceName) async {
    try {
      final script = '''
do shell script "networksetup -setdnsservers \\"$interfaceName\\" empty" with administrator privileges
''';

      final result = await Process.run('osascript', ['-e', script]);

      if (result.exitCode == 0) {
        await _flushDnsCache();
        return DnsResult.success();
      }

      final stderr = result.stderr.toString();
      if (stderr.contains('User canceled')) {
        return DnsResult.failure('用户取消了授权');
      }

      return DnsResult.failure(stderr);
    } catch (e) {
      return DnsResult.failure(e.toString());
    }
  }

  Future<void> _flushDnsCache() async {
    try {
      // macOS 刷新 DNS 缓存命令
      await Process.run('dscacheutil', ['-flushcache']);
      await Process.run('killall', ['-HUP', 'mDNSResponder']);
    } catch (e) {
      // 忽略刷新缓存的错误，不影响主流程
    }
  }
}
