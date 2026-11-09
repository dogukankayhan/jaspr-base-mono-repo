#!/usr/bin/env dart
// ignore_for_file: avoid_print

import 'dart:io';

// ─── Paths ───────────────────────────────────────────────────────────────────

const _appNavigatorPath =
    'apps/mobile/lib/core/managers/navigation_manager/app_navigator.dart';
const _shellNavigatorPath =
    'apps/mobile/lib/features/shell/shell_navigator.dart';
const _webAppNavigatorPath = 'apps/web/lib/core/navigation/app_navigator.dart';

/// Blocs/cubits are platform-neutral → they always live in app_shared and are
/// consumed by the Flutter screen and/or the Jaspr page.
const _sharedFeaturesDir = 'packages/app_shared/lib/features';

// ─── Entry point ─────────────────────────────────────────────────────────────

void main() {
  _printHeader();

  final featureName = _ask(
    prompt: 'Feature name (snake_case)',
    hint: 'e.g. user_profile, order_detail',
    validator: (v) => RegExp(r'^[a-z][a-z0-9_]*$').hasMatch(v)
        ? null
        : 'Use lowercase letters and underscores (e.g. user_profile)',
  );

  final platform = _choose(
    prompt: 'Platform',
    options: [
      const _Option('mobile', 'Mobile  — Flutter screen (apps/mobile)'),
      const _Option('web', 'Web     — Jaspr page (apps/web)'),
      const _Option('both', 'Both    — one shared bloc, two views'),
    ],
    defaultIndex: 0,
  );
  final forMobile = platform != 'web';
  final forWeb = platform != 'mobile';

  final featureDir = 'apps/mobile/lib/features/$featureName';
  final webFeatureDir = 'apps/web/lib/features/$featureName';
  final sharedDir = '$_sharedFeaturesDir/$featureName';
  for (final dir in [
    sharedDir,
    if (forMobile) featureDir,
    if (forWeb) webFeatureDir,
  ]) {
    if (Directory(dir).existsSync()) {
      stdout.write('\n⚠  $dir already exists. Overwrite? [y/n]: ');
      if ((stdin.readLineSync()?.trim().toLowerCase() ?? 'n') != 'y') {
        print('Cancelled.');
        exit(0);
      }
    }
  }

  final isCubit =
      _choose(
        prompt: 'State management',
        options: [
          const _Option('bloc', 'Bloc   — event-driven, for complex flows'),
          const _Option('cubit', 'Cubit  — method-driven, for simple screens'),
        ],
        defaultIndex: 0,
      ) ==
      'cubit';

  bool hasPagination = false;
  String paginationEntity = 'Item';
  if (!isCubit) {
    hasPagination =
        _choose(
          prompt: 'Infinite scroll (pagination)?',
          options: [
            const _Option('n', 'No   — single load screen'),
            const _Option('y', 'Yes  — loads more on scroll'),
          ],
          defaultIndex: 0,
        ) ==
        'y';
    if (hasPagination) {
      paginationEntity = _ask(
        prompt: 'List item class name',
        hint: 'PascalCase — e.g. Movie, Pokemon',
        defaultValue: 'Item',
        validator: (v) => RegExp(r'^[A-Z][a-zA-Z0-9]*$').hasMatch(v)
            ? null
            : 'Use PascalCase (e.g. Movie)',
      );
    }
  }

  var routeType = 'web-only';
  if (forMobile)
    routeType = _choose(
      prompt: 'Where does this screen open? (mobile)',
      options: [
        const _Option(
          'standalone',
          'Full screen    — bottom nav hidden (login, settings, etc.)',
        ),
        const _Option(
          'nested',
          'Inside shell   — bottom nav stays visible (detail screens)',
        ),
        const _Option(
          'tab',
          'Tab            — a root tab of the bottom nav (dashboard, etc.)',
        ),
      ],
      defaultIndex: 0,
    );

  String? shellBranch;
  if (routeType == 'nested') {
    shellBranch = _choose(
      prompt: 'Which shell branch?',
      options: [
        const _Option('dashboard', 'Movies         (/dashboard)'),
        const _Option('appointments', 'Favorites      (/appointments)'),
        const _Option('pokemon', 'Pokemon        (/pokemon)'),
      ],
      defaultIndex: 1,
    );
  }

  final className = _toPascalCase(featureName);

  // ─── Generate files ──────────────────────────────────────────────────────
  print('\nGenerating...\n');
  final created = <String>[];

  // Shared bloc/cubit (pure Dart) → packages/app_shared
  final stateDir = isCubit ? 'cubit' : 'bloc';
  _mkdir('$sharedDir/$stateDir');
  if (isCubit) {
    _write(
      '$sharedDir/cubit/${featureName}_cubit.dart',
      _cubitTemplate(featureName, className),
    );
    _write(
      '$sharedDir/cubit/${featureName}_state.dart',
      _stateTemplate(featureName, className),
    );
    created.addAll([
      '$sharedDir/cubit/${featureName}_cubit.dart',
      '$sharedDir/cubit/${featureName}_state.dart',
    ]);
  } else {
    _write(
      '$sharedDir/bloc/${featureName}_bloc.dart',
      _blocTemplate(featureName, className, hasPagination, paginationEntity),
    );
    _write(
      '$sharedDir/bloc/${featureName}_event.dart',
      _eventTemplate(featureName, className, hasPagination),
    );
    _write(
      '$sharedDir/bloc/${featureName}_state.dart',
      _stateTemplate(
        featureName,
        className,
        hasPagination: hasPagination,
        entity: paginationEntity,
      ),
    );
    created.addAll([
      '$sharedDir/bloc/${featureName}_bloc.dart',
      '$sharedDir/bloc/${featureName}_event.dart',
      '$sharedDir/bloc/${featureName}_state.dart',
    ]);
  }

  // Flutter screen + navigator → apps/mobile
  if (forMobile) {
    _mkdir('$featureDir/view');
    _write(
      '$featureDir/view/${featureName}_screen.dart',
      _screenTemplate(featureName, className, isCubit: isCubit),
    );
    created.add('$featureDir/view/${featureName}_screen.dart');

    if (routeType != 'tab') {
      _write(
        '$featureDir/${featureName}_navigator.dart',
        _navigatorTemplate(featureName, className, routeType == 'nested'),
      );
      created.add('$featureDir/${featureName}_navigator.dart');
    }
  }

  // Jaspr page + navigator → apps/web
  if (forWeb) {
    _mkdir('$webFeatureDir/view');
    _write(
      '$webFeatureDir/view/${featureName}_page.dart',
      _webPageTemplate(featureName, className, isCubit: isCubit),
    );
    _write(
      '$webFeatureDir/${featureName}_navigator.dart',
      _webNavigatorTemplate(featureName, className),
    );
    created.addAll([
      '$webFeatureDir/view/${featureName}_page.dart',
      '$webFeatureDir/${featureName}_navigator.dart',
    ]);
  }

  // ─── Register route ──────────────────────────────────────────────────────
  print('');
  if (routeType == 'standalone') {
    _registerStandalone(featureName, className);
  } else if (routeType == 'nested') {
    _registerNested(featureName, className, shellBranch!);
  }
  if (forWeb) _registerWeb(featureName, className);

  // ─── Summary ─────────────────────────────────────────────────────────────
  print('');
  print('✅  Created:');
  for (final f in created) {
    print('      $f');
  }
  print('');
}

// ─── Web route registration ───────────────────────────────────────────────────

/// Inserts the import + route at the `gen_feature:` markers in the web
/// AppNavigator.
void _registerWeb(String name, String className) {
  final file = File(_webAppNavigatorPath);
  var content = file.readAsStringSync();
  const importMarker = '// gen_feature: imports';
  const routeMarker = '// gen_feature: routes';
  if (!content.contains(importMarker) || !content.contains(routeMarker)) {
    print(
      '⚠  Markers not found in $_webAppNavigatorPath — register '
      '${className}Navigator.route manually.',
    );
    return;
  }
  content = content
      .replaceFirst(
        importMarker,
        "import '../../features/$name/${name}_navigator.dart';\n$importMarker",
      )
      .replaceFirst(
        routeMarker,
        '${className}Navigator.route,\n        $routeMarker',
      );
  file.writeAsStringSync(content);
  print('✓  Web route registered in AppNavigator');
}

// ─── Route registration ───────────────────────────────────────────────────────

void _registerStandalone(String featureName, String className) {
  var content = File(_appNavigatorPath).readAsStringSync();

  final importLine =
      "import '../../../features/$featureName/${featureName}_navigator.dart';";
  if (!content.contains(importLine)) {
    const anchor = "import '../../../features/shell/shell_navigator.dart';";
    content = content.replaceFirst(anchor, '$anchor\n$importLine');
  }

  if (!content.contains('${className}Navigator.route')) {
    // Works whether the list is on one line or several.
    const anchor = 'List<RouteBase> get routes => [';
    if (content.contains(anchor)) {
      content = content.replaceFirst(
        anchor,
        '$anchor${className}Navigator.route, ',
      );
    } else {
      print(
        '⚠  Route list not found in $_appNavigatorPath — add '
        '${className}Navigator.route manually.',
      );
    }
  }

  File(_appNavigatorPath).writeAsStringSync(content);
  print('  updated  $_appNavigatorPath');
}

void _registerNested(String featureName, String className, String branch) {
  var content = File(_shellNavigatorPath).readAsStringSync();

  final importLine = "import '../$featureName/${featureName}_navigator.dart';";
  if (!content.contains(importLine)) {
    const anchor = "import 'view/shell_screen.dart';";
    content = content.replaceFirst(anchor, '$importLine\n$anchor');
  }

  if (!content.contains('${className}Navigator')) {
    switch (branch) {
      case 'appointments':
        const anchor =
            '            ],\n          ),\n        ],\n      ),\n      StatefulShellBranch(\n        routes: [\n          GoRoute(\n            path: pokemonPath,';
        content = content.replaceFirst(
          anchor,
          '              ${className}Navigator.route,\n$anchor',
        );

      case 'pokemon':
        const anchor =
            '            ],\n          ),\n        ],\n      ),\n    ],\n  );';
        content = content.replaceFirst(
          anchor,
          '              ${className}Navigator.route,\n$anchor',
        );

      case 'dashboard':
        print(
          '  ⚠  Dashboard branch uses an inline GoRoute — add manually (ShellNavigator, add a routes: [...] parameter to the dashboardPath GoRoute).',
        );
    }
  }

  File(_shellNavigatorPath).writeAsStringSync(content);
  print('  updated  $_shellNavigatorPath');
}

// ─── IO helpers ───────────────────────────────────────────────────────────────

class _Option {
  final String value;
  final String label;
  const _Option(this.value, this.label);
}

String _choose({
  required String prompt,
  required List<_Option> options,
  int defaultIndex = 0,
}) {
  while (true) {
    print('\n$prompt:');
    for (var i = 0; i < options.length; i++) {
      final marker = i == defaultIndex ? '●' : '○';
      print('  ${i + 1}) $marker ${options[i].label}');
    }
    stdout.write('Choice [${defaultIndex + 1}]: ');
    final raw = stdin.readLineSync()?.trim() ?? '';
    if (raw.isEmpty) return options[defaultIndex].value;
    final index = int.tryParse(raw);
    if (index != null && index >= 1 && index <= options.length) {
      return options[index - 1].value;
    }
    print('  ⚠  Enter a number between 1 and ${options.length}.');
  }
}

String _ask({
  required String prompt,
  String? hint,
  String? defaultValue,
  String? Function(String)? validator,
}) {
  while (true) {
    final parts = [
      prompt,
      if (hint != null) ' ($hint)',
      if (defaultValue != null) ' [$defaultValue]',
      ': ',
    ];
    stdout.write(parts.join());
    final raw = stdin.readLineSync()?.trim() ?? '';
    final value = (raw.isEmpty && defaultValue != null) ? defaultValue : raw;
    if (value.isEmpty) {
      print('  ⚠  Cannot be empty.');
      continue;
    }
    final error = validator?.call(value);
    if (error != null) {
      print('  ⚠  $error');
      continue;
    }
    return value;
  }
}

String _toPascalCase(String snake) =>
    snake.split('_').map((w) => w[0].toUpperCase() + w.substring(1)).join();

String _toKebab(String snake) => snake.replaceAll('_', '-');

void _mkdir(String path) => Directory(path).createSync(recursive: true);

void _write(String path, String content) {
  File(path).writeAsStringSync(content);
  print('  created  $path');
}

void _printHeader() {
  print('');
  print('┌──────────────────────────────────────┐');
  print('│   Feature Generator (mobile + web)   │');
  print('└──────────────────────────────────────┘');
  print('');
}

// ─── Templates ───────────────────────────────────────────────────────────────

String _blocTemplate(
  String name,
  String className,
  bool paginated, [
  String entity = 'Item',
]) {
  if (paginated) {
    return '''
import 'package:bloc/bloc.dart';
import 'package:kit_core/base_bloc/base_bloc.dart';
import 'package:kit_core/base_bloc/paginated_bloc.dart';
import '${name}_event.dart';
import '${name}_state.dart';

// TODO: import repository and use case
// import '../../../domain/repository/${name}_repository.dart';
// import '../../../domain/usecase/get_${name}_page_usecase.dart';

class ${className}Bloc extends BaseBloc<${className}Event, ${className}State>
    with PaginatedBloc<$entity, ${className}Event, ${className}State> {
  // final Get${className}PageUseCase _useCase;

  ${className}Bloc(/* this._useCase */) : super(const ${className}State()) {
    on<${className}Started>((_, emit) => handleLoadInitial(emit));
    on<${className}LoadMore>((_, emit) => handleLoadMore(emit));
    on<${className}Refreshed>((_, emit) => handleLoadInitial(emit));
  }

  ${className}Bloc.create() : this(
    // Get${className}PageUseCase(getIt<${className}Repository>()),
  );

  @override
  void onReady() => add(const ${className}Started());

  @override
  Future<(List<$entity>, bool, int)> fetchPage(int offset, int size) async {
    // TODO: return _useCase(offset: offset, pageSize: size);
    throw UnimplementedError();
  }

  @override
  ${className}State paginatedState({
    List<$entity>? items,
    bool? hasMore,
    int? nextOffset,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) =>
      state.copyWith(
        items: items,
        hasMore: hasMore,
        nextOffset: nextOffset,
        isLoading: isLoading,
        errorMessage: errorMessage,
        clearError: clearError,
      );
}
''';
  }

  return '''
import 'package:bloc/bloc.dart';
import 'package:kit_core/base_bloc/base_bloc.dart';
import '${name}_event.dart';
import '${name}_state.dart';

class ${className}Bloc extends BaseBloc<${className}Event, ${className}State> {
  ${className}Bloc() : super(const ${className}State()) {
    on<${className}Started>(_onStarted);
  }

  ${className}Bloc.create() : this();

  @override
  void onReady() => add(const ${className}Started());

  Future<void> _onStarted(
    ${className}Started event,
    Emitter<${className}State> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true));
    // TODO: implement
    emit(state.copyWith(isLoading: false, isValid: true));
  }
}
''';
}

String _eventTemplate(String name, String className, bool paginated) {
  if (paginated) {
    return '''
sealed class ${className}Event {
  const ${className}Event();
}

class ${className}Started extends ${className}Event {
  const ${className}Started();
}

class ${className}LoadMore extends ${className}Event {
  const ${className}LoadMore();
}

class ${className}Refreshed extends ${className}Event {
  const ${className}Refreshed();
}
''';
  }
  return '''
sealed class ${className}Event {
  const ${className}Event();
}

class ${className}Started extends ${className}Event {
  const ${className}Started();
}
''';
}

String _stateTemplate(
  String name,
  String className, {
  bool hasPagination = false,
  String entity = 'Item',
}) {
  if (hasPagination) {
    return '''
import 'package:kit_core/base_bloc/base_state.dart';

// TODO: import entity
// import '../../../domain/entity/${name}.dart';

class ${className}State extends BaseState {
  final List<$entity> items;
  final bool hasMore;
  final int nextOffset;

  const ${className}State({
    this.items = const [],
    this.hasMore = true,
    this.nextOffset = 0,
    super.isLoading,
    super.isValid,
    super.errorMessage,
  });

  ${className}State copyWith({
    List<$entity>? items,
    bool? hasMore,
    int? nextOffset,
    bool? isLoading,
    bool? isValid,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ${className}State(
      items: items ?? this.items,
      hasMore: hasMore ?? this.hasMore,
      nextOffset: nextOffset ?? this.nextOffset,
      isLoading: isLoading ?? this.isLoading,
      isValid: isValid ?? this.isValid,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props =>
      [isLoading, isValid, errorMessage, items, hasMore, nextOffset];
}
''';
  }

  return '''
import 'package:kit_core/base_bloc/base_state.dart';

class ${className}State extends BaseState {
  const ${className}State({
    super.isLoading,
    super.isValid,
    super.errorMessage,
  });

  ${className}State copyWith({
    bool? isLoading,
    bool? isValid,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ${className}State(
      isLoading: isLoading ?? this.isLoading,
      isValid: isValid ?? this.isValid,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [isLoading, isValid, errorMessage];
}
''';
}

String _cubitTemplate(String name, String className) =>
    '''
import 'package:kit_core/base_bloc/base_cubit.dart';
import '${name}_state.dart';

class ${className}Cubit extends BaseCubit<${className}State> {
  ${className}Cubit() : super(const ${className}State());

  ${className}Cubit.create() : this();

  @override
  void onReady() => _load();

  Future<void> _load() async {
    safeEmit(state.copyWith(isLoading: true, clearError: true));
    // TODO: implement
    safeEmit(state.copyWith(isLoading: false, isValid: true));
  }
}
''';

String _screenTemplate(String name, String className, {required bool isCubit}) {
  final kind = isCubit ? 'cubit' : 'bloc';
  final type = isCubit ? '${className}Cubit' : '${className}Bloc';
  return '''
import 'package:app_shared/features/$name/$kind/${name}_$kind.dart';
import 'package:app_shared/features/$name/$kind/${name}_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_kit_core/base_bloc/base_bloc_view.dart';

class ${className}Screen extends StatelessWidget {
  const ${className}Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseBlocView<$type, ${className}State>(
      create: () => $type.create(),
      builder: (context, state, $kind) {
        return Scaffold(
          appBar: AppBar(title: const Text('$className')),
          body: const Center(child: Text('$className')),
        );
      },
    );
  }
}
''';
}

/// Jaspr page — same shared bloc/cubit, web view layer.
String _webPageTemplate(
  String name,
  String className, {
  required bool isCubit,
}) {
  final kind = isCubit ? 'cubit' : 'bloc';
  final type = isCubit ? '${className}Cubit' : '${className}Bloc';
  return '''
import 'package:app_shared/features/$name/$kind/${name}_$kind.dart';
import 'package:app_shared/features/$name/$kind/${name}_state.dart';
import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_kit_core/jaspr_kit_core.dart';

class ${className}Page extends StatelessComponent {
  const ${className}Page({super.key});

  @override
  Component build(BuildContext context) {
    return BaseBlocView<$type, ${className}State>(
      create: () => $type.create(),
      builder: (context, state, $kind) {
        return section([
          h1([Component.text('$className')]),
        ]);
      },
    );
  }
}
''';
}

/// Jaspr navigator — owns the route and the typed `show()` (CLAUDE.md Rule 5).
String _webNavigatorTemplate(String name, String className) =>
    '''
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_router/jaspr_router.dart';

import 'view/${name}_page.dart';

final class ${className}Navigator {
  static const String path = '/${_toKebab(name)}';

  static Route get route => Route(
    path: path,
    title: '$className',
    builder: (context, state) => const ${className}Page(),
  );

  static void show(BuildContext context) => Router.of(context).push(path);

  static Component link({required Component child, String? classes}) =>
      Link(to: path, classes: classes, child: child);
}
''';

String _navigatorTemplate(String name, String className, bool isNested) {
  final path = isNested ? _toKebab(name) : '/${_toKebab(name)}';
  final navMethod = isNested ? 'context.push' : 'context.go';
  return '''
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'view/${name}_screen.dart';

final class ${className}Navigator {
  static const String path = '$path';

  static GoRoute get route => GoRoute(
        path: path,
        builder: (_, _) => const ${className}Screen(),
      );

  static void show(BuildContext context) => $navMethod(path);
}
''';
}
