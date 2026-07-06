import 'package:artid/data/services/auth_api_service.dart';
import 'package:artid/domain/models/user.dart';
import 'package:artid/providers/auth/auth_state.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() => const AuthState();

  void enterAsGuest() {
    state = const AuthState(isGuest: true);
  }

  Future<bool> login({required String email, required String password}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final response = await ref.read(authApiServiceProvider).login(email, password);
      state = AuthState(
        user: User(id: response.userId, name: response.name, email: response.email),
        token: response.token,
      );
      return true;
    } on DioException catch (e) {
      String msg = 'Errore di connessione';
      if (e.response?.statusCode == 401) msg = 'Credenziali non valide';
      state = state.copyWith(isLoading: false, errorMessage: msg);
      return false;
    } catch (_) {
      state = state.copyWith(isLoading: false, errorMessage: 'Errore di connessione');
      return false;
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final response = await ref.read(authApiServiceProvider).register(name, email, password);
      state = AuthState(
        user: User(id: response.userId, name: response.name, email: response.email),
        token: response.token,
      );
      return true;
    } on DioException catch (e) {
      String msg = 'Errore di connessione';
      if (e.response?.statusCode == 409) msg = 'Email già registrata';
      state = state.copyWith(isLoading: false, errorMessage: msg);
      return false;
    } catch (_) {
      state = state.copyWith(isLoading: false, errorMessage: 'Errore di connessione');
      return false;
    }
  }

  void logout() {
    state = const AuthState();
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);
