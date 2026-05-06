import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:rune_forge/clear_app.dart';

class AppConfig {
//========================= App Serrings =========================//

  static const String appsFlyerDevKey = 'nmAGZwWUdCyhDotoAVSVZL';
  static const String appsFlyerAppId = '6762792448'; // Для iOS'
  static const String bundleId = 'com.ashleyswear.runeforge'; // Для iOS'
  static const String locale = 'en'; // Для iOS'
  static const String os = 'iOS'; // Для iOS'
  static const String endpoint = 'https://overuneforging.com'; // Для iOS'

  static const Widget appContent = ClearApp(); //

  static const String logoPath = 'assets/Logo.png';
  static const String pushRequestLogoPath = 'assets/Logo.png';

  static const String pushRequestBackgroundPath =
      'assets/bgnot.png';
  static const String splashBackgroundPath =
      'assets/bgloading.png';
  static const String errorBackgroundPath =
      'assets/bgnonet.png';

  static const List<DeviceOrientation> webGLAllowedOrientations = [
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ];

//========================= UI Settings =========================//

  //========================= Splash Screen ====================//
  static const Decoration splashDecoration = const BoxDecoration(
    image: DecorationImage(
      image: AssetImage(AppConfig.splashBackgroundPath),
      fit: BoxFit.cover,
    ),
  );

  static const Color loadingTextColor = Color(0xFFFFFFFF);
  static const Color spinerColor = Color(0xFCFFFFFF);

  //========================= Push Request Screen ====================//

  static const Decoration pushRequestDecoration = const BoxDecoration(
    image: DecorationImage(
      image: AssetImage(AppConfig.pushRequestBackgroundPath),
      fit: BoxFit.cover,
    ),
  );

  static const Gradient pushRequestFadeGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0x00000000),
      Color.fromARGB(135, 0, 0, 0),
    ],
  );
  static const Color titleTextColor = Color(0xFFFFFFFF);
  static const Color subtitleTextColor = Color(0x80FDFDFD);

  static const Color yesButtonColor = Color(0xFFFFB301);
  static const Color yesButtonShadowColor = Color(0xFF8B3619);
  static const Color yesButtonTextColor = Color(0xFFFFFFFF);
  static const Color skipTextColor = Color(0x7DF9F9F9);

  //========================= Error Screen ====================//
  static const Decoration errorScreenDecoration = const BoxDecoration(
    image: DecorationImage(
      image: AssetImage(AppConfig.errorBackgroundPath),
      fit: BoxFit.cover,
    ),
  );

  static const Color errorScreenTextColor = Color.fromARGB(255, 255, 0, 0);
  static const Color errorScreenIconColor = Color.fromARGB(251, 255, 0, 0);
}
