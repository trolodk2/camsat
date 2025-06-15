import 'dart:async';
import 'package:flutter/material.dart';
import 'pin_page.dart';

class SplashScreen extends StatefulWidget {
  final bool firebaseOK;
  const SplashScreen({required this.firebaseOK});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double _progress = 0;

  @override
  void initState() {
    super.initState();
    _startLoading();
  }

  void _startLoading() async {
    for (int i = 0; i <= 100; i++) {
      await Future.delayed(Duration(milliseconds: 10));
      setState(() => _progress = i / 100);
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => PinPage(), // ← przejście do aplikacji właściwej
      ),
    );
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
              SizedBox(height: 40),
              LinearProgressIndicator(
                value: _progress,
                minHeight: 6,
                backgroundColor: Colors.grey[300],
              ),
              SizedBox(height: 20),
              Text("${(_progress * 100).toInt()}%", style: TextStyle(fontSize: 18)),
            ],
          ),
        ),
      ),
    );
  }
}
