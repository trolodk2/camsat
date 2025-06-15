import 'package:flutter/material.dart';
import 'pin_page.dart';
import 'login_router.dart';


class SplashScreen extends StatefulWidget {
  final bool firebaseOK;
  const SplashScreen({required this.firebaseOK});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Future.delayed(Duration(milliseconds: 500), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => LoginRouter()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/camsat_logo.png', height: 140),
              SizedBox(height: 20),
              Text("Ładowanie...", style: TextStyle(fontSize: 16, color: Colors.black54)),
              if (!widget.firebaseOK)
                Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: Text(
                    "⚠️ Firebase niedostępny – uruchamianie offline",
                    style: TextStyle(fontSize: 12, color: Colors.redAccent),
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
