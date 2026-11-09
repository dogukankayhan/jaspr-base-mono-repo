/// Marker contract for all repository interfaces.
///
/// Usage:
/// ```dart
/// abstract class ArmyRepository implements BaseRepository {
///   Future<Result<List<Unit>, ApiError>> getUnits();
/// }
/// ```
abstract interface class BaseRepository {}
