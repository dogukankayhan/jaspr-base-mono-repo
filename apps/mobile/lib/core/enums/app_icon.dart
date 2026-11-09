import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

/// Usage:
///   SvgIcon.home()
///   SvgIcon.homeBold(width: 32, color: Colors.red)
///   SvgIcon.arrowRight(height: 20)
enum SvgIcon {
  // ─── General ────────────────────────────────────────
  add,
  alarm,
  arrowDown,
  arrowLeft,
  arrowRight,
  arrowUp,
  avatar,
  bell,
  bellNotification,
  calendar,
  call,
  callCalling,
  camera,
  close,
  eye,
  eyeSlash,
  gallery,
  icHidePassword,
  icShowPassword,
  lightning,
  lineArrowLeft,
  lineArrowRight,
  logo,
  logout,
  menu,
  menuBoard,
  messageEdit,
  messageText,
  messages,
  minus,
  moneys,
  more,
  password,
  profile,
  receipt,
  receiptItem,
  resizeHandle,
  save,
  scroll,
  searchNormal,
  setting,
  settingTool,
  shieldTick,
  shop,
  smsTracking,
  star,
  tickCircle,
  timer,
  trash,
  twoUser,
  wallet,
  walletRich,
  dottedBorderContainer,
  diagramGrowing,
  diagramDecreasing,

  // ─── Bold variants ──────────────────────────────────
  bellBold,
  calendarBold,
  homeBold,
  home,
  moneyBold,
  moneysBold,
  moreBold,
  profileBold,
  receiptBold,
  smsBold,
  trashBold,
  walletRichBold,

  // ─── Feature ────────────────────────────────────────
  addAppointment,
  addCustomer,
  addEmployee,
  addSale,
  packageSale,
  stockCount,
}

/// Usage:
///   PngAsset.appIcon()
///   PngAsset.appIcon(width: 80, fit: BoxFit.contain)
enum PngAsset { appIcon }

// ─── Camel → kebab-case helper ──────────────────────────────────────
String _toKebab(String name) => name
    .replaceAllMapped(
      RegExp(r'^([a-z])|[A-Z]'),
      (m) => m[1] == null ? '-${m[0]!.toLowerCase()}' : m[1]!,
    )
    .toLowerCase();

extension SvgIconX on SvgIcon {
  Widget call({
    double? width,
    double? height,
    BoxFit fit = BoxFit.contain,
    Color? color,
  }) {
    final path = 'assets/icons/${_toKebab(name)}.svg';
    return SvgPicture.asset(
      path,
      width: width ?? 24.w,
      height: height ?? 24.w,
      fit: fit,
      colorFilter: color != null
          ? ColorFilter.mode(color, BlendMode.srcATop)
          : null,
    );
  }
}

extension PngAssetX on PngAsset {
  Widget call({
    double? width,
    double? height,
    BoxFit fit = BoxFit.fill,
    String? variant,
  }) {
    final base = _toKebab(name);
    final path = variant == null
        ? 'assets/images/$base.png'
        : 'assets/images/$base-$variant.png';
    return SizedBox(
      width: width,
      height: height,
      child: Image.asset(path, fit: fit),
    );
  }
}
