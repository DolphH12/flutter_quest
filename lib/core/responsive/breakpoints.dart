import 'package:flutter/widgets.dart';

enum FQDeviceSize { mobile, tablet, desktop }

abstract final class FQBreakpoints {
  static const double tablet = 768;
  static const double desktop = 1100;

  static FQDeviceSize of(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= desktop) {
      return FQDeviceSize.desktop;
    }
    if (width >= tablet) {
      return FQDeviceSize.tablet;
    }
    return FQDeviceSize.mobile;
  }

  static bool isDesktop(BuildContext context) =>
      of(context) == FQDeviceSize.desktop;

  static bool isTabletOrLarger(BuildContext context) {
    return of(context) != FQDeviceSize.mobile;
  }

  static double contentMaxWidth(BuildContext context) {
    switch (of(context)) {
      case FQDeviceSize.mobile:
        return 560;
      case FQDeviceSize.tablet:
        return 840;
      case FQDeviceSize.desktop:
        return 1080;
    }
  }

  static EdgeInsets pagePadding(BuildContext context) {
    switch (of(context)) {
      case FQDeviceSize.mobile:
        return const EdgeInsets.fromLTRB(16, 14, 16, 26);
      case FQDeviceSize.tablet:
        return const EdgeInsets.fromLTRB(24, 18, 24, 28);
      case FQDeviceSize.desktop:
        return const EdgeInsets.fromLTRB(28, 24, 28, 30);
    }
  }
}
