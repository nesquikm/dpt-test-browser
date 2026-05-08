// AC-STE-257.1 + AC-STE-257.7: BrowserShell layout, empty-state, tab switch.
// AC-STE-260.1..6: tab keep-alive layout contract (Stack + keyed
// Visibility.maintain — the FR Notes-authorised fallback to literal
// IndexedStack; see lib/ui/browser_shell.dart class doc for rationale).

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

    testWidgets(
        'switching active tab does NOT dispose the previous TabView\'s '
        'adapter (AC-STE-260.1 — keep-alive contract supersedes M1)',
        (tester) async {
      final cubit = TabManagerCubit();
      await cubit.openTab(Uri.parse('https://a.com/'));
      await cubit.openTab(Uri.parse('https://b.com/')); // b is active
      final adapters = await _pumpShell(tester, cubit);
      await tester.pump();

      // AC-STE-260.5: every open tab gets its adapter constructed at mount
      // time, even ones that aren't currently active. So both a and b have
      // adapters after the initial pump.
      expect(adapters.length, equals(2),
          reason: 'all open tabs build adapters at mount under keep-alive');
      final aAdapter = adapters[0];
      final bAdapter = adapters[1];
      expect(aAdapter.disposed, isFalse);
      expect(bAdapter.disposed, isFalse);

      // Switch to tab a — under keep-alive, b's TabView stays mounted, b's
      // adapter is NOT disposed, and no new adapter is constructed.
      cubit.selectTab(cubit.state.tabs[0].id);
      await tester.pump();
      await tester.pump();

      expect(bAdapter.disposed, isFalse,
          reason: 'previous tab\'s adapter must survive the switch');
      expect(adapters.length, equals(2),
          reason: 'no new adapter on switch — both still alive');

      await cubit.close();
    });
  });

  // ---------------------------------------------------------------------------
  // AC-STE-260.1..6: keep-alive across tab switches. The shell uses a
  // `Stack` of keyed `Visibility.maintain` wrappers (the FR-STE-260
  // Notes-authorised fallback to literal `IndexedStack`) — see
  // `lib/ui/browser_shell.dart` class doc for why. The behavioural
  // contract — children stay mounted, only the active one paints, no
  // adapter dispose on switch — is identical and is what the AC asserts.
  // ---------------------------------------------------------------------------

  group('Keep-alive layout (FR-STE-260)', () {
    /// Returns the per-tab `Visibility.maintain` wrapper widget, found via
    /// its stable `tabview-vis-<id>` key. `skipOffstage: false` so we can
    /// reach wrappers whose child is currently invisible.
    Visibility wrapperFor(WidgetTester tester, String tabId) {
      return tester.widget<Visibility>(
        find.byKey(
          ValueKey<String>('tabview-vis-$tabId'),
          skipOffstage: false,
        ),
      );
    }

    testWidgets(
        'AC-STE-260.1: shell mounts one BrowserTabView per tab keyed by '
        'ValueKey(tabview-<id>); only the active tab is visible',
        (tester) async {
      final cubit = TabManagerCubit();
      await cubit.openTab(Uri.parse('https://a.com/'));
      await cubit.openTab(Uri.parse('https://b.com/'));
      await cubit.openTab(Uri.parse('https://c.com/'));
      await _pumpShell(tester, cubit);
      await tester.pump();

      // All three BrowserTabViews stay mounted — keep-alive.
      // `skipOffstage: false` is required because `Visibility.maintain`
      // wrappers hide off-stage children from default `find` traversal.
      expect(
        find.byType(BrowserTabView, skipOffstage: false),
        findsNWidgets(3),
      );

      // Each tab is keyed by ValueKey('tabview-<id>').
      for (final tab in cubit.state.tabs) {
        expect(
          find.byKey(
            ValueKey<String>('tabview-${tab.id}'),
            skipOffstage: false,
          ),
          findsOneWidget,
          reason: 'tab ${tab.id} should have a keyed BrowserTabView',
        );
      }

      // Only the active tab's wrapper is visible; others hold state but
      // do not paint. This is the keep-alive equivalent of
      // `IndexedStack.index` pointing at the active tab.
      for (final tab in cubit.state.tabs) {
        final isActive = tab.id == cubit.state.activeTabId;
        expect(wrapperFor(tester, tab.id).visible, equals(isActive),
            reason:
                'wrapper for ${tab.id} visible should equal isActive=$isActive');
      }

      await cubit.close();
    });

    testWidgets(
        'AC-STE-260.1: switching active tab updates which wrapper is '
        'visible without unmounting any BrowserTabView', (tester) async {
      final cubit = TabManagerCubit();
      await cubit.openTab(Uri.parse('https://a.com/'));
      await cubit.openTab(Uri.parse('https://b.com/'));
      await cubit.openTab(Uri.parse('https://c.com/'));
      final adapters = await _pumpShell(tester, cubit);
      await tester.pump();

      // Snapshot each tab's BrowserTabView Element before switching.
      final beforeByTabId = <String, Element>{
        for (final tab in cubit.state.tabs)
          tab.id: tester.element(find.byKey(
            ValueKey<String>('tabview-${tab.id}'),
            skipOffstage: false,
          )),
      };

      // Switch active across each of the three tabs.
      for (final target in cubit.state.tabs) {
        cubit.selectTab(target.id);
        await tester.pump();
        await tester.pump();

        // All three TabViews still mounted.
        expect(
          find.byType(BrowserTabView, skipOffstage: false),
          findsNWidgets(3),
        );

        // Visibility tracks the active tab.
        for (final tab in cubit.state.tabs) {
          final isActive = tab.id == target.id;
          expect(wrapperFor(tester, tab.id).visible, equals(isActive),
              reason: 'after selectTab(${target.id}), wrapper for ${tab.id} '
                  'visible must equal isActive=$isActive');
        }
      }

      // After the full switch sequence, the BrowserTabView Element identity
      // for each tab id is unchanged (AC-STE-260.2 widget surrogate: the
      // children are mounted-stable, not rebuilt fresh on each switch).
      for (final tab in cubit.state.tabs) {
        final after = tester.element(find.byKey(
          ValueKey<String>('tabview-${tab.id}'),
          skipOffstage: false,
        ));
        expect(identical(beforeByTabId[tab.id], after), isTrue,
            reason:
                'tab ${tab.id} BrowserTabView Element must remain identical '
                'across switches (keep-alive, not re-mounted)');
      }

      // No adapter was disposed across the whole switch sequence.
      for (final a in adapters) {
        expect(a.disposed, isFalse);
      }

      await cubit.close();
    });

    testWidgets(
        'AC-STE-260.2: switching A->B->A does not add new loadUrl calls '
        'on tab A\'s adapter (no reload via loadUrl on switch)',
        (tester) async {
      final cubit = TabManagerCubit();
      await cubit.openTab(Uri.parse('https://a.com/'));
      await cubit.openTab(Uri.parse('https://b.com/'));
      final adapters = await _pumpShell(tester, cubit);
      await tester.pump();

      // adapters[0] == tab a, adapters[1] == tab b (build order matches
      // state.tabs order under keep-alive).
      final aAdapter = adapters[0];
      final bAdapter = adapters[1];

      // Initial loadUrl fired once at construction for each tab.
      expect(aAdapter.loadUrlCalls, equals([Uri.parse('https://a.com/')]));
      expect(bAdapter.loadUrlCalls, equals([Uri.parse('https://b.com/')]));

      // Switch to a, then back to b, then to a again.
      cubit.selectTab(cubit.state.tabs[0].id); // a
      await tester.pump();
      await tester.pump();
      cubit.selectTab(cubit.state.tabs[1].id); // b
      await tester.pump();
      await tester.pump();
      cubit.selectTab(cubit.state.tabs[0].id); // a again
      await tester.pump();
      await tester.pump();

      // No additional loadUrl calls fired on either adapter due to switching.
      expect(aAdapter.loadUrlCalls, equals([Uri.parse('https://a.com/')]),
          reason: 'tab a must NOT reload-via-loadUrl on switches');
      expect(bAdapter.loadUrlCalls, equals([Uri.parse('https://b.com/')]),
          reason: 'tab b must NOT reload-via-loadUrl on switches');

      await cubit.close();
    });

    testWidgets(
        'AC-STE-260.3: closeTab disposes only the closed tab\'s adapter; '
        'remaining tabs\' adapters are untouched', (tester) async {
      final cubit = TabManagerCubit();
      await cubit.openTab(Uri.parse('https://a.com/'));
      await cubit.openTab(Uri.parse('https://b.com/'));
      await cubit.openTab(Uri.parse('https://c.com/'));
      final adapters = await _pumpShell(tester, cubit);
      await tester.pump();

      expect(adapters.length, equals(3));
      final aAdapter = adapters[0];
      final bAdapter = adapters[1];
      final cAdapter = adapters[2];

      // c is the active tab (last opened); close the inactive middle tab b.
      final bId = cubit.state.tabs[1].id;
      cubit.closeTab(bId);
      await tester.pump();
      await tester.pump();

      expect(
        find.byType(BrowserTabView, skipOffstage: false),
        findsNWidgets(2),
        reason: 'b\'s BrowserTabView is unmounted',
      );
      expect(bAdapter.disposed, isTrue,
          reason: 'closed tab\'s adapter must be disposed');
      expect(bAdapter.disposeCalls, equals(1),
          reason: 'adapter dispose must run exactly once');

      // a and c are untouched.
      expect(aAdapter.disposed, isFalse);
      expect(aAdapter.disposeCalls, equals(0));
      expect(cAdapter.disposed, isFalse);
      expect(cAdapter.disposeCalls, equals(0));

      await cubit.close();
    });

    testWidgets(
        'AC-STE-260.3 (hardening): closing the ACTIVE tab disposes only '
        'its adapter; AddressBar rebinds to the cubit-selected successor',
        (tester) async {
      final cubit = TabManagerCubit();
      await cubit.openTab(Uri.parse('https://a.com/'));
      await cubit.openTab(Uri.parse('https://b.com/'));
      await cubit.openTab(Uri.parse('https://c.com/'));
      final adapters = await _pumpShell(tester, cubit);
      await tester.pump();
      await tester.pump();

      final aAdapter = adapters[0];
      final bAdapter = adapters[1];
      final cAdapter = adapters[2];

      // c is the active tab (last opened); close it.
      final cId = cubit.state.tabs[2].id;
      cubit.closeTab(cId);
      await tester.pump();
      await tester.pump();

      // c's adapter is disposed; a and b are untouched.
      expect(cAdapter.disposed, isTrue);
      expect(cAdapter.disposeCalls, equals(1));
      expect(aAdapter.disposed, isFalse);
      expect(bAdapter.disposed, isFalse);

      // The cubit's `closeTab` rule selects the predecessor when the
      // active tab is closed, so b is the new active tab.
      expect(cubit.state.activeTabId, equals(cubit.state.tabs[1].id));

      // The address bar has rebound to b's adapter.
      final bar = tester.widget<AddressBar>(find.byType(AddressBar));
      expect(identical(bar.adapter, bAdapter), isTrue,
          reason: 'AddressBar must rebind to the new active (b) adapter '
              'after the previous active (c) was closed');

      await cubit.close();
    });

    testWidgets(
        'AC-STE-260.4: AddressBar adapter rebinds to the active tab\'s '
        'adapter on every selectTab', (tester) async {
      final cubit = TabManagerCubit();
      await cubit.openTab(Uri.parse('https://a.com/'));
      await cubit.openTab(Uri.parse('https://b.com/'));
      await cubit.openTab(Uri.parse('https://c.com/'));
      final adapters = await _pumpShell(tester, cubit);
      await tester.pump();
      // One extra pump to let the post-frame adapter publish settle.
      await tester.pump();

      final aAdapter = adapters[0];
      final bAdapter = adapters[1];
      final cAdapter = adapters[2];

      AddressBar currentBar() =>
          tester.widget<AddressBar>(find.byType(AddressBar));

      // c is active initially.
      expect(identical(currentBar().adapter, cAdapter), isTrue,
          reason: 'AddressBar starts bound to active (c)\'s adapter');

      cubit.selectTab(cubit.state.tabs[0].id); // a
      await tester.pump();
      await tester.pump();
      expect(identical(currentBar().adapter, aAdapter), isTrue,
          reason: 'AddressBar must rebind to a\'s adapter after selectTab(a)');

      cubit.selectTab(cubit.state.tabs[1].id); // b
      await tester.pump();
      await tester.pump();
      expect(identical(currentBar().adapter, bAdapter), isTrue,
          reason: 'AddressBar must rebind to b\'s adapter after selectTab(b)');

      cubit.selectTab(cubit.state.tabs[2].id); // c
      await tester.pump();
      await tester.pump();
      expect(identical(currentBar().adapter, cAdapter), isTrue,
          reason: 'AddressBar must rebind to c\'s adapter after selectTab(c)');

      await cubit.close();
    });

    testWidgets(
        'AC-STE-260.5: openTab on an already-populated shell appends a '
        'BrowserTabView; new adapter constructs and loadUrl fires '
        'immediately even if the new tab is not active at open time',
        (tester) async {
      final cubit = TabManagerCubit();
      await cubit.openTab(Uri.parse('https://a.com/'));
      final adapters = await _pumpShell(tester, cubit);
      await tester.pump();

      expect(adapters.length, equals(1));
      final aAdapter = adapters[0];
      final aId = cubit.state.tabs[0].id;

      // Open a second tab — openTab makes it the active one — then
      // immediately switch back to a so the new tab is inactive at the
      // moment we observe its adapter state.
      await cubit.openTab(Uri.parse('https://newtab.example/'));
      cubit.selectTab(aId);
      await tester.pump();
      await tester.pump();

      // The new tab's BrowserTabView is mounted alongside a's.
      expect(
        find.byType(BrowserTabView, skipOffstage: false),
        findsNWidgets(2),
      );

      // A new adapter was constructed for the new tab.
      expect(adapters.length, equals(2));
      final newAdapter = adapters[1];
      expect(newAdapter, isNot(same(aAdapter)));

      // loadUrl fired immediately on the new tab's adapter, even though
      // the new tab is not the active one.
      expect(
        newAdapter.loadUrlCalls.first,
        equals(Uri.parse('https://newtab.example/')),
        reason: 'background-loaded tab must still loadUrl at construction',
      );

      // a's adapter is untouched (still has its single original loadUrl).
      expect(aAdapter.loadUrlCalls, equals([Uri.parse('https://a.com/')]));

      await cubit.close();
    });

    testWidgets(
        'AC-STE-260.6: open 3 tabs -> switch across all 3 -> all 3 '
        'BrowserTabViews stay in tree; closing inactive disposes only '
        'its adapter; AddressBar adapter matches active tab\'s adapter '
        'after each selectTab', (tester) async {
      final cubit = TabManagerCubit();
      await cubit.openTab(Uri.parse('https://a.com/'));
      await cubit.openTab(Uri.parse('https://b.com/'));
      await cubit.openTab(Uri.parse('https://c.com/'));
      final adapters = await _pumpShell(tester, cubit);
      await tester.pump();
      await tester.pump();

      expect(adapters.length, equals(3));
      final aAdapter = adapters[0];
      final bAdapter = adapters[1];
      final cAdapter = adapters[2];
      final adaptersById = <String, FakeWebviewAdapter>{
        cubit.state.tabs[0].id: aAdapter,
        cubit.state.tabs[1].id: bAdapter,
        cubit.state.tabs[2].id: cAdapter,
      };

      AddressBar currentBar() =>
          tester.widget<AddressBar>(find.byType(AddressBar));

      // Switch active across each tab; after every switch all 3 TabViews
      // remain in the tree and AddressBar.adapter == that tab's adapter.
      for (final tab in cubit.state.tabs) {
        cubit.selectTab(tab.id);
        await tester.pump();
        await tester.pump();

        expect(
          find.byType(BrowserTabView, skipOffstage: false),
          findsNWidgets(3),
        );
        expect(identical(currentBar().adapter, adaptersById[tab.id]), isTrue,
            reason:
                'AddressBar.adapter must match active tab\'s adapter after '
                'selectTab(${tab.id})');
      }

      // Close the inactive middle tab.
      // (c is active after the loop above.)
      final bId = cubit.state.tabs[1].id;
      cubit.closeTab(bId);
      await tester.pump();
      await tester.pump();

      expect(
        find.byType(BrowserTabView, skipOffstage: false),
        findsNWidgets(2),
      );
      expect(bAdapter.disposed, isTrue);
      expect(bAdapter.disposeCalls, equals(1));
      expect(aAdapter.disposed, isFalse);
      expect(cAdapter.disposed, isFalse);

      await cubit.close();
    });
  });
}
