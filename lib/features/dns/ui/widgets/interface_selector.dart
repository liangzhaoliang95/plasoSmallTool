import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../l10n/app_localizations.dart';
import '../../providers/dns_provider.dart';

class InterfaceSelector extends ConsumerWidget {
  const InterfaceSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final interfacesAsync = ref.watch(networkInterfacesProvider);
    final selectedInterface = ref.watch(selectedInterfaceProvider);
    final theme = Theme.of(context);

    final l10n = AppLocalizations.of(context);

    return interfacesAsync.when(
      data: (interfaces) {
        if (interfaces.isEmpty) {
          return Text(l10n.dnsNoInterface);
        }

        if (selectedInterface == null && interfaces.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ref.read(selectedInterfaceProvider.notifier).state =
                interfaces.first;
          });
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: theme.colorScheme.outlineVariant,
              width: 1,
            ),
          ),
          child: DropdownButton(
            value: selectedInterface,
            isExpanded: true,
            underline: const SizedBox(),
            icon: Icon(
              Icons.keyboard_arrow_down,
              color: theme.colorScheme.onSurface,
            ),
            style: TextStyle(
              color: theme.colorScheme.onSurface,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            dropdownColor: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
            items: interfaces.map((interface) {
              return DropdownMenuItem(
                value: interface,
                child: Row(
                  children: [
                    Icon(
                      Icons.network_check,
                      size: 18,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(interface.displayName),
                  ],
                ),
              );
            }).toList(),
            onChanged: (value) {
              ref.read(selectedInterfaceProvider.notifier).state = value;
            },
          ),
        );
      },
      loading: () => const CircularProgressIndicator(),
      error: (error, stack) => Text(l10n.dnsInterfaceError(error.toString())),
    );
  }
}
