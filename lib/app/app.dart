import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seek/app/router/app_router.dart';

/// The root widget of seek.
class SeekApp extends ConsumerWidget {
  const SeekApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: 'seek',
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      // Temporary theme. It is replaced by lib/app/theme.dart in the next step.
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
    );
  }
}
