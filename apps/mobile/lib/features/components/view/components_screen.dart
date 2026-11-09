import 'package:flutter/material.dart';
import 'package:flutter_base_kit/core/components/app_button.dart';
import 'package:flutter_base_kit/core/components/app_text_field.dart';
import 'package:flutter_base_kit/core/components/country_picker_sheet.dart';
import 'package:flutter_base_kit/core/localization/localization_extension.dart';
import 'package:flutter_base_kit/features/components/bloc/components_bloc.dart';
import 'package:flutter_base_kit/features/components/bloc/components_event.dart';
import 'package:flutter_base_kit/features/components/bloc/components_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_kit_core/base_bloc/base_bloc_view.dart';
import 'package:flutter_kit_ui/colors/app_brand_colors.dart';
import 'package:flutter_kit_ui/theme/theme_cubit.dart';
import 'package:flutter_kit_ui/typography/app_text_style.dart';

class ComponentsScreen extends StatelessWidget {
  const ComponentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseBlocView<ComponentsBloc, ComponentsState>(
      create: ComponentsBloc.new,
      loadingOverlay: const SizedBox.shrink(),
      builder: (context, state, bloc) => Scaffold(
        appBar: _AppBar(bloc: bloc),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: _ComponentsForm(state: state, bloc: bloc),
        ),
      ),
    );
  }
}

// ─── AppBar ───────────────────────────────────────────────────────────────────

class _AppBar extends StatelessWidget implements PreferredSizeWidget {
  const _AppBar({required this.bloc});
  final ComponentsBloc bloc;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final t = context.translations;
    return AppBar(
      title: Text(t.components.title, style: context.textStyle.title18Bold),
      automaticallyImplyLeading: false,
      actions: [
        IconButton(
          tooltip: t.components.langToggleTooltip,
          icon: const Icon(Icons.language),
          onPressed: () => bloc.add(const ComponentsLanguageToggled()),
        ),
        BlocBuilder<ThemeCubit, ThemeMode>(
          builder: (context, mode) => IconButton(
            tooltip: t.components.themeToggleTooltip,
            icon: Icon(
              mode == ThemeMode.dark
                  ? Icons.light_mode_outlined
                  : Icons.dark_mode_outlined,
            ),
            onPressed: () => context.read<ThemeCubit>().toggleTheme(context),
          ),
        ),
      ],
    );
  }
}

// ─── Form ─────────────────────────────────────────────────────────────────────

class _ComponentsForm extends StatefulWidget {
  const _ComponentsForm({required this.state, required this.bloc});
  final ComponentsState state;
  final ComponentsBloc bloc;

  @override
  State<_ComponentsForm> createState() => _ComponentsFormState();
}

class _ComponentsFormState extends State<_ComponentsForm> {
  final _nameCtrl = TextEditingController();
  final _surnameCtrl = TextEditingController();
  final _fullNameCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  final _birthDateCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _ibanCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _urlCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _ibanCtrl.text = widget.state.iban;
  }

  @override
  void didUpdateWidget(_ComponentsForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    _sync(_nameCtrl, widget.state.name);
    _sync(_surnameCtrl, widget.state.surname);
    _sync(_fullNameCtrl, widget.state.fullName);
    _sync(_ageCtrl, widget.state.age);
    _sync(_birthDateCtrl, widget.state.birthDate);
    _sync(_phoneCtrl, widget.state.phone);
    _sync(_ibanCtrl, widget.state.iban);
    _sync(_emailCtrl, widget.state.email);
    _sync(_passwordCtrl, widget.state.password);
    _sync(_urlCtrl, widget.state.url);
    _sync(_notesCtrl, widget.state.notes);
  }

  void _sync(TextEditingController ctrl, String value) {
    if (ctrl.text != value) ctrl.text = value;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _surnameCtrl.dispose();
    _fullNameCtrl.dispose();
    _ageCtrl.dispose();
    _birthDateCtrl.dispose();
    _phoneCtrl.dispose();
    _ibanCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _urlCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.translations;
    final bloc = widget.bloc;
    final state = widget.state;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppTextField(
          label: t.components.nameLabel,
          controller: _nameCtrl,
          hintText: t.components.nameHint,
          isRequired: true,
          textCapitalization: TextCapitalization.words,
          validationMessage: state.nameError,
          onChanged: (v) => bloc.add(ComponentsNameChanged(v)),
        ),
        const SizedBox(height: 16),

        AppTextField(
          label: t.components.surnameLabel,
          controller: _surnameCtrl,
          hintText: t.components.surnameHint,
          isRequired: true,
          textCapitalization: TextCapitalization.words,
          validationMessage: state.surnameError,
          onChanged: (v) => bloc.add(ComponentsSurnameChanged(v)),
        ),
        const SizedBox(height: 16),

        AppTextField(
          label: t.components.fullNameLabel,
          controller: _fullNameCtrl,
          hintText: t.components.fullNameHint,
          textCapitalization: TextCapitalization.words,
          onChanged: (v) => bloc.add(ComponentsFullNameChanged(v)),
        ),
        const SizedBox(height: 16),

        AppTextField(
          label: t.components.ageLabel,
          controller: _ageCtrl,
          hintText: t.components.ageHint,
          type: InputType.numeric,
          onChanged: (v) => bloc.add(ComponentsAgeChanged(v)),
        ),
        if (state.ageWarning != null) ...[
          const SizedBox(height: 4),
          _WarningText(message: state.ageWarning!),
        ],
        const SizedBox(height: 16),

        AppTextField(
          label: t.components.birthDateLabel,
          controller: _birthDateCtrl,
          hintText: t.components.birthDateHint,
          type: InputType.date,
          validationMessage: state.birthDateError,
          onChanged: (v) => bloc.add(ComponentsBirthDateChanged(v)),
        ),
        const SizedBox(height: 16),

        AppTextField(
          label: t.components.phoneLabel,
          controller: _phoneCtrl,
          hintText: state.country.hint,
          type: InputType.phone,
          country: state.country,
          onCountryTap: () async {
            final picked = await CountryPickerSheet.show(
              context,
              selected: state.country,
            );
            if (picked != null) bloc.add(ComponentsCountryChanged(picked));
          },
          validationMessage: state.phoneError,
          onChanged: (v) => bloc.add(ComponentsPhoneChanged(v)),
        ),
        const SizedBox(height: 16),

        AppTextField(
          label: t.components.ibanLabel,
          controller: _ibanCtrl,
          hintText: t.components.ibanHint,
          type: InputType.iban,
          validationMessage: state.ibanError,
          onChanged: (v) => bloc.add(ComponentsIbanChanged(v)),
        ),
        const SizedBox(height: 16),

        AppTextField(
          label: t.components.emailLabel,
          controller: _emailCtrl,
          hintText: t.components.emailHint,
          type: InputType.email,
          isRequired: true,
          validationMessage: state.emailError,
          onChanged: (v) => bloc.add(ComponentsEmailChanged(v)),
        ),
        const SizedBox(height: 16),

        AppTextField(
          label: t.components.passwordLabel,
          controller: _passwordCtrl,
          hintText: t.components.passwordHint,
          type: InputType.password,
          isRequired: true,
          validationMessage: state.passwordError,
          onChanged: (v) => bloc.add(ComponentsPasswordChanged(v)),
        ),
        const SizedBox(height: 16),

        AppTextField(
          label: t.components.urlLabel,
          controller: _urlCtrl,
          hintText: t.components.urlHint,
          type: InputType.url,
          prefixText: 'https://',
          validationMessage: state.urlError,
          onChanged: (v) => bloc.add(ComponentsUrlChanged(v)),
        ),
        const SizedBox(height: 16),

        AppTextField(
          label: t.components.notesLabel,
          controller: _notesCtrl,
          hintText: t.components.notesHint,
          maxLines: 4,
          onChanged: (v) => bloc.add(ComponentsNotesChanged(v)),
        ),
        const SizedBox(height: 24),

        AppButton(
          label: t.components.validateButton,
          fullWidth: true,
          onPressed: () => bloc.add(const ComponentsValidateRequested()),
        ),
        const SizedBox(height: 32),
      ],
    );
  }
}

// ─── Warning widget ───────────────────────────────────────────────────────────

class _WarningText extends StatelessWidget {
  const _WarningText({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.info_outline, size: 14, color: AppBrandColors.warn),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            message,
            style: context.textStyle.paragraph12Regular.copyWith(
              color: AppBrandColors.warn,
            ),
          ),
        ),
      ],
    );
  }
}
