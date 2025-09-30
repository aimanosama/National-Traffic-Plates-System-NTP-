import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/app_colors.dart';

class ThemedBackground extends StatelessWidget {
  const ThemedBackground({
    super.key,
    required this.child,
    this.safeArea = true,
    this.padding,
    this.backgroundColor,
  });

  final Widget child;
  final bool safeArea;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    Widget content = child;

    if (padding != null) {
      content = Padding(padding: padding!, child: content);
    }

    if (safeArea) {
      content = SafeArea(child: content);
    }

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        image: backgroundColor == null
            ? const DecorationImage(
                image: NetworkImage(AppColors.mainBackgroundUrl),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: content,
    );
  }
}
