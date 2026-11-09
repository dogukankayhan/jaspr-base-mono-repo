import '../../domain/entity/evolution_chain_entity.dart';

class EvolutionChainDto {
  final int id;
  final EvolutionNodeDto root;

  EvolutionChainDto({required this.id, required this.root});

  factory EvolutionChainDto.fromJson(Map<String, dynamic> json) {
    return EvolutionChainDto(
      id: json['id'] as int,
      root: EvolutionNodeDto.fromJson(json['chain']),
    );
  }

  EvolutionChain toDomain() {
    return EvolutionChain(id: id, root: _convertNode(root));
  }

  static EvolutionNode _convertNode(EvolutionNodeDto nodeDto) {
    return EvolutionNode(
      speciesName: nodeDto.speciesName,
      speciesId: nodeDto.speciesId,
      evolvesTo: nodeDto.evolvesTo.map((e) => _convertNode(e)).toList(),
      minLevel: nodeDto.minLevel,
      triggerName: nodeDto.triggerName,
      itemName: nodeDto.itemName,
    );
  }
}

class EvolutionNodeDto {
  final String speciesName;
  final int speciesId;
  final List<EvolutionNodeDto> evolvesTo;
  final int? minLevel;
  final String? triggerName;
  final String? itemName;

  EvolutionNodeDto({
    required this.speciesName,
    required this.speciesId,
    required this.evolvesTo,
    this.minLevel,
    this.triggerName,
    this.itemName,
  });

  factory EvolutionNodeDto.fromJson(Map<String, dynamic> json) {
    final speciesUrl = json['species']['url'] as String;
    final speciesId = int.parse(
      speciesUrl.split('/').where((e) => e.isNotEmpty).last,
    );

    final detailsList = json['evolution_details'] as List<dynamic>?;
    int? minLevel;
    String? triggerName;
    String? itemName;
    if (detailsList != null && detailsList.isNotEmpty) {
      final details = detailsList.first as Map<String, dynamic>;
      minLevel = details['min_level'] as int?;
      triggerName =
          (details['trigger'] as Map<String, dynamic>?)?['name'] as String?;
      itemName = (details['item'] as Map<String, dynamic>?)?['name'] as String?;
    }

    return EvolutionNodeDto(
      speciesName: json['species']['name'] as String,
      speciesId: speciesId,
      evolvesTo: (json['evolves_to'] as List<dynamic>)
          .map((e) => EvolutionNodeDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      minLevel: minLevel,
      triggerName: triggerName,
      itemName: itemName,
    );
  }
}
