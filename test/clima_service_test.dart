import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:arreglaya/clima_service.dart';

void main() {
  test('convierte JSON y solicita temperatura y código del clima', () async {
    final service = ClimaService(client: MockClient((request) async {
      expect(request.method, 'GET');
      expect(request.url.queryParameters['latitude'], '-17.78');
      expect(request.url.queryParameters['current'], 'temperature_2m,weather_code');
      return http.Response('{"current":{"temperature_2m":29.5,"weather_code":3}}', 200);
    }));
    final clima = await service.obtener(-17.78, -63.18);
    expect(clima.temperatura, 29.5);
    expect(clima.descripcion, 'Parcialmente nublado');
    service.dispose();
  });
  test('maneja respuesta inválida', () async {
    final service = ClimaService(client: MockClient((_) async => http.Response('{}', 200)));
    await expectLater(service.obtener(0, 0), throwsA(isA<ClimaException>()));
    service.dispose();
  });
  test('maneja error de conexión', () async {
    final service = ClimaService(client: MockClient((_) async => throw http.ClientException('sin red')));
    await expectLater(service.obtener(0, 0), throwsA(isA<ClimaException>()));
    service.dispose();
  });
  test('maneja el tiempo límite', () async {
    final service = ClimaService(client: MockClient((_) async => throw TimeoutException('tiempo agotado')));
    await expectLater(service.obtener(0, 0), throwsA(isA<ClimaException>()));
    service.dispose();
  });
}
