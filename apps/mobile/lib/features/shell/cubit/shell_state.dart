import 'package:equatable/equatable.dart';

class ShellState extends Equatable {
  final int selectedIndex;

  const ShellState({this.selectedIndex = 0});

  ShellState copyWith({int? selectedIndex}) =>
      ShellState(selectedIndex: selectedIndex ?? this.selectedIndex);

  @override
  List<Object?> get props => [selectedIndex];
}
