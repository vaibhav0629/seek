import 'package:geolocator/geolocator.dart';
import 'package:seek/features/clubs/domain/entities/club.dart';

typedef NearbyClub = ({Club club, double distanceKm});

List<NearbyClub> findNearbyClubs(
  List<Club> clubs, {
  required double latitude,
  required double longitude,
  required double radiusKm,
  String query = '',
}) {
  final text = query.trim().toLowerCase();
  final results = <NearbyClub>[];
  for (final club in clubs) {
    if (club.isPrivate || !club.hasLocation) continue;
    if (!'${club.name} ${club.sport} ${club.city}'.toLowerCase().contains(
      text,
    )) {
      continue;
    }
    final distance =
        Geolocator.distanceBetween(
          latitude,
          longitude,
          club.latitude!,
          club.longitude!,
        ) /
        1000;
    if (distance <= radiusKm) results.add((club: club, distanceKm: distance));
  }
  results.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
  return results;
}
