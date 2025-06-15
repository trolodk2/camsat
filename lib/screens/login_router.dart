import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'pin_page.dart';
import 'start_page.dart';
import 'start_page_serwisant.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'globals.dart' as globals;

class LoginRouter extends StatefulWidget {
  @override
  State<LoginRouter> createState() => _LoginRouterState();
}

class _LoginRouterState extends State<LoginRouter> {
  final LocalAuthentication auth = LocalAuthentication();
  String? rola;

  @override
  void initState() {
    super.initState();
    _sprawdzRola();
  }

  Future<void> _sprawdzRola() async {
    final prefs = await SharedPreferences.getInstance();
    final zapisanaRola = prefs.getString('rola_zalogowanego');

    if (zapisanaRola == null) {
      // Brak roli – pokaż ekran z PINem
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => PinPage()));
    } else {
      setState(() {
        rola = zapisanaRola;
        globals.rolaZalogowanego = zapisanaRola;
      });
    }
  }

  Future<void> _zalogujBiometrycznie() async {
    try {
      bool authenticated = await auth.authenticate(
        localizedReason: 'Uwierzytelnij się, aby się zalogować',
        options: AuthenticationOptions(biometricOnly: true),
      );

      if (authenticated) {
        final RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
        if (initialMessage != null) {
          final typ = initialMessage.data['typ'];
          final idZadania = initialMessage.data['id_zadania'];
          if (typ == 'nowe_zadanie' && idZadania != null) {
            Navigator.pushReplacementNamed(
              context,
              rola == 'admin' ? '/todo_admin' : '/todo_serwis',
              arguments: {'highlightId': idZadania},
            );
            return;
          }
        }

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => rola == 'admin' ? StartPage() : StartPageSerwisant(),
          ),
        );
      }
    } catch (e) {
      print("❌ Biometria nieudana: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Nie udało się uwierzytelnić.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (rola == null) {
      // Jeszcze sprawdzamy rolę – pokaż puste okno
      return Scaffold(backgroundColor: Colors.white);
    }

    return Scaffold(
      backgroundColor: Color(0xFFFFFFFF),
      body: SafeArea(
        child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/camsat_logoCien.png', height: 110),
              SizedBox(height: 100),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.green,
                  minimumSize: const Size(double.infinity, 2),
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                ),
                icon: Icon(Icons.fingerprint),
                label: Text("Zaloguj biometrycznie"),
                onPressed: _zalogujBiometrycznie,
              ),
              SizedBox(height: 20),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 2),
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                ),
                icon: Icon(Icons.login),
                label: Text("Zaloguj ręcznie"),
                onPressed: () {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => PinPage()));
                },
              ),
            ],
          ),
					),
        ),
      ),
    );
  }
}
