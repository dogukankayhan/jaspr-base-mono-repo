# Contributing Guide

## Getting Started

**Requirements:**
- Flutter SDK (stable channel, `3.32.x` or higher)
- Dart SDK (`^3.9.0`)
- Melos: `dart pub global activate melos`

**Initial setup:**
```bash
git clone <repo-url>
cd Flutter_Base_Mono_Repo
melos bootstrap
```

`melos bootstrap` resolves dependencies in all packages and sets up pub workspaces connections. **Do not** just run `flutter pub get` — workspace connections will not be established.

---

## Branch Naming

| Type | Prefix | Example |
|-----|--------|-------|
| New Feature | `feat/` | `feat/app-card-component` |
| Bug Fix | `fix/` | `fix/login-validation-crash` |
| Infrastructure / Config | `chore/` | `chore/upgrade-flutter-3-32` |
| Documentation | `docs/` | `docs/architecture-diagram` |
| Refactoring | `refactor/` | `refactor/dashboard-extract-widgets` |

Branches should always be created from `main`.

---

## Commit Style — Conventional Commits

```
<type>(<scope>): <short description>
```

**Types:** `feat`, `fix`, `chore`, `docs`, `refactor`, `test`, `ci`

**Scope examples:** `mobile`, `network`, `auth`, `ui`, `firebase`, `core`

```bash
# Examples
feat(mobile): add AppCard component
fix(network): retry on 503 status code
chore(ci): add code quality workflow
test(mobile): add DashboardBloc unit tests
docs(core): document PaginatedBloc pattern
```

---

## Pull Request Process

1. Create a branch and make your changes.
2. Run all checks locally:
   ```bash
   melos format       # Format code
   melos analyze      # Run lint checks
   melos test         # Run all tests
   ```
3. Open a PR — `.github/pull_request_template.md` will be loaded automatically.
4. The `Analyze & Test` workflow in CI must be green.
5. At least 1 reviewer approval is required.
6. Merge: **Squash and Merge** (for a clean commit history).

---

## Melos Script Reference

| Command | What it does | When to run |
|-------|----------|-----------------------|
| `melos bootstrap` | Installs dependencies and sets up workspace connections | During initial setup or when pubspec changes |
| `melos analyze` | Runs `dart analyze` in all packages | Before every commit |
| `melos test` | Runs `flutter test` in all packages | Before every commit |
| `melos format` | Formats all code with `dart format` | Before commit (after editing) |
| `melos format:check` | Checks formatting without modifying files | Used in CI |

---

## Adding a New Feature

Prefer scaffolding with `dart run scripts/gen_feature.dart` — see the README's "Adding a New Feature" section for the interactive prompts and full generated tree. It produces:

```
apps/mobile/lib/features/<feature_name>/
├── bloc/                         # or cubit/ if you chose Cubit
│   ├── <feature>_bloc.dart      # extends BaseBloc<Event, State>
│   ├── <feature>_event.dart     # Sealed class events
│   └── <feature>_state.dart     # extends BaseState, copyWith pattern
├── view/
│   └── <feature>_screen.dart    # extends StatelessWidget, wrapped with BaseBlocView
└── <feature>_navigator.dart     # GoRoute definition + show() method
```

It does **not** generate entities, use cases, repositories, or DTOs — those are shared and live under `apps/mobile/lib/core/domain/` and `apps/mobile/lib/core/data/`.

If the screen needs sub-widgets (tabs, sections) that only it uses, add them under a `widgets/` folder joined via `part`/`part of` rather than separate imported files — see `CLAUDE.md`'s "Screen-Specific Widgets" pattern. Only do this for single-consumer widgets; anything reused by another screen must stay a standalone `import`-ed file.

**Steps:**
1. Open a `feat/<feature>` branch.
2. Run the generator (or create files matching the structure above by hand).
3. For standalone/nested routes the generator registers the navigator with `AppNavigator`/`ShellNavigator` automatically; for a tab route, add it to the shell branch manually.
4. Add the required use case / repository / entity under `apps/mobile/lib/core/`. Prefer calling `ApiManager` directly from the repository (see `PokemonRepositoryImpl`, `UserRepositoryImpl`) — only add a separate datasource when a source is local (e.g. `SharedPreferences`) or genuinely needs to be swapped independently of the repository.
5. Add registration to the DI module (if needed).
6. Add a test file under `apps/mobile/test/features/<feature>/`.
7. Verify tests with `melos test`.

---

## Adding a New Package

1. Create `packages/flutter_kit_<name>/` directory.
2. Add `pubspec.yaml` (name: `flutter_kit_<name>`, `publish_to: none`).
3. Add to the `workspace:` list in the root `pubspec.yaml`.
4. Add a path dependency to `apps/mobile/pubspec.yaml`:
   ```yaml
   flutter_kit_<name>:
     path: ../../packages/flutter_kit_<name>
   ```
5. Run `melos bootstrap`.
6. Add package README.md.

**Package Isolation Rule:** Dependency direction between packages:
`network ← auth`, `core ← auth`, others are independent. `firebase` ➡️ `auth` dependency is forbidden (circular dependency).

---

## Code Style

- `analysis_options.yaml` rules are enforced in CI — check locally with `melos analyze`.
- String literals: `prefer_single_quotes` is active (single quotes instead of double quotes).
- `avoid_print`: Use `debugPrint` or `log`.
- `prefer_const_constructors`: Use `const` whenever possible.
- Comments are only for WHY: add them if the reason is not obvious, do not explain what the code does.

---

## Test Requirements

- A `_test.dart` file is mandatory for every new `Bloc` and `Cubit` class.
- Pattern reference: `packages/flutter_kit_auth/test/manager/auth_manager_test.dart`.
- Mock generation: `@GenerateMocks([ClassName])` + `dart run build_runner build --delete-conflicting-outputs`.
- Organize every test inside a `group()`, and use descriptive test names.
- `provideDummy<Result<T,E>>(...)` prevents Mockito generic type warnings.

---

## Questions

For questions about architecture or patterns, read these files first:
- `CLAUDE.md` — quick reference for patterns
- `docs/ARCHITECTURE.md` — layer diagram and data flow
- `docs/RESULT_PATTERN.md` — Result<T,E> quick-start
- The `README.md` of each package.
