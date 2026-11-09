import 'package:app_shared/features/login/bloc/login_bloc.dart';
import 'package:app_shared/features/login/bloc/login_event.dart';
import 'package:app_shared/features/login/bloc/login_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_kit_core/base_bloc/base_bloc_view.dart';

import '../../../core/components/app_button.dart';
import '../../../core/components/app_error_banner.dart';
import '../../../core/components/app_text_field.dart';
import '../../../core/localization/localization_extension.dart';
import '../../../core/managers/navigation_manager/app_navigator.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseBlocView<LoginBloc, LoginState>(
      create: LoginBloc.new,
      loadingOverlay: const SizedBox.shrink(),
      builder: (context, state, bloc) => Scaffold(
        body: _Background(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const _Brand(),
                    const SizedBox(height: 32),
                    _LoginForm(state: state, bloc: bloc),
                    const SizedBox(height: 24),
                    const _OrDivider(),
                    const SizedBox(height: 16),
                    const _SocialButtons(),
                    const SizedBox(height: 24),
                    const _RegisterLink(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Form — controller lifecycle ──────────────────────────────────────────

class _LoginForm extends StatefulWidget {
  const _LoginForm({required this.state, required this.bloc});
  final LoginState state;
  final LoginBloc bloc;

  @override
  State<_LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<_LoginForm> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  @override
  void didUpdateWidget(_LoginForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_emailCtrl.text != widget.state.email) {
      _emailCtrl.text = widget.state.email;
    }
    if (_passwordCtrl.text != widget.state.password) {
      _passwordCtrl.text = widget.state.password;
    }
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.translations;
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  t.login.title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                AppTextField(
                  label: t.login.emailLabel,
                  controller: _emailCtrl,
                  hintText: t.login.emailHint,
                  type: InputType.email,
                  isRequired: true,
                  validationMessage: widget.state.emailError,
                  onChanged: (v) => widget.bloc.add(LoginEmailChanged(v)),
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: t.login.passwordLabel,
                  controller: _passwordCtrl,
                  hintText: t.login.passwordHint,
                  type: InputType.password,
                  isRequired: true,
                  validationMessage: widget.state.passwordError,
                  onChanged: (v) => widget.bloc.add(LoginPasswordChanged(v)),
                ),
                if (widget.state.errorMessage != null) ...[
                  const SizedBox(height: 12),
                  AppErrorBanner(
                    message: widget.state.errorMessage!,
                    isInline: true,
                  ),
                ],
                const SizedBox(height: 24),
                AppButton(
                  label: t.login.submitButton,
                  onPressed: () => widget.bloc.add(const LoginSubmitted()),
                  isLoading: widget.state.isLoading,
                  fullWidth: true,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () => widget.bloc.add(const LoginDemoFillRequested()),
          icon: const Icon(Icons.play_circle_outline),
          label: Text(t.login.demoButton),
        ),
      ],
    );
  }
}

// ─── Stateless sub-widgets ─────────────────────────────────────────────────

class _Background extends StatelessWidget {
  const _Background({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            cs.surface,
            cs.primaryContainer.withValues(alpha: 0.12),
            cs.surface,
          ],
        ),
      ),
      child: child,
    );
  }
}

class _Brand extends StatelessWidget {
  const _Brand();

  @override
  Widget build(BuildContext context) {
    final t = context.translations;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Column(
      children: [
        Icon(Icons.blur_on_rounded, size: 64, color: cs.primary),
        const SizedBox(height: 12),
        Text(
          t.login.appName,
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          t.login.subtitle,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: cs.onSurface.withValues(alpha: 0.55),
          ),
        ),
      ],
    );
  }
}

class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            context.translations.login.orDivider,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: cs.onSurface.withValues(alpha: 0.4),
            ),
          ),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }
}

class _SocialButtons extends StatelessWidget {
  const _SocialButtons();

  @override
  Widget build(BuildContext context) {
    final t = context.translations;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton.outlined(
          onPressed: () {},
          icon: const Icon(Icons.g_mobiledata, size: 32),
          tooltip: t.login.googleTooltip,
        ),
        const SizedBox(width: 16),
        IconButton.outlined(
          onPressed: () {},
          icon: const Icon(Icons.apple, size: 32),
          tooltip: t.login.appleTooltip,
        ),
      ],
    );
  }
}

class _RegisterLink extends StatelessWidget {
  const _RegisterLink();

  @override
  Widget build(BuildContext context) {
    final t = context.translations;
    final cs = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          t.login.noAccount,
          style: TextStyle(color: cs.onSurface.withValues(alpha: 0.6)),
        ),
        TextButton(
          onPressed: AppNavigator.instance.register.show,
          child: Text(t.login.registerLink),
        ),
      ],
    );
  }
}
