import '../../domain/entity/pokemon_brief_entity.dart';

class PokemonBriefDto {
  final String name;
  final String url;

  PokemonBriefDto({required this.name, required this.url});

  factory PokemonBriefDto.fromJson(Map<String, dynamic> json) =>
      PokemonBriefDto(name: json['name'] as String, url: json['url'] as String);

  PokemonBrief toDomain() => PokemonBrief(name: name, url: url);
}
