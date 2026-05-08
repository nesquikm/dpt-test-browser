import 'package:freezed_annotation/freezed_annotation.dart';

part 'tab.freezed.dart';

@freezed
abstract class BrowserTab with _$BrowserTab {
  const factory BrowserTab({
    required String id,
    required Uri url,
    String? title,
    @Default(false) bool isLoading,
  }) = _BrowserTab;
}
