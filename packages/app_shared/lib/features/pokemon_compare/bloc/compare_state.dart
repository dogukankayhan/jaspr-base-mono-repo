import 'package:app_shared/domain/entity/pokemon_entity.dart';
import 'package:kit_core/base_bloc/base_state.dart';

class CompareState extends BaseState {
  final List<Pokemon> pokemons;

  const CompareState({required this.pokemons});

  @override
  List<Object?> get props => [...super.props, pokemons];
}
