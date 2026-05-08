import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:dpt_test_browser/tabs/tab.dart';

part 'tab_manager_state.freezed.dart';

@freezed
abstract class TabManagerState with _$TabManagerState {
  const factory TabManagerState({
    required List<BrowserTab> tabs,
    String? activeTabId,
  }) = _TabManagerState;
}
