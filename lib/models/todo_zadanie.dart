// lib/models/todo_zadanie.dart
class TodoZadanie {
  final int id;
  final String tytul;
  final String opis;
  final int priorytet;
  final String status;
  final String dataDodania;
  final String? sciezkaZdjecia;
	final String opisSerwis;

  TodoZadanie({
    required this.id,
    required this.tytul,
    required this.opis,
		required this.opisSerwis,
    required this.priorytet,
    required this.status,
    required this.dataDodania,
    this.sciezkaZdjecia,
  });

  factory TodoZadanie.fromJson(Map<String, dynamic> json) {
    return TodoZadanie(
      id: int.parse(json['id']),
      tytul: json['tytul'],
      opis: json['opis'],
    	opisSerwis: json['opis_serwis'] ?? '',
      priorytet: int.parse(json['priorytet']),
      status: json['status'],
      dataDodania: json['data_dodania'],
      sciezkaZdjecia: json['sciezka_zdjecia'],
    );
  }
}
