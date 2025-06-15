import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'screens/start_page.dart';
import 'screens/pin_page.dart';
import 'screens/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  print(" START MAIN");

  bool firebaseOK = true;

  Future(() async {
    try {
      print(" Lista aplikacji Firebase przed inicjalizacj�:");
      Firebase.apps.forEach((app) => print(" ? ${app.name}"));

      if (Firebase.apps.isEmpty) {
        print(" Firebase.apps.isEmpty = true � pr�buj� zainicjalizowa�...");
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
        print("? Firebase zainicjalizowany r�cznie");
      } else {
        print("?? Firebase ju� by� zainicjalizowany � pomijam.");
      }

      if (!kIsWeb) {
        try {
          //await FirebaseMessaging.instance.subscribeToTopic("serwisanci");
          //await FirebaseMessaging.instance.subscribeToTopic("wszyscy");
          print("? Subskrypcje OK");
        } catch (e) {
          print("? B��d przy subskrypcji temat�w: $e");
        }
      }
    } catch (e, stack) {
      firebaseOK = false;
      print("? B��d przy Firebase.initializeApp(): $e");
      print(stack);
    }
  });

  runApp(KlimaApp(firebaseOK: firebaseOK));
}


class KlimaApp extends StatelessWidget {
  final bool firebaseOK;
  const KlimaApp({required this.firebaseOK});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CAM-SAT Gwarancje',
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: SplashScreen(firebaseOK: firebaseOK),
    );
  }
}

