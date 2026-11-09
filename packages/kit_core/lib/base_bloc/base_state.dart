import 'package:equatable/equatable.dart';

/// Base state class - all cubit states should inherit from this
///
/// Uses immutable state pattern.
/// Provides performance optimization with Equatable.
abstract class BaseState extends Equatable {
  final bool isLoading;
  final bool isValid;
  final String? errorMessage;

  const BaseState({
    this.isLoading = false,
    this.isValid = false,
    this.errorMessage,
  });

  @override
  List<Object?> get props => [isLoading, isValid, errorMessage];
}
