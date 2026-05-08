import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:dpt_test_browser/browser/webview_adapter.dart';
import 'package:dpt_test_browser/shared/constants.dart';
import 'package:dpt_test_browser/tabs/tab.dart';
import 'package:dpt_test_browser/tabs/tab_manager_cubit.dart';
import 'package:dpt_test_browser/tabs/tab_manager_state.dart';
import 'package:dpt_test_browser/ui/address_bar.dart';
import 'package:dpt_test_browser/ui/tab_bar.dart';
import 'package:dpt_test_browser/ui/tab_view.dart';

/// Top-level shell. Stacks (top → bottom) tab strip, address bar, active
/// tab's webview. When `state.activeTabId == null`, renders an empty-state
/// placeholder with a "New tab" button.
class BrowserShell extends StatefulWidget {
  const BrowserShell({super.key, this.adapterFactory});

  /// Optional factory used to build each tab's [WebviewAdapter]. Tests
  /// inject a closure returning `FakeWebviewAdapter`; production leaves it
  /// null so each `BrowserTabView` builds a real `WebviewFlutterAdapter`.
  final WebviewAdapterFactory? adapterFactory;

  @override
  State<BrowserShell> createState() => _BrowserShellState();
}

class _BrowserShellState extends State<BrowserShell> {
  /// Holds the active tab's adapter. Set by [BrowserTabView] in initState
  /// (via `adapterSink`); cleared in dispose. The address bar listens via
  /// [ValueListenableBuilder].
  ///
  /// Not disposed in [dispose] on purpose: the active [BrowserTabView]'s
  /// own dispose schedules a post-frame clear of `sink.value` (notifying
  /// listeners during teardown is illegal), so disposing the notifier here
  /// would race with that callback. The whole subtree comes down with this
  /// state, so the notifier is reachable only via this object — once the
  /// state is collected, the notifier goes with it.
  final ValueNotifier<WebviewAdapter?> _adapterSink =
      ValueNotifier<WebviewAdapter?>(null);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<TabManagerCubit, TabManagerState>(
          builder: (context, state) {
            if (state.activeTabId == null) {
              return _EmptyState(
                onNewTab: () => context
                    .read<TabManagerCubit>()
                    .openTab(kDefaultNewTabUrl),
              );
            }
            final activeTab =
                state.tabs.firstWhere((t) => t.id == state.activeTabId);
            return _ShellBody(
              activeTab: activeTab,
              adapterFactory: widget.adapterFactory,
              adapterSink: _adapterSink,
            );
          },
        ),
      ),
    );
  }
}

class _ShellBody extends StatelessWidget {
  const _ShellBody({
    required this.activeTab,
    required this.adapterSink,
    this.adapterFactory,
  });

  final BrowserTab activeTab;
  final ValueNotifier<WebviewAdapter?> adapterSink;
  final WebviewAdapterFactory? adapterFactory;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const BrowserTabBar(),
        ValueListenableBuilder<WebviewAdapter?>(
          valueListenable: adapterSink,
          builder: (context, adapter, _) {
            // AddressBar accepts a nullable adapter so the layout is stable
            // during the one-frame gap between TabView mount and adapter
            // publish — buttons are disabled until the adapter arrives.
            return AddressBar(activeTab: activeTab, adapter: adapter);
          },
        ),
        Expanded(
          child: BrowserTabView(
            key: ValueKey<String>('tabview-${activeTab.id}'),
            tab: activeTab,
            adapterFactory: adapterFactory,
            adapterSink: adapterSink,
          ),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onNewTab});

  final VoidCallback onNewTab;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.tab, size: 48),
          const SizedBox(height: 8),
          const Text('No open tabs'),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            key: const Key('new-tab-empty'),
            onPressed: onNewTab,
            icon: const Icon(Icons.add),
            label: const Text('New tab'),
          ),
        ],
      ),
    );
  }
}
