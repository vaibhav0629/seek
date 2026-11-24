import 'package:flutter_test/flutter_test.dart';
import 'package:seek/features/clubs/domain/entities/club.dart';
import 'package:seek/features/clubs/domain/nearby_clubs.dart';
import 'package:seek/features/clubs/data/mock_club_repository.dart';

void main() {
  Club club(String id, double? latitude, {bool private = false}) => Club(
    id: id,
    name: id,
    sport: 'Running',
    city: 'Jakarta',
    ownerId: 'owner',
    latitude: latitude,
    longitude: 0,
    isPrivate: private,
  );

  test('filters radius, missing/invalid locations and private clubs; sorts distance', () {
    final results = findNearbyClubs(
      [
        club('far', 0.08),
        club('near', 0.01),
        club('outside', 1),
        club('missing', null),
        club('invalid', 100),
        club('private', 0, private: true),
      ],
      latitude: 0,
      longitude: 0,
      radiusKm: 10,
    );
    expect(results.map((r) => r.club.id), ['near', 'far']);
    expect(results.first.distanceKm, closeTo(1.112, 0.01));
  });

  test('search is case insensitive and matches sport and city', () {
    for (final query in [' RUNNING ', 'jakarta', 'near']) {
      expect(
        findNearbyClubs(
          [club('near', 0)],
          latitude: 0,
          longitude: 0,
          radiusKm: 5,
          query: query,
        ),
        hasLength(1),
      );
    }
    expect(
      findNearbyClubs(
        [club('near', 0)],
        latitude: 0,
        longitude: 0,
        radiusKm: 5,
        query: 'padel',
      ),
      isEmpty,
    );
  });

  test(
    'coordinates survive map serialization and repository creation',
    () async {
      final original = club('Located club', 0.01);
      final restored = Club.fromMap(original.toMap(), 'restored');
      expect(restored.latitude, original.latitude);
      expect(restored.longitude, 0);
      expect(restored.hasLocation, isTrue);
      final repository = MockClubRepository();
      final id = await repository.createClub(original, ownerName: 'Owner');
      final saved = await repository.watchClub(id).first;
      expect(saved?.latitude, original.latitude);
      expect(saved?.longitude, original.longitude);
    },
  );
}
