import 'package:flutter_base_kit/core/localization/i18n/strings.g.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_kit_core/base_bloc/base_bloc.dart';
import 'package:flutter_kit_core/utils/validator/field_validator.dart';
import 'package:flutter_kit_core/utils/validator/validators.dart';
import 'components_event.dart';
import 'components_state.dart';

class ComponentsBloc extends BaseBloc<ComponentsEvent, ComponentsState> {
  static const _minAge = 18;
  static const _ageWarningMessage =
      '18 yaşından küçükler için bazı özellikler kısıtlı olabilir';

  static final _nameValidator = FieldValidator<String>([Validators.required()]);
  static final _surnameValidator = FieldValidator<String>([
    Validators.required(),
  ]);
  static final _emailValidator = FieldValidator<String>([
    Validators.required(),
    Validators.email(),
  ]);
  static final _passwordValidator = FieldValidator<String>([
    Validators.required(),
    Validators.minLength(8),
  ]);
  static final _ibanValidator = FieldValidator<String>([Validators.iban()]);
  static final _dateValidator = FieldValidator<String>([Validators.date()]);
  static final _urlValidator = FieldValidator<String>([Validators.url()]);

  ComponentsBloc() : super(const ComponentsState()) {
    on<ComponentsNameChanged>(_onNameChanged);
    on<ComponentsSurnameChanged>(_onSurnameChanged);
    on<ComponentsFullNameChanged>(_onFullNameChanged);
    on<ComponentsAgeChanged>(_onAgeChanged);
    on<ComponentsBirthDateChanged>(_onBirthDateChanged);
    on<ComponentsPhoneChanged>(_onPhoneChanged);
    on<ComponentsCountryChanged>(_onCountryChanged);
    on<ComponentsIbanChanged>(_onIbanChanged);
    on<ComponentsEmailChanged>(_onEmailChanged);
    on<ComponentsPasswordChanged>(_onPasswordChanged);
    on<ComponentsUrlChanged>(_onUrlChanged);
    on<ComponentsNotesChanged>(_onNotesChanged);
    on<ComponentsLanguageToggled>(_onLanguageToggled);
    on<ComponentsValidateRequested>(_onValidateRequested);
  }

  void _onNameChanged(ComponentsNameChanged e, Emitter<ComponentsState> emit) =>
      emit(state.copyWith(name: e.name, nameError: null));

  void _onSurnameChanged(
    ComponentsSurnameChanged e,
    Emitter<ComponentsState> emit,
  ) => emit(state.copyWith(surname: e.surname, surnameError: null));

  void _onFullNameChanged(
    ComponentsFullNameChanged e,
    Emitter<ComponentsState> emit,
  ) => emit(state.copyWith(fullName: e.fullName));

  void _onAgeChanged(ComponentsAgeChanged e, Emitter<ComponentsState> emit) {
    final age = int.tryParse(e.age.trim());
    final warning = (age != null && age < _minAge) ? _ageWarningMessage : null;
    emit(state.copyWith(age: e.age, ageWarning: warning));
  }

  void _onBirthDateChanged(
    ComponentsBirthDateChanged e,
    Emitter<ComponentsState> emit,
  ) => emit(state.copyWith(birthDate: e.birthDate, birthDateError: null));

  void _onPhoneChanged(
    ComponentsPhoneChanged e,
    Emitter<ComponentsState> emit,
  ) => emit(state.copyWith(phone: e.phone, phoneError: null));

  void _onCountryChanged(
    ComponentsCountryChanged e,
    Emitter<ComponentsState> emit,
  ) => emit(
    // A new country's mask rarely matches the digits already typed under the
    // old one, so the field is cleared rather than left showing a stale,
    // wrongly-grouped number.
    state.copyWith(country: e.country, phone: '', phoneError: null),
  );

  void _onIbanChanged(ComponentsIbanChanged e, Emitter<ComponentsState> emit) =>
      emit(state.copyWith(iban: e.iban, ibanError: null));

  void _onEmailChanged(
    ComponentsEmailChanged e,
    Emitter<ComponentsState> emit,
  ) => emit(state.copyWith(email: e.email, emailError: null));

  void _onPasswordChanged(
    ComponentsPasswordChanged e,
    Emitter<ComponentsState> emit,
  ) => emit(state.copyWith(password: e.password, passwordError: null));

  void _onUrlChanged(ComponentsUrlChanged e, Emitter<ComponentsState> emit) =>
      emit(state.copyWith(url: e.url, urlError: null));

  void _onNotesChanged(
    ComponentsNotesChanged e,
    Emitter<ComponentsState> emit,
  ) => emit(state.copyWith(notes: e.notes));

  Future<void> _onLanguageToggled(
    ComponentsLanguageToggled e,
    Emitter<ComponentsState> emit,
  ) async {
    final isEn = LocaleSettings.currentLocale == AppLocale.en;
    await LocaleSettings.setLocale(isEn ? AppLocale.tr : AppLocale.en);
  }

  void _onValidateRequested(
    ComponentsValidateRequested e,
    Emitter<ComponentsState> emit,
  ) {
    // "TR" alone = untouched IBAN prefix, treat as empty for validation
    final ibanValue = state.iban == 'TR' ? '' : state.iban;
    // prefixText is visual only — prepend https:// for URL validation
    final urlValue = state.url.isEmpty ? '' : 'https://${state.url}';

    emit(
      state.copyWith(
        nameError: _nameValidator.validate(state.name),
        surnameError: _surnameValidator.validate(state.surname),
        birthDateError: _dateValidator.validate(state.birthDate),
        phoneError: Validators.phone(
          country: state.country,
        ).validate(state.phone),
        ibanError: _ibanValidator.validate(ibanValue),
        emailError: _emailValidator.validate(state.email),
        passwordError: _passwordValidator.validate(state.password),
        urlError: _urlValidator.validate(urlValue),
      ),
    );
  }
}
