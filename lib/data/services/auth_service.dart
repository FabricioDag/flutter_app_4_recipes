import 'package:app4_receitas/di/service_locator.dart';
import 'package:app4_receitas/utils/app_error.dart';
import 'package:either_dart/either.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _supabaseClient = getIt<SupabaseClient>();

  User? get currentUser => _supabaseClient.auth.currentUser;

  Stream<AuthState> get authStateChanges =>
      _supabaseClient.auth.onAuthStateChange;

  Future<Either<AppError, AuthResponse>> signInWithPassword({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabaseClient.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return Right(response);
    } on AuthException catch (e) {
      switch (e.message) {
        case 'Invalid login credentials':
          return Left(
            AppError('Usuário não cadastrado ou credenciais inválidas'),
          );
        case 'Email not confirmed':
          return Left(AppError('E-mail não confirmado'));
        default:
          return Left(AppError('Erro ao fazer login', e));
      }
    }
  }

  // Retorna os valores da tabela profile
  Future<Either<AppError, Map<String, dynamic>?>> fetchUserProfile(
    String userId,
  ) async {
    try {
      final profile = await _supabaseClient
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();
      return Right(profile);
    } catch (e) {
      return Left(AppError('Erro ao carregar profile'));
    }
  }

  // Sign Up - Registro de novo usuário
  Future<Either<AppError, AuthResponse>> signUpWithPassword({
    required String email,
    required String password,
    required String username,
    required String avatarUrl,
  }) async {
    try {
      final response = await _supabaseClient.auth.signUp(
        email: email,
        password: password,
      );

      final user = response.user;
      if (user == null) {
        return Left(AppError('Não foi possível criar o usuário'));
      }

      await _supabaseClient.from('profiles').insert({
        'id': user.id,
        'username': username,
        'avatar_url': avatarUrl,
        'created_at': DateTime.now().toIso8601String(),
      });

      return Right(response);
    } on AuthException catch (e) {
      switch (e.message) {
        case 'User already registered':
          return Left(AppError('Usuário já cadastrado'));
        default:
          return Left(AppError('Erro ao registrar usuário', e));
      }
    } catch (e) {
      return Left(AppError('Erro inesperado ao registrar usuário', e));
    }
  }

  Future<Either<AppError, void>> signOut() async {
    try {
      await _supabaseClient.auth.signOut();
      return Right(null);
    } on AuthException catch (e) {
      return Left(AppError('Erro ao sair', e));
    } catch (e) {
      return Left(AppError('Erro inesperado ao sair', e));
    }
  }
}
