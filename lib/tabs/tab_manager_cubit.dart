import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:dpt_test_browser/tabs/tab.dart';
import 'package:dpt_test_browser/tabs/tab_manager_state.dart';

class TabManagerCubit extends Cubit<TabManagerState> {
  TabManagerCubit() : super(const TabManagerState(tabs: []));

  static const _uuid = Uuid();

  /// Opens a new tab at [url] and selects it.
  ///
  /// Returns a [Future] so a future webview-adapter FR can `await` the
  /// initial load without changing this signature; today the body is
  /// synchronous.
  Future<void> openTab(Uri url) async {
    final id = _uuid.v4();
    final newTab = BrowserTab(id: id, url: url);
    emit(state.copyWith(
      tabs: [...state.tabs, newTab],
      activeTabId: id,
    ));
  }

  /// Closes [tabId] and, if it was the active tab, selects its predecessor
  /// by index; falls back to the first remaining tab when there is no
  /// predecessor. Emits nothing when [tabId] is not found.
  void closeTab(String tabId) {
    final closedIndex = state.tabs.indexWhere((t) => t.id == tabId);
    if (closedIndex == -1) return;

    final newTabs = state.tabs.where((t) => t.id != tabId).toList();

    if (newTabs.isEmpty) {
      emit(state.copyWith(tabs: [], activeTabId: null));
      return;
    }

    if (state.activeTabId != tabId) {
      emit(state.copyWith(tabs: newTabs));
      return;
    }

    // Prefer the tab at the predecessor index in the pre-removal list (its
    // identity is unchanged by removing a later element); fall back to the
    // first remaining tab when the closed tab was at the front.
    final successor = closedIndex > 0 ? state.tabs[closedIndex - 1] : newTabs.first;
    emit(state.copyWith(tabs: newTabs, activeTabId: successor.id));
  }

  /// Makes [tabId] the active tab. Emits nothing when [tabId] is not found.
  void selectTab(String tabId) {
    if (!_tabExists(tabId)) return;
    emit(state.copyWith(activeTabId: tabId));
  }

  /// Updates the URL of [tabId]. Emits nothing when [tabId] is not found.
  void navigate(String tabId, Uri url) {
    _updateTab(tabId, (t) => t.copyWith(url: url));
  }

  /// Updates the loading state of [tabId]. Emits nothing when [tabId] is not found.
  void setLoading(String tabId, bool isLoading) {
    _updateTab(tabId, (t) => t.copyWith(isLoading: isLoading));
  }

  /// Updates the title of [tabId]. Emits nothing when [tabId] is not found.
  /// Lands `WebviewAdapter.onTitleChanged` events on the cubit.
  void setTitle(String tabId, String title) {
    _updateTab(tabId, (t) => t.copyWith(title: title));
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  bool _tabExists(String tabId) => state.tabs.any((t) => t.id == tabId);

  /// Applies [update] to the tab with [tabId] and emits the new state.
  /// No-ops when [tabId] is not found.
  void _updateTab(String tabId, BrowserTab Function(BrowserTab) update) {
    if (!_tabExists(tabId)) return;
    final newTabs = state.tabs
        .map((t) => t.id == tabId ? update(t) : t)
        .toList();
    emit(state.copyWith(tabs: newTabs));
  }
}
