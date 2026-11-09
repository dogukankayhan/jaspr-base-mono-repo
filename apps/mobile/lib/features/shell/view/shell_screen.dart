import 'package:flutter/material.dart';
import 'package:flutter_base_kit/core/enums/app_icon.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_kit_ui/colors/app_brand_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../cubit/shell_cubit.dart';
import '../cubit/shell_state.dart';

class ShellScreen extends StatelessWidget {
  const ShellScreen({super.key, required this.navigationShell});
  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ShellCubit(),
      child: _ShellView(navigationShell: navigationShell),
    );
  }
}

class _ShellView extends StatelessWidget {
  const _ShellView({required this.navigationShell});
  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return BlocListener<ShellCubit, ShellState>(
      listener: (context, state) => navigationShell.goBranch(
        state.selectedIndex,
        initialLocation: state.selectedIndex == navigationShell.currentIndex,
      ),
      child: Scaffold(
        body: navigationShell,
        bottomNavigationBar: _BottomNav(
          currentIndex: navigationShell.currentIndex,
          onTap: context.read<ShellCubit>().selectTab,
        ),
      ),
    );
  }
}

// ─── Bottom Nav ──────────────────────────────────────────────────────────────
// StatefulWidget: SVG items are built once and cached.
// GoRouter rebuilds ShellScreen on every root-navigator push even when the
// bottom nav is visually hidden — caching prevents redundant SVG builds.

class _BottomNav extends StatefulWidget {
  const _BottomNav({required this.currentIndex, required this.onTap});
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  State<_BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<_BottomNav> {
  static const _tabs = [
    (SvgIcon.lightning, SvgIcon.lightning, 'Pokemon'),
    (SvgIcon.calendar, SvgIcon.calendarBold, 'Favorilerim'),
    (SvgIcon.setting, SvgIcon.settingTool, 'Bileşenler'),
  ];

  List<BottomNavigationBarItem>? _items;

  @override
  Widget build(BuildContext context) {
    _items ??= [
      for (final tab in _tabs)
        BottomNavigationBarItem(
          icon: tab.$1.call(
            width: 24.w,
            height: 24.w,
            color: AppBrandColors.unSelectedTabIconColor,
          ),
          activeIcon: tab.$2.call(
            width: 24.w,
            height: 24.w,
            color: AppBrandColors.selectedTabIconColor,
          ),
          label: tab.$3,
        ),
    ];
    return BottomNavigationBar(
      currentIndex: widget.currentIndex,
      onTap: widget.onTap,
      type: BottomNavigationBarType.fixed,
      backgroundColor: Theme.of(context).colorScheme.surface,
      selectedItemColor: AppBrandColors.selectedTabIconColor,
      unselectedItemColor: AppBrandColors.unSelectedTabIconColor,
      selectedLabelStyle: const TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: const TextStyle(fontSize: 10),
      elevation: 8,
      items: _items!,
    );
  }
}
