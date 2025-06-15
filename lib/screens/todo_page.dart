// lib/screens/todo_page.dart
// lib/screens/todo_page.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/todo_zadanie.dart';
import '../widgets/dialogs/edit_todo_dialog.dart';
import '../widgets/dialogs/add_todo_dialog.dart';

class TodoPage extends StatefulWidget {
  @override
  _TodoPageState createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  List<TodoZadanie> lista = [];
	Map<String, GlobalKey> itemKeys = {};
	String? highlightedId;


  @override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    final args = ModalRoute.of(context)?.settings.arguments as Map?;
    if (args != null && args['highlightId'] != null) {
      setState(() {
        highlightedId = args['highlightId'].toString();
        print("➡ Otrzymano ID do podświetlenia: $highlightedId");
      });
    }
    fetchZadania();
  });
}


  Future<void> fetchZadania() async {
    final response = await http.get(Uri.parse('https://cam-sat.pl/klima/api_getTodo.php'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
			  lista = data.map((e) => TodoZadanie.fromJson(e)).toList();
			  itemKeys.clear();
			  for (var zad in lista) {
			    itemKeys[zad.id.toString()] = GlobalKey();
			  }
			});

			if (highlightedId != null && itemKeys[highlightedId] != null) {
			  Future.delayed(Duration(milliseconds: 500), () {
			    final key = itemKeys[highlightedId];
			    if (key != null && key.currentContext != null) {
			      Scrollable.ensureVisible(
			        key.currentContext!,
			        duration: Duration(milliseconds: 600),
			      );
			    }

			    // zgaś po 5 sekundach
			    Future.delayed(Duration(seconds: 5), () {
			      setState(() {
			        highlightedId = null;
			      });
			    });
			  });
			}
    } else {
      print("Błąd pobierania danych");
    }
  }

  Future<void> _usunZadanie(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Usuń zadanie"),
        content: Text("Czy na pewno chcesz usunąć to zadanie?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text("Anuluj")),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text("Usuń")),
        ],
      ),
    );
    if (confirm == true) {
      final response = await http.post(
        Uri.parse('https://cam-sat.pl/klima/api_deleteTodo.php'),
        body: {'id': id.toString()},
      );
      if (response.statusCode == 200) {
        fetchZadania();
      } else {
        print("Błąd usuwania zadania");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Rzeczy do zrobienia")),
      body: ListView.builder(
        itemCount: lista.length,
        itemBuilder: (context, index) {
          final zadanie = lista[index];
          return Card(
						key: itemKeys[zadanie.id.toString()],
  					color: zadanie.id.toString() == highlightedId ? Colors.yellow[200] : null,
            child: ListTile(
              title: Row(
							  children: [
							    if (zadanie.priorytet == 1)
							      Icon(Icons.priority_high, color: Colors.red, size: 20),
							    if (zadanie.priorytet == 1)
							      SizedBox(width: 6),
							    Expanded(
							      child: Text(
							        zadanie.tytul,
							        style: TextStyle(fontWeight: FontWeight.bold),
							      ),
							    ),
							  ],
							),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
								  Text(zadanie.opis),
								  if (zadanie.opisSerwis.isNotEmpty)
								    Padding(
								      padding: const EdgeInsets.only(top: 4.0),
								      child: GestureDetector(
								        onTap: () {
								          showDialog(
								            context: context,
								            builder: (_) => AlertDialog(
								              title: Text("Opis dla serwisanta"),
								              content: Text(zadanie.opisSerwis),
								              actions: [
								                TextButton(
								                  onPressed: () => Navigator.pop(context),
								                  child: Text("Zamknij"),
								                ),
								              ],
								            ),
								          );
								        },
								        child: Row(
								          children: [
								            Icon(Icons.info_outline, size: 20, color: Colors.blueGrey),
								            SizedBox(width: 6),
								            Text("Pokaż opis dla serwisanta", style: TextStyle(color: Colors.blue)),
								          ],
								        ),
								      ),
								    ),
								  if (zadanie.sciezkaZdjecia != null && zadanie.sciezkaZdjecia!.isNotEmpty)
                    GestureDetector(
                      onTap: () => showDialog(
                        context: context,
                        builder: (_) => Dialog(
                          child: Image.network('https://cam-sat.pl/klima/${zadanie.sciezkaZdjecia}'),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Image.network(
                          'https://cam-sat.pl/klima/${zadanie.sciezkaZdjecia}',
                          height: 100,
                        ),
                      ),
                    ),
                ],
              ),
              trailing: Row(
							  mainAxisSize: MainAxisSize.min,
							  children: [
							    //if (zadanie.priorytet == 1)
							    //  Icon(Icons.priority_high, color: Colors.red),
							    IconButton(
							      icon: Icon(Icons.edit),
							      onPressed: () {
							        showDialog(
							          context: context,
							          builder: (context) => EdytujZadanieDialog(
							            zadanie: zadanie,
							            onZapisane: fetchZadania,
							          ),
							        );
							      },
							    ),
							    IconButton(
							      icon: Icon(Icons.delete),
							      onPressed: () => _usunZadanie(zadanie.id),
							    ),
							  ],
							),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xFF4AB117), // zielony CAM-SAT
        child: Icon(Icons.add),
        onPressed: () {
				  showDialog(
				    context: context,
				    builder: (context) => DodajZadanieDialog(onDodane: fetchZadania),
				  );
				},
      ),
    );
  }
}
