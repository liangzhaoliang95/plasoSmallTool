class NetworkInterfaceInfo {
  final String name;
  final String displayName;
  final List<String> currentDns;
  final int? interfaceIndex; // Windows only

  const NetworkInterfaceInfo({
    required this.name,
    required this.displayName,
    this.currentDns = const [],
    this.interfaceIndex,
  });

  @override
  bool operator ==(Object other) =>
      other is NetworkInterfaceInfo && other.name == name;

  @override
  int get hashCode => name.hashCode;
}
