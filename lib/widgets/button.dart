import 'package:flutter/material.dart';
import 'package:flukit_icons/flukit_icons.dart';

/// Create a button
class FluButton extends StatelessWidget {
  const FluButton({
    required this.child,
    required this.onPressed,
    this.builder,
    this.backgroundColor,
    this.foregroundColor,
    this.padding = EdgeInsets.zero,
    this.margin = EdgeInsets.zero,
    this.elevation = 0.0,
    this.filled = false,
    this.flat = false,
    super.key,
  });

  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final EdgeInsets padding;
  final EdgeInsets margin;
  final double elevation;
  final bool filled;
  final bool flat;
  final Widget? child;
  final Widget Function(BuildContext)? builder;

  /// Create a button with icon content
  factory FluButton.icon(FluIcons icon,
          {double iconSize = 20,
          double iconStrokeWidth = 1.5,
          FluIconStyles iconStyle = FluIconStyles.twotone,
          VoidCallback? onPressed,
          Color? backgroundColor,
          Color? foregroundColor,
          EdgeInsets padding = EdgeInsets.zero,
          EdgeInsets margin = EdgeInsets.zero,
          double elevation = 0.0,
          bool filled = false,
          bool flat = false}) =>
      FluButton(
        onPressed: onPressed,
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        padding: padding,
        margin: margin,
        elevation: elevation,
        filled: filled,
        flat: flat,
        builder: (context) => FluIcon(
          icon,
          size: iconSize,
          style: iconStyle,
          strokewidth: iconStrokeWidth,
          color: _getButtonForegroundColor(context,
              flat: flat, filled: filled, disabled: onPressed == null),
        ),
        child: null,
      );

  /// Create a button with text content
  /// You can also add an icon before or after the text using [prefixIcon] and [suffixIcon].
  /// Control icons sizes with [iconSize], [prefixIconSize] and [suffixIconSize].
  /// use [iconStyle] to choose your icon style. refer to [https://github.com/charles9904/flukit_icons] to learn more.
  /// [spacing] determine the space available between text and icon.
  factory FluButton.text(String text,
      {FluIcons? prefixIcon,
      FluIcons? suffixIcon,
      double iconSize = 20,
      double? prefixIconSize,
      double? suffixIconSize,
      FluIconStyles iconStyle = FluIconStyles.twotone,
      double gap = 6.0,
      VoidCallback? onPressed,
      Color? backgroundColor,
      Color? foregroundColor,
      EdgeInsets padding = EdgeInsets.zero,
      EdgeInsets margin = EdgeInsets.zero,
      double elevation = 0.0,
      bool filled = false,
      bool flat = false}) {
    return FluButton(
      onPressed: onPressed,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      padding: padding,
      margin: margin,
      elevation: elevation,
      filled: filled,
      flat: flat,
      builder: (context) {
        Color foregroundColor = _getButtonForegroundColor(context,
            flat: flat, filled: filled, disabled: onPressed == null);
        Widget buildIcon(FluIcons icon, [double? size]) => FluIcon(
              icon,
              style: iconStyle,
              size: size ?? iconSize,
              color: foregroundColor,
              margin: EdgeInsets.only(
                right: prefixIcon != null ? gap : 0,
                left: suffixIcon != null ? gap : 0,
              ),
            );

        Widget textWidget =
            Text(text, style: TextStyle(color: foregroundColor));

        return (prefixIcon != null || suffixIcon != null)
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (prefixIcon != null) buildIcon(prefixIcon, prefixIconSize),
                  textWidget,
                  if (suffixIcon != null) buildIcon(suffixIcon, suffixIconSize),
                ],
              )
            : textWidget;
      },
      child: null,
    );
  }

  @override
  Widget build(BuildContext context) {
    ButtonStyle buttonStyle = ButtonStyle(
      backgroundColor: MaterialStateProperty.all(backgroundColor),
      foregroundColor: MaterialStatePropertyAll(foregroundColor),
      padding: MaterialStatePropertyAll(padding),
      elevation: MaterialStatePropertyAll(elevation),
    );
    Widget? child = this.child ?? builder?.call(context);
    Widget button;

    if (elevation > 0 && !flat && !filled) {
      button = ElevatedButton(
          onPressed: onPressed,
          style: buttonStyle,
          child: child ?? const Text('Elevated button !'));
    } else if (flat) {
      button = TextButton(
          onPressed: onPressed,
          style: buttonStyle,
          child: child ?? const Text('Text button !'));
    } else if (filled) {
      button = FilledButton(
        onPressed: onPressed,
        style: buttonStyle,
        child: child ?? const Text('Filled button !'),
      );
    } else {
      button = FilledButton.tonal(
        onPressed: onPressed,
        style: buttonStyle,
        child: child ?? const Text('Tonal button !'),
      );
    }

    if (margin != EdgeInsets.zero) {
      return Container(
        margin: margin,
        child: button,
      );
    }

    return button;
  }
}

/// Return foreground color according to M3 button specs
/// https://m3.material.io/components/buttons/specs
Color _getButtonForegroundColor(BuildContext context,
    {required bool flat,
    required bool filled,
    required bool disabled,
    double elevation = 0.0}) {
  ColorScheme colorScheme = Theme.of(context).colorScheme;

  if (disabled) {
    return colorScheme.onSurface;
  } else if (elevation > 0 && !flat && !filled) {
    return colorScheme.onBackground;
  } else if (flat) {
    return colorScheme.primary;
  } else if (filled) {
    return colorScheme.onPrimary;
  } else {
    return colorScheme.onSecondaryContainer;
  }
}
