import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';
import 'pin_page.dart';

import 'gwarancje_page.dart';
import 'todo_page.dart';
import 'docs_page.dart';
import 'protokoly_page.dart';

class StartPage extends StatefulWidget {
  @override
  _StartPageState createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  final Color przyciskKolor = Color(0xFF4AB117);

  @override
void initState() {
  super.initState();

  FirebaseMessaging.instance.getToken().then((token) {
    print("?? FCM TOKEN: $token");

    Future.delayed(Duration(milliseconds: 500), () {
      if (!mounted) return;
    });
  });
}


  @override
  Widget build(BuildContext context) {
	print("?? build() StartPage uruchomiony");
		void _wyloguj() async {
	  final prefs = await SharedPreferences.getInstance();
	  await prefs.remove('rola_zalogowanego');
	  Navigator.pushAndRemoveUntil(
	    context,
	    MaterialPageRoute(builder: (_) => PinPage()),
	    (route) => false,
	  );
	}
    return Scaffold(
      body: Stack(
			  children: [
			    Positioned(
			      top: 50,
			      right: 20,
			      child: GestureDetector(
			        onTap: _wyloguj,
			        child: Container(
			          padding: EdgeInsets.all(8),
			          decoration: BoxDecoration(
			            color: Colors.black.withOpacity(0.05),
			            shape: BoxShape.circle,
			          ),
			          child: Icon(Icons.logout, size: 28, color: Colors.grey.shade800),
			        ),
			      ),
			    ),
			    Center(
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
                icon: Icons.list_alt,
                text: "Gwarancje",
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => GwarancjePage()),
                ),
              ),
              SizedBox(height: 20),
              _buildButton(
                icon: Icons.task_alt,
                text: "Rzeczy do zrobienia",
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TodoPage()),
                ),
              ),
              SizedBox(height: 20),
              _buildButton(
                icon: Icons.description,
                text: "Dokumenty",
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DocsPage()),
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
			],
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
        mainAxisSize: MainAxisSize.max,
        children: [
          Icon(icon, size: 28, color: Colors.white),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 18, color: Colors.white),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.left,
              textScaleFactor: 1.0,
            ),
          ),
        ],
      ),
    ),
  );
}

}
