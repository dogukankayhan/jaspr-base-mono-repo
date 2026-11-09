import 'package:flutter/material.dart';
import 'package:flutter_base_kit/core/enums/app_icon.dart';
import 'package:flutter_base_kit/core/localization/i18n/strings.g.dart';
import 'package:flutter_base_kit/core/localization/localization_extension.dart';
import 'package:flutter_kit_core/utils/extensions/string_ext.dart';
import 'package:flutter_kit_core/utils/phone/country_phone.dart';
import 'package:flutter_kit_ui/colors/app_brand_colors.dart';
import 'package:flutter_kit_ui/extensions/context_ext.dart';
import 'package:flutter_kit_ui/typography/app_text_style.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'app_bottom_sheet.dart';
import 'app_text_field.dart';

/// Searchable country picker behind the dial-code prefix of a phone field.
///
/// ```dart
/// final picked = await CountryPickerSheet.show(context, selected: state.country);
/// ```
class CountryPickerSheet extends StatefulWidget {
  const CountryPickerSheet({super.key, required this.selected});

  final CountryPhone selected;

  /// Opens the picker and resolves to the chosen country, or null if the
  /// sheet was dismissed.
  static Future<CountryPhone?> show(
    BuildContext context, {
    required CountryPhone selected,
  }) => context.showAppBottomSheet<CountryPhone>(
    title: context.translations.countryPicker.title,
    padding: EdgeInsets.zero,
    child: CountryPickerSheet(selected: selected),
  );

  @override
  State<CountryPickerSheet> createState() => _CountryPickerSheetState();
}

class _CountryPickerSheetState extends State<CountryPickerSheet> {
  final _searchCtrl = TextEditingController();

  /// Null until the first [didChangeDependencies], which is also what tells
  /// the re-sort below whether the locale actually changed.
  String? _languageCode;

  /// Sorted once per locale — 231 entries re-sorted on every keystroke, or on
  /// every keyboard-driven MediaQuery change, would be wasteful.
  late List<CountryPhone> _sorted;
  late List<CountryPhone> _visible;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Read from the provider rather than slang's global, so the country names
    // follow the same locale as this sheet's own strings.
    final languageCode = TranslationProvider.of(
      context,
    ).flutterLocale.languageCode;
    if (languageCode == _languageCode) return;

    _languageCode = languageCode;
    _sorted = CountryPhones.all.toList()
      ..sort(
        (a, b) => a
            .localizedName(languageCode)
            .normalizedForSearch
            .compareTo(b.localizedName(languageCode).normalizedForSearch),
      );
    // Keep whatever the user has typed; only the ordering changed.
    _visible = _filter(_searchCtrl.text);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<CountryPhone> _filter(String query) {
    final needle = query.normalizedForSearch;
    if (needle.isEmpty) return _sorted;
    return _sorted
        .where(
          (country) =>
              country
                  .localizedName(_languageCode!)
                  .normalizedForSearch
                  .contains(needle) ||
              country.dialCode.contains(needle) ||
              country.isoCode.normalizedForSearch.startsWith(needle),
        )
        .toList();
  }

  void _search(String query) => setState(() => _visible = _filter(query));

  @override
  Widget build(BuildContext context) {
    final t = context.translations;
    final screenHeight = MediaQuery.sizeOf(context).height;
    final keyboard = MediaQuery.viewInsetsOf(context).bottom;
    final maxHeight = screenHeight * 0.75;

    return SizedBox(
      // A fixed height, not a constraint: filtering down to three results must
      // not collapse the sheet around them. Only the keyboard shortens it, and
      // only by as much as it covers.
      height: (maxHeight - keyboard).clamp(0.0, maxHeight),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 8.h),
            child: AppTextField(
              controller: _searchCtrl,
              hintText: t.countryPicker.searchHint,
              prefixIcon: SvgIcon.searchNormal(color: AppBrandColors.primary),
              onChanged: _search,
            ),
          ),
          Expanded(
            child: _visible.isEmpty
                ? Center(
                    child: Text(
                      t.countryPicker.emptyMessage,
                      style: context.textStyle.paragraph16Regular.copyWith(
                        color: context.appColors.secondaryTextColor,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.only(bottom: 8.h),
                    itemCount: _visible.length,
                    itemBuilder: (context, index) => _CountryTile(
                      country: _visible[index],
                      languageCode: _languageCode!,
                      isSelected:
                          _visible[index].isoCode == widget.selected.isoCode,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _CountryTile extends StatelessWidget {
  const _CountryTile({
    required this.country,
    required this.languageCode,
    required this.isSelected,
  });

  final CountryPhone country;
  final String languageCode;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return InkWell(
      onTap: () => Navigator.of(context).pop(country),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
        child: Row(
          children: [
            Text(country.flagEmoji, style: TextStyle(fontSize: 24.sp)),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                country.localizedName(languageCode),
                style: context.textStyle.paragraph16Regular,
              ),
            ),
            SizedBox(width: 8.w),
            Text(
              country.dialCode,
              style: context.textStyle.paragraph16Regular.copyWith(
                color: colors.secondaryTextColor,
              ),
            ),
            if (isSelected) ...[
              SizedBox(width: 8.w),
              SvgIcon.tickCircle(
                width: 18.w,
                height: 18.w,
                color: AppBrandColors.primary,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
