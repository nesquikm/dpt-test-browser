import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'package:dpt_test_browser/browser/webview_adapter.dart';
import 'package:dpt_test_browser/browser/webview_flutter_adapter.dart';
import 'package:dpt_test_browser/tabs/tab.dart';
import 'package:dpt_test_browser/tabs/tab_manager_cubit.dart';

/// Callback fired exactly once per [BrowserTabView] mount, after the adapter
/// is constructed and before the first frame, so the shell can register the
/// per-tab adapter for address-bar wiring.
typedef OnAdapterReady = void Function(String tabId, WebviewAdapter adapter);

/// Callback fired when a [BrowserTabView] is unmounted — the shell removes
/// the adapter entry it registered via [OnAdapterReady].
typedef OnAdapterDisposed = void Function(String tabId);

/// Per-tab webview surface. Owns the [WebviewAdapter] for `tab` — built in
/// `initState`, disposed in `dispose`. Mounts a [WebViewWidget] when the
/// underlying adapter is the real `webview_flutter` impl; falls back to an
/// inert placeholder for adapters that don't expose a controller (used in
/// widget tests via the injected factory).
///
/// Class is namespaced as `BrowserTabView` to avoid shadowing Material's
/// own `TabBarView` / similar.
class BrowserTabView extends StatefulWidget {
  const BrowserTabView({
    super.key,
    required this.tab,
    this.adapterFactory,
    this.onAdapterReady,
    this.onAdapterDisposed,
  });

  final BrowserTab tab;
  final WebviewAdapterFactory? adapterFactory;

  /// Invoked after the adapter is constructed so the shell can register it
  /// for address-bar wiring under the keep-alive (`IndexedStack`) layout.
  /// Replaces the older `adapterSink` "publish on init / clear on dispose"
  /// pattern, which raced when N tab views were mounted simultaneously.
  final OnAdapterReady? onAdapterReady;

  /// Invoked from `dispose` so the shell can drop the adapter entry it
  /// registered via [onAdapterReady]. The adapter itself is disposed by
  /// this widget — the shell should not call `adapter.dispose()`.
  final OnAdapterDisposed? onAdapterDisposed;

  @override
  State<BrowserTabView> createState() => _BrowserTabViewState();
}

class _BrowserTabViewState extends State<BrowserTabView> {
  late final WebviewAdapter adapter;
  late final TabManagerCubit _cubit;
  final List<StreamSubscription<dynamic>> _subs =
      <StreamSubscription<dynamic>>[];

  WebviewLoadError? _error;

  @override
  void initState() {
    super.initState();
    adapter = (widget.adapterFactory ?? WebviewFlutterAdapter.new)();
    final onReady = widget.onAdapterReady;
    if (onReady != null) {
      // Defer the notify by one frame — invoking during initState fires
      // listeners during the current build, which trips Flutter's
      // "setState() during build" assertion in any rebuild upstream.
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (mounted) onReady(widget.tab.id, adapter);
      });
    }
    _cubit = context.read<TabManagerCubit>();

    _subs.add(adapter.onLoadStart.listen((url) {
      if (!mounted) return;
      setState(() => _error = null);
      _cubit.setLoading(widget.tab.id, true);
      _cubit.navigate(widget.tab.id, url);
    }));
    _subs.add(adapter.onLoadFinish.listen((url) {
      if (!mounted) return;
      _cubit.setLoading(widget.tab.id, false);
      _cubit.navigate(widget.tab.id, url);
    }));
    _subs.add(adapter.onTitleChanged.listen((title) {
      if (!mounted) return;
      _cubit.setTitle(widget.tab.id, title);
    }));
    _subs.add(adapter.onLoadError.listen((error) {
      if (!mounted) return;
      _cubit.setLoading(widget.tab.id, false);
      setState(() => _error = error);
    }));

    // Kick off the initial load for this tab — fires immediately even for
    // tabs that aren't currently active under the keep-alive layout.
    adapter.loadUrl(widget.tab.url);
  }

  @override
  void dispose() {
    final onDisposed = widget.onAdapterDisposed;
    if (onDisposed != null) {
      // Defer the callback by one frame for the same reason as initState's
      // notify — notifying listeners while the framework is locked
      // (mid-unmount) would trip its assertion.
      final tabId = widget.tab.id;
      SchedulerBinding.instance.addPostFrameCallback((_) {
        onDisposed(tabId);
      });
    }
    for (final s in _subs) {
      s.cancel();
    }
    adapter.dispose();
    super.dispose();
  }

  void _retry() {
    final url = widget.tab.url;
    setState(() => _error = null);
    _cubit.navigate(widget.tab.id, url);
    adapter.loadUrl(url);
  }

  @override
  Widget build(BuildContext context) {
    final error = _error;
    if (error != null) {
      return _ErrorView(error: error, onRetry: _retry);
    }
    final controller = _resolveController(adapter);
    if (controller == null) {
      // Test / non-webview_flutter adapter — render an empty surface so the
      // widget tree is still pumpable.
      return const SizedBox.expand();
    }
    return WebViewWidget(controller: controller);
  }

  // Deliberate downcast: `WebviewAdapter` is platform-agnostic and does
  // not expose a webview_flutter `WebViewController` (that would leak the
  // impl into the abstraction). When the adapter is the real production
  // impl, we mount a `WebViewWidget(controller: …)`; when it's a fake
  // (any non-WebviewFlutterAdapter), we render a blank surface so widget
  // tests can pump the tree without standing up a platform webview. If a
  // second concrete adapter is ever added (e.g. flutter_inappwebview), a
  // sibling resolver will be needed.
  WebViewController? _resolveController(WebviewAdapter a) {
    if (a is WebviewFlutterAdapter) return a.controller;
    return null;
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.error, required this.onRetry});

  final WebviewLoadError error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 32),
            const SizedBox(height: 8),
            Text('Failed to load ${error.url}'),
            const SizedBox(height: 4),
            Text(error.message,
                style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 12),
            TextButton(
              key: const Key('retry-button'),
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
