import 'package:flutter/material.dart';

import 'fq_colors.dart';

abstract final class FQSpacing {
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 40;
}

abstract final class FQRadius {
  static const BorderRadius small = BorderRadius.all(Radius.circular(14));
  static const BorderRadius medium = BorderRadius.all(Radius.circular(22));
  static const BorderRadius large = BorderRadius.all(Radius.circular(30));
  static const BorderRadius xLarge = BorderRadius.all(Radius.circular(38));
  static const BorderRadius pill = BorderRadius.all(Radius.circular(999));
}

abstract final class FQShadows {
  static const List<BoxShadow> soft = [
    BoxShadow(color: Color(0x14002C57), blurRadius: 24, offset: Offset(0, 12)),
    BoxShadow(color: Color(0x0E7EAFFF), blurRadius: 8, offset: Offset(0, 2)),
  ];

  static const List<BoxShadow> floating = [
    BoxShadow(
      color: Color(0x2600356C),
      blurRadius: 36,
      spreadRadius: 2,
      offset: Offset(0, 20),
    ),
  ];

  static const List<BoxShadow> glow = [
    BoxShadow(
      color: Color(0x3867B3FF),
      blurRadius: 24,
      spreadRadius: 0,
      offset: Offset(0, 10),
    ),
  ];
}

abstract final class FQIconContainerStyle {
  static BoxDecoration base({Color? color}) => BoxDecoration(
    color: color ?? FQColors.surfaceLow,
    borderRadius: FQRadius.small,
    boxShadow: FQShadows.soft,
  );
}
