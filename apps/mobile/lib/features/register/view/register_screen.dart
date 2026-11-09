import 'package:app_shared/features/register/bloc/register_bloc.dart';
import 'package:app_shared/features/register/bloc/register_event.dart';
import 'package:app_shared/features/register/bloc/register_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_kit_core/base_bloc/base_bloc_view.dart';

import '../../../core/components/app_button.dart';
import '../../../core/components/app_error_banner.dart';
import '../../../core/components/app_text_field.dart';
import '../../../core/localization/localization_extension.dart';
import '../../../core/managers/navigation_manager/app_navigator.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseBlocView<RegisterBloc, RegisterState>(
      create: RegisterBloc.new,
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
                    const _BackButton(),
                    const SizedBox(height: 8),
                    const _Header(),
                    const SizedBox(height: 24),
                    _RegisterForm(state: state, bloc: bloc),
                    const SizedBox(height: 24),
                    const _LoginLink(),
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

class _RegisterForm extends StatefulWidget {
  const _RegisterForm({required this.state, required this.bloc});
  final RegisterState state;
  final RegisterBloc bloc;

  @override
  State<_RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<_RegisterForm> {
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.translations;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: AppTextField(
                    label: t.register.firstNameLabel,
                    controller: _firstNameCtrl,
                    hintText: t.register.firstNameHint,
                    isRequired: true,
                    validationMessage: widget.state.firstNameError,
                    onChanged: (v) =>
                        widget.bloc.add(RegisterFirstNameChanged(v)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppTextField(
                    label: t.register.lastNameLabel,
                    controller: _lastNameCtrl,
                    hintText: t.register.lastNameHint,
                    isRequired: true,
                    validationMessage: widget.state.lastNameError,
                    onChanged: (v) =>
                        widget.bloc.add(RegisterLastNameChanged(v)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: t.register.emailLabel,
              controller: _emailCtrl,
              hintText: t.register.emailHint,
              type: InputType.email,
              isRequired: true,
              validationMessage: widget.state.emailError,
              onChanged: (v) => widget.bloc.add(RegisterEmailChanged(v)),
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: t.register.passwordLabel,
              controller: _passwordCtrl,
              hintText: t.register.passwordHint,
              type: InputType.password,
              isRequired: true,
              validationMessage: widget.state.passwordError,
              onChanged: (v) => widget.bloc.add(RegisterPasswordChanged(v)),
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
              label: t.register.submitButton,
              onPressed: () => widget.bloc.add(const RegisterSubmitted()),
              isLoading: widget.state.isLoading,
              fullWidth: true,
            ),
          ],
        ),
      ),
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

class _BackButton extends StatelessWidget {
  const _BackButton();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: AppNavigator.instance.login.show,
        tooltip: context.translations.register.backTooltip,
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    final t = context.translations;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Column(
      children: [
        Text(
          t.register.title,
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          t.register.subtitle,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: cs.onSurface.withValues(alpha: 0.55),
          ),
        ),
      ],
    );
  }
}

class _LoginLink extends StatelessWidget {
  const _LoginLink();

  @override
  Widget build(BuildContext context) {
    final t = context.translations;
    final cs = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          t.register.hasAccount,
          style: TextStyle(color: cs.onSurface.withValues(alpha: 0.6)),
        ),
        TextButton(
          onPressed: AppNavigator.instance.login.show,
          child: Text(t.register.loginLink),
        ),
      ],
    );
  }
}
