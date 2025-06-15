import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:signature/signature.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

	final Map<String, String> ilosciCzynnikaNaModel = {
  'SOH-09BIT': '0.53',
  'SOH-13BIT': '0.57',
  'SOH-18BIT': '1.0',
  'SOH-24BIT': '1.5',
  'SOH-09BIK2': '0.53',
  'SOH-12BIK2': '0.57',
  'SOH-18BIK2': '0.75',
  'SOH-24BIK2': '1.3',
  'MV-E14BI2': '0.75',
  'MV-E18BI2': '0.9',
  'MV-E21BI2': '1.6',
  'MV-E24BI2': '1.7',
  'MV-E28BI2': '1.8',
  'MV-E36BI2': '2.4',
  'MV-E42BI2': '2.4',
};

	final Map<String, List<String>> modeleZew = {
	  'Sinclair Terrel': ['SOH-09BIT', 'SOH-13BIT', 'SOH-18BIT', 'SOH-24BIT'],
	  'Sinclair Keyon': ['SOH-09BIK2', 'SOH-12BIK2', 'SOH-18BIK2', 'SOH-24BIK2'],
	  'Sinclair Ray': ['SOH-12BIR', 'SOH-18BIR'],
	  'Sinclair Multi': ['MV-E14BI2', 'MV-E18BI2', 'MV-E21BI2', 'MV-E24BI2', 'MV-E28BI2', 'MV-E36BI2', 'MV-E42BI2'],
	};

	final Map<String, List<String>> modeleWew = modeleZew.map(
	  (k, v) => MapEntry(k, v.map((e) => e.replaceFirst('SOH', 'SIH')).toList()),
	);

String? _wybranyProducent;
String? _modelZewnetrzny;
String? _modelWewnetrzny;
String wykonujacy = "Rafał Madziąg";
String certyfikatFgaz = "FGAZ/O/04/00050/16";
String dataRozpoczecia = "";
String dataZakonczenia = "";
String rodzajCzynnosci = "instalowanie";
String kontrolaSzczelnosci = "Szczelny";
String metodaKontroli = "Bezpośrednia Testo 316-3";
String? kategoria = "1";
String? podkategoria = "A";
String? rodzajCzynnika = "R32";
String? iloscCzynnika;
String? odzyskany;
String? dodany;
String? okresGwarancji = "36";
String? pompkaSkroplin = "Brak";
String? poziomProzni = "200";
String? dlugoscInstalacji;
String? croRejestracja = "NIE";
String? uwagi;

class FormularzDane {
  final int numerProtokolu;
  final String dataRozpoczecia;
  final String dataZakonczenia;
  final String domyslnyCzynnik;
  final String domyslneCRO;
  final Map<String, List<String>> modele;
	List<String> _listaModeliZew = [];


  FormularzDane({
    required this.numerProtokolu,
    required this.dataRozpoczecia,
    required this.dataZakonczenia,
    required this.domyslnyCzynnik,
    required this.domyslneCRO,
    required this.modele,
  });

  factory FormularzDane.fromJson(Map<String, dynamic> json) {
    return FormularzDane(
      numerProtokolu: json['numer_protokolu'],
      dataRozpoczecia: json['domyslne']['data_rozpoczecia'],
      dataZakonczenia: json['domyslne']['data_zakonczenia'],
      domyslnyCzynnik: json['domyslne']['rodzaj_czynnika'],
      domyslneCRO: json['domyslne']['cro_rejestracja'],
      modele: Map<String, List<String>>.from(
        (json['modele'] as Map).map((k, v) => MapEntry(k, List<String>.from(v))),
      ),
    );
  }
}

class DodajProtokolPage extends StatefulWidget {
  @override
  _DodajProtokolPageState createState() => _DodajProtokolPageState();
}

class _DodajProtokolPageState extends State<DodajProtokolPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _adresController = TextEditingController();
	final TextEditingController _iloscCzynnikaController = TextEditingController();
	final TextEditingController _dataRozpoczeciaController = TextEditingController();
	final TextEditingController _dataZakonczeniaController = TextEditingController();
  final TextEditingController _modelZewController = TextEditingController();
  final SignatureController _signatureController = SignatureController(
    penStrokeWidth: 3,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );

  FormularzDane? _formularzDane;
  bool _isSaving = false;

@override
void initState() {
  super.initState();
  _pobierzDaneFormularza();
}


  Future<void> _pobierzDaneFormularza() async {
    final response = await http.get(Uri.parse('https://cam-sat.pl/push/api_formularz_dane.php'));

    if (response.statusCode == 200) {
      final dane = FormularzDane.fromJson(json.decode(response.body));
      setState(() {
        _formularzDane = dane;
        _dataRozpoczeciaController.text = dane.dataRozpoczecia;
				_dataZakonczeniaController.text = dane.dataZakonczenia;
        _wybranyProducent = dane.modele.keys.first;
        _modelZewnetrzny = modeleZew[_wybranyProducent!]!.first;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Błąd ładowania danych formularza")));
    }
  }

  Future<void> _zapiszProtokol() async {
    if (!_formKey.currentState!.validate()) return;
    if (_signatureController.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Podpis jest wymagany")));
      return;
    }
		if (_dataRozpoczeciaController.text.isEmpty || _dataZakonczeniaController.text.isEmpty) {
		  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Uzupełnij daty rozpoczęcia i zakończenia")));
		  return;
		}


    setState(() => _isSaving = true);

    final podpisBytes = await _signatureController.toPngBytes();

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('https://cam-sat.pl/push/api_zapisz_protokol.php'),
    );
    request.fields['adres_eksploatacji'] = _adresController.text;
    request.fields['producent'] = _wybranyProducent ?? '';
    request.fields['model_jednostki_zew'] = _modelZewController.text;
    int i = 0;
		for (final item in _jednostkiWew) {
		  request.fields['model_jednostki_wew[$i]'] = item['model']!.text;
		  request.fields['nr_seryjny_wew[$i]'] = item['nr']!.text;
		  i++;
		}
		request.fields['wykonujacy'] = wykonujacy;
		request.fields['certyfikat_fgaz'] = certyfikatFgaz;
		request.fields['data_rozpoczecia'] = "${_dataRozpoczeciaController.text} 00:00:00";
		request.fields['data_zakonczenia'] = "${_dataZakonczeniaController.text} 00:00:00";
		request.fields['rodzaj_czynnosci'] = rodzajCzynnosci;
		request.fields['kontrola_szczelnosci'] = kontrolaSzczelnosci;
		request.fields['metoda_kontroli'] = metodaKontroli;
		request.fields['nazwa_urzadzenia'] = _wybranaNazwaUrzadzenia ?? '';
		request.fields['nr_seryjny_zew'] = _nrSeryjnyZewController.text;
		request.fields['rodzaj_czynnika'] = rodzajCzynnika ?? '';
		request.fields['ilosc_czynnika'] = iloscCzynnika ?? '';
		request.fields['ilosc_odzyskanego'] = odzyskany ?? '';
		request.fields['ilosc_dodanego'] = dodany ?? '';
		request.fields['okres_gwarancji'] = okresGwarancji ?? '';
		request.fields['kategoria'] = kategoria ?? '';
		request.fields['podkategoria'] = podkategoria ?? '';
		request.fields['pompka_skroplin'] = pompkaSkroplin ?? '';
		request.fields['poziom_prozni'] = poziomProzni ?? '';
		request.fields['dlugosc_instalacji'] = dlugoscInstalacji ?? '';
		request.fields['cro_rejestracja'] = croRejestracja ?? '';
		request.fields['uwagi'] = uwagi ?? '';
		request.fields['numer_protokolu'] = _formularzDane!.numerProtokolu.toString();
		request.fields['rok'] = DateTime.now().year.toString();


    final podpisBase64 = base64Encode(podpisBytes!);
		request.fields['podpis_base64'] = 'data:image/png;base64,$podpisBase64';


    final streamedResponse = await request.send();
		final response = await http.Response.fromStream(streamedResponse);
    setState(() => _isSaving = false);

		print("STATUS: ${response.statusCode}");
		print("BODY: ${response.body}");

    if (response.statusCode == 200) {
		  ScaffoldMessenger.of(context).showSnackBar(
		    SnackBar(content: Text("Zapisano protokół")),
		  );
		  Navigator.pop(context, true); // ← to powinno zamykać ekran
		} else {
		  ScaffoldMessenger.of(context).showSnackBar(
		    SnackBar(content: Text("Błąd podczas zapisu")),
		  );
		}

  }


String? _wybranaNazwaUrzadzenia;
final TextEditingController _nrSeryjnyZewController = TextEditingController();
List<Map<String, TextEditingController>> _jednostkiWew = [
  {'model': TextEditingController(), 'nr': TextEditingController()}
];

void _ustawDomyslneJednostki(String nazwa) {
  final modelZew = modeleZew[nazwa]?.first;
  final modelWew = modeleWew[nazwa]?.first;

  _modelZewnetrzny = modelZew;
  _modelZewController.text = modelZew ?? '';
  iloscCzynnika = ilosciCzynnikaNaModel[modelZew] ?? '';

  _jednostkiWew = [
    {
      'model': TextEditingController(text: modelWew ?? ''),
      'nr': TextEditingController()
    }
  ];
}

  @override
  void dispose() {
    _adresController.dispose();
		_dataRozpoczeciaController.dispose();
		_dataZakonczeniaController.dispose();
    _modelZewController.dispose();
		_iloscCzynnikaController.dispose();
    _signatureController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_formularzDane == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Nowy protokół')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('Nowy protokół')),
			backgroundColor: Color(0xFFF0F0F0),
      body: Padding(
  padding: const EdgeInsets.all(16.0),
  child: _isSaving
      ? Center(child: CircularProgressIndicator())
      : Form(
          key: _formKey,
          child: ListView(

                  children: [
									Text("Protokół nr: ${_formularzDane!.numerProtokolu}/${_formularzDane!.dataRozpoczecia.substring(0,4)}", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
SizedBox(height: 16),
                    Container(
  margin: EdgeInsets.only(bottom: 20),
  padding: EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12),
    boxShadow: [
      BoxShadow(
        color: Colors.grey.withOpacity(0.2),
        spreadRadius: 2,
        blurRadius: 6,
        offset: Offset(0, 3),
      ),
    ],
  ),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      TextFormField(
        controller: _adresController,
        decoration: InputDecoration(labelText: 'Adres eksploatacji'),
        validator: (val) => val == null || val.isEmpty ? 'Wymagane' : null,
      ),
      SizedBox(height: 12),
      Row(
        children: [
          Expanded(
            child: TextFormField(
              initialValue: "Rafał Madziąg",
              decoration: InputDecoration(labelText: 'Wykonujący czynności'),
              onChanged: (val) => wykonujacy = val,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: TextFormField(
              initialValue: "FGAZ/O/04/00050/16",
              decoration: InputDecoration(labelText: 'Certyfikat F-gaz'),
              onChanged: (val) => certyfikatFgaz = val,
            ),
          ),
        ],
      ),
      SizedBox(height: 12),
      Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () async {
                final data = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2100),
                );
                if (data != null) {
                  _dataRozpoczeciaController.text = data.toIso8601String().split("T").first;
                  dataRozpoczecia = data.toIso8601String().split("T").first;
                }
              },
              child: AbsorbPointer(
                child: TextFormField(
                  controller: _dataRozpoczeciaController,
                  decoration: InputDecoration(labelText: "Data rozpoczęcia"),
                ),
              ),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: () async {
                final data = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2100),
                );
                if (data != null) {
                  _dataZakonczeniaController.text = data.toIso8601String().split("T").first;
                  dataZakonczenia = data.toIso8601String().split("T").first;
                }
              },
              child: AbsorbPointer(
                child: TextFormField(
                  controller: _dataZakonczeniaController,
                  decoration: InputDecoration(labelText: "Data zakończenia"),
                ),
              ),
            ),
          ),
        ],
      ),
    ],
  ),
),



Container(
  margin: EdgeInsets.only(bottom: 20),
  padding: EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12),
    boxShadow: [
      BoxShadow(
        color: Colors.grey.withOpacity(0.2),
        spreadRadius: 2,
        blurRadius: 6,
        offset: Offset(0, 3),
      ),
    ],
  ),
  child: Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Text("Rodzaj czynności", style: TextStyle(fontWeight: FontWeight.bold)),
    ...[
      "instalowanie",
      "konserwacja lub serwisowanie",
      "naprawa lub likwidacja",
      "Odzysk",
      "Naprawa nieszczelności"
    ].map((val) => RadioListTile<String>(
      title: Text(val),
      value: val,
      groupValue: rodzajCzynnosci,
      onChanged: (val) => setState(() => rodzajCzynnosci = val!),
      dense: true,
    )),
    SizedBox(height: 16),
    Text("Kontrola szczelności", style: TextStyle(fontWeight: FontWeight.bold)),
    RadioListTile<String>(
      title: Text("Szczelny"),
      value: "Szczelny",
      groupValue: kontrolaSzczelnosci,
      onChanged: (val) => setState(() => kontrolaSzczelnosci = val!),
      dense: true,
    ),
    RadioListTile<String>(
      title: Text("Nieszczelny"),
      value: "Nieszczelny",
      groupValue: kontrolaSzczelnosci,
      onChanged: (val) => setState(() => kontrolaSzczelnosci = val!),
      dense: true,
    ),
    SizedBox(height: 12),
    TextFormField(
      initialValue: "Bezpośrednia Testo 316-3",
      decoration: InputDecoration(labelText: "Metoda kontroli szczelności"),
      onChanged: (val) => metodaKontroli = val,
    ),
  ],
),

),


Container(
  margin: EdgeInsets.only(bottom: 20),
  padding: EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12),
    boxShadow: [
      BoxShadow(
        color: Colors.grey.withOpacity(0.2),
        spreadRadius: 2,
        blurRadius: 6,
        offset: Offset(0, 3),
      ),
    ],
  ),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text("Urządzenie i jednostki", style: TextStyle(fontWeight: FontWeight.bold)),

      SizedBox(height: 12),
      DropdownButtonFormField<String>(
        value: _wybranaNazwaUrzadzenia,
        decoration: InputDecoration(labelText: "Nazwa urządzenia"),
        items: [
          'Sinclair Terrel', 'Sinclair Keyon', 'Sinclair Ray', 'Sinclair Multi', 'Inne'
        ].map((nazwa) => DropdownMenuItem(
          value: nazwa,
          child: Text(nazwa),
        )).toList(),
        onChanged: (nowa) {
          setState(() {
            _wybranaNazwaUrzadzenia = nowa;
            if (nowa != 'Inne') _ustawDomyslneJednostki(nowa!);
            else {
              _modelZewController.text = '';
							iloscCzynnika = ''; // wyczyść ilość czynnika
              _jednostkiWew = [
                {'model': TextEditingController(), 'nr': TextEditingController()}
              ];
            }
          });
        },
      ),

      SizedBox(height: 12),
      Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<String>(
									  value: (_modelZewnetrzny != null &&
										        (modeleZew[_wybranaNazwaUrzadzenia] ?? []).contains(_modelZewnetrzny))
										    ? _modelZewnetrzny
										    : null,
									  decoration: InputDecoration(labelText: "Model jednostki zewnętrznej"),
									  items: (_wybranaNazwaUrzadzenia != null
										  ? modeleZew[_wybranaNazwaUrzadzenia] ?? []
										  : []
										)
									      .map<DropdownMenuItem<String>>((model) => DropdownMenuItem<String>(
												  value: model,
												  child: Text(model),
												))
									      .toList(),
									  onChanged: (nowyModel) {
										  setState(() {
										    _modelZewnetrzny = nowyModel;
										    _modelZewController.text = nowyModel ?? '';

										    // Ustaw model wewnętrzny na analogiczny SIH...
										    final nowyModelWew = nowyModel?.replaceFirst('SOH', 'SIH');
										    if (_jednostkiWew.isNotEmpty) {
										      _jednostkiWew[0]['model']!.text = nowyModelWew ?? '';
										    }

										    // Ustaw ilość czynnika
										    iloscCzynnika = ilosciCzynnikaNaModel[nowyModel] ?? '';
										    _iloscCzynnikaController.text = iloscCzynnika!;
										  });
										},
									),

          ),
          SizedBox(width: 8),
          Expanded(
            child: TextFormField(
              controller: _nrSeryjnyZewController,
              decoration: InputDecoration(labelText: "Numer seryjny (zew.)"),
            ),
          )
        ],
      ),

      SizedBox(height: 16),
      Text("Model jednostki wewnętrznej (może być wiele)", style: TextStyle(fontWeight: FontWeight.bold)),
      ..._jednostkiWew.asMap().entries.map((entry) {
        int index = entry.key;
        var para = entry.value;
        return Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: para['model'],
                  decoration: InputDecoration(labelText: "Model wew."),
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  controller: para['nr'],
                  decoration: InputDecoration(labelText: "Numer seryjny"),
                ),
              ),
              if (_jednostkiWew.length > 1)
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    setState(() {
                      _jednostkiWew.removeAt(index);
                    });
                  },
                )
            ],
          ),
        );
      }).toList(),

      SizedBox(height: 8),
      TextButton(
        onPressed: () {
          setState(() {
            _jednostkiWew.add({
              'model': TextEditingController(),
              'nr': TextEditingController(),
            });
          });
        },
        child: Text("+ Dodaj kolejną"),
      ),
    ],
  ),
),

Container(
  margin: EdgeInsets.only(bottom: 20),
  padding: EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12),
    boxShadow: [
      BoxShadow(
        color: Colors.grey.withOpacity(0.2),
        spreadRadius: 2,
        blurRadius: 6,
        offset: Offset(0, 3),
      ),
    ],
  ),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text("Kategoria", style: TextStyle(fontWeight: FontWeight.bold)),
      Wrap(
        spacing: 12,
        children: ['1', '2', '3'].map((kat) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Radio<String>(
                value: kat,
                groupValue: kategoria,
                onChanged: (val) => setState(() => kategoria = val!),
              ),
              Text(kat),
            ],
          );
        }).toList(),
      ),
      SizedBox(height: 12),
      Text("Podkategoria", style: TextStyle(fontWeight: FontWeight.bold)),
      Wrap(
        spacing: 12,
        children: ['A', 'C', 'I', 'P'].map((pod) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Radio<String>(
                value: pod,
                groupValue: podkategoria,
                onChanged: (val) => setState(() => podkategoria = val!),
              ),
              Text(pod),
            ],
          );
        }).toList(),
      ),
      SizedBox(height: 12),
      Text(
        "Kategoria:\n1 - urządzenia chłodnicze, 2 - klimatyzacyjne, 3 - pompa ciepła\n"
        "Podkategoria:\nA - domowe, C - handlowe, I - przemysłowe, P - inne",
        style: TextStyle(fontSize: 12, color: Colors.black54),
      ),
    ],
  ),
),
//--------
Container(
  margin: EdgeInsets.only(bottom: 20),
  padding: EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12),
    boxShadow: [
      BoxShadow(
        color: Colors.grey.withOpacity(0.2),
        spreadRadius: 2,
        blurRadius: 6,
        offset: Offset(0, 3),
      ),
    ],
  ),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      TextFormField(
        initialValue: "R32",
        decoration: InputDecoration(labelText: "Rodzaj czynnika"),
        onChanged: (val) => rodzajCzynnika = val,
      ),
      SizedBox(height: 12),
      TextFormField(
			  controller: _iloscCzynnikaController,
			  decoration: InputDecoration(labelText: "Ilość czynnika (kg)"),
			  keyboardType: TextInputType.numberWithOptions(decimal: true),
			  onChanged: (val) => iloscCzynnika = val,
			),
      SizedBox(height: 12),
      Row(
        children: [
          Expanded(
            child: TextFormField(
              decoration: InputDecoration(labelText: "Odzyskany (kg)"),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              onChanged: (val) => odzyskany = val,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: TextFormField(
              decoration: InputDecoration(labelText: "Dodany (kg)"),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              onChanged: (val) => dodany = val,
            ),
          ),
        ],
      ),
      SizedBox(height: 12),
      TextFormField(
        initialValue: "36",
        decoration: InputDecoration(labelText: "Okres gwarancji (miesiące)"),
        keyboardType: TextInputType.number,
        onChanged: (val) => okresGwarancji = val,
      ),
      SizedBox(height: 12),
      TextFormField(
        decoration: InputDecoration(labelText: "Pompka skroplin"),
        onChanged: (val) => pompkaSkroplin = val,
      ),
      SizedBox(height: 12),
      Row(
        children: [
          Expanded(
            child: TextFormField(
              decoration: InputDecoration(labelText: "Poziom próżni (micron)"),
              keyboardType: TextInputType.number,
              onChanged: (val) => poziomProzni = val,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: TextFormField(
              decoration: InputDecoration(labelText: "Długość instalacji (m)"),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              onChanged: (val) => dlugoscInstalacji = val,
            ),
          ),
        ],
      ),
      SizedBox(height: 16),
      Text("Rejestracja CRO", style: TextStyle(fontWeight: FontWeight.bold)),
      Wrap(
        spacing: 12,
        children: ["TAK", "NIE"].map((val) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Radio<String>(
                value: val,
                groupValue: croRejestracja,
                onChanged: (newVal) => setState(() => croRejestracja = newVal!),
              ),
              Text(val),
            ],
          );
        }).toList(),
      ),
      SizedBox(height: 16),
      TextFormField(
        decoration: InputDecoration(labelText: "Uwagi"),
        maxLines: 3,
        onChanged: (val) => uwagi = val,
      ),
    ],
  ),
),

//--------



                                  SizedBox(height: 20),
              Text('Podpis', style: TextStyle(fontWeight: FontWeight.bold)),
              Container(
                height: 200,
                decoration: BoxDecoration(border: Border.all()),
                child: Signature(
                  controller: _signatureController,
                  backgroundColor: Colors.white,
                ),
              ),
              Row(
							  children: [
							    Expanded(
							      child: ElevatedButton(
							        onPressed: () => _signatureController.clear(),
							        style: ElevatedButton.styleFrom(
							          backgroundColor: Colors.grey[700],
							          foregroundColor: Colors.white,
							          padding: EdgeInsets.symmetric(vertical: 20),
							          textStyle: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
							          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
							        ),
							        child: Text("❌ Wyczyść podpis"),
							      ),
							    ),
							    SizedBox(width: 12),
							    Expanded(
							      child: ElevatedButton(
							        onPressed: _zapiszProtokol,
							        style: ElevatedButton.styleFrom(
							          backgroundColor: Colors.green,
							          foregroundColor: Colors.white,
							          padding: EdgeInsets.symmetric(vertical: 20),
							          textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
							          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
							        ),
							        child: Text("💾 Zapisz protokół"),
							      ),
							    ),
							  ],
							),
            ],
          ),
        ),
      ),
    );
  }
}
