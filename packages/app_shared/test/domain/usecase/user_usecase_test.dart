import 'package:app_shared/domain/entity/user_profile.dart';
import 'package:app_shared/domain/repository/user_repository.dart';
import 'package:app_shared/domain/usecase/get_user_profile_usecase.dart';
import 'package:kit_network/core/network/error/api_error.dart';
import 'package:kit_network/core/utils/result.dart';
import 'package:test/test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'user_usecase_test.mocks.dart';

// ─── Fixtures ─────────────────────────────────────────────────────────────────

const _kProfile = UserProfile(
  firstName: 'John',
  lastName: 'Doe',
  email: 'john@example.com',
);

final _kError = ApiError(message: 'unauthorized');

// ─── Mocks ────────────────────────────────────────────────────────────────────

@GenerateMocks([UserRepository])
void main() {
  late MockUserRepository mockRepo;
  late GetUserProfileUseCase useCase;

  setUp(() {
    provideDummy<Result<UserProfile, ApiError>>(const Ok(_kProfile));
    mockRepo = MockUserRepository();
    useCase = GetUserProfileUseCase(mockRepo);
  });

  group('GetUserProfileUseCase', () {
    test('returns Result directly from repository on ok', () async {
      when(mockRepo.getProfile()).thenAnswer((_) async => const Ok(_kProfile));

      final result = await useCase();

      result.when(
        ok: (p) {
          expect(p.firstName, 'John');
          expect(p.email, 'john@example.com');
          expect(p.fullName, 'John Doe');
        },
        err: (_) => fail('expected ok'),
      );
    });

    test('returns Err Result from repository on failure', () async {
      when(mockRepo.getProfile()).thenAnswer((_) async => Err(_kError));

      final result = await useCase();

      result.when(
        ok: (_) => fail('expected err'),
        err: (e) => expect(e.message, 'unauthorized'),
      );
    });

    test('delegates to repository.getProfile', () async {
      when(mockRepo.getProfile()).thenAnswer((_) async => const Ok(_kProfile));

      await useCase();

      verify(mockRepo.getProfile()).called(1);
    });
  });
}
