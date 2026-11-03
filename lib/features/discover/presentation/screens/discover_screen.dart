import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seek/features/clubs/data/club_providers.dart';

/// Starter screen and example of the pattern every screen uses:
/// 1. extend ConsumerWidget (it gives you "ref")
/// 2. ask for data with ref.watch(someProvider)
/// 3. use .when(...) to show data, a loading spinner, or an error
class DiscoverScreen extends ConsumerWidget {
  const DiscoverScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clubs = ref.watch(clubsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Discover')),
      body: clubs.when(
        data: (list) => ListView(
          children: [
            for (final c in list)
              ListTile(
                title: Text(c.name),
                subtitle: Text('${c.sport} - ${c.city}'),
              ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}