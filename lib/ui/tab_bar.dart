import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:dpt_test_browser/shared/constants.dart';
import 'package:dpt_test_browser/tabs/tab.dart';
import 'package:dpt_test_browser/tabs/tab_manager_cubit.dart';

/// Horizontal tab strip. Renders one chip per [BrowserTab] plus a trailing
/// `+` button for opening a new tab.
///
/// Class is namespaced as `BrowserTabBar` to avoid shadowing Material's
/// own `TabBar`.
class BrowserTabBar extends StatelessWidget {
  const BrowserTabBar({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<TabManagerCubit>();
    final state = cubit.state;

    return SizedBox(
      height: 36,
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (final tab in state.tabs)
                    _TabChip(
                      tab: tab,
                      isActive: tab.id == state.activeTabId,
                      onSelect: () => cubit.selectTab(tab.id),
                      onClose: () => cubit.closeTab(tab.id),
                    ),
                ],
              ),
            ),
          ),
          IconButton(
            key: const Key('new-tab-button'),
            tooltip: 'New tab',
            icon: const Icon(Icons.add),
            onPressed: () => cubit.openTab(kDefaultNewTabUrl),
          ),
        ],
      ),
    );
  }
}

class _TabChip extends StatelessWidget {
  const _TabChip({
    required this.tab,
    required this.isActive,
    required this.onSelect,
    required this.onClose,
  });

  final BrowserTab tab;
  final bool isActive;
  final VoidCallback onSelect;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final label = (tab.title?.isNotEmpty ?? false) ? tab.title! : tab.url.host;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: GestureDetector(
        key: Key('tab-${tab.id}'),
        onTap: onSelect,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: isActive
                ? theme.colorScheme.primaryContainer
                : theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (tab.isLoading)
                const Padding(
                  padding: EdgeInsets.only(right: 6),
                  child: SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              Text(
                label,
                style: theme.textTheme.bodyMedium,
                overflow: TextOverflow.ellipsis,
              ),
              IconButton(
                key: Key('close-${tab.id}'),
                tooltip: 'Close tab',
                iconSize: 16,
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(Icons.close),
                onPressed: onClose,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

