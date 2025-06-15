
import 'package:flutter/material.dart';

void main() {
  runApp(KlimaApp());
}

class KlimaApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CAM-SAT',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: StartPage(),
    );
  }
}

class StartPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Wybierz tryb',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF006400),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 2,
      ),
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
						  style: ElevatedButton.styleFrom(
						    backgroundColor: Color(0xFF2E7D32),
						    minimumSize: Size(double.infinity, 100),
						    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
						  ),
						  onPressed: () {
						    Navigator.push(context, MaterialPageRoute(builder: (_) => KlimaHomePage()));
						  },
						  icon: Icon(Icons.assignment, size: 36, color: Colors.white),
						  label: Text("Gwarancje", style: TextStyle(fontSize: 24, color: Colors.white)),
						),

						SizedBox(height: 40),

						ElevatedButton.icon(
						  style: ElevatedButton.styleFrom(
						    backgroundColor: Color(0xFF1565C0),
						    minimumSize: Size(double.infinity, 100),
						    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
						  ),
						  onPressed: () {
						    Navigator.push(context, MaterialPageRoute(builder: (_) => TodoPage()));
						  },
						  icon: Icon(Icons.check_circle_outline, size: 36, color: Colors.white),
						  label: Text("Rzeczy do zrobienia", style: TextStyle(fontSize: 24, color: Colors.white)),
						),
          ],
        ),
      ),
    );
  }
}

class KlimaHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Gwarancje"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Text("Tutaj będzie ekran Gwarancji (stara zawartość)", style: TextStyle(fontSize: 20)),
      ),
    );
  }
}

class TodoPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Rzeczy do zrobienia"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Text("Tu będą rzeczy do zrobienia", style: TextStyle(fontSize: 20)),
      ),
    );
  }
}
