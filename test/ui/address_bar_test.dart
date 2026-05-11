// AC-STE-257.3 + AC-STE-257.4: AddressBar behaviour.
// AC-STE-260.4: AddressBar rebinds to active tab's adapter on tab switch.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dpt_test_browser/browser/webview_adapter.dart';
import 'package:dpt_test_browser/tabs/tab.dart';
import 'package:dpt_test_browser/tabs/tab_manager_cubit.dart';
import 'package:dpt_test_browser/ui/address_bar.dart';
import 'package:dpt_test_browser/ui/browser_shell.dart';

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

  // ---------------------------------------------------------------------------
  // AC-STE-260.4: tap back/forward/reload after each selectTab — taps must
  // land on the new active tab's adapter, not the previously-active one.
  // Driven through the full BrowserShell so the address-bar adapter sink
  // wiring (shell-held Map + ValueNotifier) is exercised end-to-end.
  // ---------------------------------------------------------------------------

  group('AddressBar — adapter rebinding on tab switch (AC-STE-260.4)', () {
    testWidgets(
        'tapping back/forward/reload after selectTab increments counters '
        'on the NEW active tab\'s adapter, not the previous',
        (tester) async {
      final cubit = TabManagerCubit();
      await cubit.openTab(Uri.parse('https://a.com/'));
      await cubit.openTab(Uri.parse('https://b.com/'));

      final adapters = <FakeWebviewAdapter>[];
      WebviewAdapter makeAdapter() {
        final a = FakeWebviewAdapter();
        adapters.add(a);
        return a;
      }

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<TabManagerCubit>.value(
            value: cubit,
            child: BrowserShell(adapterFactory: makeAdapter),
          ),
        ),
      );
      await tester.pump();
      await tester.pump();

      // Both adapters are constructed under keep-alive; b is initially active.
      expect(adapters.length, equals(2));
      final aAdapter = adapters[0];
      final bAdapter = adapters[1];

      // Tap on the active (b) tab — counters land on b.
      await tester.tap(find.byTooltip('Back'));
      await tester.tap(find.byTooltip('Forward'));
      await tester.tap(find.byTooltip('Reload'));
      await tester.pump();

      expect(bAdapter.goBackCalls, equals(1));
      expect(bAdapter.goForwardCalls, equals(1));
      expect(bAdapter.reloadCalls, equals(1));
      expect(aAdapter.goBackCalls, equals(0),
          reason: 'a is inactive — no taps should reach a yet');
      expect(aAdapter.goForwardCalls, equals(0));
      expect(aAdapter.reloadCalls, equals(0));

      // Switch to a; tap again — counters must increment on a, NOT b.
      cubit.selectTab(cubit.state.tabs[0].id);
      await tester.pump();
      await tester.pump();

      await tester.tap(find.byTooltip('Back'));
      await tester.tap(find.byTooltip('Forward'));
      await tester.tap(find.byTooltip('Reload'));
      await tester.pump();

      expect(aAdapter.goBackCalls, equals(1),
          reason: 'after selectTab(a), Back must land on a');
      expect(aAdapter.goForwardCalls, equals(1));
      expect(aAdapter.reloadCalls, equals(1));
      expect(bAdapter.goBackCalls, equals(1),
          reason: 'b counters must NOT advance after switching away');
      expect(bAdapter.goForwardCalls, equals(1));
      expect(bAdapter.reloadCalls, equals(1));

      // Switch back to b; tap once more — b advances, a does not.
      cubit.selectTab(cubit.state.tabs[1].id);
      await tester.pump();
      await tester.pump();

      await tester.tap(find.byTooltip('Reload'));
      await tester.pump();

      expect(bAdapter.reloadCalls, equals(2),
          reason: 'after selectTab(b), Reload must land on b again');
      expect(aAdapter.reloadCalls, equals(1),
          reason: 'a must NOT advance after switching away');

      await cubit.close();
    });
  });
}
