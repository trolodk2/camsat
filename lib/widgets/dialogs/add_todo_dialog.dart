import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:flutter/foundation.dart';

class DodajZadanieDialog extends StatefulWidget {
  final VoidCallback onDodane;

  DodajZadanieDialog({required this.onDodane});

  @override
  _DodajZadanieDialogState createState() => _DodajZadanieDialogState();
}

class _DodajZadanieDialogState extends State<DodajZadanieDialog> {
  final tytulController = TextEditingController();
  final opisController = TextEditingController();
	final TextEditingController opisSerwisController = TextEditingController();
  int priorytet = 2;
  File? _zdjecie;

  Future<void> _wybierzZdjecie() async {
    final picker = ImagePicker();

    showModalBottomSheet(
      context: context,
      builder: (_) => Wrap(
        children: [
          ListTile(
            leading: Icon(Icons.camera_alt),
            title: Text("Zrób zdjęcie"),
            onTap: () async {
              final picked = await picker.pickImage(source: ImageSource.camera, imageQuality: 75);
              if (picked != null) {
                setState(() {
                  _zdjecie = File(picked.path);
                });
              }
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.photo),
            title: Text("Wybierz z galerii"),
            onTap: () async {
              final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 75);
              if (picked != null) {
                setState(() {
                  _zdjecie = File(picked.path);
                });
              }
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _zapisz() async {
    final uri = Uri.parse('https://cam-sat.pl/klima/api_addTodo.php');
    final request = http.MultipartRequest('POST', uri);

    request.fields['tytul'] = tytulController.text;
    request.fields['opis'] = opisController.text;
		request.fields['opis_serwis'] = opisSerwisController.text;
    request.fields['priorytet'] = priorytet.toString();

    if (_zdjecie != null) {
		  if (kIsWeb) {
		    final bytes = await _zdjecie!.readAsBytes();
		    final multipartFile = http.MultipartFile.fromBytes(
		      'zdjecie',
		      bytes,
		      filename: 'zdjecie.jpg',
		      contentType: MediaType('image', 'jpeg'),
		    );
		    request.files.add(multipartFile);
		  } else {
		    final multipartFile = await http.MultipartFile.fromPath(
		      'zdjecie',
		      _zdjecie!.path,
		      contentType: MediaType('image', 'jpeg'),
		    );
		    request.files.add(multipartFile);
		  }
		}
    final response = await request.send();
    if (response.statusCode == 200) {
      widget.onDodane();
      Navigator.pop(context);
    } else {
      print("Błąd zapisu: ${response.statusCode}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Dodaj zadanie"),
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextField(controller: tytulController, decoration: InputDecoration(labelText: "Tytuł")),
            TextField(controller: opisController, decoration: InputDecoration(labelText: "Opis")),
						TextField(controller: opisSerwisController, maxLines: 3, decoration: InputDecoration(labelText: "Opis dla serwisanta"),),
							SizedBox(height: 8),
            DropdownButton<int>(
              value: priorytet,
              items: [
                DropdownMenuItem(value: 1, child: Text("Pilne")),
                DropdownMenuItem(value: 2, child: Text("Normalne")),
              ],
              onChanged: (val) => setState(() => priorytet = val!),
            ),
            SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _wybierzZdjecie,
              icon: Icon(Icons.add_a_photo),
              label: Text("Dodaj zdjęcie"),
              style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF4AB117)),
            ),
            if (_zdjecie != null)
						  Padding(
						    padding: EdgeInsets.only(top: 12),
						    child: kIsWeb
						        ? Text("Zdjęcie wybrane") // tymczasowo na webie nie pokażemy obrazka
						        : Image.file(_zdjecie!, height: 100),
						  ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text("Anuluj")),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF4AB117)),
          child: Text("Zapisz"),
          onPressed: _zapisz,
        ),
      ],
    );
  }
}
