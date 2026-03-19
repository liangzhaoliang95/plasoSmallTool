class DnsPreset {
  final String name;
  final String primary;
  final String secondary;
  final String description;
  final bool isAuto;
  final String nameKey;
  final String descriptionKey;

  const DnsPreset({
    required this.name,
    required this.primary,
    required this.secondary,
    required this.description,
    required this.nameKey,
    required this.descriptionKey,
    this.isAuto = false,
  });

  List<String> get dnsServers {
    if (isAuto) return [];
    return [primary, if (secondary.isNotEmpty) secondary];
  }

  bool matches(List<String> currentDns) {
    if (isAuto) return currentDns.isEmpty;
    if (currentDns.isEmpty) return false;
    return currentDns.first == primary;
  }
}
