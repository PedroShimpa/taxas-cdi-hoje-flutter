import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Taxas Econômicas',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: const TextTheme(
          titleLarge: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          bodyMedium: TextStyle(
            fontSize: 16.0,
            color: Colors.black54,
          ),
        ),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Taxas Econômicas'),
      ),
      body: ListView(
        children: <Widget>[
          ListTile(
            title: const Text('Taxa SELIC'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => TaxaPage(taxaNome: 'Selic')),
              );
            },
          ),
          ListTile(
            title: const Text('Taxa CDI'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => TaxaPage(taxaNome: 'CDI')),
              );
            },
          ),
          ListTile(
            title: const Text('Taxa IPCA'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => TaxaPage(taxaNome: 'IPCA')),
              );
            },
          ),
        ],
      ),
    );
  }
}

class TaxaPage extends StatefulWidget {
  final String taxaNome;

  const TaxaPage({Key? key, required this.taxaNome}) : super(key: key);

  @override
  _TaxaPageState createState() => _TaxaPageState();
}

class _TaxaPageState extends State<TaxaPage> {
  late Future<double> _taxa;

  @override
  void initState() {
    super.initState();
    _taxa = fetchTaxa(widget.taxaNome);
  }

  Future<double> fetchTaxa(String nome) async {
    final response =
        await http.get(Uri.parse('https://brasilapi.com.br/api/taxas/v1'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List;
      final taxaData = data.firstWhere((taxa) => taxa['nome'] == nome,
          orElse: () => {'valor': 0});
      return taxaData['valor'];
    } else {
      throw Exception('Failed to load taxa');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Taxa ${widget.taxaNome} Hoje'),
      ),
      body: Center(
        child: FutureBuilder<double>(
          future: _taxa,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Erro: ${snapshot.error}');
            } else if (snapshot.hasData) {
              return Text(
                'TAXA ${widget.taxaNome} HOJE\n${snapshot.data!.toStringAsFixed(2)}%',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge,
              );
            } else {
              return const Text('Nenhuma informação disponível.');
            }
          },
        ),
      ),
    );
  }
}
