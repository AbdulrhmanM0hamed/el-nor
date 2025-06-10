import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/models/user_model.dart';
import '../../../../core/services/session_service.dart';
import '../../../../core/services/permissions_manager.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/services/preferences_service.dart';
import 'auth_state.dart';

class GlobalAuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;
  final SessionService _sessionService;
  final PermissionsManager _permissionsManager;
  final NotificationService _notificationService;
  late PreferencesService _preferencesService;
  static GlobalAuthCubit? _instance;

  GlobalAuthCubit._({
    required AuthRepository authRepository,
  })  : _authRepository = authRepository,
        _sessionService = SessionService(),
        _permissionsManager = PermissionsManager(),
        _notificationService = NotificationService(),
        super(AuthInitial());

  static GlobalAuthCubit get instance {
    if (_instance == null) {
      throw Exception(
          'GlobalAuthCubit not initialized. Call initialize() first.');
    }
    return _instance!;
  }

  static Future<void> initialize(
      {required AuthRepository authRepository}) async {
    if (_instance == null) {
      _instance = GlobalAuthCubit._(authRepository: authRepository);
      _instance!._preferencesService = await PreferencesService.getInstance();
      await _instance!.checkAuthState();
    }
  }

  UserModel? get currentUser =>
      state is AuthAuthenticated ? (state as AuthAuthenticated).user : null;

  bool get isGuest => state is AuthGuest;

  Future<void> checkAuthState() async {
    emit(const AuthLoading());

    try {
      final user = await _authRepository.getCurrentUser();

      if (user != null) {
        // Validate session and permissions
        final isValid = await _permissionsManager.validatePermissions(user.id);
        if (!isValid) {
          await _permissionsManager.setPermissions(user.id, user.role);
        }

        // Check if user has seen waiting dialog
        final hasSeenDialog =
            await _preferencesService.hasUserSeenWaitingDialog(user.id);
        emit(AuthAuthenticated(user, isNewUser: !hasSeenDialog));
      } else {
        emit(const AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> signIn({required String email, required String password}) async {
    emit(const AuthLoading());

    try {
      final user = await _authRepository.signIn(
        email,
        password,
      );

      // Set up session and permissions
      await _permissionsManager.setPermissions(user.id, user.role);

      // Get and save FCM token
      final fcmToken = await _notificationService.getFCMToken();
      await _notificationService.saveTokenToSupabase(fcmToken);

      // Check if user has seen waiting dialog
      final hasSeenDialog =
          await _preferencesService.hasUserSeenWaitingDialog(user.id);

      emit(AuthAuthenticated(user, isNewUser: !hasSeenDialog));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> signOut() async {
    emit(const AuthLoading());

    try {
      if (state is AuthGuest) {
        emit(const AuthUnauthenticated());
        return;
      }

      // Clear permissions and session first
      await _permissionsManager.clearPermissions();

      // Then clear user data and sign out
      await _authRepository.clearUserData();

      await _authRepository.signOut();

      emit(const AuthUnauthenticated());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  void enterAsGuest() {
    emit(const AuthGuest());
  }

  Future<void> updateProfile({
    required UserModel user,
    File? profileImage,
  }) async {
    try {
      final updatedUser = await _authRepository.updateProfile(
        user: user,
        profileImage: profileImage,
      );

      // Update permissions if role changed
      if (currentUser?.role != updatedUser.role) {
        await _permissionsManager.setPermissions(
            updatedUser.id, updatedUser.role);
      }

      emit(AuthAuthenticated(updatedUser, isNewUser: false));
    } catch (e) {
      rethrow;
    }
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await _authRepository.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> markWaitingDialogAsSeen() async {
    if (state is AuthAuthenticated) {
      final user = (state as AuthAuthenticated).user;
      await _preferencesService.markWaitingDialogAsSeen(user.id);
    }
  }
}
