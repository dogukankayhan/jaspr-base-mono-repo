class PokemonMove {
  final MoveInfo move;
  final List<VersionGroupDetail> versionGroupDetails;

  const PokemonMove({required this.move, required this.versionGroupDetails});
}

class MoveInfo {
  final String name;
  final String url;

  const MoveInfo({required this.name, required this.url});
}

class VersionGroupDetail {
  final int levelLearnedAt;
  final MoveLearnMethod moveLearnMethod;
  final VersionGroup versionGroup;

  const VersionGroupDetail({
    required this.levelLearnedAt,
    required this.moveLearnMethod,
    required this.versionGroup,
  });
}

class MoveLearnMethod {
  final String name;
  final String url;

  const MoveLearnMethod({required this.name, required this.url});
}

class VersionGroup {
  final String name;
  final String url;

  const VersionGroup({required this.name, required this.url});
}
