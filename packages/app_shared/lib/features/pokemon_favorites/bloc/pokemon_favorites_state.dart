import 'package:kit_core/base_bloc/base_state.dart';
import '../../../domain/entity/pokemon_entity.dart';

class PokemonFavoritesState extends BaseState {
  final List<Pokemon> favorites;

  const PokemonFavoritesState({
    this.favorites = const [],
    super.isLoading,
    super.isValid,
    super.errorMessage,
  });

  PokemonFavoritesState copyWith({
    List<Pokemon>? favorites,
    bool? isLoading,
    bool? isValid,
    String? errorMessage,
    bool clearError = false,
  }) {
    return PokemonFavoritesState(
      favorites: favorites ?? this.favorites,
      isLoading: isLoading ?? this.isLoading,
      isValid: isValid ?? this.isValid,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  static const empty = PokemonFavoritesState();

  @override
  List<Object?> get props => [isLoading, isValid, errorMessage, favorites];
}
