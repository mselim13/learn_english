import 'package:flutter/material.dart';

/// Ekran genişliğine göre detaylı breakpoint'ler
class Breakpoints {
  static const double smallMobile = 360;
  static const double mobile = 600;
  static const double tablet = 900;
  static const double desktop = 1200;
  static const double largeDesktop = 1600;
}

/// Responsive yardımcı sınıfı - detaylı tasarım desteği
class Responsive {
  Responsive._();

  static bool isSmallMobile(BuildContext context) =>
      MediaQuery.sizeOf(context).width < Breakpoints.smallMobile;

  static bool isMobile(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    return w >= Breakpoints.smallMobile && w < Breakpoints.mobile;
  }

  static bool isTablet(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    return w >= Breakpoints.mobile && w < Breakpoints.tablet;
  }

  static bool isDesktop(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= Breakpoints.tablet;

  static bool isLargeDesktop(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= Breakpoints.desktop;

  static double width(BuildContext context) => MediaQuery.sizeOf(context).width;
  static double height(BuildContext context) => MediaQuery.sizeOf(context).height;

  /// 0-1 arası ölçek: küçük ekranda 0, büyük ekranda 1
  static double _scaleFactor(BuildContext context) {
    final w = width(context);
    if (w < Breakpoints.smallMobile) return 0.0;
    if (w < Breakpoints.mobile) return 0.25;
    if (w < Breakpoints.tablet) return 0.5;
    if (w < Breakpoints.desktop) return 0.75;
    return 1.0;
  }

  /// Ölçeklendirilmiş değer (min ve max arasında interpolasyon)
  static double scaled(
    BuildContext context, {
    required double min,
    required double max,
  }) {
    final t = _scaleFactor(context);
    return min + (max - min) * t;
  }

  /// Mobil, tablet ve masaüstü için farklı değerler (geriye uyumlu)
  static T value<T>(
    BuildContext context, {
    required T mobile,
    T? tablet,
    T? desktop,
    T? smallMobile,
  }) {
    final w = width(context);
    if (w < Breakpoints.smallMobile && smallMobile != null) return smallMobile;
    if (w >= Breakpoints.tablet && desktop != null) return desktop;
    if (w >= Breakpoints.mobile && tablet != null) return tablet;
    return mobile;
  }

  /// Yatay padding - ekran boyutuna uyumlu
  static double horizontalPadding(BuildContext context) => value(
        context,
        smallMobile: 16.0,
        mobile: 20.0,
        tablet: 32.0,
        desktop: 48.0,
      );

  /// Dikey padding
  static double verticalPadding(BuildContext context) => value(
        context,
        smallMobile: 12.0,
        mobile: 16.0,
        tablet: 24.0,
        desktop: 32.0,
      );

  /// Öğeler arası boşluk
  static double spacing(BuildContext context, {double multiplier = 1.0}) =>
      scaled(context, min: 8.0 * multiplier, max: 20.0 * multiplier);

  /// Maksimum içerik genişliği (masaüstü için)
  static double maxContentWidth(BuildContext context) => value(
        context,
        mobile: double.infinity,
        tablet: 640.0,
        desktop: 900.0,
      );

  /// Grid sütun sayısı
  static int gridColumns(BuildContext context) => value(
        context,
        smallMobile: 2,
        mobile: 2,
        tablet: 3,
        desktop: 4,
      );

  /// Minimum dokunma hedefi (erişilebilirlik - 48dp)
  static double minTouchTarget(BuildContext context) =>
      value(context, smallMobile: 44.0, mobile: 48.0, tablet: 52.0, desktop: 56.0);

  // === Tipografi ===

  static double fontSizeDisplay(BuildContext context) =>
      scaled(context, min: 28.0, max: 42.0);

  static double fontSizeTitle(BuildContext context) =>
      scaled(context, min: 20.0, max: 28.0);

  static double fontSizeTitleSmall(BuildContext context) =>
      scaled(context, min: 16.0, max: 22.0);

  static double fontSizeBody(BuildContext context) =>
      scaled(context, min: 14.0, max: 18.0);

  static double fontSizeBodySmall(BuildContext context) =>
      scaled(context, min: 12.0, max: 15.0);

  static double fontSizeCaption(BuildContext context) =>
      scaled(context, min: 11.0, max: 14.0);

  static double fontSizeButton(BuildContext context) =>
      scaled(context, min: 14.0, max: 18.0);

  // === Kart ve Bileşen Boyutları ===

  static double cardRadius(BuildContext context) =>
      value(context, smallMobile: 14.0, mobile: 18.0, tablet: 22.0, desktop: 28.0);

  static double cardPadding(BuildContext context) =>
      value(context, smallMobile: 16.0, mobile: 20.0, tablet: 28.0, desktop: 36.0);

  static double buttonPaddingVertical(BuildContext context) =>
      value(context, smallMobile: 12.0, mobile: 14.0, tablet: 16.0, desktop: 20.0);

  static double iconSizeSmall(BuildContext context) =>
      value(context, smallMobile: 20.0, mobile: 22.0, tablet: 26.0, desktop: 30.0);

  static double iconSizeMedium(BuildContext context) =>
      value(context, smallMobile: 24.0, mobile: 28.0, tablet: 34.0, desktop: 40.0);

  static double iconSizeLarge(BuildContext context) =>
      value(context, smallMobile: 48.0, mobile: 56.0, tablet: 72.0, desktop: 88.0);

  /// Kısa boşluk (4-8px)
  static double gapXs(BuildContext context) =>
      scaled(context, min: 4.0, max: 8.0);

  /// Küçük boşluk (8-12px)
  static double gapSm(BuildContext context) =>
      scaled(context, min: 8.0, max: 12.0);

  /// Orta boşluk (12-20px)
  static double gapMd(BuildContext context) =>
      scaled(context, min: 12.0, max: 20.0);

  /// Büyük boşluk (16-28px)
  static double gapLg(BuildContext context) =>
      scaled(context, min: 16.0, max: 28.0);

  /// Çok büyük boşluk (24-40px)
  static double gapXl(BuildContext context) =>
      scaled(context, min: 24.0, max: 40.0);

  /// Avatar çember çapı (radius için /2 kullan)
  static double avatarSize(BuildContext context) =>
      scaled(context, min: 90.0, max: 140.0);

  /// Bottom sheet handle genişliği
  static double handleWidth(BuildContext context) =>
      value(context, smallMobile: 36.0, mobile: 40.0, tablet: 48.0, desktop: 56.0);

  /// Bottom sheet handle yüksekliği
  static double handleHeight(BuildContext context) => 4.0;
}
