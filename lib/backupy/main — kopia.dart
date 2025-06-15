import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'klima_entry.dart';

void main() {
  runApp(KlimaApp());
}

class KlimaApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gwarancje Klima',
      home: KlimaHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

String _twoDigits(int n) => n.toString().padLeft(2, '0');

class KlimaHomePage extends StatefulWidget {
  @override
  _KlimaHomePageState createState() => _KlimaHomePageState();
}

class _KlimaHomePageState extends State<KlimaHomePage> {
  late Future<List<KlimaEntry>> futureEntries;

  @override
  void initState() {
    super.initState();
    futureEntries = fetchEntries();
  }

  Future<List<KlimaEntry>> fetchEntries() async {
    final response = await http.get(Uri.parse('https://cam-sat.pl/klima/getEntries.php'));

    if (response.statusCode == 200) {
      final List jsonData = json.decode(response.body);
      return jsonData.map((item) => KlimaEntry.fromJson(item)).toList();
    } else {
      throw Exception('Błąd ładowania danych');
    }
  }

Future<void> dodajWpis({
  required String adres,
  required String model,
  required String producent,
  required String telefon,
  required String gwarancja,
  required String data,
  required bool przypomnij,
  required bool przypomnijSMS,
}) async {
  final uri = Uri.parse('https://cam-sat.pl/klima/api_dodaj.php');
  final response = await http.post(
    uri,
    headers: {
      'Content-Type': 'application/x-www-form-urlencoded',
    },
    body: {
      'adres': adres,
      'komentarz': model,
      'producent': producent,
      'telefon': telefon,
      'gwarancja': gwarancja,
      'data': data,
      'przypomnij': przypomnij ? "1" : "0",
      'przypomnijsms': przypomnijSMS ? "1" : "0",
    },
  );

  if (response.statusCode != 200) {
    throw Exception('Nie udało się dodać wpisu: ${response.body}');
  }
}

//-----------------------

Future<void> zapiszEdycjeWpisu({
  required String id,
  required String adres,
  required String model,
  required String producent,
  required String telefon,
  required String gwarancja,
  required String data,
}) async {
  final uri = Uri.parse('https://cam-sat.pl/klima/api_edytuj.php');
  final response = await http.post(
    uri,
    headers: {'Content-Type': 'application/x-www-form-urlencoded'},
    body: {
      'id': id,
      'adres': adres,
      'komentarz': model,
      'producent': producent,
      'telefon': telefon,
      'gwarancja': gwarancja,
      'data': data,
    },
  );

  if (response.statusCode != 200) {
    throw Exception('Nie udało się zapisać edycji: ${response.body}');
  }
}

//-----------------------

Future<void> usunWpis(String id) async {
  final uri = Uri.parse('https://cam-sat.pl/klima/api_usun.php');
  final response = await http.post(
    uri,
    headers: {'Content-Type': 'application/x-www-form-urlencoded'},
    body: {'id': id},
  );

  if (response.statusCode != 200) {
    throw Exception('Nie udało się usunąć wpisu: ${response.body}');
  }
}


//-----------------------



  void showAddDialog(BuildContext context, {required VoidCallback odswiezDane}) {
  final adresController = TextEditingController();
  final modelController = TextEditingController();
  final telefonController = TextEditingController();

  DateTime selectedDate = DateTime.now();
  String? selectedProducent = 'Sinclair';
  String? selectedGwarancja = '3';
  bool przypomnijEmail = false;
  bool przypomnijSMS = false;

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text("Dodaj wpis"),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  TextField(controller: adresController, decoration: InputDecoration(labelText: "Adres")),
                  TextField(controller: modelController, decoration: InputDecoration(labelText: "Komentarz")),
                  TextField(controller: telefonController, decoration: InputDecoration(labelText: "Telefon")),

                  SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: selectedProducent,
                    items: ['Sinclair', 'LG', 'AUX', 'Mitsubishi', 'Inny']
                        .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                        .toList(),
                    onChanged: (val) => setState(() => selectedProducent = val),
                    decoration: InputDecoration(labelText: "Producent *"),
                  ),
                  DropdownButtonFormField<String>(
                    value: selectedGwarancja,
                    items: ['3', '5']
                        .map((g) => DropdownMenuItem(value: g, child: Text("$g lata")))
                        .toList(),
                    onChanged: (val) => setState(() => selectedGwarancja = val),
                    decoration: InputDecoration(labelText: "Gwarancja *"),
                  ),

                  SizedBox(height: 10),
                  Row(
                    children: [
                      Text("Data montażu: "),
                      TextButton(
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) {
                            setState(() {
                              selectedDate = picked;
                            });
                          }
                        },
                        child: Text("${selectedDate.year}/${selectedDate.month.toString().padLeft(2, '0')}/${selectedDate.day.toString().padLeft(2, '0')}"),
                      ),
                    ],
                  ),

                  CheckboxListTile(
                    value: przypomnijEmail,
                    onChanged: (value) => setState(() => przypomnijEmail = value!),
                    title: Text("Przypomnij e-mail"),
                  ),
                  CheckboxListTile(
                    value: przypomnijSMS,
                    onChanged: (value) => setState(() => przypomnijSMS = value!),
                    title: Text("Przypomnij SMS"),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text("Anuluj"),
              ),
              ElevatedButton(
							  onPressed: () async {
							    if (selectedProducent == null || selectedGwarancja == null) {
							      ScaffoldMessenger.of(context).showSnackBar(
							        SnackBar(content: Text("Uzupełnij wymagane pola.")),
							      );
							      return;
							    }

							    final dataFormatted = "${selectedDate.year}/${selectedDate.month.toString().padLeft(2, '0')}/${selectedDate.day.toString().padLeft(2, '0')}";

							    await dodajWpis(
							      adres: adresController.text,
							      model: modelController.text,
							      producent: selectedProducent!,
							      telefon: telefonController.text,
							      gwarancja: selectedGwarancja!,
							      data: dataFormatted,
							      przypomnij: przypomnijEmail,
							      przypomnijSMS: przypomnijSMS,
							    );

							    Navigator.of(context).pop(); // najpierw zamknij okno

							    // ODŚWIEŻ PO ZAMKNIĘCIU
							    WidgetsBinding.instance.addPostFrameCallback((_) {
							      odswiezDane(); // wywołaj dopiero po wyrenderowaniu głównego widoku
							    });
							  },
							  child: Text("Dodaj"),
							),
            ],
          );
        },
      );
    },
  );
}

//---------------------------------------------------------------------------
//---------------------------------------------------------------------------
//---------------------------------------------------------------------------

void showEditDialog(BuildContext context, KlimaEntry entry, {required VoidCallback odswiezDane}) {
  final adresController = TextEditingController(text: entry.adres);
  final modelController = TextEditingController(text: entry.komentarz);
  final telefonController = TextEditingController(text: entry.telefon);

  DateTime selectedDate = DateTime.tryParse(entry.data.replaceAll("/", "-")) ?? DateTime.now();
  String selectedProducent = entry.producent;
  String selectedGwarancja = entry.gwarancja;
  bool przypomnijEmail = false;
  bool przypomnijSMS = false;

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text("Edytuj wpis"),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  TextField(controller: adresController, decoration: InputDecoration(labelText: "Adres")),
                  TextField(controller: modelController, decoration: InputDecoration(labelText: "Komentarz")),
                  TextField(controller: telefonController, decoration: InputDecoration(labelText: "Telefon")),
                  SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: selectedProducent,
                    items: ['Sinclair', 'LG', 'AUX', 'Mitsubishi', 'Inny']
                        .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                        .toList(),
                    onChanged: (val) => setState(() => selectedProducent = val!),
                    decoration: InputDecoration(labelText: "Producent *"),
                  ),
                  DropdownButtonFormField<String>(
                    value: selectedGwarancja,
                    items: ['3', '5']
                        .map((g) => DropdownMenuItem(value: g, child: Text("$g lata")))
                        .toList(),
                    onChanged: (val) => setState(() => selectedGwarancja = val!),
                    decoration: InputDecoration(labelText: "Gwarancja *"),
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Text("Data montażu: "),
                      TextButton(
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) {
                            setState(() {
                              selectedDate = picked;
                            });
                          }
                        },
                        child: Text("${selectedDate.year}/${selectedDate.month.toString().padLeft(2, '0')}/${selectedDate.day.toString().padLeft(2, '0')}"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text("Anuluj"),
              ),
              ElevatedButton(
                onPressed: () async {
                  final dataFormatted = "${selectedDate.year}/${selectedDate.month.toString().padLeft(2, '0')}/${selectedDate.day.toString().padLeft(2, '0')}";

                  // 👇 tu dodamy zapis do bazy
                  await zapiszEdycjeWpisu(
									  id: entry.id,
									  adres: adresController.text,
									  model: modelController.text,
									  producent: selectedProducent,
									  telefon: telefonController.text,
									  gwarancja: selectedGwarancja,
									  data: dataFormatted,
									);

                  Navigator.of(context).pop();

                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    odswiezDane();
                  });
                },
                child: Text("Zapisz"),
              ),
            ],
          );
        },
      );
    },
  );
}

//---------------------------------------------------------------------------
//---------------------------------------------------------------------------
//---------------------------------------------------------------------------



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Lista Gwarancji')),
      body: FutureBuilder<List<KlimaEntry>>(
        future: futureEntries,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Błąd: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Brak danych'));
          }

          final entries = snapshot.data!;

          return ListView.builder(
					  itemCount: entries.length,
					  itemBuilder: (context, index) {
					    final entry = entries[index];
					    return Padding(
					      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
					      child: Card(
					        elevation: 3,
					        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
					        child: ListTile(
					          leading: Icon(Icons.house_siding_rounded, color: Colors.blue),
					          title: Text(
					            entry.adres,
					            style: TextStyle(fontWeight: FontWeight.bold),
					          ),
					          subtitle: Column(
					            crossAxisAlignment: CrossAxisAlignment.start,
					            children: [
					              Text("Komentarz: ${entry.komentarz}"),
					              Text("Producent: ${entry.producent}"),
					              Text("Data: ${entry.data}"),
					              Text("Gwarancja: ${entry.gwarancja} lata"),
					              Text("Telefon: ${entry.telefon}"),
					            ],
					          ),
					          trailing: Row(
										  mainAxisSize: MainAxisSize.min,
										  children: [
										    IconButton(
										      icon: Icon(Icons.edit, color: Colors.orange),
										      onPressed: () {
										        showEditDialog(context, entry, odswiezDane: () {
										          setState(() {
										            futureEntries = fetchEntries();
										          });
										        });
										      },
										    ),
										    IconButton(
										      icon: Icon(Icons.delete, color: Colors.red),
										      onPressed: () {
										        showDialog(
										          context: context,
										          builder: (ctx) => AlertDialog(
										            title: Text("Potwierdź"),
										            content: Text("Na pewno chcesz usunąć ten wpis?"),
										            actions: [
										              TextButton(
										                onPressed: () => Navigator.of(ctx).pop(),
										                child: Text("Anuluj"),
										              ),
										              ElevatedButton(
										                onPressed: () async {
										                  Navigator.of(ctx).pop();
										                  await usunWpis(entry.id);
										                  setState(() {
										                    futureEntries = fetchEntries();
										                  });
										                },
										                child: Text("Usuń"),
										              ),
										            ],
										          ),
										        );
										      },
										    ),
										  ],
										),
					          isThreeLine: true,
					        ),
					      ),
					    );
					  },
					);
        },
      ),
      floatingActionButton: FloatingActionButton(
			  onPressed: () {
			    showAddDialog(context, odswiezDane: () {
			      setState(() {
			        futureEntries = fetchEntries();
			      });
			    });
			  },
			  child: Icon(Icons.add),
			),

    );
  }
}
