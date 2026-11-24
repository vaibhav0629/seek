import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:seek/app/router/app_routes.dart';
import 'package:seek/features/clubs/data/club_location_service.dart';
import 'package:seek/features/clubs/data/club_providers.dart';
import 'package:seek/features/clubs/domain/nearby_clubs.dart';
import 'package:seek/features/clubs/presentation/screens/club_card.dart';

class NearbyClubsScreen extends ConsumerStatefulWidget {
  const NearbyClubsScreen({super.key});

  @override
  ConsumerState<NearbyClubsScreen> createState() => _NearbyClubsScreenState();
}

class _NearbyClubsScreenState extends ConsumerState<NearbyClubsScreen> {
  Position? _position;
  bool _loading = false;
  bool _settings = false;
  String? _error;
  double _radius = 10;
  String _query = '';

  Future<void> _locate() async {
    setState(() {
      _loading = true;
      _error = null;
      _settings = false;
    });
    try {
      final position = await ClubLocationService().locate();
      if (mounted) setState(() => _position = position);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error is ClubLocationException
            ? error.message
            : 'Gagal mengambil lokasi. Periksa izin lokasi dan coba lagi.';
        _settings = error is ClubLocationException && error.openSettings;
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final clubs = ref.watch(clubsProvider);
    final position = _position;
    return Scaffold(
      appBar: AppBar(title: const Text('Search Near Me')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [colors.primaryContainer, colors.secondaryContainer],
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.radar_rounded,
                  size: 44,
                  color: colors.onPrimaryContainer,
                ),
                const SizedBox(height: 16),
                Text(
                  'Temukan teman main\ndi sekitarmu',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colors.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Cari club terdekat dan mulai olahraga bersama. Lokasi hanya diakses saat kamu menekan tombol.',
                  style: TextStyle(color: colors.onPrimaryContainer),
                ),
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: _loading ? null : _locate,
                  icon: _loading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.my_location),
                  label: Text(
                    _loading
                        ? 'Mencari lokasi...'
                        : position == null
                        ? 'Gunakan lokasi saya'
                        : 'Perbarui lokasi',
                  ),
                ),
                if (position != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Lokasi ditemukan • Akurasi ±${position.accuracy.round()} m',
                    style: TextStyle(color: colors.onPrimaryContainer),
                  ),
                ],
              ],
            ),
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_error!, style: TextStyle(color: colors.error)),
                  if (_settings)
                    TextButton(
                      onPressed: () async {
                        try {
                          await Geolocator.openAppSettings();
                        } catch (_) {
                          /* Browser settings must be opened manually. */
                        }
                      },
                      child: const Text('Buka pengaturan'),
                    ),
                ],
              ),
            ),
          const SizedBox(height: 24),
          TextField(
            onChanged: (value) => setState(() => _query = value),
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'Cari nama club, olahraga, atau kota',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(16)),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Radius pencarian',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [5, 10, 25, 50, 100]
                .map(
                  (radius) => ChoiceChip(
                    label: Text('$radius km'),
                    selected: _radius == radius,
                    onSelected: (_) =>
                        setState(() => _radius = radius.toDouble()),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 20),
          if (position == null)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                children: [
                  Icon(Icons.explore_outlined, size: 48),
                  SizedBox(height: 12),
                  Text(
                    'Mulai dari lokasimu',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Tekan “Gunakan lokasi saya” untuk melihat club dalam radius pilihanmu.',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          else
            clubs.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, _) => Column(
                children: [
                  const Text('Club belum berhasil dimuat.'),
                  TextButton(
                    onPressed: () => ref.invalidate(clubsProvider),
                    child: const Text('Coba lagi'),
                  ),
                ],
              ),
              data: (items) {
                final results = findNearbyClubs(
                  items,
                  latitude: position.latitude,
                  longitude: position.longitude,
                  radiusKm: _radius,
                  query: _query,
                );
<<<<<<< HEAD
                final missing = items.where((club) => !club.hasLocation).length;
=======
                final missing = items
                    .where((club) => !club.isPrivate && !club.hasLocation)
                    .length;
>>>>>>> main
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${results.length} club ditemukan',
                      style: Theme.of(context).textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const Text(
                      'Terdekat dahulu • Jarak garis lurus, bukan rute perjalanan',
                    ),
                    if (missing > 0)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          '$missing club belum memiliki koordinat dan tidak ditampilkan.',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    const SizedBox(height: 12),
                    if (results.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 32),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(Icons.travel_explore, size: 48),
                              SizedBox(height: 12),
                              Text('Belum ada club di area ini'),
                              SizedBox(height: 8),
                              Text(
                                'Perbesar radius atau ubah kata pencarian.',
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    for (final result in results)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Chip(
                              avatar: const Icon(
                                Icons.near_me_outlined,
                                size: 16,
                              ),
                              label: Text(
                                '${result.distanceKm.toStringAsFixed(1)} km dari lokasimu',
                              ),
                            ),
                            ClubCard(
                              club: result.club,
                              onTap: () =>
                                  context.push(AppRoutes.club(result.club.id)),
                            ),
                          ],
                        ),
                      ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }
}
