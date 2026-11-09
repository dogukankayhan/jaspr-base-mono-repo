sealed class CompareEvent {
  const CompareEvent();
}

class ComparePokemonRemoved extends CompareEvent {
  const ComparePokemonRemoved(this.pokemonId);
  final int pokemonId;
}
