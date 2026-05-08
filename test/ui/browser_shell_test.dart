// AC-STE-257.1 + AC-STE-257.7: BrowserShell layout, empty-state, tab switch.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dpt_test_browser/shared/constants.dart';
import 'package:dpt_test_browser/tabs/tab_manager_cubit.dart';
import 'package:dpt_test_browser/ui/address_bar.dart';
import 'package:dpt_test_browser/ui/browser_shell.dart';
import 'package:dpt_test_browser/ui/tab_bar.dart';
import 'package:dpt_test_browser/ui/tab_view.dart';

import '../fakes/fake_webview_adapter.dart';

Future<List<FakeWebviewAdapter>> _pumpShell(
  WidgetTester tester,
  TabManagerCubit cubit,
) async {
  final adapters = <FakeWebviewAdapter>[];
  await tester.pumpWidget(
    MaterialApp(
      home: BlocProvider<TabManagerCubit>.value(
        value: cubit,
        child: BrowserShell(
          adapterFactory: () {
            final a = FakeWebviewAdapter();
            adapters.add(a);
            return a;
          },
        ),
      ),
    ),
  );
  await tester.pump();
  return adapters;
}

void main() {
  group('BrowserShell empty state', () {
    testWidgets('renders the New tab button when activeTabId is null',
        (tester) async {
      final cubit = TabManagerCubit();
      await _pumpShell(tester, cubit);

      expect(find.text('No open tabs'), findsOneWidget);
      expect(find.byKey(const Key('new-tab-empty')), findsOneWidget);
      expect(find.byType(BrowserTabBar), findsNothing);
      expect(find.byType(BrowserTabView), findsNothing);

      await cubit.close();
    });

    testWidgets('tapping the empty-state button opens a new tab',
        (tester) async {
      final cubit = TabManagerCubit();
      await _pumpShell(tester, cubit);

      await tester.tap(find.byKey(const Key('new-tab-empty')));
      await tester.pump();

      expect(cubit.state.tabs.length, equals(1));
      expect(cubit.state.tabs.first.url, equals(kDefaultNewTabUrl));
      expect(cubit.state.activeTabId, equals(cubit.state.tabs.first.id));

      await cubit.close();
    });
  });

  group('BrowserShell with tabs', () {
    testWidgets('with one tab, layout shows TabBar / AddressBar / TabView',
        (tester) async {
      final cubit = TabManagerCubit();
      await cubit.openTab(Uri.parse('https://a.com/'));
      await _pumpShell(tester, cubit);

      // Two pumps: one to mount the TabView (which sets the adapterSink),
      // one to let ValueListenableBuilder rebuild with the real AddressBar.
      await tester.pump();

      expect(find.byType(BrowserTabBar), findsOneWidget);
      expect(find.byType(AddressBar), findsOneWidget);
      expect(find.byType(BrowserTabView), findsOneWidget);

      await cubit.close();
    });

    testWidgets('switching active tab disposes the previous TabView\'s adapter',
        (tester) async {
      final cubit = TabManagerCubit();
      await cubit.openTab(Uri.parse('https://a.com/'));
      await cubit.openTab(Uri.parse('https://b.com/')); // b is active
      final adapters = await _pumpShell(tester, cubit);
      await tester.pump();

      // First adapter built was for tab b (the only active one); a hasn't
      // built one yet because it was never the active tab.
      expect(adapters.length, equals(1));
      final bAdapter = adapters[0];
      expect(bAdapter.disposed, isFalse);

      // Switch to tab a — its TabView mounts (new adapter), b's disposes.
      cubit.selectTab(cubit.state.tabs[0].id);
      await tester.pump();
      await tester.pump();

      expect(bAdapter.disposed, isTrue);
      expect(adapters.length, equals(2));
      expect(adapters[1].disposed, isFalse);

      await cubit.close();
    });
  });
}
