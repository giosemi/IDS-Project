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

  Future<OtpSentResponse?> requestLoginOtp({required String email, required String password}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final response = await ref.read(authApiServiceProvider).requestLoginOtp(email.trim(), password);
      state = state.copyWith(isLoading: false);
      return response;
    } on DioException catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: _dioMessage(e, invalidCredentials: true));
      return null;
    } on FormatException catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: 'Risposta del server non valida: ${e.message}');
      return null;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: 'Errore imprevisto: $e');
      return null;
    }
  }

  Future<bool> verifyOtp({required String email, required String otp}) async {
    if (otp.length != 5) {
      state = state.copyWith(errorMessage: 'Codice OTP non valido');
      return false;
    }

    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final response = await ref.read(authApiServiceProvider).verifyOtp(email.trim(), otp);
      state = AuthState(
        user: User(id: response.userId, name: response.name, email: response.email),
        token: response.token,
      );
      return true;
    } on DioException catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: _dioMessage(e, invalidOtp: true));
      return false;
    } on FormatException catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: 'Risposta del server non valida: ${e.message}');
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: 'Errore imprevisto: $e');
      return false;
    }
  }

  Future<OtpSentResponse?> resendOtp({required String email}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final response = await ref.read(authApiServiceProvider).resendOtp(email.trim());
      state = state.copyWith(isLoading: false);
      return response;
    } on DioException catch (_) {
      state = state.copyWith(isLoading: false, errorMessage: 'Impossibile reinviare il codice');
      return null;
    } catch (_) {
      state = state.copyWith(isLoading: false, errorMessage: 'Errore di connessione');
      return null;
    }
  }

  Future<OtpSentResponse?> requestPasswordReset({required String email}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final response = await ref.read(authApiServiceProvider).requestPasswordReset(email.trim());
      state = state.copyWith(isLoading: false);
      return response;
    } on DioException catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: _dioMessage(e));
      return null;
    } catch (_) {
      state = state.copyWith(isLoading: false, errorMessage: 'Errore di connessione');
      return null;
    }
  }

  Future<bool> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    if (code.length != 5) {
      state = state.copyWith(errorMessage: 'Codice non valido');
      return false;
    }

    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await ref.read(authApiServiceProvider).resetPassword(
            email: email.trim(),
            code: code,
            newPassword: newPassword,
          );
      state = state.copyWith(isLoading: false);
      return true;
    } on DioException catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: _dioMessage(e, invalidOtp: true));
      return false;
    } catch (_) {
      state = state.copyWith(isLoading: false, errorMessage: 'Errore di connessione');
      return false;
    }
  }

  Future<AuthResponse?> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String institution,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final response = await ref.read(authApiServiceProvider).register(
            firstName: firstName,
            lastName: lastName,
            email: email,
            password: password,
            institution: institution,
          );
      state = state.copyWith(isLoading: false);
      return response;
    } on DioException catch (e) {
      String msg = _dioMessage(e);
      if (e.response?.statusCode == 409) msg = 'Email già registrata';
      state = state.copyWith(isLoading: false, errorMessage: msg);
      return null;
    } catch (_) {
      state = state.copyWith(isLoading: false, errorMessage: 'Errore di connessione');
      return null;
    }
  }

  void completeRegistration(AuthResponse response) {
    state = AuthState(
      user: User(id: response.userId, name: response.name, email: response.email),
      token: response.token,
    );
  }

  void logout() {
    state = const AuthState();
  }

  String _dioMessage(DioException e, {bool invalidCredentials = false, bool invalidOtp = false}) {
    final status = e.response?.statusCode;
    if (status == 401 && invalidCredentials) return 'Credenziali non valide';
    if (status == 401 && invalidOtp) return 'Codice OTP non valido o scaduto';
    if (e.type == DioExceptionType.connectionError || e.type == DioExceptionType.connectionTimeout) {
      return 'Impossibile raggiungere il server. Verifica che il backend sia avviato.';
    }
    if (status != null) return 'Errore del server ($status)';
    return 'Errore di connessione';
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);
