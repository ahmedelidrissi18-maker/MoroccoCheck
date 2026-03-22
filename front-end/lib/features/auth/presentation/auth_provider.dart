import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/network/api_service.dart';
import '../domain/auth_repository.dart';
import '../data/auth_repository_impl.dart';
import '../../../shared/models/user.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository;
  bool _isDisposed = false;

  AuthProvider({AuthRepository? authRepository})
    : _authRepository = authRepository ?? AuthRepositoryImpl();

  // State
  User? _user;
  bool _isLoading = false;
  String? _error;

  // Getters
  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;

  // Private method to set loading state
  void _setLoading(bool value) {
    _isLoading = value;
    if (!_isDisposed) notifyListeners();
  }

  // Private method to set error
  void _setError(String? errorMessage) {
    _error = errorMessage;
    if (!_isDisposed) notifyListeners();
  }

  // Clear error
  void clearError() {
    _error = null;
    if (!_isDisposed) notifyListeners();
  }

  String _normalizeErrorMessage(Object error, {required bool isRegister}) {
    if (error is ApiException) {
      final message = error.message.toLowerCase();

      if (error.code == 'EMAIL_ALREADY_USED') {
        return 'Cette adresse email est deja utilisee.';
      }

      if (error.code == 'INVALID_CREDENTIALS') {
        return 'Email ou mot de passe incorrect.';
      }

      if (error.isUnauthorized) {
        return 'Email ou mot de passe incorrect.';
      }

      if (error.isForbidden) {
        return 'Votre compte est indisponible pour le moment.';
      }

      if (error.statusCode == 409) {
        return isRegister
            ? 'Cette adresse email est deja utilisee.'
            : 'Conflit de session detecte.';
      }

      if (error.statusCode == 400) {
        if (message.contains('email')) {
          return 'Veuillez verifier votre adresse email.';
        }
        if (message.contains('password') || message.contains('mot de passe')) {
          return 'Veuillez verifier votre mot de passe.';
        }
        return isRegister
            ? 'Certaines informations du formulaire sont invalides.'
            : 'Informations de connexion invalides.';
      }

      if (error.type == DioExceptionType.connectionError ||
          error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout ||
          error.type == DioExceptionType.sendTimeout) {
        return 'Impossible de contacter le serveur. Verifiez votre connexion.';
      }

      if (error.message.isNotEmpty) {
        return error.message;
      }
    }

    String errorMessage = error.toString();
    if (errorMessage.startsWith('Exception: ')) {
      errorMessage = errorMessage.substring(11);
    }
    return errorMessage;
  }

  /// Login user with email and password
  /// Optionally redirects to home if successful
  Future<bool> login(
    String email,
    String password, {
    BuildContext? context,
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      final user = await _authRepository.login(email, password);
      _user = user;

      _setLoading(false);

      // Redirect to home if context is provided and user is logged in
      if (context != null && _user != null && context.mounted) {
        context.go('/home');
      }

      return true;
    } catch (e) {
      _setLoading(false);
      _setError(_normalizeErrorMessage(e, isRegister: false));
      return false;
    }
  }

  /// Register new user
  /// Optionally redirects to home if successful
  Future<bool> register(
    String firstName,
    String lastName,
    String email,
    String password, {
    BuildContext? context,
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      final user = await _authRepository.register(
        firstName,
        lastName,
        email,
        password,
      );
      _user = user;

      _setLoading(false);

      // Redirect to home if context is provided and user is logged in
      if (context != null && _user != null && context.mounted) {
        context.go('/home');
      }

      return true;
    } catch (e) {
      _setLoading(false);
      _setError(_normalizeErrorMessage(e, isRegister: true));
      return false;
    }
  }

  /// Logout current user
  /// Optionally redirects to login if context is provided
  Future<bool> logout({BuildContext? context}) async {
    try {
      _setLoading(true);
      _setError(null);

      await _authRepository.logout();
      _user = null;

      _setLoading(false);

      // Redirect to login if context is provided
      if (context != null && context.mounted) {
        context.go('/login');
      }

      return true;
    } catch (e) {
      _setLoading(false);
      _setError(_normalizeErrorMessage(e, isRegister: false));
      return false;
    }
  }

  /// Auto login - check if user is already logged in
  /// Redirects to home if user is logged in, otherwise redirects to login
  Future<void> autoLogin({BuildContext? context}) async {
    try {
      _setLoading(true);
      _setError(null);

      final currentUser = await _authRepository.getCurrentUser();

      if (currentUser != null) {
        _user = currentUser;

        // Redirect to home if user is logged in
        if (context != null && context.mounted) {
          context.go('/home');
        }
      } else {
        _user = null;

        // Redirect to welcome if user is not logged in
        if (context != null && context.mounted) {
          context.go('/welcome');
        }
      }

      _setLoading(false);
    } catch (e) {
      _setLoading(false);
      _setError(_normalizeErrorMessage(e, isRegister: false));
      _user = null;

      // Redirect to welcome on error
      if (context != null && context.mounted) {
        context.go('/welcome');
      }
    }
  }

  /// Refresh current user data
  Future<void> refreshUser() async {
    try {
      _setError(null);
      final currentUser = await _authRepository.getCurrentUser();
      _user = currentUser;
      notifyListeners();
    } catch (e) {
      _setError(_normalizeErrorMessage(e, isRegister: false));
      _user = null;
      if (!_isDisposed) notifyListeners();
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}
