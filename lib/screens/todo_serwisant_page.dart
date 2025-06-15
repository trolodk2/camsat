import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/todo_zadanie.dart';

class TodoSerwisantPage extends StatefulWidget {
  @override
  _TodoSerwisantPageState createState() => _TodoSerwisantPageState();
}

class _TodoSerwisantPageState extends State<TodoSerwisantPage> {
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
        print("➡ Serwisant – ID do podświetlenia: $highlightedId");
      });
    }
    fetchZadania(); // <-- po ustawieniu highlightedId
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

			    Future.delayed(Duration(seconds: 5), () {
			      setState(() {
			        highlightedId = null;
			      });
			    });
			  });
			}
    } else {
      print("❌ Błąd pobierania danych");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Zadania – Serwisant")),
      body: ListView.builder(
        itemCount: lista.length,
        itemBuilder: (context, index) {
				  final zadanie = lista[index];
				  return Card(
				    key: itemKeys[zadanie.id.toString()],
				    margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
				    color: zadanie.id.toString() == highlightedId ? Colors.yellow[200] : null,
				    child: ExpansionTile(
				      title: Text(zadanie.tytul, style: TextStyle(fontWeight: FontWeight.bold)),
				      children: [
				        Padding(
				          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
				          child: Text(
				            zadanie.opisSerwis.isNotEmpty
				                ? zadanie.opisSerwis
				                : 'Brak opisu dla serwisanta',
				            style: TextStyle(fontSize: 15),
				          ),
				        ),
				        if (zadanie.sciezkaZdjecia != null && zadanie.sciezkaZdjecia!.isNotEmpty)
				          Padding(
				            padding: const EdgeInsets.only(bottom: 12),
				            child: Image.network(
				              'https://cam-sat.pl/klima/${zadanie.sciezkaZdjecia}',
				              height: 120,
				            ),
				          ),
				      ],
				    ),
				  );
				},
      ),
    );
  }
}
