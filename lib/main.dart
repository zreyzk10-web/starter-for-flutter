import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const NbaApp());
}

class NbaApp extends StatelessWidget {
  const NbaApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NBA Predictor AI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepOrange,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121212),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // ⚠️ REEMPLAZA ESTA URL CON LA DE TU BACKEND EN RENDER (ej. https://tu-app.onrender.com)
  final String backendUrl = 'https://tu-backend.onrender.com/predict';

  List<dynamic> games = [];
  bool isLoading = false;
  String errorMessage = '';

  Future<void> fetchPredictions() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final response = await http.get(Uri.parse(backendUrl));
      if (response.statusCode == 200) {
        setState(() {
          games = json.decode(response.body);
        });
      } else {
        setState(() {
          errorMessage = 'Error al conectar con el servidor (${response.statusCode})';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error de conexión: Verifica tu URL o internet.';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🏀 Predicciones NBA (Gemini)'),
        centerTitle: true,
        backgroundColor: Colors.deepOrangeAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              onPressed: fetchPredictions,
              icon: const Icon(Icons.sports_basketball),
              label: const Text('Cargar Partidos y Pronósticos', style: TextStyle(fontSize: 16)),
            ),
            const SizedBox(height: 20),
            if (errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(8.0),
                Text(errorMessage, style: const TextStyle(color: Colors.redAccent)),
              ),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator(color: Colors.deepOrange))
                  : games.isEmpty
                      ? const Center(
                          child: Text(
                            'Presiona el botón superior para consultar los partidos de hoy.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey, fontSize: 16),
                          ),
                        )
                      : ListView.builder(
                          itemCount: games.length,
                          itemBuilder: (context, index) {
                            final game = games[index];
                            return Card(
                              color: const Color(0xFF1E1E1E),
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${game['home_team']} vs ${game['visitor_team']}',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const Divider(color: Colors.grey),
                                    const SizedBox(height: 6),
                                    Text(
                                      '🤖 Análisis de IA: ${game['prediction'] ?? 'Sin pronóstico disponible'}',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.orangeAccent,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
