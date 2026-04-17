import 'package:flutter/material.dart';

import '../utils/responsive.dart';

/// Standard page body wrapper for phone + tablet.
///
/// - Adds SafeArea
/// - Centers content on wide screens with max width
/// - Applies adaptive padding
/// - Optionally makes the content scrollable
class ResponsivePage extends StatelessWidget {
  const ResponsivePage({
    super.key,
    required this.child,
    this.scroll = true,
    this.padding,
    this.backgroundColor,
  });

  final Widget child;
  final bool scroll;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final effectivePadding = padding ??
        EdgeInsets.symmetric(
          horizontal: Responsive.horizontalPadding(context),
          vertical: Responsive.verticalPadding(context),
        );

    Widget body = Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: Responsive.maxContentWidth(context),
        ),
        child: Padding(
          padding: effectivePadding,
          child: child,
        ),
      ),
    );

    if (scroll) {
      body = SingleChildScrollView(child: body);
    }

    return ColoredBox(
      color: backgroundColor ?? Colors.transparent,
      child: SafeArea(child: body),
    );
  }
}

