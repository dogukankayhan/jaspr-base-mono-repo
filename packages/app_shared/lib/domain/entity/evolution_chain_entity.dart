class EvolutionChain {
  final int id;
  final EvolutionNode root;

  const EvolutionChain({required this.id, required this.root});

  List<List<EvolutionNode>> get allPaths {
    final paths = <List<EvolutionNode>>[];
    _findPaths(root, [], paths);
    return paths;
  }

  void _findPaths(
    EvolutionNode node,
    List<EvolutionNode> currentPath,
    List<List<EvolutionNode>> paths,
  ) {
    final nextPath = List<EvolutionNode>.from(currentPath)..add(node);
    if (node.evolvesTo.isEmpty) {
      paths.add(nextPath);
    } else {
      for (final child in node.evolvesTo) {
        _findPaths(child, nextPath, paths);
      }
    }
  }
}

class EvolutionNode {
  final String speciesName;
  final int speciesId;
  final List<EvolutionNode> evolvesTo;
  final int? minLevel;
  final String? triggerName;
  final String? itemName;

  const EvolutionNode({
    required this.speciesName,
    required this.speciesId,
    required this.evolvesTo,
    this.minLevel,
    this.triggerName,
    this.itemName,
  });
}
