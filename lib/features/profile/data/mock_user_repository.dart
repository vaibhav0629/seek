import 'package:seek/core/mock/mock_data.dart';
import 'package:seek/core/mock/mock_support.dart';
import 'package:seek/features/profile/domain/entities/app_user.dart';
import 'package:seek/features/profile/domain/repositories/user_repository.dart';

class MockUserRepository implements UserRepository {
  final MockCollection<AppUser> _users = MockCollection<AppUser>(mockUsers);

  @override
  Stream<AppUser?> watchUser(String userId) {
    return _users.watch(
      (users) => users.where((u) => u.id == userId).firstOrNull,
    );
  }

  @override
  Future<void> saveUser(AppUser user) async {
    await mockDelay();
    _users.mutate((items) {
      final index = items.indexWhere((u) => u.id == user.id);
      if (index == -1) {
        items.add(user);
      } else {
        items[index] = user;
      }
    });
  }
}
