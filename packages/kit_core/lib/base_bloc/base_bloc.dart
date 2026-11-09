import 'package:bloc/bloc.dart';
import 'base_state.dart';
import 'lifecycle_bloc.dart';

/// Base Bloc - all blocs should inherit from this.
///
/// authManager / apiManager not kept here — to prevent package cycle
/// each bloc receives its required dependency from its own constructor.
///
/// onReady() is triggered by post-frame callback of BaseBlocView;
/// BaseBloc remains independent of the widget render loop and in unit tests
/// Does not require TestWidgetsFlutterBinding in unit tests.
///
/// Example:
/// ```dart
/// class HomeBloc extends BaseBloc<HomeEvent, HomeState> {
///   final HomeRepository repo;
///   HomeBloc(this.repo) : super(const HomeState()) {
///     on<HomeStarted>(_onStarted);
///   }
/// }
/// ```
abstract class BaseBloc<E, S extends BaseState> extends Bloc<E, S>
    implements LifecycleBloc {
  BaseBloc(super.initialState);

  @override
  void onInit() {}

  @override
  void onReady() {}
}
