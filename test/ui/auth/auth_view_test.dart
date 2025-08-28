import 'package:app4_receitas/data/models/user_profile.dart';
import 'package:app4_receitas/data/repositories/auth_repository.dart';
import 'package:app4_receitas/data/services/auth_service.dart';
import 'package:app4_receitas/di/service_locator.dart';
import 'package:app4_receitas/ui/auth/auth_view.dart';
import 'package:app4_receitas/ui/auth/auth_view_model.dart';
import 'package:app4_receitas/utils/app_error.dart';
import 'package:either_dart/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import './auth_view_test.mocks.dart';

@GenerateMocks([AuthRepository, AuthService])
void main() {
  late MockAuthService mockAuthService;
  late MockAuthRepository mockAuthRepository;

  setUpAll(() {
    provideDummy<Either<AppError, UserProfile>>(
      Right(
        UserProfile(
          id: 'test_user_id',
          email: "test@email.com",
          username: 'testUser',
          avatarUrl: "image.com.br",
        ),
      ),
    );
  });

  setUp(() {
    mockAuthService = MockAuthService;
    mockAuthRepository = MockAuthRepository;

    Get.reset();
    getIt.reset();

    getIt.registerSingleton<AuthService>(mockAuthService);
    getIt.registerSingleton<AuthService>(mockAuthRepository);
    getIt.registerLazySingleton<AuthViewModel>(() => AuthViewModel());
  });

  tearDown(() {
    getIt.reset();
  });

  group('AuthView', () {
    testWidgets('deve verificar o titulo', (tester) async {
      await tester.pumpWidget(MaterialApp(home: AuthView()));

      await tester.pumpAndSettle();

      final titleFindler = find.text('Eu Amo Cozinhar');

      expect(titleFindler, findsOneWidget);
      final Text titleText = tester.widget(titleFindler);

      expect(titleText.style?.fontSize, 32); // valida se titulo tem tamanho 32
      expect(
        titleText.style?.fontFamily,
        equals(GoogleFonts.roboto().fontFamilyFallback),
      );
    });

    testWidgets("deve realizar login", (tester) async {
      await tester.pumpWidget(MaterialApp(home: AuthView()));

      await tester.pumpAndSettle();

      final emailField = find.byKey(ValueKey("emailField"));
      final passwordField = find.byKey(ValueKey("passwordField"));
      final submitButton = find.byKey(ValueKey("submitButton"));

      when(
        mockAuthRepository.signInWithPassword(
          email: "test@email.com",
          password: "test4@123",
        ),
      ).thenAnswer(
        (_) async => Right(
          UserProfile(
            id: 'test_user_id',
            email: "test@email.com",
            username: 'testUser',
            avatarUrl: "image.com.br",
          ),
        ),
      );

      await tester.enterText(emailField, "test@email.com");
      await tester.enterText(passwordField, "test4@123");
      await tester.pump();

      await tester.ensureVisible(submitButton);
      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      verify(
        mockAuthRepository.signInWithPassword(
          email: "test@email.com",
          password: "test4@123",
        ),
      );
    });
  });
}
