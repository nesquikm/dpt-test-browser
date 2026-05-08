// AC-STE-254.2 through AC-STE-254.7: TabManagerCubit behaviour.
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:dpt_test_browser/tabs/tab_manager_cubit.dart';
import 'package:dpt_test_browser/tabs/tab_manager_state.dart';

void main() {
  // ---------------------------------------------------------------------------
  // AC-STE-254.2: initial state
  // ---------------------------------------------------------------------------
  group('TabManagerCubit initial state', () {
    test('tabs is empty list', () {
      final cubit = TabManagerCubit();
      expect(cubit.state.tabs, isEmpty);
      cubit.close();
    });

    test('activeTabId is null', () {
      final cubit = TabManagerCubit();
      expect(cubit.state.activeTabId, isNull);
      cubit.close();
    });
  });

  // ---------------------------------------------------------------------------
  // AC-STE-254.3: openTab
  // ---------------------------------------------------------------------------
  group('openTab', () {
    blocTest<TabManagerCubit, TabManagerState>(
      'appends a new tab and emits state',
      build: () => TabManagerCubit(),
      act: (cubit) => cubit.openTab(Uri.parse('https://example.com')),
      expect: () => [
        predicate<TabManagerState>((s) {
          return s.tabs.length == 1 &&
              s.tabs.first.url == Uri.parse('https://example.com') &&
              s.activeTabId == s.tabs.first.id;
        }),
      ],
    );

    blocTest<TabManagerCubit, TabManagerState>(
      'sets activeTabId to the new tab id',
      build: () => TabManagerCubit(),
      act: (cubit) => cubit.openTab(Uri.parse('https://example.com')),
      verify: (cubit) {
        expect(cubit.state.activeTabId, equals(cubit.state.tabs.first.id));
      },
    );

    blocTest<TabManagerCubit, TabManagerState>(
      'two consecutive openTab calls produce tabs with different ids',
      build: () => TabManagerCubit(),
      act: (cubit) async {
        await cubit.openTab(Uri.parse('https://example.com'));
        await cubit.openTab(Uri.parse('https://flutter.dev'));
      },
      verify: (cubit) {
        expect(cubit.state.tabs.length, equals(2));
        expect(cubit.state.tabs[0].id, isNot(equals(cubit.state.tabs[1].id)));
        // Last opened tab is active.
        expect(cubit.state.activeTabId, equals(cubit.state.tabs[1].id));
      },
    );
  });

  // ---------------------------------------------------------------------------
  // AC-STE-254.4: closeTab
  // ---------------------------------------------------------------------------
  group('closeTab', () {
    blocTest<TabManagerCubit, TabManagerState>(
      'happy: closes a non-active tab, list shrinks by 1, active stays',
      build: () => TabManagerCubit(),
      act: (cubit) async {
        await cubit.openTab(Uri.parse('https://a.com')); // tab A
        await cubit.openTab(Uri.parse('https://b.com')); // tab B (now active)
        // close A (non-active)
        final tabAId = cubit.state.tabs[0].id;
        cubit.closeTab(tabAId);
      },
      verify: (cubit) {
        expect(cubit.state.tabs.length, equals(1));
        expect(cubit.state.tabs.first.url, equals(Uri.parse('https://b.com')));
        expect(cubit.state.activeTabId, equals(cubit.state.tabs.first.id));
      },
    );

    blocTest<TabManagerCubit, TabManagerState>(
      'active-close-with-predecessor: close active tab B, A becomes active',
      build: () => TabManagerCubit(),
      act: (cubit) async {
        await cubit.openTab(Uri.parse('https://a.com')); // tab A
        await cubit.openTab(Uri.parse('https://b.com')); // tab B (now active)
        final tabBId = cubit.state.activeTabId!;
        cubit.closeTab(tabBId);
      },
      verify: (cubit) {
        expect(cubit.state.tabs.length, equals(1));
        expect(cubit.state.tabs.first.url, equals(Uri.parse('https://a.com')));
        expect(cubit.state.activeTabId, equals(cubit.state.tabs.first.id));
      },
    );

    blocTest<TabManagerCubit, TabManagerState>(
      'active-close-with-no-predecessor: close active tab A, B becomes active (falls back to first remaining)',
      build: () => TabManagerCubit(),
      act: (cubit) async {
        await cubit.openTab(Uri.parse('https://a.com')); // tab A
        final tabAId = cubit.state.tabs.first.id;
        await cubit.openTab(Uri.parse('https://b.com')); // tab B (now active)
        cubit.selectTab(tabAId);                          // select A
        cubit.closeTab(tabAId);                           // close A (active, no predecessor)
      },
      verify: (cubit) {
        expect(cubit.state.tabs.length, equals(1));
        expect(cubit.state.tabs.first.url, equals(Uri.parse('https://b.com')));
        expect(cubit.state.activeTabId, equals(cubit.state.tabs.first.id));
      },
    );

    blocTest<TabManagerCubit, TabManagerState>(
      'empty-after-close: closing the only tab yields empty list + null activeTabId',
      build: () => TabManagerCubit(),
      act: (cubit) async {
        await cubit.openTab(Uri.parse('https://a.com'));
        final tabId = cubit.state.tabs.first.id;
        cubit.closeTab(tabId);
      },
      verify: (cubit) {
        expect(cubit.state.tabs, isEmpty);
        expect(cubit.state.activeTabId, isNull);
      },
    );

    blocTest<TabManagerCubit, TabManagerState>(
      'no-op: closeTab on a missing id emits no state',
      build: () => TabManagerCubit(),
      act: (cubit) => cubit.closeTab('non-existent-id'),
      expect: () => <TabManagerState>[],
    );
  });

  // ---------------------------------------------------------------------------
  // AC-STE-254.5: selectTab
  // ---------------------------------------------------------------------------
  group('selectTab', () {
    blocTest<TabManagerCubit, TabManagerState>(
      'sets activeTabId to the specified id',
      build: () => TabManagerCubit(),
      act: (cubit) async {
        await cubit.openTab(Uri.parse('https://a.com')); // tab A
        final tabAId = cubit.state.tabs.first.id;
        await cubit.openTab(Uri.parse('https://b.com')); // tab B (now active)
        cubit.selectTab(tabAId);
      },
      verify: (cubit) {
        expect(cubit.state.activeTabId, equals(cubit.state.tabs.first.id));
        expect(cubit.state.tabs.first.url, equals(Uri.parse('https://a.com')));
      },
    );

    blocTest<TabManagerCubit, TabManagerState>(
      'no-op: selectTab on a missing id emits no state',
      build: () => TabManagerCubit(),
      act: (cubit) => cubit.selectTab('non-existent-id'),
      expect: () => <TabManagerState>[],
    );
  });

  // ---------------------------------------------------------------------------
  // AC-STE-254.6: navigate
  // ---------------------------------------------------------------------------
  group('navigate', () {
    blocTest<TabManagerCubit, TabManagerState>(
      'updates the matching tab url',
      build: () => TabManagerCubit(),
      act: (cubit) async {
        await cubit.openTab(Uri.parse('https://a.com'));
        final tabId = cubit.state.tabs.first.id;
        cubit.navigate(tabId, Uri.parse('https://b.com'));
      },
      verify: (cubit) {
        expect(cubit.state.tabs.first.url, equals(Uri.parse('https://b.com')));
      },
    );

    blocTest<TabManagerCubit, TabManagerState>(
      'no-op: navigate on a missing id emits no state',
      build: () => TabManagerCubit(),
      act: (cubit) => cubit.navigate('non-existent-id', Uri.parse('https://b.com')),
      expect: () => <TabManagerState>[],
    );
  });

  // ---------------------------------------------------------------------------
  // AC-STE-254.7: setLoading
  // ---------------------------------------------------------------------------
  group('setLoading', () {
    blocTest<TabManagerCubit, TabManagerState>(
      'sets isLoading to true for the matching tab',
      build: () => TabManagerCubit(),
      act: (cubit) async {
        await cubit.openTab(Uri.parse('https://a.com'));
        final tabId = cubit.state.tabs.first.id;
        cubit.setLoading(tabId, true);
      },
      verify: (cubit) {
        expect(cubit.state.tabs.first.isLoading, isTrue);
      },
    );

    blocTest<TabManagerCubit, TabManagerState>(
      'sets isLoading back to false for the matching tab',
      build: () => TabManagerCubit(),
      act: (cubit) async {
        await cubit.openTab(Uri.parse('https://a.com'));
        final tabId = cubit.state.tabs.first.id;
        cubit.setLoading(tabId, true);
        cubit.setLoading(tabId, false);
      },
      verify: (cubit) {
        expect(cubit.state.tabs.first.isLoading, isFalse);
      },
    );

    blocTest<TabManagerCubit, TabManagerState>(
      'no-op: setLoading on a missing id emits no state',
      build: () => TabManagerCubit(),
      act: (cubit) => cubit.setLoading('non-existent-id', true),
      expect: () => <TabManagerState>[],
    );
  });

  // ---------------------------------------------------------------------------
  // AC-STE-254.9: setTitle (added by STE-257 to land onTitleChanged events).
  // ---------------------------------------------------------------------------
  group('setTitle', () {
    blocTest<TabManagerCubit, TabManagerState>(
      'sets the title for the matching tab',
      build: () => TabManagerCubit(),
      act: (cubit) async {
        await cubit.openTab(Uri.parse('https://a.com'));
        final tabId = cubit.state.tabs.first.id;
        cubit.setTitle(tabId, 'A site');
      },
      verify: (cubit) {
        expect(cubit.state.tabs.first.title, equals('A site'));
      },
    );

    blocTest<TabManagerCubit, TabManagerState>(
      'overwrites a previous title',
      build: () => TabManagerCubit(),
      act: (cubit) async {
        await cubit.openTab(Uri.parse('https://a.com'));
        final tabId = cubit.state.tabs.first.id;
        cubit.setTitle(tabId, 'first');
        cubit.setTitle(tabId, 'second');
      },
      verify: (cubit) {
        expect(cubit.state.tabs.first.title, equals('second'));
      },
    );

    blocTest<TabManagerCubit, TabManagerState>(
      'no-op: setTitle on a missing id emits no state',
      build: () => TabManagerCubit(),
      act: (cubit) => cubit.setTitle('non-existent-id', 'whatever'),
      expect: () => <TabManagerState>[],
    );
  });
}
