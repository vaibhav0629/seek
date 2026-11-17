
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seek/app/router/app_router.dart';
import 'package:seek/app/theme.dart';

/// The root widget of Playvo.
class SeekApp extends ConsumerWidget {
  const SeekApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Playvo',
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      theme: AppTheme.darkTheme,
    );
  }
}
