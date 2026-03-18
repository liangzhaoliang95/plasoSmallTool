import 'dart:io';
import 'dart:convert';
import '../models/network_interface_info.dart';
import 'dns_service.dart';

class DnsServiceWindows implements DnsService {
  @override
  Future<List<NetworkInterfaceInfo>> getNetworkInterfaces() async {
    try {
      final result = await Process.run('powershell', [
        '-Command',
        'Get-NetAdapter | Where-Object {\$_.Status -eq "Up"} | '
            'Select-Object Name, InterfaceIndex | ConvertTo-Json',
      ]);

      if (result.exitCode != 0) {
        return [];
      }

      final output = result.stdout.toString().trim();
      if (output.isEmpty) return [];

      dynamic adapters = jsonDecode(output);
      if (adapters is! List) {
        adapters = [adapters];
      }

      final interfaces = <NetworkInterfaceInfo>[];
      for (final adapter in adapters) {
        final name = adapter['Name'] as String;
        final index = adapter['InterfaceIndex'] as int;
        final dns = await getCurrentDns(name);

        interfaces.add(NetworkInterfaceInfo(
          name: name,
          displayName: name,
          interfaceIndex: index,
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
      final result = await Process.run('powershell', [
        '-Command',
        'Get-DnsClientServerAddress -InterfaceAlias "$interfaceName" '
            '-AddressFamily IPv4 | Select-Object -ExpandProperty ServerAddresses',
      ]);

      if (result.exitCode != 0) {
        return [];
      }

      final output = result.stdout.toString().trim();
      if (output.isEmpty) return [];

      return output
          .split('\n')
          .where((line) => line.trim().isNotEmpty)
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
    final isAdmin = await _checkAdminPrivileges();
    if (!isAdmin) {
      return DnsResult.needsElevation();
    }

    return await _setDnsDirectly(interfaceName, dnsServers);
  }

  Future<bool> _checkAdminPrivileges() async {
    try {
      final result = await Process.run('powershell', [
        '-Command',
        '[Security.Principal.WindowsIdentity]::GetCurrent() | '
            '% { [Security.Principal.WindowsPrincipal]\$_ } | '
            '% { \$_.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator) }',
      ]);

      return result.stdout.toString().trim() == 'True';
    } catch (e) {
      return false;
    }
  }

  Future<DnsResult> _setDnsDirectly(
    String interfaceName,
    List<String> dnsServers,
  ) async {
    try {
      final dnsStr = dnsServers.map((d) => '"$d"').join(',');
      final result = await Process.run('powershell', [
        '-Command',
        'Set-DnsClientServerAddress -InterfaceAlias "$interfaceName" '
            '-ServerAddresses ($dnsStr)',
      ]);

      if (result.exitCode == 0) {
        await _flushDnsCache();
        return DnsResult.success();
      }

      return DnsResult.failure(result.stderr.toString());
    } catch (e) {
      return DnsResult.failure(e.toString());
    }
  }

  @override
  Future<DnsResult> clearDns(String interfaceName) async {
    final isAdmin = await _checkAdminPrivileges();
    if (!isAdmin) {
      return DnsResult.needsElevation();
    }

    try {
      final result = await Process.run('powershell', [
        '-Command',
        'Set-DnsClientServerAddress -InterfaceAlias "$interfaceName" '
            '-ResetServerAddresses',
      ]);

      if (result.exitCode == 0) {
        await _flushDnsCache();
        return DnsResult.success();
      }

      return DnsResult.failure(result.stderr.toString());
    } catch (e) {
      return DnsResult.failure(e.toString());
    }
  }

  Future<void> _flushDnsCache() async {
    try {
      // Windows 刷新 DNS 缓存命令
      await Process.run('ipconfig', ['/flushdns']);
    } catch (e) {
      // 忽略刷新缓存的错误，不影响主流程
    }
  }
}
