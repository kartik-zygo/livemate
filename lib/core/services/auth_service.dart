import 'dart:async';

import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

import '../../data/models/user_model.dart';
import '../../data/repositories/user_repository.dart';
import '../network/api_exception.dart';

/// Owns the Supabase session and the MyFlat Homes profile behind it.
///
/// Supabase issues and auto-refreshes the JWT; the Dio interceptor reads that
/// token straight off `Supabase.instance.client`, so this service never has to
/// push it anywhere. What it does own is the *profile* — fetched on sign-in via
/// `GET /auth/me`, which is also the call that creates the row server-side.
class AuthService extends GetxService {
  AuthService(this._users);

  final UserRepository _users;

  final Rxn<UserModel> user = Rxn<UserModel>();
  final RxBool bootstrapping = true.obs;

  StreamSubscription<sb.AuthState>? _authSub;

  sb.SupabaseClient get _client => sb.Supabase.instance.client;

  sb.Session? get session => _client.auth.currentSession;

  String? get accessToken => session?.accessToken;

  bool get isSignedIn => session != null;

  UserModel? get profile => user.value;

  String? get userId => user.value?.id;

  @override
  void onInit() {
    super.onInit();
    _authSub = _client.auth.onAuthStateChange.listen(_onAuthChanged);
  }

  @override
  void onClose() {
    _authSub?.cancel();
    super.onClose();
  }

  /// Called once at startup: if a session survived the last run, hydrate the
  /// profile before the splash screen decides where to send the user.
  Future<AuthService> init() async {
    if (isSignedIn) {
      try {
        user.value = await _users.bootstrap();
      } on ApiException {
        // A stale token or an unreachable API should not trap the user on the
        // splash screen — the auth gate will route them to sign-in.
        user.value = null;
      }
    }
    bootstrapping.value = false;
    return this;
  }

  void _onAuthChanged(sb.AuthState state) {
    switch (state.event) {
      case sb.AuthChangeEvent.signedOut:
        user.value = null;
      case sb.AuthChangeEvent.signedIn:
      case sb.AuthChangeEvent.tokenRefreshed:
      case sb.AuthChangeEvent.userUpdated:
        break;
      default:
        break;
    }
  }

  Future<UserModel> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    final res = await _client.auth.signUp(
      email: email.trim(),
      password: password,
      data: {'full_name': fullName.trim()},
    );

    // Projects with email confirmation on return no session; sign in explicitly
    // so the flow works either way.
    if (res.session == null) {
      await _client.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
    }

    return _loadProfile();
  }

  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    await _client.auth.signInWithPassword(
      email: email.trim(),
      password: password,
    );
    return _loadProfile();
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
    user.value = null;
  }

  /// Deletes the account server-side, then drops the local session.
  Future<void> deleteAccount() async {
    await _users.deleteMe();
    try {
      await _client.auth.signOut();
    } catch (_) {
      // The user no longer exists, so Supabase may reject the server-side
      // sign-out; the local session is cleared regardless.
    }
    user.value = null;
  }

  Future<void> sendPasswordReset(String email) =>
      _client.auth.resetPasswordForEmail(email.trim());

  /// `GET /auth/me` — the first authenticated call, and the one that upserts
  /// the local user row on the backend.
  Future<UserModel> _loadProfile() async {
    final profile = await _users.bootstrap();
    user.value = profile;
    return profile;
  }

  Future<UserModel> refreshProfile() async {
    final fresh = await _users.me();
    user.value = fresh;
    return fresh;
  }

  /// Lets the profile editor push its result back without a second GET.
  void setProfile(UserModel value) => user.value = value;

  /// Asks Supabase for a fresh token; used by the Dio interceptor on a 401.
  Future<String?> refreshToken() async {
    try {
      final res = await _client.auth.refreshSession();
      return res.session?.accessToken;
    } catch (_) {
      return null;
    }
  }

  /// Turns Supabase's own auth errors into the same shape the rest of the app
  /// already knows how to display.
  static ApiException describeAuthError(Object error) {
    if (error is sb.AuthApiException) {
      final msg = error.message.toLowerCase();
      if (msg.contains('invalid login')) {
        return const ApiException(
          message: 'That email and password do not match.',
          statusCode: 401,
        );
      }
      if (msg.contains('already registered') ||
          msg.contains('already been registered')) {
        return const ApiException(
          message: 'An account already exists for that email. Sign in instead.',
          statusCode: 409,
        );
      }
      if (msg.contains('email not confirmed')) {
        return const ApiException(
          message: 'Confirm your email address, then sign in.',
          statusCode: 403,
        );
      }
      return ApiException(message: error.message, statusCode: 400);
    }
    if (error is sb.AuthException) {
      return ApiException(message: error.message, statusCode: 400);
    }
    return ApiException.from(error);
  }
}
