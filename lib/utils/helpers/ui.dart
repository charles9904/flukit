import 'dart:math' as math;
import 'package:flukit/utils/flu_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../widgets/bottom_sheet.dart';

extension U on FluInterface {
  /// give access to currentContext
  BuildContext? get context => Get.context;

  /// give access to current theme data
  ThemeData getThemeOf(BuildContext context) => Theme.of(context);

  /// give access to current [ColorScheme]
  ColorScheme getColorSchemeOf(BuildContext context) =>
      getThemeOf(context).colorScheme;

  /// give access to current theme [TextTheme]
  TextTheme getTextThemeOf(BuildContext context) =>
      getThemeOf(context).textTheme;

  /// SystemUIOverlayStyle
  SystemUiOverlayStyle getDefaultSystemUiOverlayStyle(BuildContext context) {
    final ColorScheme colorScheme = getColorSchemeOf(context);
    return SystemUiOverlayStyle(
        statusBarColor: colorScheme.background,
        statusBarIconBrightness:
            Get.isDarkMode ? Brightness.light : Brightness.dark,
        systemNavigationBarColor: colorScheme.background,
        systemNavigationBarIconBrightness:
            Get.isDarkMode ? Brightness.light : Brightness.dark);
  }

  /// Does the current theme [Brightness] is dark
  bool get isDarkMode => Get.isDarkMode;

  /// switch theme
  void changeTheme(ThemeData theme) => Get.changeTheme(theme);

  /// switch theme mode
  void changeThemeMode() =>
      Get.changeThemeMode(isDarkMode ? ThemeMode.light : ThemeMode.dark);

  /// Get the screen size
  Size get screenSize => Get.size;

  /// Get the screen width
  double get screenWidth => screenSize.width;

  /// Get the screen height
  double get screenHeight => screenSize.height;

  /// return the status bar height
  double get statusBarHeight => MediaQuery.of(context!).padding.top;

  /// Detect if the keyboard is visible or not
  bool isKeyboardHidden(BuildContext context) =>
      !(MediaQuery.of(context).viewInsets.bottom == 0);

  /// Hide the keyboard
  void hideKeyboard() {
    SystemChannels.textInput.invokeMethod('TextInput.hide');
  }

  /// Show the keyboard
  void showKeyboard() {
    SystemChannels.textInput.invokeMethod('TextInput.show');
  }

  /// Get available avatars
  String getAvatar({FluAvatarTypes type = FluAvatarTypes.material3D, int? id}) {
    final bool getMaterial3DAvatars = type == FluAvatarTypes.material3D;
    int number;

    if (id != null) {
      number = id;
    } else {
      number = math.Random().nextInt(getMaterial3DAvatars
          ? 29
          : 35); // 29 and 35 are the numbers of available avatars
    }

    if (getMaterial3DAvatars) {
      return 'assets/Images/Avatars/Material3D/3d_avatar_${number == 0 ? number + 1 : number}.png';
    }
    return 'assets/Images/Avatars/Memojis/avatar${number == 0 ? '' : '-$number'}.png';
  }

  /// Show a [FluModalBottomSheet]
  void showFluModalBottomSheet(BuildContext context,
      {required Widget child,
      EdgeInsets padding = EdgeInsets.zero,
      double? cornerRadius,
      double? maxChildSize}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      backgroundColor: Colors.transparent,
      elevation: 10,
      builder: (context) => FluModalBottomSheet(
        maxChildSize: maxChildSize ?? .85,
        cornerRadius: cornerRadius,
        padding: padding,
        child: child,
      ),
    );
  }
}

enum FluAvatarTypes { material3D, memojis }
