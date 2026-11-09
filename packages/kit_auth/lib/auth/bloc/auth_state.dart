import 'package:kit_core/base_bloc/base_state.dart';
import '../domain/entity/profile_entity.dart';

class AuthState extends BaseState {
  final bool isAuthenticated;
  final Profile? profile;

  const AuthState({
    this.isAuthenticated = false,
    this.profile,
    super.isLoading,
    super.errorMessage,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    Profile? profile,
    bool? isLoading,
    String? errorMessage,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      profile: profile ?? this.profile,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [...super.props, isAuthenticated, profile];
}
