import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../l10n/app_localizations.dart';

class AppShell extends StatefulWidget {
  final Widget child;

  const AppShell({super.key, required this.child});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  bool _extended = true;
  bool _showContent = true;

  void _toggle() {
    if (_extended) {
      // 收起：先隐藏内容，再收缩宽度
      setState(() => _showContent = false);
      Future.delayed(const Duration(milliseconds: 80), () {
        if (mounted) setState(() => _extended = false);
      });
    } else {
      // 展开：先展开宽度，再显示内容
      setState(() => _extended = true);
      Future.delayed(const Duration(milliseconds: 120), () {
        if (mounted) setState(() => _showContent = true);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final location = GoRouter.of(context).routerDelegate.currentConfiguration.uri.path;
    final items = [
      (icon: Icons.dns, label: l10n.navDns, path: '/dns'),
      (icon: Icons.info_outline, label: l10n.navAbout, path: '/about'),
    ];

    return Scaffold(
      body: Row(
        children: [
          _Sidebar(
            extended: _extended,
            showContent: _showContent,
            items: items,
            currentPath: location,
            onToggle: _toggle,
          ),
          VerticalDivider(
            width: 1,
            thickness: 1,
            color: theme.colorScheme.outlineVariant,
          ),
          Expanded(child: widget.child),
        ],
      ),
    );
  }
}

class _Sidebar extends StatelessWidget {
  final bool extended;
  final bool showContent;
  final List<({IconData icon, String label, String path})> items;
  final String currentPath;
  final VoidCallback onToggle;

  const _Sidebar({
    required this.extended,
    required this.showContent,
    required this.items,
    required this.currentPath,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      width: extended ? 200 : 64,
      color: theme.colorScheme.surfaceContainer,
      child: Column(
        children: [
          const SizedBox(height: 8),
          ...items.map((item) => _SidebarItem(
                icon: item.icon,
                label: item.label,
                selected: currentPath == item.path,
                extended: showContent,
                onTap: () => context.go(item.path),
              )),
          const Spacer(),
          _ToggleButton(extended: showContent, onTap: onToggle),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final bool extended;
  final VoidCallback onTap;

  const _SidebarItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.extended,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Material(
        color: selected ? theme.colorScheme.primaryContainer : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          hoverColor: theme.colorScheme.surfaceContainerHighest,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: extended
                ? Row(
                    children: [
                      Icon(
                        icon,
                        size: 22,
                        color: selected
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          label,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: selected
                                ? FontWeight.w600
                                : FontWeight.normal,
                            color: selected
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onSurface,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  )
                : Icon(
                    icon,
                    size: 22,
                    color: selected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurfaceVariant,
                  ),
          ),
        ),
      ),
    );
  }
}

class _ToggleButton extends StatelessWidget {
  final bool extended;
  final VoidCallback onTap;

  const _ToggleButton({required this.extended, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          hoverColor: theme.colorScheme.surfaceContainerHighest,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: extended
                ? Row(
                    children: [
                      Icon(
                        Icons.chevron_left,
                        size: 22,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          l10n.navCollapse,
                          style: TextStyle(
                            fontSize: 14,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  )
                : Icon(
                    Icons.chevron_right,
                    size: 22,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
          ),
        ),
      ),
    );
  }
}
