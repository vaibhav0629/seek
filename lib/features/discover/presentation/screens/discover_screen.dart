import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:seek/core/config/app_options.dart';
import 'package:seek/features/clubs/data/club_providers.dart';
import 'package:seek/features/clubs/domain/entities/club.dart';
import 'package:seek/features/clubs/presentation/screens/club_card.dart';
import 'package:seek/features/clubs/presentation/screens/club_empty_state.dart';

/// Discover clubs using search and sport/city filters.
class DiscoverScreen extends ConsumerStatefulWidget {
  const DiscoverScreen({super.key});

  @override
  ConsumerState<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends ConsumerState<DiscoverScreen> {
  final _searchController = TextEditingController();
  String? _selectedSport;
  String? _selectedCity;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Club> _filterClubs(List<Club> clubs) {
    final query = _searchController.text.trim().toLowerCase();
    return clubs.where((club) {
      final matchesQuery =
          query.isEmpty ||
          club.name.toLowerCase().contains(query) ||
          club.sport.toLowerCase().contains(query) ||
          club.city.toLowerCase().contains(query);
      return matchesQuery &&
          (_selectedSport == null || club.sport == _selectedSport) &&
          (_selectedCity == null || club.city == _selectedCity);
    }).toList();
  }

  void _clearFilters() => setState(() {
    _searchController.clear();
    _selectedSport = null;
    _selectedCity = null;
  });

  Future<void> _showFilters(List<Club> clubs) async {
    final sports = clubs.map((club) => club.sport).toSet().toList()..sort();
    const cities = AppOptions.cities;
    var sport = _selectedSport;
    var city = _selectedCity;

    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Filter club',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String?>(
                  initialValue: sport,
                  decoration: const InputDecoration(
                    labelText: 'Olahraga',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    const DropdownMenuItem<String?>(
                      value: null,
                      child: Text('Semua olahraga'),
                    ),
                    ...sports.map(
                      (value) => DropdownMenuItem<String?>(
                        value: value,
                        child: Text(value),
                      ),
                    ),
                  ],
                  onChanged: (value) => setSheetState(() => sport = value),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String?>(
                  initialValue: city,
                  decoration: const InputDecoration(
                    labelText: 'Kota',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    const DropdownMenuItem<String?>(
                      value: null,
                      child: Text('Semua kota'),
                    ),
                    ...cities.map(
                      (value) => DropdownMenuItem<String?>(
                        value: value,
                        child: Text(value),
                      ),
                    ),
                  ],
                  onChanged: (value) => setSheetState(() => city = value),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () {
                      setState(() {
                        _selectedSport = sport;
                        _selectedCity = city;
                      });
                      Navigator.pop(context);
                    },
                    child: const Text('Terapkan filter'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final clubsAsync = ref.watch(clubsProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Discover'),
        actions: [
          IconButton(
            tooltip: 'Buat club',
            onPressed: () => context.push('/clubs/create'),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: clubsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => const Center(child: Text('Gagal memuat club')),
        data: (clubs) {
          final filtered = _filterClubs(clubs);
          final hasFilter =
              _searchController.text.trim().isNotEmpty ||
              _selectedSport != null ||
              _selectedCity != null;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Cari club, olahraga, atau kota',
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: _searchController.text.isEmpty
                              ? null
                              : IconButton(
                                  onPressed: () => _searchController.clear(),
                                  icon: const Icon(Icons.clear),
                                ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filledTonal(
                      tooltip: 'Filter',
                      onPressed: clubs.isEmpty
                          ? null
                          : () => _showFilters(clubs),
                      icon: Badge(
                        isLabelVisible:
                            _selectedSport != null || _selectedCity != null,
                        child: const Icon(Icons.tune),
                      ),
                    ),
                  ],
                ),
              ),
              if (hasFilter)
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: _clearFilters,
                    icon: const Icon(Icons.filter_alt_off, size: 18),
                    label: const Text('Hapus pencarian/filter'),
                  ),
                ),
              Expanded(
                child: filtered.isEmpty
                    ? ClubEmptyState(
                        message: hasFilter
                            ? 'Club yang sesuai tidak ditemukan'
                            : 'Belum ada club publik',
                        actionLabel: hasFilter ? 'Hapus filter' : 'Buat Club',
                        onAction: hasFilter
                            ? _clearFilters
                            : () => context.push('/clubs/create'),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(top: 4, bottom: 24),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final club = filtered[index];
                          return ClubCard(
                            club: club,
                            onTap: () => context.push('/clubs/${club.id}'),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
