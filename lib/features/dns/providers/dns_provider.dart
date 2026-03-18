import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/dns_service.dart';
import '../models/network_interface_info.dart';

final dnsServiceProvider = Provider<DnsService>((ref) {
  return DnsService();
});

final networkInterfacesProvider =
    FutureProvider<List<NetworkInterfaceInfo>>((ref) async {
  final service = ref.watch(dnsServiceProvider);
  return await service.getNetworkInterfaces();
});

final selectedInterfaceProvider =
    StateProvider<NetworkInterfaceInfo?>((ref) => null);

final currentDnsProvider = FutureProvider<List<String>>((ref) async {
  final selectedInterface = ref.watch(selectedInterfaceProvider);
  if (selectedInterface == null) return [];

  final service = ref.watch(dnsServiceProvider);
  return await service.getCurrentDns(selectedInterface.name);
});

final isLoadingProvider = StateProvider<bool>((ref) => false);
