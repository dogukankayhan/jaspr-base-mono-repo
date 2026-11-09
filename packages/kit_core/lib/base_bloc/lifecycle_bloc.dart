/// Interface for blocs/cubits with lifecycle methods
/// Both BaseCubit and BaseBloc implement this interface
abstract class LifecycleBloc {
  /// Called when Bloc/Cubit is created (optional)
  void onInit();

  /// Called after widget is rendered (optional)
  void onReady();

  /// Is Bloc/Cubit closed?
  bool get isClosed;

  /// Close the bloc/cubit
  Future<void> close();
}
