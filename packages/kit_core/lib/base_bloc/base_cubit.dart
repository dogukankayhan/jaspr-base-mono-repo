import 'package:bloc/bloc.dart';
import 'base_state.dart';
import 'lifecycle_bloc.dart';

abstract class BaseCubit<T extends BaseState> extends Cubit<T>
    implements LifecycleBloc {
  BaseCubit(super.initialState);

  @override
  void onInit() {}

  @override
  void onReady() {}

  void safeEmit(T newState) {
    if (!isClosed) emit(newState);
  }
}
