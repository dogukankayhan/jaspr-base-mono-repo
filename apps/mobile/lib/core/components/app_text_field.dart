import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_base_kit/core/enums/app_icon.dart';
import 'package:flutter_kit_core/utils/formatter/card_expiry_input_formatter.dart';
import 'package:flutter_kit_core/utils/formatter/card_number_input_formatter.dart';
import 'package:flutter_kit_core/utils/formatter/date_input_formatter.dart';
import 'package:flutter_kit_core/utils/formatter/iban_input_formatter.dart';
import 'package:flutter_kit_core/utils/formatter/name_case_input_formatter.dart';
import 'package:flutter_kit_core/utils/phone/country_phone.dart';
import 'package:flutter_kit_core/utils/phone/masked_phone_input_formatter.dart';
import 'package:flutter_kit_ui/colors/app_brand_colors.dart';
import 'package:flutter_kit_ui/colors/app_colors.dart';
import 'package:flutter_kit_ui/extensions/context_ext.dart';
import 'package:flutter_kit_ui/typography/app_text_style.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

enum InputType {
  text,

  /// A person's name — title-cased as it is typed (see [NameCaseInputFormatter]).
  name,
  password,
  numeric,
  email,
  phone,
  date,
  iban,
  url,
  cardNumber,
  cardExpiry,
  cvv,
}

/// Usage:
///   AppTextField(label: 'Email', controller: _ctrl, hintText: 'example@mail.com', type: InputType.email)
///   AppTextField(label: 'Password',   controller: _ctrl, hintText: '••••••••',       type: InputType.password)
///   AppTextField(label: 'Note',     controller: _ctrl, hintText: 'Enter description', maxLines: 4)
class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    this.label,
    required this.controller,
    required this.hintText,
    this.type = InputType.text,
    this.isRequired = false,
    this.isEnabled = true,
    this.prefixIcon,
    this.suffixIcon,
    this.maxLines = 1,
    this.focusNode,
    this.validator,
    this.validationMessage,
    this.onChanged,
    this.textCapitalization = TextCapitalization.none,
    this.prefixText,
    this.country,
    this.onCountryTap,
  });

  final String? label;
  final TextEditingController controller;
  final String hintText;
  final InputType type;
  final bool isRequired;
  final bool isEnabled;
  final Widget? prefixIcon;

  /// Automatic toggle icon is created for password type,
  /// this field is only applicable for text/numeric/email/phone.
  final SvgIcon? suffixIcon;

  final int maxLines;
  final FocusNode? focusNode;
  final FormFieldValidator<String>? validator;

  /// To provide direct error message from outside instead of validator message.
  final String? validationMessage;
  final ValueChanged<String>? onChanged;
  final TextCapitalization textCapitalization;
  final String? prefixText;

  /// Drives the dial-code prefix and the input mask of an [InputType.phone]
  /// field. Ignored by every other type; takes priority over [prefixIcon] and
  /// [prefixText] when set.
  final CountryPhone? country;

  /// Makes the [country] prefix tappable — wire it to the country picker.
  /// Without it the prefix renders as plain, non-interactive text.
  final VoidCallback? onCountryTap;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late final FocusNode _focusNode;
  final _isFocused = ValueNotifier<bool>(false);
  final _isPasswordVisible = ValueNotifier<bool>(false);

  bool get _isPassword => widget.type == InputType.password;
  bool get _isObscured => _isPassword || widget.type == InputType.cvv;
  bool get _isMultiline => !_isPassword && widget.maxLines > 1;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _isFocused.dispose();
    _isPasswordVisible.dispose();
    if (widget.focusNode == null) _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() => _isFocused.value = _focusNode.hasFocus;

  // ─── Build ──────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return ValueListenableBuilder<bool>(
      valueListenable: _isPasswordVisible,
      builder: (context, passwordVisible, _) {
        final field = TextFormField(
          controller: widget.controller,
          focusNode: _focusNode,
          obscureText: _isPassword ? !passwordVisible : _isObscured,
          keyboardType: _keyboardType,
          inputFormatters: _inputFormatters,
          textCapitalization: widget.textCapitalization,
          maxLines: _isPassword ? 1 : widget.maxLines,
          minLines: _isPassword ? 1 : widget.maxLines,
          enabled: widget.isEnabled,
          onChanged: widget.onChanged,
          style: context.textStyle.paragraph16Regular.copyWith(
            color: colors.textColor,
          ),
          validator:
              widget.validator ??
              (widget.isRequired ? _requiredValidator : null),
          onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
          decoration: _decoration(context, colors),
        );

        if (!_isMultiline) return field;

        // Multiline: show resize handle
        return Stack(
          children: [
            field,
            Positioned(
              bottom: 0,
              right: 0,
              child: Padding(
                padding: EdgeInsets.only(bottom: 16.w, right: 8.w),
                child: SvgIcon.resizeHandle(width: 8.w, height: 8.w),
              ),
            ),
          ],
        );
      },
    );
  }

  // ─── Decoration ─────────────────────────────────────────
  InputDecoration _decoration(BuildContext context, AppColors colors) {
    return InputDecoration(
      hintText: widget.hintText,
      hintStyle: context.textStyle.paragraph16Regular.copyWith(
        color: colors.textFieldUnFocusText,
      ),
      prefixText: widget.prefixText,
      prefixStyle: context.textStyle.paragraph16Regular.copyWith(
        color: colors.textFieldFocusBorder,
      ),
      filled: true,
      fillColor: Colors.transparent,
      contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
      floatingLabelBehavior: FloatingLabelBehavior.always,
      label: widget.label != null ? _label(context) : null,
      prefixIcon: _prefixIcon(context, colors),
      suffixIcon: _suffixIcon(colors),
      errorText: widget.validationMessage,
      errorStyle: context.textStyle.paragraph14Regular.copyWith(
        color: AppBrandColors.error,
      ),
      border: _border(colors.textFieldUnFocusBorder),
      enabledBorder: _border(colors.textFieldUnFocusBorder),
      focusedBorder: _border(colors.textFieldFocusBorder),
      errorBorder: _border(AppBrandColors.error),
      focusedErrorBorder: _border(AppBrandColors.error),
      disabledBorder: _border(colors.textFieldDisabledBorder),
    );
  }

  /// Rendered directly (not the plain [prefixText]/[prefixIcon] path) so a
  /// tappable dial code can sit ahead of the number.
  Widget? _prefixIcon(BuildContext context, AppColors colors) {
    final country = widget.country;
    if (country != null) return _countryPrefix(context, colors, country);
    if (widget.prefixIcon == null) return null;
    return Padding(padding: EdgeInsets.all(12.w), child: widget.prefixIcon);
  }

  /// Dial code, tappable when [AppTextField.onCountryTap] is wired.
  ///
  /// No flag here — the code alone identifies the country and keeps the
  /// prefix narrow, leaving the number itself the widest thing in the field.
  /// The flag appears in the picker, where it helps scanning a long list.
  Widget _countryPrefix(
    BuildContext context,
    AppColors colors,
    CountryPhone country,
  ) {
    final label = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          country.dialCode,
          style: context.textStyle.paragraph16Regular.copyWith(
            color: colors.textColor,
          ),
        ),
        if (widget.onCountryTap != null) ...[
          SizedBox(width: 2.w),
          SvgIcon.arrowDown(width: 14.w, height: 14.w, color: colors.textColor),
        ],
      ],
    );

    return Padding(
      padding: EdgeInsets.only(left: 12.w, right: 4.w),
      child: Center(
        widthFactor: 1,
        child: widget.onCountryTap == null
            ? label
            : InkWell(
                onTap: widget.isEnabled ? widget.onCountryTap : null,
                borderRadius: BorderRadius.circular(8.r),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 6.h),
                  child: label,
                ),
              ),
      ),
    );
  }

  Widget _label(BuildContext context) {
    return RichText(
      text: TextSpan(
        text: widget.label!,
        style: context.textStyle.paragraph16Regular,
        children: [
          if (widget.isRequired)
            TextSpan(
              text: ' *',
              style: context.textStyle.paragraph16Regular.copyWith(
                color: AppBrandColors.error,
              ),
            ),
        ],
      ),
    );
  }

  Widget? _suffixIcon(AppColors colors) {
    if (_isPassword) {
      return ValueListenableBuilder<bool>(
        valueListenable: _isPasswordVisible,
        builder: (_, visible, _) => IconButton(
          icon: (visible ? SvgIcon.eye : SvgIcon.eyeSlash).call(
            color: colors.textFieldUnFocusBorder,
          ),
          onPressed: () => _isPasswordVisible.value = !_isPasswordVisible.value,
        ),
      );
    }

    if (widget.suffixIcon != null) {
      return Padding(
        padding: EdgeInsets.only(right: 10.w),
        child: ValueListenableBuilder<bool>(
          valueListenable: _isFocused,
          builder: (_, focused, _) => SizedBox.square(
            dimension: 20.w,
            child: Center(
              child: widget.suffixIcon!.call(
                color: focused
                    ? colors.textFieldFocusBorder
                    : colors.textFieldUnFocusBorder,
              ),
            ),
          ),
        ),
      );
    }

    return null;
  }

  OutlineInputBorder _border(Color color) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(12.r),
    borderSide: BorderSide(color: color, width: 1.5.w),
  );

  // ─── Keyboard / Formatter ───────────────────────────────
  TextInputType get _keyboardType => switch (widget.type) {
    InputType.text => TextInputType.text,
    InputType.name => TextInputType.name,
    InputType.password => TextInputType.visiblePassword,
    InputType.numeric => TextInputType.number,
    InputType.email => TextInputType.emailAddress,
    InputType.phone => TextInputType.phone,
    InputType.date => TextInputType.number,
    InputType.iban => TextInputType.number,
    InputType.url => TextInputType.url,
    InputType.cardNumber => TextInputType.number,
    InputType.cardExpiry => TextInputType.number,
    InputType.cvv => TextInputType.number,
  };

  List<TextInputFormatter>? get _inputFormatters => switch (widget.type) {
    InputType.name => [const NameCaseInputFormatter()],
    InputType.numeric => [FilteringTextInputFormatter.digitsOnly],
    InputType.phone => [
      if (widget.country case final country?)
        MaskedPhoneInputFormatter(
          pattern: country.pattern,
          trunkPrefix: country.trunkPrefix,
        )
      else
        FilteringTextInputFormatter.digitsOnly,
    ],
    InputType.date => [DateInputFormatter()],
    InputType.iban => [IbanInputFormatter()],
    InputType.cardNumber => [CardNumberInputFormatter()],
    InputType.cardExpiry => [CardExpiryInputFormatter()],
    InputType.cvv => [
      FilteringTextInputFormatter.digitsOnly,
      LengthLimitingTextInputFormatter(4),
    ],
    _ => null,
  };

  // ─── Default validator ──────────────────────────────────
  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field cannot be empty';
    }
    return null;
  }
}
