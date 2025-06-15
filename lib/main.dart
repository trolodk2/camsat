import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'screens/pin_page.dart';
import 'screens/splash_screen.dart';
import 'screens/todo_page.dart';
import 'screens/todo_serwisant_page.dart';
import 'screens/globals.dart' as globals;

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  print(" START MAIN");

  bool firebaseOK = true;

  try {
    print(" Lista aplikacji Firebase przed inicjalizacj¹:");
    Firebase.apps.forEach((app) => print(" ? ${app.name}"));

    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      print("? Firebase zainicjalizowany rêcznie");
    } else {
      print("?? Firebase ju¿ by³ zainicjalizowany – pomijam.");
    }

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("?? Klikniêto powiadomienie!");

      final typ = message.data['typ'];
      final idZadania = message.data['id_zadania'];
      final rola = globals.rolaZalogowanego?.trim();

      print("? typ: $typ, id_zadania: $idZadania, rola: $rola");

      if (typ == 'nowe_zadanie' && idZadania != null) {
        if (rola == 'admin') {
          navigatorKey.currentState?.pushNamed('/todo_admin', arguments: {'highlightId': idZadania});
        } else if (rola == 'serwisant') {
          navigatorKey.currentState?.pushNamed('/todo_serwis', arguments: {'highlightId': idZadania});
        }
      }
    });

  } catch (e, stack) {
    firebaseOK = false;
    print("? B³¹d przy Firebase.initializeApp(): $e");
    print(stack);
  }

  runApp(MaterialApp(
    navigatorKey: navigatorKey,
    debugShowCheckedModeBanner: false,
    title: 'CAM-SAT Gwarancje',
    theme: ThemeData(
      primarySwatch: Colors.green,
      scaffoldBackgroundColor: Colors.white,
    ),
    home: SplashScreen(firebaseOK: firebaseOK),
    routes: {
      '/todo_admin': (context) => TodoPage(),
      '/todo_serwis': (context) => TodoSerwisantPage(),
    },
  ));
}

