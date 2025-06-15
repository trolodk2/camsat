class KlimaEntry {
  final String id;
  final String producent;
  final String adres;
  final String telefon;
  final String komentarz;
  final String data;
  final String gwarancja;

  KlimaEntry({
    required this.id,
    required this.producent,
    required this.adres,
    required this.telefon,
    required this.komentarz,
    required this.data,
    required this.gwarancja,
  });

  factory KlimaEntry.fromJson(Map<String, dynamic> json) {
    return KlimaEntry(
      id: json['id'] ?? '',
      producent: json['producent'] ?? '',
      adres: json['adres'] ?? '',
      telefon: json['telefon'] ?? '',
      komentarz: json['komentarz'] ?? '',
      data: json['data'] ?? '',
      gwarancja: json['gwarancja'] ?? '',
    );
  }
}
