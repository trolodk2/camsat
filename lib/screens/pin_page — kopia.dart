import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'start_page.dart';
import 'start_page_serwisant.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'globals.dart' as globals;

class PinPage extends StatefulWidget {
  @override
  _PinPageState createState() => _PinPageState();
}

class _PinPageState extends State<PinPage> {
	String _rola = 'serwisant'; // domyślnie serwisant
  final TextEditingController _pinController = TextEditingController();
  bool _loading = false;
  String? _error;

Future<void> _sprawdzPin() async {
  setState(() {
    _loading = true;
    _error = null;
  });

  try {
    final response = await http.get(Uri.parse("https://cam-sat.pl/push/pin.php?klucz=camsattoken"));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final pinZSerwera = _rola == 'admin' ? data['admin_pin'] : data['serwisant_pin'];

			if (_pinController.text == pinZSerwera) {
			  await _subskrybujTematyDlaRoli(_rola);
			  globals.rolaZalogowanego = _rola;

			  // 🔥 Sprawdź, czy apka była uruchomiona z powiadomienia (zimny start)
			  final RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
			  if (initialMessage != null) {
			    print("🟡 App uruchomiona z powiadomienia (PIN-page)!");
			    final typ = initialMessage.data['typ'];
			    final idZadania = initialMessage.data['id_zadania'];
			    print("➡ [PINpage] typ: $typ, id: $idZadania, rola: $_rola");

			    if (typ == 'nowe_zadanie' && idZadania != null) {
			      Navigator.pushReplacementNamed(
			        context,
			        _rola == 'admin' ? '/todo_admin' : '/todo_serwis',
			        arguments: {'highlightId': idZadania},
			      );
			      return; // Zakończ logikę – już nawigujemy
			    }
			  }

			  // Jeśli nie z powiadomienia, to idź normalnie
			  Navigator.pushReplacement(
			    context,
			    MaterialPageRoute(
			      builder: (context) => _rola == 'admin' ? StartPage() : StartPageSerwisant(),
			    ),
			  );
			}
			 else {
        setState(() => _error = 'Nieprawidłowy PIN');
      }
    } else {
      setState(() => _error = 'Błąd pobierania PIN');
    }
  } catch (e) {
    setState(() => _error = 'Błąd połączenia: $e');
  } finally {
    setState(() => _loading = false);
  }
}


Future<void> _subskrybujTematyDlaRoli(String rola) async {
  final messaging = FirebaseMessaging.instance;
  final String rolaCzysta = rola.trim();

  try {
    print("🧹 Usuwam subskrypcje z poprzednich tematów...");
    await messaging.unsubscribeFromTopic("wszyscy");
    await messaging.unsubscribeFromTopic("kierownicy");
    await messaging.unsubscribeFromTopic("serwisanci");

    print("✅ Subskrybuję temat: wszyscy");
    await messaging.subscribeToTopic("wszyscy");

    if (rolaCzysta == 'admin') {
      print("✅ Subskrybuję temat: kierownicy");
      await messaging.subscribeToTopic("kierownicy");
    } else if (rolaCzysta == 'serwisant') {
      print("✅ Subskrybuję temat: serwisanci");
      await messaging.subscribeToTopic("serwisanci");
    } else {
      print("⚠️ Nieznana rola: '$rolaCzysta'. Tylko 'wszyscy' zostaje.");
    }

    print("🎯 Subskrypcja zakończona dla roli: '$rolaCzysta'");
  } catch (e) {
    print("❌ Błąd podczas subskrypcji tematów FCM: $e");
  }
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Wprowadź PIN')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
					DropdownButtonFormField<String>(
					  value: _rola,
					  decoration: InputDecoration(labelText: 'Wybierz rolę'),
					  items: ['admin', 'serwisant'].map((rola) {
					    return DropdownMenuItem(
					      value: rola,
					      child: Text(rola == 'admin' ? 'Administrator' : 'Serwisant'),
					    );
					  }).toList(),
					  onChanged: (val) {
					    setState(() {
					      _rola = val!;
					    });
					  },
					),
					SizedBox(height: 16),

            TextField(
              controller: _pinController,
              obscureText: true,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'PIN'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loading ? null : _sprawdzPin,
              child: _loading ? CircularProgressIndicator() : Text('Zaloguj'),
            ),
            if (_error != null) ...[
              SizedBox(height: 20),
              Text(_error!, style: TextStyle(color: Colors.red)),
            ]
          ],
        ),
      ),
    );
  }
}
