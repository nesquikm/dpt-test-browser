// AC-STE-257.2: BrowserTabBar tap/close/+ behaviour.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dpt_test_browser/shared/constants.dart';
import 'package:dpt_test_browser/tabs/tab_manager_cubit.dart';
import 'package:dpt_test_browser/ui/tab_bar.dart';

Future<void> _pumpTabBar(WidgetTester tester, TabManagerCubit cubit) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: BlocProvider<TabManagerCubit>.value(
          value: cubit,
          child: const BrowserTabBar(),
        ),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  group('BrowserTabBar', () {
    testWidgets('renders one chip per tab with title falling back to host',
        (tester) async {
      final cubit = TabManagerCubit();
      await cubit.openTab(Uri.parse('https://flutter.dev/'));
      await cubit.openTab(Uri.parse('https://example.com/'));
      cubit.setTitle(cubit.state.tabs[0].id, 'Flutter');

      await _pumpTabBar(tester, cubit);

      expect(find.text('Flutter'), findsOneWidget);
      expect(find.text('example.com'), findsOneWidget);

      await cubit.close();
    });

    testWidgets('tap on a non-active tab fires selectTab', (tester) async {
      final cubit = TabManagerCubit();
      await cubit.openTab(Uri.parse('https://a.com/'));
      await cubit.openTab(Uri.parse('https://b.com/')); // b is active
      final aId = cubit.state.tabs[0].id;

      await _pumpTabBar(tester, cubit);

      await tester.tap(find.byKey(Key('tab-$aId')));
      await tester.pump();

      expect(cubit.state.activeTabId, equals(aId));
      await cubit.close();
    });

    testWidgets('close button fires closeTab', (tester) async {
      final cubit = TabManagerCubit();
      await cubit.openTab(Uri.parse('https://a.com/'));
      await cubit.openTab(Uri.parse('https://b.com/'));
      final aId = cubit.state.tabs[0].id;

      await _pumpTabBar(tester, cubit);

      await tester.tap(find.byKey(Key('close-$aId')));
      await tester.pump();

      expect(cubit.state.tabs.length, equals(1));
      expect(
        cubit.state.tabs.first.url,
        equals(Uri.parse('https://b.com/')),
      );
      await cubit.close();
    });

    testWidgets('+ button fires openTab(kDefaultNewTabUrl)', (tester) async {
      final cubit = TabManagerCubit();
      await _pumpTabBar(tester, cubit);

      await tester.tap(find.byKey(const Key('new-tab-button')));
      await tester.pump();

      expect(cubit.state.tabs.length, equals(1));
      expect(cubit.state.tabs.first.url, equals(kDefaultNewTabUrl));
      expect(cubit.state.activeTabId, equals(cubit.state.tabs.first.id));
      await cubit.close();
    });

    testWidgets('shows a loading spinner while a tab isLoading', (tester) async {
      final cubit = TabManagerCubit();
      await cubit.openTab(Uri.parse('https://a.com/'));
      cubit.setLoading(cubit.state.tabs.first.id, true);

      await _pumpTabBar(tester, cubit);

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await cubit.close();
    });
  });
}
