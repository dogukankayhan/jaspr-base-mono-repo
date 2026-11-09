import 'package:equatable/equatable.dart';
import 'package:flutter_kit_core/utils/phone/country_phone.dart';

sealed class ComponentsEvent extends Equatable {
  const ComponentsEvent();

  @override
  List<Object?> get props => [];
}

class ComponentsNameChanged extends ComponentsEvent {
  final String name;
  const ComponentsNameChanged(this.name);
  @override
  List<Object?> get props => [name];
}

class ComponentsSurnameChanged extends ComponentsEvent {
  final String surname;
  const ComponentsSurnameChanged(this.surname);
  @override
  List<Object?> get props => [surname];
}

class ComponentsFullNameChanged extends ComponentsEvent {
  final String fullName;
  const ComponentsFullNameChanged(this.fullName);
  @override
  List<Object?> get props => [fullName];
}

class ComponentsAgeChanged extends ComponentsEvent {
  final String age;
  const ComponentsAgeChanged(this.age);
  @override
  List<Object?> get props => [age];
}

class ComponentsBirthDateChanged extends ComponentsEvent {
  final String birthDate;
  const ComponentsBirthDateChanged(this.birthDate);
  @override
  List<Object?> get props => [birthDate];
}

class ComponentsPhoneChanged extends ComponentsEvent {
  final String phone;
  const ComponentsPhoneChanged(this.phone);
  @override
  List<Object?> get props => [phone];
}

class ComponentsCountryChanged extends ComponentsEvent {
  final CountryPhone country;
  const ComponentsCountryChanged(this.country);
  @override
  List<Object?> get props => [country];
}

class ComponentsIbanChanged extends ComponentsEvent {
  final String iban;
  const ComponentsIbanChanged(this.iban);
  @override
  List<Object?> get props => [iban];
}

class ComponentsEmailChanged extends ComponentsEvent {
  final String email;
  const ComponentsEmailChanged(this.email);
  @override
  List<Object?> get props => [email];
}

class ComponentsPasswordChanged extends ComponentsEvent {
  final String password;
  const ComponentsPasswordChanged(this.password);
  @override
  List<Object?> get props => [password];
}

class ComponentsUrlChanged extends ComponentsEvent {
  final String url;
  const ComponentsUrlChanged(this.url);
  @override
  List<Object?> get props => [url];
}

class ComponentsNotesChanged extends ComponentsEvent {
  final String notes;
  const ComponentsNotesChanged(this.notes);
  @override
  List<Object?> get props => [notes];
}

class ComponentsLanguageToggled extends ComponentsEvent {
  const ComponentsLanguageToggled();
}

class ComponentsValidateRequested extends ComponentsEvent {
  const ComponentsValidateRequested();
}
