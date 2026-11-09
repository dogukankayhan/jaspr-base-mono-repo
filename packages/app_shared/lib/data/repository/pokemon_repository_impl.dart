import 'package:kit_core/utils/background/run_in_background.dart';
import 'package:kit_network/core/network/api/api_manager_interface.dart';
import 'package:kit_network/core/network/error/api_error.dart';
import 'package:kit_network/core/network/error/api_exception.dart';
import 'package:kit_network/core/utils/result.dart';

import '../../domain/entity/evolution_chain_entity.dart';
import '../../domain/entity/pokemon_brief_entity.dart';
import '../../domain/entity/pokemon_entity.dart';
import '../../domain/entity/pokemon_species_entity.dart';
import '../../domain/repository/pokemon_repository.dart';
import '../../service/api/pokemon_api.dart';
import '../dto/evolution_chain_dto.dart';
import '../dto/pokemon_brief_dto.dart';
import '../dto/pokemon_dto.dart';
import '../dto/pokemon_species_dto.dart';

class PokemonRepositoryImpl implements PokemonRepository {
  final ApiManager _api;
  final int pageSize;

  PokemonRepositoryImpl(this._api, {this.pageSize = 20});

  // Cached after the first search — never re-fetched within the same session.
  List<PokemonBrief>? _allBriefs;

  @override
  Future<Result<(List<Pokemon>, bool, int), ApiError>> page(int offset) {
    return pageWithSize(pageSize, offset);
  }

  @override
  Future<Result<(List<Pokemon>, bool, int), ApiError>> pageWithSize(
    int size,
    int offset,
  ) async {
    try {
      final briefs = await _listPokemon(limit: size, offset: offset);
      final details = await _batchFetchDetails(briefs, concurrency: 5);
      final hasMore = briefs.isNotEmpty && briefs.length == size;
      return Ok((details, hasMore, offset + briefs.length));
    } on ApiException catch (e) {
      return Err(e.error);
    } catch (e) {
      return Err(ApiError(message: e.toString()));
    }
  }

  @override
  Future<Result<(List<Pokemon>, bool, int), ApiError>> pageByType(
    String type,
    int size,
    int offset,
  ) async {
    try {
      final briefs = await _filterByType(type);
      final batch = briefs.skip(offset).take(size).toList();
      final details = await _batchFetchDetails(batch, concurrency: 5);
      final hasMore = (offset + batch.length) < briefs.length;
      return Ok((details, hasMore, offset + batch.length));
    } on ApiException catch (e) {
      return Err(e.error);
    } catch (e) {
      return Err(ApiError(message: e.toString()));
    }
  }

  @override
  Future<Result<(List<Pokemon>, bool, int), ApiError>> pageSearch(
    String query,
    int size,
    int offset,
  ) async {
    try {
      final filtered = (await _allPokemonBriefs())
          .where((p) => p.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
      final batch = filtered.skip(offset).take(size).toList();
      final details = await _batchFetchDetails(batch, concurrency: 5);
      final hasMore = (offset + batch.length) < filtered.length;
      return Ok((details, hasMore, offset + batch.length));
    } on ApiException catch (e) {
      return Err(e.error);
    } catch (e) {
      return Err(ApiError(message: e.toString()));
    }
  }

  @override
  Future<Result<Pokemon, ApiError>> getById(int id) async {
    try {
      return Ok(await _getDetailByName(id.toString()));
    } on ApiException catch (e) {
      return Err(e.error);
    } catch (e) {
      return Err(ApiError(message: e.toString()));
    }
  }

  @override
  Future<Result<Pokemon, ApiError>> getByName(String name) async {
    try {
      return Ok(await _getDetailByName(name));
    } on ApiException catch (e) {
      return Err(e.error);
    } catch (e) {
      return Err(ApiError(message: e.toString()));
    }
  }

  @override
  Future<Result<PokemonSpecies, ApiError>> getSpecies(String url) async {
    try {
      final id = url.split('/').where((e) => e.isNotEmpty).last;
      final response = await _api.get<PokemonSpeciesDto>(
        path: GetPokemonSpeciesEndpoint.path(id),
        fromJson: PokemonSpeciesDto.fromJson,
      );
      return Ok(await runInBackground(() => response.data.toDomain()));
    } on ApiException catch (e) {
      return Err(e.error);
    } catch (e) {
      return Err(ApiError(message: e.toString()));
    }
  }

  @override
  Future<Result<EvolutionChain, ApiError>> getEvolutionChain(String url) async {
    try {
      final id = url.split('/').where((e) => e.isNotEmpty).last;
      final response = await _api.get<EvolutionChainDto>(
        path: GetEvolutionChainEndpoint.path(id),
        fromJson: EvolutionChainDto.fromJson,
      );
      return Ok(await runInBackground(() => response.data.toDomain()));
    } on ApiException catch (e) {
      return Err(e.error);
    } catch (e) {
      return Err(ApiError(message: e.toString()));
    }
  }

  @override
  Future<Result<List<PokemonBrief>, ApiError>> listAll() async {
    try {
      return Ok(await _allPokemonBriefs());
    } on ApiException catch (e) {
      return Err(e.error);
    } catch (e) {
      return Err(ApiError(message: e.toString()));
    }
  }

  /// Shared by search and [listAll]; fetched once, then cached.
  Future<List<PokemonBrief>> _allPokemonBriefs() async =>
      _allBriefs ??= await _listPokemon(limit: 1302, offset: 0);

  Future<List<PokemonBrief>> _listPokemon({
    required int limit,
    required int offset,
  }) async {
    // sendRequest, not get<List<…>>: get() can't reify a typed list at
    // runtime and always throws PARSE_ERROR (see ApiManager docs).
    final response = await _api
        .sendRequest<PokemonBriefDto, List<PokemonBriefDto>>(
          ListPokemonEndpoint.path,
          fromJson: PokemonBriefDto.fromJson,
          method: RequestMethod.get,
          queryParameters: ListPokemonEndpoint.query(
            limit: limit,
            offset: offset,
          ),
          listWrapperKey: ListPokemonEndpoint.listWrapperKey,
        );
    return runInBackground(
      () => response.data.map((dto) => dto.toDomain()).toList(),
    );
  }

  Future<List<PokemonBrief>> _filterByType(String type) async {
    final response = await _api.get<List<PokemonBriefDto>>(
      path: FilterPokemonByTypeEndpoint.path(type),
      extractor: (data) {
        final pokemon = (data as Map<String, dynamic>)['pokemon'] as List;
        return pokemon
            .map(
              (e) => PokemonBriefDto.fromJson(
                e['pokemon'] as Map<String, dynamic>,
              ),
            )
            .toList();
      },
    );
    return runInBackground(
      () => response.data.map((dto) => dto.toDomain()).toList(),
    );
  }

  Future<Pokemon> _getDetailByName(
    String name, {
    bool includeMoves = true,
  }) async {
    final response = await _api.get<PokemonDto>(
      path: GetPokemonDetailEndpoint.path(name),
      fromJson: (json) => PokemonDto.fromJson(json, includeMoves: includeMoves),
    );
    return runInBackground(() => response.data.toDomain());
  }

  Future<Pokemon> _getDetailByUrl(String url, {bool includeMoves = true}) {
    final name = url.split('/').where((e) => e.isNotEmpty).last;
    return _getDetailByName(name, includeMoves: includeMoves);
  }

  // Batch fetch with concurrency limit to prevent network congestion.
  // Failures are swallowed per-item so a single bad request doesn't wipe the page.
  Future<List<Pokemon>> _batchFetchDetails(
    List<PokemonBrief> briefs, {
    int concurrency = 5,
  }) async {
    final results = <Pokemon>[];
    for (var i = 0; i < briefs.length; i += concurrency) {
      final batch = briefs.skip(i).take(concurrency).toList();
      final batchResults = await Future.wait(
        batch.map(
          (b) => _getDetailByUrl(
            b.url,
            includeMoves: false,
          ).then<Pokemon?>((p) => p).onError((_, _) => null),
        ),
      );
      results.addAll(batchResults.whereType<Pokemon>());
    }
    return results;
  }
}
