import 'package:flutter/material.dart';
import '../utils/responsive.dart';

class AppTheme {
  AppTheme._();

  static const Color primary = Color(0xFF4A148C);
  static const Color primaryLight = Color(0xFFD1BEEB);
  static const Color surface = Color(0xFFF5F0FA);

  static BoxDecoration cardDecorationFor(BuildContext context) => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(Responsive.cardRadius(context)),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.06),
        blurRadius: Responsive.gapSm(context) * 1.2,
        offset: Offset(0, Responsive.gapXs(context)),
      ),
    ],
  );

  static BoxDecoration get cardDecoration => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(18),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.06),
        blurRadius: 12,
        offset: const Offset(0, 4),
      ),
    ],
  );

  static Widget buildAppBar(BuildContext context, String title, {bool showBack = true}) {
    final fontSize = Responsive.fontSizeTitle(context);
    final iconSize = Responsive.iconSizeSmall(context);
    final minTouch = Responsive.minTouchTarget(context);
    return Row(
      children: [
        if (showBack)
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(Icons.arrow_back_ios_new, color: primary, size: iconSize),
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(minWidth: minTouch, minHeight: minTouch),
          ),
        if (showBack) SizedBox(width: Responsive.gapSm(context)),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: primary,
            ),
          ),
        ),
      ],
    );
  }
}
