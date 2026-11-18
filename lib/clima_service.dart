import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class Clima {
  const Clima({required this.temperatura, required this.codigo});
  final double temperatura;
  final int codigo;

  factory Clima.fromJson(Map<String, dynamic> json) {
    final current = json['current'];
    if (current is! Map<String, dynamic> ||
        current['temperature_2m'] is! num || current['weather_code'] is! int) {
      throw const FormatException('La respuesta del clima está incompleta');
    }
    return Clima(temperatura: (current['temperature_2m'] as num).toDouble(),
        codigo: current['weather_code'] as int);
  }

  String get descripcion {
    if (codigo == 0) return 'Despejado';
    if (codigo <= 3) return 'Parcialmente nublado';
    if (codigo <= 48) return 'Niebla';
    if (codigo <= 67 || (codigo >= 80 && codigo <= 82)) return 'Lluvia';
    if (codigo >= 95) return 'Tormenta';
    return 'Condiciones variables';
  }
}

class ClimaService {
  ClimaService({http.Client? client}) : _client = client ?? http.Client();
  final http.Client _client;

  Future<Clima> obtener(double latitud, double longitud) async {
    final uri = Uri.https('api.open-meteo.com', '/v1/forecast', {
      'latitude': '$latitud', 'longitude': '$longitud',
      'current': 'temperature_2m,weather_code', 'timezone': 'auto',
    });
    try {
      final respuesta = await _client.get(uri).timeout(const Duration(seconds: 10));
      if (respuesta.statusCode != 200) throw const ClimaException('El servicio del clima no respondió correctamente.');
      final json = jsonDecode(respuesta.body);
      if (json is! Map<String, dynamic>) throw const FormatException();
      return Clima.fromJson(json);
    } on TimeoutException {
      throw const ClimaException('La consulta tardó demasiado. Revisa tu conexión e inténtalo de nuevo.');
    } on FormatException {
      throw const ClimaException('Los datos del clima no están disponibles. Inténtalo de nuevo.');
    } on http.ClientException {
      throw const ClimaException('No se pudo conectar. Revisa tu internet e inténtalo de nuevo.');
    }
  }
  void dispose() => _client.close();
}

class ClimaException implements Exception {
  const ClimaException(this.mensaje);
  final String mensaje;
}
