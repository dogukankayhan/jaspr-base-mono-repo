import 'package:flutter_kit_core/base_bloc/base_state.dart';
import 'package:flutter_kit_core/utils/phone/country_phone.dart';

const _omit = Object();

class ComponentsState extends BaseState {
  final String name;
  final String surname;
  final String fullName;
  final String age;
  final String? ageWarning;
  final String birthDate;
  final String phone;
  final CountryPhone country;
  final String iban;
  final String email;
  final String password;
  final String url;
  final String notes;

  // Field-level validation errors — set by BLoC, shown via validationMessage
  final String? nameError;
  final String? surnameError;
  final String? birthDateError;
  final String? phoneError;
  final String? ibanError;
  final String? emailError;
  final String? passwordError;
  final String? urlError;

  const ComponentsState({
    this.name = '',
    this.surname = '',
    this.fullName = '',
    this.age = '',
    this.ageWarning,
    this.birthDate = '',
    this.phone = '',
    this.country = CountryPhones.defaultCountry,
    this.iban = 'TR',
    this.email = '',
    this.password = '',
    this.url = '',
    this.notes = '',
    this.nameError,
    this.surnameError,
    this.birthDateError,
    this.phoneError,
    this.ibanError,
    this.emailError,
    this.passwordError,
    this.urlError,
  });

  ComponentsState copyWith({
    String? name,
    String? surname,
    String? fullName,
    String? age,
    Object? ageWarning = _omit,
    String? birthDate,
    String? phone,
    CountryPhone? country,
    String? iban,
    String? email,
    String? password,
    String? url,
    String? notes,
    Object? nameError = _omit,
    Object? surnameError = _omit,
    Object? birthDateError = _omit,
    Object? phoneError = _omit,
    Object? ibanError = _omit,
    Object? emailError = _omit,
    Object? passwordError = _omit,
    Object? urlError = _omit,
  }) {
    return ComponentsState(
      name: name ?? this.name,
      surname: surname ?? this.surname,
      fullName: fullName ?? this.fullName,
      age: age ?? this.age,
      ageWarning: identical(ageWarning, _omit)
          ? this.ageWarning
          : ageWarning as String?,
      birthDate: birthDate ?? this.birthDate,
      phone: phone ?? this.phone,
      country: country ?? this.country,
      iban: iban ?? this.iban,
      email: email ?? this.email,
      password: password ?? this.password,
      url: url ?? this.url,
      notes: notes ?? this.notes,
      nameError: identical(nameError, _omit)
          ? this.nameError
          : nameError as String?,
      surnameError: identical(surnameError, _omit)
          ? this.surnameError
          : surnameError as String?,
      birthDateError: identical(birthDateError, _omit)
          ? this.birthDateError
          : birthDateError as String?,
      phoneError: identical(phoneError, _omit)
          ? this.phoneError
          : phoneError as String?,
      ibanError: identical(ibanError, _omit)
          ? this.ibanError
          : ibanError as String?,
      emailError: identical(emailError, _omit)
          ? this.emailError
          : emailError as String?,
      passwordError: identical(passwordError, _omit)
          ? this.passwordError
          : passwordError as String?,
      urlError: identical(urlError, _omit)
          ? this.urlError
          : urlError as String?,
    );
  }

  @override
  List<Object?> get props => [
    ...super.props,
    name,
    surname,
    fullName,
    age,
    ageWarning,
    birthDate,
    phone,
    country,
    iban,
    email,
    password,
    url,
    notes,
    nameError,
    surnameError,
    birthDateError,
    phoneError,
    ibanError,
    emailError,
    passwordError,
    urlError,
  ];
}
