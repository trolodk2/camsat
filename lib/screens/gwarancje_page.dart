import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'klima_entry.dart';

class GwarancjePage extends StatefulWidget {
  @override
  _GwarancjePageState createState() => _GwarancjePageState();
}

class _GwarancjePageState extends State<GwarancjePage> {
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
                TextButton(onPressed: () => Navigator.pop(context), child: Text("Anuluj")),
                ElevatedButton(
                  onPressed: () async {
                    final dataFormatted = "${selectedDate.year}/${selectedDate.month.toString().padLeft(2, '0')}/${selectedDate.day.toString().padLeft(2, '0')}";
                    await http.post(
                      Uri.parse('https://cam-sat.pl/klima/api_dodaj.php'),
                      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
                      body: {
                        'adres': adresController.text,
                        'komentarz': modelController.text,
                        'producent': selectedProducent!,
                        'telefon': telefonController.text,
                        'gwarancja': selectedGwarancja!,
                        'data': dataFormatted,
                        'przypomnij': przypomnijEmail ? "1" : "0",
                        'przypomnijsms': przypomnijSMS ? "1" : "0",
                      },
                    );
                    Navigator.pop(context);
                    odswiezDane();
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

  void showEditDialog(BuildContext context, KlimaEntry entry, {required VoidCallback odswiezDane}) {
    final adresController = TextEditingController(text: entry.adres);
    final modelController = TextEditingController(text: entry.komentarz);
    final telefonController = TextEditingController(text: entry.telefon);
    DateTime selectedDate = DateTime.tryParse(entry.data.replaceAll("/", "-")) ?? DateTime.now();
    String selectedProducent = entry.producent;
    String selectedGwarancja = entry.gwarancja;

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
                TextButton(onPressed: () => Navigator.pop(context), child: Text("Anuluj")),
                ElevatedButton(
                  onPressed: () async {
                    final dataFormatted = "${selectedDate.year}/${selectedDate.month.toString().padLeft(2, '0')}/${selectedDate.day.toString().padLeft(2, '0')}";
                    await http.post(
                      Uri.parse('https://cam-sat.pl/klima/api_edytuj.php'),
                      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
                      body: {
                        'id': entry.id,
                        'adres': adresController.text,
                        'komentarz': modelController.text,
                        'producent': selectedProducent,
                        'telefon': telefonController.text,
                        'gwarancja': selectedGwarancja,
                        'data': dataFormatted,
                      },
                    );
                    Navigator.pop(context);
                    odswiezDane();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Lista Gwarancji"),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: Image.asset('assets/images/camsat_logo.png', height: 50),
          )
        ],
      ),
      body: FutureBuilder<List<KlimaEntry>>(
        future: futureEntries,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator());
          if (snapshot.hasError) return Center(child: Text("Błąd: ${snapshot.error}"));
          if (!snapshot.hasData || snapshot.data!.isEmpty) return Center(child: Text("Brak danych"));

          final entries = snapshot.data!.where((entry) {
            final rok = entry.data.split('/')[0];
            final miesiac = entry.data.split('/')[1].padLeft(2, '0');
            final matchProducent = wybranyProducent == null || entry.producent == wybranyProducent;
            final matchRok = wybranyRok == null || rok == wybranyRok;
            final matchMiesiac = wybranyMiesiac == null || miesiac == wybranyMiesiac;
            return matchProducent && matchRok && matchMiesiac;
          }).toList();

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: wybranyProducent,
                        hint: Text("Producent"),
                        items: ['Sinclair', 'LG', 'AUX', 'Mitsubishi', 'Inny']
                            .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                            .toList(),
                        onChanged: (val) => setState(() => wybranyProducent = val),
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: wybranyRok,
                        hint: Text("Rok"),
                        items: List.generate(6, (i) => (2020 + i).toString())
                            .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                            .toList(),
                        onChanged: (val) => setState(() => wybranyRok = val),
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: wybranyMiesiac,
                        hint: Text("Miesiąc"),
                        items: List.generate(12, (i) {
                          final mc = (i + 1).toString().padLeft(2, '0');
                          return DropdownMenuItem(value: mc, child: Text(mc));
                        }),
                        onChanged: (val) => setState(() => wybranyMiesiac = val),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.clear),
                      onPressed: () => setState(() {
                        wybranyProducent = null;
                        wybranyRok = null;
                        wybranyMiesiac = null;
                      }),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: entries.length,
                  itemBuilder: (context, index) {
                    final entry = entries[index];
                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      child: ListTile(
                        title: Text(entry.adres, style: TextStyle(fontWeight: FontWeight.bold)),
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
                              onPressed: () => showEditDialog(context, entry, odswiezDane: () {
                                setState(() {
                                  futureEntries = fetchEntries();
                                });
                              }),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
															  showDialog(
															    context: context,
															    builder: (ctx) => AlertDialog(
															      title: Text("Potwierdzenie"),
															      content: Text("Czy na pewno usunąć ten wpis?"),
															      actions: [
															        TextButton(
															          onPressed: () => Navigator.of(ctx).pop(),
															          child: Text("Anuluj"),
															        ),
															        ElevatedButton(
															          onPressed: () async {
															            Navigator.of(ctx).pop(); // zamknij dialog
															            await http.post(
															              Uri.parse('https://cam-sat.pl/klima/api_usun.php'),
															              headers: {'Content-Type': 'application/x-www-form-urlencoded'},
															              body: {'id': entry.id},
															            );
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


/*import 'package:flutter/material.dart';

class GwarancjePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Gwarancje")),
      body: Center(
        child: Text("Tutaj będzie lista gwarancji"),
      ),
    );
  }
}*/
