# flutter_kit_ui

UI kit for flutter_base_kit monorepo. Provides the app theme, colour palette, typography, and shared widgets.

## Contents

```
lib/
├── theme/
│   ├── app_theme.dart        # MaterialApp light/dark ThemeData
│   ├── app_colors.dart       # Colour constants
│   ├── app_text_theme.dart   # Typography scale
│   ├── theme_cubit.dart      # ThemeCubit — persisted theme mode
│   └── game/
│       ├── game_colors.dart
│       ├── game_dimens.dart
│       └── game_text_styles.dart
└── widgets/
    ├── app_image.dart        # CachedNetworkImage wrapper
    ├── game_snackbar.dart    # Styled snackbar helper
    └── loading_overlay.dart  # Full-screen loading overlay
```

## Theme

```dart
// In MaterialApp
MaterialApp.router(
  theme: AppTheme.light,
  darkTheme: AppTheme.dark,
  themeMode: themeMode, // from ThemeCubit
)
```

### ThemeCubit

`ThemeCubit` persists the selected theme to `SharedPreferences` and survives app restarts:

```dart
// Change theme
context.read<ThemeCubit>().setLight();
context.read<ThemeCubit>().setDark();
context.read<ThemeCubit>().setSystem();

// Read current mode
final mode = context.read<ThemeCubit>().state; // ThemeMode
```

Register in your widget tree:

```dart
BlocProvider<ThemeCubit>.value(value: themeCubit)
```

### AppColors

```dart
AppColors.primary
AppColors.secondary
AppColors.background
AppColors.surface
AppColors.error
AppColors.onPrimary
```

### AppTextTheme

```dart
AppTextTheme.displayLarge
AppTextTheme.titleLarge
AppTextTheme.bodyMedium
AppTextTheme.labelSmall
```

## Widgets

### AppImage

```dart
AppImage(
  url: 'https://example.com/image.png',
  width: 80,
  height: 80,
  fit: BoxFit.cover,
  borderRadius: BorderRadius.circular(8),
  placeholder: const Icon(Icons.image),
)
```

### LoadingOverlay

Full-screen overlay shown while loading. Used automatically by `BaseBlocView` when `state.isLoading` is true.

Pass a custom overlay via `BaseBlocView.loadingOverlay` if you want a branded spinner:

```dart
BaseBlocView<MyBloc, MyState>(
  loadingOverlay: const LoadingOverlay(), // from flutter_kit_ui
  ...
)
```

### GameSnackbar

```dart
GameSnackbar.show(context, message: 'Operation completed');
GameSnackbar.showError(context, message: 'Something went wrong');
```

## Responsive Sizing

`flutter_screenutil` is included. Design size is configured in the app's `ScreenUtilInit`. Use `sp`, `w`, `h`, `r` extensions as usual:

```dart
SizedBox(height: 16.h, width: 100.w)
Text('Hello', style: TextStyle(fontSize: 14.sp))
```

## Dependencies

- `flutter_bloc`
- `flutter_screenutil`
- `flutter_spinkit`
- `flutter_svg`
- `cached_network_image`
- `shared_preferences`
