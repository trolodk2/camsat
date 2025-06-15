
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'klima_entry.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Future.delayed(Duration(seconds: 1));
  runApp(KlimaApp());
}

class TodoZadanie {
  final int id;
  final String tytul;
  final String opis;
  final int priorytet;
  final String status;
  final String dataDodania;
	final String? sciezkaZdjecia;

  TodoZadanie({
    required this.id,
    required this.tytul,
    required this.opis,
    required this.priorytet,
    required this.status,
    required this.dataDodania,
    this.sciezkaZdjecia, // ← TO BYŁO POMINIĘTE
  });

  factory TodoZadanie.fromJson(Map<String, dynamic> json) {
    return TodoZadanie(
      id: int.parse(json['id']),
      tytul: json['tytul'],
      opis: json['opis'] ?? '',
      priorytet: int.parse(json['priorytet']),
      status: json['status'],
      dataDodania: json['data_dodania'],
			sciezkaZdjecia: json['sciezka_zdjecia'],
    );
  }
}


class KlimaApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CAM-SAT',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      debugShowCheckedModeBanner: false,
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
            Image.asset(
						  'assets/images/camsat_logoCien.png',
						  width: 200,
						  height: 200,
						  fit: BoxFit.contain,
						),

            SizedBox(height: 40),
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


// --- Wklejamy oryginalny KlimaHomePage z pełną logiką:
class KlimaHomePage extends StatefulWidget {
  @override
  _KlimaHomePageState createState() => _KlimaHomePageState();
}

class _KlimaHomePageState extends State<KlimaHomePage> {
  late Future<List<KlimaEntry>> futureEntries;
	String? wybranyProducent;
  String? wybranyRok;
	String? wybranyMiesiac;

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
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        title: Text(
          'Lista Gwarancji',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF006400), // ciemnozielony
          ),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: Image.asset(
              'assets/images/camsat_logo.png',
              height: 100,
              width: 100,
            ),
          )
        ],
      ),
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

          final allEntries = snapshot.data!;
          final entries = allEntries.where((entry) {
					  final rokMontazu = entry.data.split('/')[0];
					  final miesiacMontazu = entry.data.split('/')[1].padLeft(2, '0');

					  final matchProducent = wybranyProducent == null || entry.producent == wybranyProducent;
					  final matchRok = wybranyRok == null || rokMontazu == wybranyRok;
					  final matchMiesiac = wybranyMiesiac == null || miesiacMontazu == wybranyMiesiac;

					  return matchProducent && matchRok && matchMiesiac;
					}).toList();


          return Column(
            children: [
              Padding(
							  padding: const EdgeInsets.all(8.0),
							  child: Column(
							    crossAxisAlignment: CrossAxisAlignment.start,
							    children: [
							      Text("Filtruj:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
							      SizedBox(height: 8),
							      Row(
							        children: [
							          Expanded(
							            child: DropdownButton<String>(
							              isExpanded: true,
							              value: wybranyProducent,
							              hint: Text("Producent"),
							              items: ['Sinclair', 'LG', 'AUX', 'Mitsubishi', 'Inny']
							                  .map((p) => DropdownMenuItem(value: p, child: Text(p)))
							                  .toList(),
							              onChanged: (val) {
							                setState(() {
							                  wybranyProducent = val;
							                });
							              },
							            ),
							          ),
							          SizedBox(width: 10),
							          Expanded(
							            child: DropdownButton<String>(
							              isExpanded: true,
							              value: wybranyRok,
							              hint: Text("Rok"),
							              items: List.generate(6, (i) => (2020 + i).toString())
							                  .map((r) => DropdownMenuItem(value: r, child: Text(r)))
							                  .toList(),
							              onChanged: (val) {
							                setState(() {
							                  wybranyRok = val;
							                });
							              },
							            ),
							          ),
												SizedBox(width: 10),
												Expanded(
												  child: DropdownButton<String>(
												    isExpanded: true,
												    value: wybranyMiesiac,
												    hint: Text("Miesiąc"),
												    items: [
												      DropdownMenuItem(value: '01', child: Text('Styczeń')),
												      DropdownMenuItem(value: '02', child: Text('Luty')),
												      DropdownMenuItem(value: '03', child: Text('Marzec')),
												      DropdownMenuItem(value: '04', child: Text('Kwiecień')),
												      DropdownMenuItem(value: '05', child: Text('Maj')),
												      DropdownMenuItem(value: '06', child: Text('Czerwiec')),
												      DropdownMenuItem(value: '07', child: Text('Lipiec')),
												      DropdownMenuItem(value: '08', child: Text('Sierpień')),
												      DropdownMenuItem(value: '09', child: Text('Wrzesień')),
												      DropdownMenuItem(value: '10', child: Text('Październik')),
												      DropdownMenuItem(value: '11', child: Text('Listopad')),
												      DropdownMenuItem(value: '12', child: Text('Grudzień')),
												    ],
												    onChanged: (val) {
												      setState(() {
												        wybranyMiesiac = val;
												      });
												    },
												  ),
												),
							          SizedBox(width: 10),
							          ElevatedButton(
							            onPressed: () {
							              setState(() {
							                wybranyProducent = null;
							                wybranyRok = null;
															wybranyMiesiac = null;
															//print("Miesiąc wyczyszczony!");
							              });
							            },
							            child: Text("Wyczyść"),
							          ),
							        ],
							      ),
							    ],
							  ),
							),
              Expanded(
                child: ListView.builder(
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
                ),
              ),
            ],
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


// --- Prosty placeholder dla TODO:
class TodoPage extends StatefulWidget {
  @override
  _TodoPageState createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  List<TodoZadanie> zadania = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchZadania();
  }

  Future<void> fetchZadania() async {
    final response = await http.get(Uri.parse('https://cam-sat.pl/klima/api_getTodo.php'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
      setState(() {
        zadania = data.map((json) => TodoZadanie.fromJson(json)).toList();
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      print('Błąd ładowania danych');
    }
  }

Future<void> _usunZadanie(int id) async {
  final response = await http.post(
    Uri.parse('https://cam-sat.pl/klima/api_deleteTodo.php'),
    body: {'id': id.toString()},
  );

  if (response.statusCode == 200) {
    fetchZadania(); // odśwież listę
  } else {
    print("Błąd usuwania zadania");
  }
}

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
			//--
			floatingActionButton: FloatingActionButton(
		    onPressed: () {
		      showDialog(
		        context: context,
		        builder: (context) => DodajZadanieDialog(onDodane: fetchZadania),
		      );
		    },
		    child: Icon(Icons.add),
		  ),
//--
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : zadania.isEmpty
              ? Center(child: Text("Brak rzeczy do zrobienia"))
              : ListView.builder(
                  itemCount: zadania.length,
                  itemBuilder: (context, index) {
                    final zadanie = zadania[index];
                    return Card(
                      margin: EdgeInsets.all(12),
                      child: ListTile(
											  leading: zadanie.sciezkaZdjecia != null
											      ? Image.network(
											          'https://cam-sat.pl/klima/${zadanie.sciezkaZdjecia}',
											          width: 50,
											          height: 50,
											          fit: BoxFit.cover,
											        )
											      : null,
                        title: Text(zadanie.tytul, style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(zadanie.opis),
												trailing: Row(
												  mainAxisSize: MainAxisSize.min,
												  children: [
												    if (zadanie.priorytet == 1)
												      Padding(
												        padding: EdgeInsets.only(right: 8),
												        child: Icon(Icons.priority_high, color: Colors.red, size: 20),
												      ),
												    IconButton(
												      icon: Icon(Icons.edit, color: Colors.blue, size: 20),
												      onPressed: () {
												        // Tu dodamy edycję
												      },
												    ),
												    IconButton(
												      icon: Icon(Icons.delete, color: Colors.grey, size: 20),
												      onPressed: () {
												        _usunZadanie(zadanie.id);
												      },
												    ),
												  ],
												),
                      ),
                    );
                  },
                ),
    );
  }
}

class DodajZadanieDialog extends StatefulWidget {
  final VoidCallback onDodane;

  DodajZadanieDialog({required this.onDodane});

  @override
  _DodajZadanieDialogState createState() => _DodajZadanieDialogState();
}

class _DodajZadanieDialogState extends State<DodajZadanieDialog> {
  final _tytulCtrl = TextEditingController();
  final _opisCtrl = TextEditingController();
  int _priorytet = 2;

  Future<void> _dodajZadanie() async {
    final url = Uri.parse('https://cam-sat.pl/klima/api_addTodo.php');
    final response = await http.post(url, body: {
      'tytul': _tytulCtrl.text,
      'opis': _opisCtrl.text,
      'priorytet': _priorytet.toString(),
    });

    if (response.statusCode == 200) {
      Navigator.pop(context);
      widget.onDodane();
    } else {
      print("Błąd przy dodawaniu zadania");
    }
  }



  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Dodaj nowe zadanie"),
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              controller: _tytulCtrl,
              decoration: InputDecoration(labelText: "Tytuł"),
            ),
            TextField(
              controller: _opisCtrl,
              decoration: InputDecoration(labelText: "Opis"),
            ),
            DropdownButton<int>(
              value: _priorytet,
              onChanged: (val) {
                if (val != null) setState(() => _priorytet = val);
              },
              items: [
                DropdownMenuItem(child: Text("Pilne"), value: 1),
                DropdownMenuItem(child: Text("Normalne"), value: 2),
                DropdownMenuItem(child: Text("Niskie"), value: 3),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text("Anuluj"),
        ),
        ElevatedButton(
          onPressed: _dodajZadanie,
          child: Text("Dodaj"),
        ),
      ],
    );
  }
}


