// AC-STE-257.3 + AC-STE-257.4: AddressBar behaviour.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dpt_test_browser/tabs/tab.dart';
import 'package:dpt_test_browser/tabs/tab_manager_cubit.dart';
import 'package:dpt_test_browser/ui/address_bar.dart';

import '../fakes/fake_webview_adapter.dart';

Future<void> _pumpAddressBar(
  WidgetTester tester, {
  required TabManagerCubit cubit,
  required BrowserTab activeTab,
  required FakeWebviewAdapter adapter,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: BlocProvider<TabManagerCubit>.value(
          value: cubit,
          child: AddressBar(activeTab: activeTab, adapter: adapter),
        ),
      ),
    ),
  );
}

void main() {
  group('AddressBar', () {
    testWidgets('renders the active tab\'s url in the TextField',
        (tester) async {
      final cubit = TabManagerCubit();
      await cubit.openTab(Uri.parse('https://flutter.dev/'));
      final tab = cubit.state.tabs.first;
      final adapter = FakeWebviewAdapter();

      await _pumpAddressBar(tester,
          cubit: cubit, activeTab: tab, adapter: adapter);

      expect(
        find.widgetWithText(TextField, 'https://flutter.dev/'),
        findsOneWidget,
      );

      await cubit.close();
      await adapter.dispose();
    });

    testWidgets('Enter on a valid URL fires cubit.navigate + adapter.loadUrl',
        (tester) async {
      final cubit = TabManagerCubit();
      await cubit.openTab(Uri.parse('https://a.com/'));
      final tab = cubit.state.tabs.first;
      final adapter = FakeWebviewAdapter();

      await _pumpAddressBar(tester,
          cubit: cubit, activeTab: tab, adapter: adapter);

      await tester.enterText(find.byType(TextField), 'flutter.dev/docs');
      await tester.testTextInput.receiveAction(TextInputAction.go);
      await tester.pump();

      expect(
        cubit.state.tabs.first.url,
        equals(Uri.parse('https://flutter.dev/docs')),
      );
      expect(
        adapter.loadUrlCalls,
        equals([Uri.parse('https://flutter.dev/docs')]),
      );

      await cubit.close();
      await adapter.dispose();
    });

    testWidgets(
        'Enter on invalid input shows snackbar and leaves cubit unchanged',
        (tester) async {
      final cubit = TabManagerCubit();
      await cubit.openTab(Uri.parse('https://a.com/'));
      final tab = cubit.state.tabs.first;
      final adapter = FakeWebviewAdapter();

      await _pumpAddressBar(tester,
          cubit: cubit, activeTab: tab, adapter: adapter);

      await tester.enterText(find.byType(TextField), 'not a url');
      await tester.testTextInput.receiveAction(TextInputAction.go);
      await tester.pump();

      expect(find.text('Invalid URL'), findsOneWidget);
      // cubit's URL hasn't changed.
      expect(cubit.state.tabs.first.url, equals(Uri.parse('https://a.com/')));
      expect(adapter.loadUrlCalls, isEmpty);

      await cubit.close();
      await adapter.dispose();
    });

    testWidgets(
        'back / forward / reload buttons hit the adapter', (tester) async {
      final cubit = TabManagerCubit();
      await cubit.openTab(Uri.parse('https://a.com/'));
      final tab = cubit.state.tabs.first;
      final adapter = FakeWebviewAdapter();

      await _pumpAddressBar(tester,
          cubit: cubit, activeTab: tab, adapter: adapter);

      await tester.tap(find.byTooltip('Back'));
      await tester.tap(find.byTooltip('Forward'));
      await tester.tap(find.byTooltip('Reload'));
      await tester.pump();

      expect(adapter.goBackCalls, equals(1));
      expect(adapter.goForwardCalls, equals(1));
      expect(adapter.reloadCalls, equals(1));

      await cubit.close();
      await adapter.dispose();
    });
  });
}
