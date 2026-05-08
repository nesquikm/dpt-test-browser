import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:dpt_test_browser/tabs/tab_manager_cubit.dart';
import 'package:dpt_test_browser/ui/browser_shell.dart';

void main() {
  runApp(const DptTestBrowserApp());
}

class DptTestBrowserApp extends StatelessWidget {
  const DptTestBrowserApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'dpt-test-browser',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: BlocProvider<TabManagerCubit>(
        create: (_) => TabManagerCubit(),
        child: const BrowserShell(),
      ),
    );
  }
}
