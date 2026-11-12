
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seek/features/clubs/data/club_providers.dart';

class DiscoverScreen extends ConsumerStatefulWidget {
  const DiscoverScreen({super.key});

  @override
  ConsumerState<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends ConsumerState<DiscoverScreen> {
  static const Color background = Color(0xFF10051F);
  static const Color surface = Color(0xFF1D1035);
  static const Color surface2 = Color(0xFF25163B);
  static const Color primary = Color(0xFF7C3AED);
  static const Color accent = Color(0xFFA855F7);
  static const Color lavender = Color(0xFFC084FC);
  static const Color textSecondary = Color(0xFFB8A9CC);
  static const Color border = Color(0xFF392451);

  final TextEditingController searchController = TextEditingController();

  String selectedSport = 'All';
  String searchQuery = '';

  final List<Map<String, dynamic>> sports = [
    {'name': 'All', 'icon': Icons.grid_view_rounded},
    {'name': 'Padel', 'icon': Icons.sports_tennis_rounded},
    {'name': 'Basketball', 'icon': Icons.sports_basketball_rounded},
    {'name': 'Running', 'icon': Icons.directions_run_rounded},
    {'name': 'Pilates', 'icon': Icons.self_improvement_rounded},
    {'name': 'Mahjong', 'icon': Icons.extension_rounded},
  ];

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  IconData getSportIcon(String sport) {
    switch (sport.toLowerCase()) {
      case 'padel':
        return Icons.sports_tennis_rounded;
      case 'basketball':
        return Icons.sports_basketball_rounded;
      case 'running':
        return Icons.directions_run_rounded;
      case 'pilates':
        return Icons.self_improvement_rounded;
      case 'mahjong':
        return Icons.extension_rounded;
      default:
        return Icons.sports_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final clubs = ref.watch(clubsProvider);

    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: clubs.when(
          data: (list) {
            final filteredClubs = list.where((club) {
              final matchesSport = selectedSport == 'All' ||
                  club.sport.toLowerCase() == selectedSport.toLowerCase();

              final matchesSearch =
                  club.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
                  club.sport.toLowerCase().contains(searchQuery.toLowerCase()) ||
                  club.city.toLowerCase().contains(searchQuery.toLowerCase());

              return matchesSport && matchesSearch;
            }).toList();

            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // HEADER
                        Row(
                          children: [
                            Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [primary, accent],
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.sports_soccer_rounded,
                                color: Colors.white,
                                size: 23,
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              'Playvo',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                                letterSpacing: -0.7,
                              ),
                            ),
                            const Spacer(),
                            IconButton(
                              onPressed: () {},
                              icon: const Icon(
                                Icons.notifications_none_rounded,
                                color: Colors.white,
                                size: 27,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 22),

                        // HERO BANNER
                        Container(
                          width: double.infinity,
                          height: 175,
                          padding: const EdgeInsets.all(22),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFF5420A8),
                                Color(0xFF7C3AED),
                                Color(0xFFA855F7),
                              ],
                              begin: Alignment.bottomLeft,
                              end: Alignment.topRight,
                            ),
                            borderRadius: BorderRadius.circular(22),
                          ),
                          child: Stack(
                            children: [
                              Positioned(
                                right: -12,
                                bottom: -25,
                                child: Icon(
                                  Icons.sports_basketball_rounded,
                                  size: 145,
                                  color: Colors.white.withValues(alpha: 0.13),
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    'Play. Connect.\nMove Together.',
                                    style: TextStyle(
                                      fontSize: 25,
                                      height: 1.2,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  const Text(
                                    'Find your next game,\nmeet new people!',
                                    style: TextStyle(
                                      fontSize: 13,
                                      height: 1.5,
                                      color: Color(0xFFE9D5FF),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Text(
                                      'Explore now →',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 22),

                        // SEARCH BAR
                        Container(
                          decoration: BoxDecoration(
                            color: surface,
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: border),
                          ),
                          child: TextField(
                            controller: searchController,
                            style: const TextStyle(color: Colors.white),
                            onChanged: (value) {
                              setState(() {
                                searchQuery = value;
                              });
                            },
                            decoration: const InputDecoration(
                              hintText: 'Search clubs or sports...',
                              hintStyle: TextStyle(
                                color: textSecondary,
                                fontSize: 13,
                              ),
                              prefixIcon: Icon(
                                Icons.search_rounded,
                                color: lavender,
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                vertical: 16,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 26),

                        // SPORTS SECTION
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Popular Sports',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Explore',
                              style: TextStyle(
                                color: lavender,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        SizedBox(
                          height: 91,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: sports.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(width: 15),
                            itemBuilder: (context, index) {
                              final sport = sports[index];
                              final isSelected =
                                  selectedSport == sport['name'];

                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedSport = sport['name'];
                                  });
                                },
                                child: SizedBox(
                                  width: 65,
                                  child: Column(
                                    children: [
                                      AnimatedContainer(
                                        duration:
                                            const Duration(milliseconds: 200),
                                        width: 55,
                                        height: 55,
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? primary
                                              : surface2,
                                          borderRadius:
                                              BorderRadius.circular(18),
                                          border: Border.all(
                                            color: isSelected
                                                ? lavender
                                                : border,
                                          ),
                                        ),
                                        child: Icon(
                                          sport['icon'],
                                          color: Colors.white,
                                          size: 27,
                                        ),
                                      ),
                                      const SizedBox(height: 7),
                                      Text(
                                        sport['name'],
                                        style: TextStyle(
                                          color: isSelected
                                              ? lavender
                                              : textSecondary,
                                          fontSize: 10,
                                          fontWeight: isSelected
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                        ),
                                        textAlign: TextAlign.center,
                                        maxLines: 1,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                        const SizedBox(height: 25),

                        // CLUBS HEADER
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Explore Communities',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${filteredClubs.length} clubs',
                              style: const TextStyle(
                                color: lavender,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 14),
                      ],
                    ),
                  ),
                ),

                // CLUB LIST
                if (filteredClubs.isEmpty)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.search_off_rounded,
                            size: 45,
                            color: lavender,
                          ),
                          SizedBox(height: 12),
                          Text(
                            'No communities found',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            'Try another sport or keyword.',
                            style: TextStyle(
                              color: textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 25),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final club = filteredClubs[index];

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: surface,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: border),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 55,
                                  height: 55,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [primary, accent],
                                      begin: Alignment.bottomLeft,
                                      end: Alignment.topRight,
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Icon(
                                    getSportIcon(club.sport),
                                    color: Colors.white,
                                    size: 29,
                                  ),
                                ),
                                const SizedBox(width: 13),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        club.name,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        club.sport,
                                        style: const TextStyle(
                                          color: lavender,
                                          fontSize: 11,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.location_on_outlined,
                                            color: textSecondary,
                                            size: 13,
                                          ),
                                          const SizedBox(width: 3),
                                          Expanded(
                                            child: Text(
                                              club.city,
                                              style: const TextStyle(
                                                color: textSecondary,
                                                fontSize: 11,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: primary,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Text(
                                    'Explore',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                        childCount: filteredClubs.length,
                      ),
                    ),
                  ),
              ],
            );
          },
          loading: () => const Center(
            child: CircularProgressIndicator(color: accent),
          ),
          error: (error, _) => Center(
            child: Text(
              'Something went wrong: $error',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}
