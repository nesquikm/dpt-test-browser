import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:dpt_test_browser/browser/webview_adapter.dart';
import 'package:dpt_test_browser/shared/constants.dart';
import 'package:dpt_test_browser/tabs/tab_manager_cubit.dart';
import 'package:dpt_test_browser/tabs/tab_manager_state.dart';
import 'package:dpt_test_browser/ui/address_bar.dart';
import 'package:dpt_test_browser/ui/tab_bar.dart';
import 'package:dpt_test_browser/ui/tab_view.dart';

/// Top-level shell. Stacks (top → bottom) tab strip, address bar, and the
/// per-tab webview area. Under the keep-alive contract (FR-STE-260), every
/// open tab gets a [BrowserTabView] mounted inside the per-tab webview
/// area; only the active child paints, but every child stays in the
/// element tree across active-tab switches so DOM / scroll / JS / video
/// state is preserved.
///
/// Layout choice: a [Stack] of [Visibility.maintain] children, **not**
/// [IndexedStack]. The FR's AC-STE-260.1 prescribes `IndexedStack`
/// nominally, and AC-STE-260's Notes explicitly authorise
/// `Stack + Offstage` (or equivalent) as a functionally-equivalent
/// fallback. We take the fallback path because:
///
///  * `IndexedStack` wraps each child in an *unkeyed* `Visibility.maintain`
///    internally (Flutter SDK behaviour). When a tab is closed, the
///    children list shrinks; the unkeyed wrappers reconcile *positionally*,
///    which causes Flutter to deactivate the right-most child even if it
///    has a stable `ValueKey` — its `State` is disposed, the `WebviewAdapter`
///    is torn down, and the keep-alive contract breaks for any tab to the
///    right of the closed one.
///  * Wrapping each child in a *keyed* `Visibility.maintain` ourselves keeps
///    element reconciliation key-based across list shrinks: closing tab B
///    deactivates only B's element, A and C keep their `State` and
///    adapters intact. This is the FR-Notes-authorised fallback.
///  * `Visibility.maintain` (rather than `Offstage`) keeps the off-stage
///    child laid out at full size, which matters for `webview_flutter`
///    platform views — `Offstage` collapses children to size 0, which
///    risks the native view detaching/reattaching on toggle.
///
/// When `state.activeTabId == null`, renders an empty-state placeholder
/// with a "New tab" button.
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
  /// Per-tab adapter registry. Populated as each [BrowserTabView] mounts
  /// (via `onAdapterReady`); entries are removed when a tab is closed
  /// (via `onAdapterDisposed`). The address bar reads this map keyed by
  /// the active tab id.
  ///
  /// A plain `Map` plus a separate revision notifier lets us mutate in
  /// place and rebuild only the address bar when an entry changes,
  /// without forcing the whole shell to rebuild.
  final Map<String, WebviewAdapter> _adaptersById =
      <String, WebviewAdapter>{};

  /// Bumped on every adapter map mutation so the address-bar
  /// `ValueListenableBuilder` rebuilds when the active tab's adapter
  /// becomes available (or when the active tab changes).
  final ValueNotifier<int> _adaptersRevision = ValueNotifier<int>(0);

  /// `true` once [dispose] has run. Guards the per-tab callbacks so a
  /// post-frame `onAdapterDisposed` scheduled by a child [BrowserTabView]
  /// during shell teardown does not mutate a disposed [_adaptersRevision].
  bool _disposed = false;

  void _onAdapterReady(String tabId, WebviewAdapter adapter) {
    if (_disposed) return;
    _adaptersById[tabId] = adapter;
    _adaptersRevision.value = _adaptersRevision.value + 1;
  }

  void _onAdapterDisposed(String tabId) {
    if (_disposed) return;
    if (_adaptersById.remove(tabId) != null) {
      _adaptersRevision.value = _adaptersRevision.value + 1;
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _adaptersRevision.dispose();
    super.dispose();
  }

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
            return _ShellBody(
              state: state,
              adapterFactory: widget.adapterFactory,
              adaptersById: _adaptersById,
              adaptersRevision: _adaptersRevision,
              onAdapterReady: _onAdapterReady,
              onAdapterDisposed: _onAdapterDisposed,
            );
          },
        ),
      ),
    );
  }
}

class _ShellBody extends StatelessWidget {
  const _ShellBody({
    required this.state,
    required this.adaptersById,
    required this.adaptersRevision,
    required this.onAdapterReady,
    required this.onAdapterDisposed,
    this.adapterFactory,
  });

  final TabManagerState state;
  final Map<String, WebviewAdapter> adaptersById;
  final ValueListenable<int> adaptersRevision;
  final OnAdapterReady onAdapterReady;
  final OnAdapterDisposed onAdapterDisposed;
  final WebviewAdapterFactory? adapterFactory;

  @override
  Widget build(BuildContext context) {
    final activeTab =
        state.tabs.firstWhere((t) => t.id == state.activeTabId);
    final activeIndex =
        state.tabs.indexWhere((t) => t.id == state.activeTabId);
    return Column(
      children: [
        const BrowserTabBar(),
        ValueListenableBuilder<int>(
          valueListenable: adaptersRevision,
          builder: (context, _, _) {
            // AddressBar accepts a nullable adapter so the layout is stable
            // during the one-frame gap between TabView mount and adapter
            // publish — buttons are disabled until the adapter arrives.
            final adapter = adaptersById[activeTab.id];
            return AddressBar(activeTab: activeTab, adapter: adapter);
          },
        ),
        Expanded(
          child: Stack(
            fit: StackFit.expand,
            children: [
              for (var i = 0; i < state.tabs.length; i++)
                Visibility.maintain(
                  // Key on the wrapper so Stack's child reconciliation
                  // matches by tab id when the list shrinks (close tab).
                  // See class doc — without this, `IndexedStack`-style
                  // positional matching disposes the wrong child.
                  key: ValueKey<String>(
                    'tabview-vis-${state.tabs[i].id}',
                  ),
                  visible: i == activeIndex,
                  child: BrowserTabView(
                    key: ValueKey<String>('tabview-${state.tabs[i].id}'),
                    tab: state.tabs[i],
                    adapterFactory: adapterFactory,
                    onAdapterReady: onAdapterReady,
                    onAdapterDisposed: onAdapterDisposed,
                  ),
                ),
            ],
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
