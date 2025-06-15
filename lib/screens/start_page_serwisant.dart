import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'todo_serwisant_page.dart';
import 'docs_page.dart'; // działa tak samo, tylko inny folder listujemy
import 'protokoly_page.dart';

class StartPageSerwisant extends StatefulWidget {
  @override
  _StartPageSerwisantState createState() => _StartPageSerwisantState();
}

class _StartPageSerwisantState extends State<StartPageSerwisant> {
  final Color przyciskKolor = Color(0xFF4AB117);

  @override
  void initState() {
    super.initState();
    FirebaseMessaging.instance.getToken().then((token) {
      print("📲 FCM TOKEN: $token");
    });
  }

  @override
  Widget build(BuildContext context) {
    print("🛠 build() StartPageSerwisant uruchomiony");
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 60),
              Image.asset(
                'assets/images/camsat_logoCien.png',
                width: 200,
                height: 200,
                fit: BoxFit.contain,
              ),
              SizedBox(height: 40),
              _buildButton(
                icon: Icons.task_alt,
                text: "Rzeczy do zrobienia",
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TodoSerwisantPage()),
                ),
              ),
              SizedBox(height: 20),
              _buildButton(
                icon: Icons.description,
                text: "Dokumenty",
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DocsPage(sciezka: "serwis/"),
                  ),
                ),
              ),
              SizedBox(height: 20),
              _buildButton(
                icon: Icons.picture_as_pdf,
                text: "Protokoły",
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProtokolyPage()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButton({
    required IconData icon,
    required String text,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: 260,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: przyciskKolor,
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 28, color: Colors.white),
            SizedBox(width: 12),
            Flexible(
              child: Text(text, style: TextStyle(fontSize: 18, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
