import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:dpt_test_browser/browser/webview_adapter.dart';
import 'package:dpt_test_browser/shared/url.dart';
import 'package:dpt_test_browser/tabs/tab.dart';
import 'package:dpt_test_browser/tabs/tab_manager_cubit.dart';

/// Back / forward / reload buttons + URL `TextField`.
///
/// The URL field commits on `onSubmitted` (Enter):
///  - valid input ⇒ `cubit.navigate(activeId, parsedUri)` and
///    `adapter.loadUrl(parsedUri)` on the active tab's adapter.
///  - invalid input ⇒ "Invalid URL" SnackBar; cubit state unchanged.
///
/// All three nav buttons are always enabled — out-of-history calls are
/// webview-level no-ops in M1 (no `canGoBack` / `canGoForward` plumbing).
class AddressBar extends StatefulWidget {
  const AddressBar({
    super.key,
    required this.activeTab,
    required this.adapter,
  });

  final BrowserTab activeTab;

  /// The active tab's adapter. Nullable so the bar can render with disabled
  /// nav buttons during the one-frame gap between [BrowserTabView] mounting
  /// and publishing its adapter to the shell's sink.
  final WebviewAdapter? adapter;

  @override
  State<AddressBar> createState() => _AddressBarState();
}

class _AddressBarState extends State<AddressBar> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.activeTab.url.toString());
  }

  @override
  void didUpdateWidget(covariant AddressBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    // When the active tab changes (or its URL does), reset the field —
    // unless the user is mid-edit on the current tab.
    if (oldWidget.activeTab.id != widget.activeTab.id ||
        oldWidget.activeTab.url != widget.activeTab.url) {
      _controller.text = widget.activeTab.url.toString();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onSubmitted(String input) {
    final parsed = parseAddressBarInput(input);
    if (parsed == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid URL')),
      );
      return;
    }
    final cubit = context.read<TabManagerCubit>();
    cubit.navigate(widget.activeTab.id, parsed);
    widget.adapter?.loadUrl(parsed);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          IconButton(
            tooltip: 'Back',
            icon: const Icon(Icons.arrow_back),
            onPressed: widget.adapter?.goBack,
          ),
          IconButton(
            tooltip: 'Forward',
            icon: const Icon(Icons.arrow_forward),
            onPressed: widget.adapter?.goForward,
          ),
          IconButton(
            tooltip: 'Reload',
            icon: const Icon(Icons.refresh),
            onPressed: widget.adapter?.reload,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _controller,
              keyboardType: TextInputType.url,
              textInputAction: TextInputAction.go,
              decoration: const InputDecoration(
                isDense: true,
                border: OutlineInputBorder(),
                hintText: 'https://example.com',
              ),
              onSubmitted: _onSubmitted,
            ),
          ),
        ],
      ),
    );
  }
}
