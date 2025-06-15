import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dodaj_protokol_page.dart'; // to zara trza zrobic
import '../utils/file_helper.dart';

String? _wybranyRok;
final List<String> _dostepneLata = [
  '2025',
  '2024',
  '2023',
  'Wszystkie'
];

String? _wybranyMiesiac;
final List<String> _dostepneMiesiace = [
  'Wszystkie',
  '01',
  '02',
  '03',
  '04',
  '05',
  '06',
  '07',
  '08',
  '09',
  '10',
  '11',
  '12',
];


class Protokol {
  final int id;
  final String numer;
  final String adres;
  final String model;
  final DateTime dataMontazu;
  final String pdfPath;

  Protokol({
    required this.id,
    required this.numer,
    required this.adres,
    required this.model,
    required this.dataMontazu,
    required this.pdfPath,
  });

	factory Protokol.fromJson(Map<String, dynamic> json) {
  final numerPelny = "API/${json['rok']}/${json['numer_protokolu']}";
  print("DATA ZAKOŃCZENIA: ${json['data_zakonczenia']}"); // <-- debug OK tu

  return Protokol(
    id: int.parse(json['id']),
    numer: numerPelny,
    adres: json['adres_eksploatacji'],
    model: json['model_jednostki_wew'] ?? 'Brak',
    dataMontazu: DateTime.parse(json['data_montazu']),
    pdfPath: json['pdf_path'],
  );
}


}


class ProtokolyPage extends StatefulWidget {
  @override
  _ProtokolyPageState createState() => _ProtokolyPageState();
}

class _ProtokolyPageState extends State<ProtokolyPage> {
  List<Protokol> protokoly = [];
	TextEditingController _filterController = TextEditingController();
	List<Protokol> _filteredProtokoly = [];

  @override
  void initState() {
    super.initState();
    fetchProtokoly();
  }

  Future<void> fetchProtokoly() async {
    final response = await http.get(Uri.parse('https://cam-sat.pl/push/api_pobierz_protokoly.php'));
    if (response.statusCode == 200) {
      final List jsonList = json.decode(response.body);
			print(jsonList);
      setState(() {
			  protokoly = jsonList.map((e) => Protokol.fromJson(e)).toList();
			  _filtruj(); // zamiast: _filteredProtokoly = protokoly;
			});
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Błąd pobierania danych')));
    }
  }

Future<void> _usunProtokol(int id) async {
  final response = await http.post(
    Uri.parse('https://cam-sat.pl/push/api_usun_protokol.php'),
    body: {'id': id.toString()},
  );

  if (response.statusCode == 200) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Usunięto protokół")));
    await fetchProtokoly(); // odśwież listę
  } else {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Błąd podczas usuwania")));
  }
}


void _filtruj() {
  final tekst = _filterController.text.toLowerCase();
  final rok = _wybranyRok;
  final miesiac = _wybranyMiesiac;

  _filteredProtokoly = protokoly.where((p) {
    final matchesTekst = p.adres.toLowerCase().contains(tekst) || p.numer.toLowerCase().contains(tekst);
    final matchesRok = (rok == 'Wszystkie' || rok == null)
        ? true
        : p.numer.contains('/$rok/');

    final pMiesiac = p.dataMontazu.month.toString().padLeft(2, '0');
    final matchesMiesiac = (miesiac == 'Wszystkie' || miesiac == null)
        ? true
        : pMiesiac == miesiac;

    return matchesTekst && matchesRok && matchesMiesiac;
  }).toList();
}




  Future<void> openPDF(String pdfPath) async {
	  final url = 'https://cam-sat.pl/push/$pdfPath';
	  await otworzPlikZUrl(context, url);
	}


  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(title: Text('Protokoły z montażu')),
            body: protokoly.isEmpty
        ? Center(child: CircularProgressIndicator())
        : Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
  children: [
    Expanded(
      child: DropdownButtonFormField<String>(
        value: _wybranyRok ?? 'Wszystkie',
        decoration: InputDecoration(
          labelText: "Rok",
          border: OutlineInputBorder(),
        ),
        items: _dostepneLata.map((rok) {
          return DropdownMenuItem(value: rok, child: Text(rok));
        }).toList(),
        onChanged: (wybrane) {
          setState(() {
            _wybranyRok = wybrane;
            _filtruj();
          });
        },
      ),
    ),
    SizedBox(width: 10),
    Expanded(
      child: DropdownButtonFormField<String>(
        value: _wybranyMiesiac ?? 'Wszystkie',
        decoration: InputDecoration(
          labelText: "Miesiąc",
          border: OutlineInputBorder(),
        ),
        items: _dostepneMiesiace.map((m) {
          return DropdownMenuItem(value: m, child: Text(m));
        }).toList(),
        onChanged: (wybrany) {
          setState(() {
            _wybranyMiesiac = wybrany;
            _filtruj();
          });
        },
      ),
    ),
  ],
),

                    SizedBox(height: 12),
                    TextField(
  controller: _filterController,
  decoration: InputDecoration(
    labelText: "Szukaj",
    border: OutlineInputBorder(),
    prefixIcon: Icon(Icons.search),
  ),
  onChanged: (value) {
    setState(() {
      _filtruj();
    });
  },
)

                  ],
                ),
              ),
              Expanded(
  child: ListView.builder(
    itemCount: _filteredProtokoly.length,
    itemBuilder: (context, index) {
      final p = _filteredProtokoly[index];
      return ListTile(
        title: Text(p.numer, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 4),
            Text('📍 ${p.adres}'),
            Text('❄️  ${p.model.replaceAll("<br>", "\n")}'),
            Text('📅 ${p.dataMontazu.toString().split(" ").first}'),
          ],
        ),
        trailing: Icon(Icons.picture_as_pdf, color: Colors.redAccent),
        onTap: () => openPDF(p.pdfPath),
        onLongPress: () {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: Text("Usunąć protokół?"),
              content: Text("Czy na pewno chcesz usunąć protokół ${p.numer}?"),
              actions: [
                TextButton(
                  child: Text("Anuluj"),
                  onPressed: () => Navigator.of(ctx).pop(),
                ),
                TextButton(
                  child: Text("Usuń", style: TextStyle(color: Colors.red)),
                  onPressed: () async {
                    Navigator.of(ctx).pop();
                    await _usunProtokol(p.id);
                  },
                ),
              ],
            ),
          );
        },
      );
    },
  ),
),

            ],
          ),
    floatingActionButton: FloatingActionButton(
      onPressed: () async {
        final dodano = await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => DodajProtokolPage()),
        );
        if (dodano == true) fetchProtokoly();
      },
      child: Icon(Icons.add),
    ),
  );
}
}

