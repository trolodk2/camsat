import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../models/todo_zadanie.dart';

class EdytujZadanieDialog extends StatefulWidget {
  final TodoZadanie zadanie;
  final VoidCallback onZapisane;

  const EdytujZadanieDialog({
    required this.zadanie,
    required this.onZapisane,
  });

  @override
  _EdytujZadanieDialogState createState() => _EdytujZadanieDialogState();
}

class _EdytujZadanieDialogState extends State<EdytujZadanieDialog> {
  late TextEditingController tytulController;
  late TextEditingController opisController;
	late TextEditingController opisSerwisController;
  late int priorytet;

  @override
  void initState() {
    super.initState();
    tytulController = TextEditingController(text: widget.zadanie.tytul);
    opisController = TextEditingController(text: widget.zadanie.opis);
		opisSerwisController = TextEditingController(text: widget.zadanie.opisSerwis);
    priorytet = widget.zadanie.priorytet;
  }

  Future<void> _zapiszZmiany() async {
    final response = await http.post(
      Uri.parse('https://cam-sat.pl/klima/api_editTodo.php'),
      body: {
			  'id': widget.zadanie.id.toString(),
			  'tytul': tytulController.text,
			  'opis': opisController.text,
			  'opis_serwis': opisSerwisController.text,
			  'priorytet': priorytet.toString(),
			},
    );

    if (response.statusCode == 200) {
      Navigator.pop(context);
      widget.onZapisane();
    } else {
      print("Błąd aktualizacji: ${response.body}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Edytuj zadanie"),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: tytulController,
              decoration: InputDecoration(labelText: "Tytuł"),
            ),
            TextField(
              controller: opisController,
              decoration: InputDecoration(labelText: "Opis"),
            ),
						SizedBox(height: 8),
						TextField(
						  controller: opisSerwisController,
						  decoration: InputDecoration(labelText: "Opis dla serwisanta"),
						),
            DropdownButton<int>(
              value: priorytet,
              items: [
                DropdownMenuItem(value: 1, child: Text("Pilne")),
                DropdownMenuItem(value: 2, child: Text("Normalne")),
              ],
              onChanged: (val) {
                setState(() {
                  priorytet = val!;
                });
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          child: Text("Anuluj"),
          onPressed: () => Navigator.pop(context),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF4AB117)),
          child: Text("Zapisz"),
          onPressed: _zapiszZmiany,
        ),
      ],
    );
  }
}
