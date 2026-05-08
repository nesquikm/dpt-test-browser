// AC-STE-257.5 + AC-STE-257.6: BrowserTabView stream subscription + error UI.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dpt_test_browser/browser/webview_adapter.dart';
import 'package:dpt_test_browser/tabs/tab_manager_cubit.dart';
import 'package:dpt_test_browser/ui/tab_view.dart';

import '../fakes/fake_webview_adapter.dart';

Future<({TabManagerCubit cubit, FakeWebviewAdapter adapter})> _pumpTabView(
  WidgetTester tester,
) async {
  final cubit = TabManagerCubit();
  await cubit.openTab(Uri.parse('https://a.com/'));
  final tab = cubit.state.tabs.first;
  final adapter = FakeWebviewAdapter();

  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: BlocProvider<TabManagerCubit>.value(
          value: cubit,
          child: BrowserTabView(
            tab: tab,
            adapterFactory: () => adapter,
          ),
        ),
      ),
    ),
  );
  await tester.pump();
  return (cubit: cubit, adapter: adapter);
}

void main() {
  group('BrowserTabView stream subscriptions', () {
    testWidgets('initState calls adapter.loadUrl with the tab\'s URL',
        (tester) async {
      final r = await _pumpTabView(tester);
      expect(r.adapter.loadUrlCalls, equals([Uri.parse('https://a.com/')]));
      await r.cubit.close();
    });

    testWidgets('onLoadStart sets isLoading=true', (tester) async {
      final r = await _pumpTabView(tester);
      r.adapter.emitLoadStart(Uri.parse('https://a.com/'));
      await tester.pump();
      expect(r.cubit.state.tabs.first.isLoading, isTrue);
      await r.cubit.close();
    });

    testWidgets('onLoadFinish sets isLoading=false', (tester) async {
      final r = await _pumpTabView(tester);
      r.adapter.emitLoadStart(Uri.parse('https://a.com/'));
      await tester.pump();
      r.adapter.emitLoadFinish(Uri.parse('https://a.com/'));
      await tester.pump();
      expect(r.cubit.state.tabs.first.isLoading, isFalse);
      await r.cubit.close();
    });

    testWidgets('onTitleChanged calls cubit.setTitle', (tester) async {
      final r = await _pumpTabView(tester);
      r.adapter.emitTitleChanged('Example Site');
      await tester.pump();
      expect(r.cubit.state.tabs.first.title, equals('Example Site'));
      await r.cubit.close();
    });

    testWidgets('onLoadFinish navigate updates the tab url for in-page nav',
        (tester) async {
      final r = await _pumpTabView(tester);
      r.adapter.emitLoadFinish(Uri.parse('https://a.com/page2'));
      await tester.pump();
      expect(
        r.cubit.state.tabs.first.url,
        equals(Uri.parse('https://a.com/page2')),
      );
      await r.cubit.close();
    });
  });

  group('BrowserTabView error UI', () {
    testWidgets('onLoadError shows inline error widget with Retry button',
        (tester) async {
      final r = await _pumpTabView(tester);

      r.adapter.emitLoadError(WebviewLoadError(
        url: Uri.parse('https://a.com/'),
        code: -1,
        message: 'host unreachable',
      ));
      await tester.pump(); // deliver microtask + setState
      await tester.pump(); // build the dirty subtree

      expect(find.textContaining('Failed to load'), findsOneWidget);
      expect(find.text('host unreachable'), findsOneWidget);
      expect(find.byKey(const Key('retry-button')), findsOneWidget);
      // setLoading(false) ran.
      expect(r.cubit.state.tabs.first.isLoading, isFalse);

      await r.cubit.close();
    });

    testWidgets('Retry calls adapter.loadUrl with the same url + clears error',
        (tester) async {
      final r = await _pumpTabView(tester);
      r.adapter.emitLoadError(WebviewLoadError(
        url: Uri.parse('https://a.com/'),
        code: -1,
        message: 'host unreachable',
      ));
      await tester.pump(); // deliver microtask + setState
      await tester.pump(); // build the dirty subtree

      // Initial load already fired one loadUrl call in initState.
      expect(r.adapter.loadUrlCalls.length, equals(1));

      await tester.tap(find.byKey(const Key('retry-button')));
      await tester.pump();

      expect(r.adapter.loadUrlCalls.length, equals(2));
      expect(
        r.adapter.loadUrlCalls.last,
        equals(Uri.parse('https://a.com/')),
      );
      // Error widget gone.
      expect(find.byKey(const Key('retry-button')), findsNothing);

      await r.cubit.close();
    });
  });

  group('BrowserTabView dispose', () {
    testWidgets('dispose cancels subscriptions and disposes the adapter',
        (tester) async {
      final r = await _pumpTabView(tester);
      // Replace the widget with an empty tree to trigger dispose.
      await tester.pumpWidget(const SizedBox.shrink());
      expect(r.adapter.disposed, isTrue);
      await r.cubit.close();
    });
  });
}
