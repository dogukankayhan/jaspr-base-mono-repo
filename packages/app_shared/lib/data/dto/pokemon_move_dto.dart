import '../../domain/entity/pokemon_move_entity.dart';

class PokemonMoveDto {
  final String moveName;
  final String moveUrl;
  final List<VersionGroupDetailDto> versionGroupDetails;

  PokemonMoveDto({
    required this.moveName,
    required this.moveUrl,
    required this.versionGroupDetails,
  });

  factory PokemonMoveDto.fromJson(Map<String, dynamic> json) {
    return PokemonMoveDto(
      moveName: json['move']['name'] as String,
      moveUrl: json['move']['url'] as String,
      versionGroupDetails: (json['version_group_details'] as List<dynamic>)
          .map((e) => VersionGroupDetailDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  PokemonMove toDomain() {
    return PokemonMove(
      move: MoveInfo(name: moveName, url: moveUrl),
      versionGroupDetails: versionGroupDetails
          .map(
            (d) => VersionGroupDetail(
              levelLearnedAt: d.levelLearnedAt,
              moveLearnMethod: MoveLearnMethod(
                name: d.moveLearnMethodName,
                url: d.moveLearnMethodUrl,
              ),
              versionGroup: VersionGroup(
                name: d.versionGroupName,
                url: d.versionGroupUrl,
              ),
            ),
          )
          .toList(),
    );
  }
}

class VersionGroupDetailDto {
  final int levelLearnedAt;
  final String moveLearnMethodName;
  final String moveLearnMethodUrl;
  final String versionGroupName;
  final String versionGroupUrl;

  VersionGroupDetailDto({
    required this.levelLearnedAt,
    required this.moveLearnMethodName,
    required this.moveLearnMethodUrl,
    required this.versionGroupName,
    required this.versionGroupUrl,
  });

  factory VersionGroupDetailDto.fromJson(Map<String, dynamic> json) {
    return VersionGroupDetailDto(
      levelLearnedAt: json['level_learned_at'] as int,
      moveLearnMethodName: json['move_learn_method']['name'] as String,
      moveLearnMethodUrl: json['move_learn_method']['url'] as String,
      versionGroupName: json['version_group']['name'] as String,
      versionGroupUrl: json['version_group']['url'] as String,
    );
  }
}
