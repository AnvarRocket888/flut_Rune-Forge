import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:rune_forge/clear_app.dart';
import 'package:rune_forge/firebase_options.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/services/sdk_initializer.dart';
import 'package:flutter/cupertino.dart';
import 'core/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  SdkInitializer.prefs = await SharedPreferences.getInstance();
  await SdkInitializer.loadRuntimeStorageToDevice();
  var isFirstStart = !SdkInitializer.hasValue("isFirstStart");
  var isOrganic = SdkInitializer.getValue("Organic");
  // if (isFirstStart) SdkInitializer.initAppsFlyer();

  runApp(
    const App(),
  );
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return const CupertinoApp(
      debugShowCheckedModeBanner: false,
      home: ClearApp(),
    );
  }
}
