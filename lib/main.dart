import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chequea el Clima!',
      debugShowCheckedModeBanner: false,
      home: const ClimaPage(),
    );
  }
}

class ClimaPage extends StatefulWidget {
  const ClimaPage({super.key});
  @override
  State<ClimaPage> createState() => _ClimaPageState();
}

class _ClimaPageState extends State<ClimaPage> {
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  String _weatherInfo = '';
  bool _error = false;
  bool _cargando = false;
  final String _apiKey = "9731666879b40e9aa00306e01cb1cd92";

  Future<void> _obtenerClima() async {
    final city = _cityController.text.trim();
    final country = _countryController.text.trim();
    if (city.isEmpty) {
      setState(() {
        _weatherInfo = 'Por favor, ingresa el nombre de una ciudad!';
        _error = true;
      });
      return;
    }
    setState(() => _cargando = true);
    String apiUrl = 'https://api.openweathermap.org/data/2.5/weather?q=$city';
    if (country.isNotEmpty) apiUrl += ',$country';
    apiUrl += '&appid=$_apiKey&units=metric&lang=es';
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _mostrarClima(data);
      } else {
        setState(() {
          _weatherInfo = 'Error ${response.statusCode}: Ciudad no encontrada.';
          _error = true;
        });
      }
    } catch (e) {
      setState(() {
        _weatherInfo = 'Error de conexión';
        _error = true;
      });
    } finally {
      setState(() => _cargando = false);
    }
  }

  void _mostrarClima(Map<String, dynamic> data) {
    final cityName = data['name'];
    final temp = data['main']['temp'];
    final description = data['weather'][0]['description'];
    final humidity = data['main']['humidity'];
    final windSpeed = data['wind']['speed'];
    setState(() {
      _weatherInfo = 'Clima en $cityName\nTemperatura: ${temp}°C\nDescripción: $description\nHumedad: $humidity%\nVelocidad: ${windSpeed} m/s';
      _error = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFDBEEFF), Color(0xFFB3D9FF)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.9,
              constraints: const BoxConstraints(maxWidth: 500),
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 25,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.network('https://cdn-icons-png.flaticon.com/512/869/869869.png', width: 100),
                  const SizedBox(height: 15),
                  const Text('¿Cómo anda el Clima?', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF333333))),
                  const SizedBox(height: 16),
                  TextField(controller: _cityController, decoration: InputDecoration(hintText: 'Nombre de la Ciudad (Ej. México)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)))),
                  const SizedBox(height: 8),
                  TextField(controller: _countryController, decoration: InputDecoration(hintText: 'Código del país (Ej. MX) - Opcional', border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)))),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _cargando? null : _obtenerClima,
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4DA6FF), padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                    child: _cargando? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('Obtener Clima', style: TextStyle(color: Colors.white)),
                  ),
                  const SizedBox(height: 24),
                  if (_weatherInfo.isNotEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.only(top: 24),
                      decoration: const BoxDecoration(border: Border(top: BorderSide(color: Color(0xFFEEEEEE)))),
                      child: Text(_weatherInfo, style: TextStyle(color: _error? Colors.red : const Color(0xFF666666), fontSize: 16, height: 1.5)),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}