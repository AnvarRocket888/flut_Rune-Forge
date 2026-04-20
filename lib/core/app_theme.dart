import 'package:flutter/cupertino.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static CupertinoThemeData get dark => const CupertinoThemeData(
    brightness: Brightness.dark,
    primaryColor: AppColors.accent,
    scaffoldBackgroundColor: AppColors.bgDark,
    barBackgroundColor: AppColors.navBg,
    textTheme: CupertinoTextThemeData(
      primaryColor: AppColors.textPrimary,
      textStyle: TextStyle(
        fontFamily: '.SF Pro Text',
        color: AppColors.textPrimary,
        fontSize: 16,
      ),
      navTitleTextStyle: TextStyle(
        fontFamily: '.SF Pro Display',
        color: AppColors.textGold,
        fontSize: 18,
        fontWeight: FontWeight.w700,
      ),
      navLargeTitleTextStyle: TextStyle(
        fontFamily: '.SF Pro Display',
        color: AppColors.textGold,
        fontSize: 34,
        fontWeight: FontWeight.w800,
      ),
    ),
  );
}
