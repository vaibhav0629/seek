
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seek/features/clubs/data/club_providers.dart';

class DiscoverScreen extends ConsumerStatefulWidget {
  const DiscoverScreen({super.key});

  @override
  ConsumerState<DiscoverScreen> createState() =>
      _DiscoverScreenState();
}

class _DiscoverScreenState extends ConsumerState<DiscoverScreen> {
  // SEEK COLOR PALETTE
  static const Color background = Color(0xFF192C38);
  static const Color surface = Color(0xFF06384D);
  static const Color surface2 = Color(0xFF11617A);
  static const Color primary = Color(0xFFF2FF38);
  static const Color textSecondary = Color(0xFFA9C1CA);
  static const Color border = Color(0xFF285365);

  final TextEditingController searchController =
      TextEditingController();

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

  Widget sectionTitle(String title, String trailing) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 19,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          trailing,
          style: const TextStyle(
            color: primary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // HERO BANNER
  Widget buildHeroBanner() {
    return Container(
      width: double.infinity,
      height: 215,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF06384D),
            Color(0xFF11617A),
            Color(0xFF192C38),
          ],
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: border),
      ),
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          Positioned(
            right: -20,
            bottom: -25,
            child: Icon(
              Icons.sports_tennis_rounded,
              size: 145,
              color: Colors.white.withValues(alpha: 0.10),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'FIND YOUR\nNEXT GAME.',
                style: TextStyle(
                  fontSize: 27,
                  height: 1.15,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 9),
              const Text(
                'Discover sports, meet people,\nand play together.',
                style: TextStyle(
                  fontSize: 12,
                  height: 1.4,
                  color: textSecondary,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Explore Now  →',
                  style: TextStyle(
                    color: background,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // SEARCH BAR
  Widget buildSearchBar() {
    return Container(
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
            color: primary,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  // POPULAR SPORTS
  Widget buildSportsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        sectionTitle('Popular Sports', 'Explore'),
        const SizedBox(height: 17),
        SizedBox(
          height: 95,
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
                                ? primary
                                : border,
                          ),
                        ),
                        child: Icon(
                          sport['icon'],
                          color: isSelected
                              ? background
                              : Colors.white,
                          size: 26,
                        ),
                      ),
                      const SizedBox(height: 7),
                      Text(
                        sport['name'],
                        style: TextStyle(
                          color: isSelected
                              ? primary
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
      ],
    );
  }

  // COMMUNITY CARD
  Widget buildClubCard(dynamic club) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: surface2,
              borderRadius: BorderRadius.circular(17),
            ),
            child: Icon(
              getSportIcon(club.sport),
              color: primary,
              size: 30,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  club.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  club.sport,
                  style: const TextStyle(
                    color: primary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      color: textSecondary,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        club.city,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: textSecondary,
                          fontSize: 11,
                        ),
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
              horizontal: 14,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              color: primary,
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Text(
              'Explore',
              style: TextStyle(
                color: background,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
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
                  club.sport.toLowerCase() ==
                      selectedSport.toLowerCase();

              final matchesSearch =
                  club.name.toLowerCase().contains(
                        searchQuery.toLowerCase(),
                      ) ||
                  club.sport.toLowerCase().contains(
                        searchQuery.toLowerCase(),
                      ) ||
                  club.city.toLowerCase().contains(
                        searchQuery.toLowerCase(),
                      );

              return matchesSport && matchesSearch;
            }).toList();

            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      20, 16, 20, 0,
                    ),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        // HEADER
                        Row(
                          children: [
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: primary,
                                borderRadius:
                                    BorderRadius.circular(13),
                              ),
                              child: const Icon(
                                Icons.explore_rounded,
                                color: background,
                                size: 26,
                              ),
                            ),
                            const SizedBox(width: 11),
                            const Text(
                              'SEEK',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 25,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.5,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              decoration: BoxDecoration(
                                color: surface,
                                borderRadius:
                                    BorderRadius.circular(14),
                                border: Border.all(
                                  color: border,
                                ),
                              ),
                              child: IconButton(
                                onPressed: () {},
                                icon: const Icon(
                                  Icons.notifications_none_rounded,
                                  color: Colors.white,
                                  size: 25,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 25),

                        buildHeroBanner(),

                        const SizedBox(height: 22),

                        buildSearchBar(),

                        const SizedBox(height: 27),

                        buildSportsSection(),

                        const SizedBox(height: 27),

                        sectionTitle(
                          'Explore Communities',
                          '${filteredClubs.length} clubs',
                        ),

                        const SizedBox(height: 15),
                      ],
                    ),
                  ),
                ),

                // COMMUNITY LIST
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
                            color: primary,
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
                    padding: const EdgeInsets.fromLTRB(
                      20, 0, 20, 25,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          return buildClubCard(
                            filteredClubs[index],
                          );
                        },
                        childCount: filteredClubs.length,
                      ),
                    ),
                  ),
              ],
            );
          },

          // LOADING
          loading: () => const Center(
            child: CircularProgressIndicator(
              color: primary,
            ),
          ),

          // ERROR
          error: (error, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'Something went wrong: $error',
                style: const TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
