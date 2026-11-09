import 'package:flutter_bloc/flutter_bloc.dart';
import 'shell_state.dart';

class ShellCubit extends Cubit<ShellState> {
  ShellCubit() : super(const ShellState());

  void selectTab(int index) => emit(ShellState(selectedIndex: index));
}
