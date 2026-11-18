import 'package:flutter/material.dart';

import 'clima.dart';
import 'clima_service.dart';

class TechnicianWeatherCard extends StatefulWidget {
  const TechnicianWeatherCard({super.key, required this.zone});

  final String zone;

  @override
  State<TechnicianWeatherCard> createState() => _TechnicianWeatherCardState();
}

class _TechnicianWeatherCardState extends State<TechnicianWeatherCard> {
  late Future<Clima>? _weather;

  @override
  void initState() {
    super.initState();
    _weather = _load();
  }

  @override
  void didUpdateWidget(covariant TechnicianWeatherCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.zone != widget.zone) _weather = _load();
  }

  Future<Clima>? _load() {
    if (widget.zone.trim().length < 2) return null;
    return ClimaService().obtenerPorZona(widget.zone);
  }

  void _retry() => setState(() => _weather = _load());

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final weather = _weather;
    return Card(
      color: theme.colorScheme.surfaceContainerLow,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: weather == null
            ? const _WeatherMessage(
                icon: Icons.location_off_outlined,
                text: 'El técnico todavía no indicó su zona de trabajo.',
              )
            : FutureBuilder<Clima>(
                future: weather,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Row(
                      children: [
                        SizedBox.square(
                          dimension: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: 12),
                        Text('Consultando el clima de la zona…'),
                      ],
                    );
                  }
                  if (snapshot.hasError) {
                    final error = snapshot.error;
                    final message = error is ClimaServiceException
                        ? error.message
                        : 'No se pudo cargar el clima en este momento.';
                    return Row(
                      children: [
                        const Icon(Icons.cloud_off_outlined),
                        const SizedBox(width: 12),
                        Expanded(child: Text(message)),
                        IconButton(
                          tooltip: 'Volver a consultar',
                          onPressed: _retry,
                          icon: const Icon(Icons.refresh),
                        ),
                      ],
                    );
                  }
                  final climate = snapshot.data;
                  if (climate == null) {
                    return const _WeatherMessage(
                      icon: Icons.cloud_off_outlined,
                      text: 'No hay datos del clima para esta zona.',
                    );
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            climate.isDay
                                ? Icons.wb_sunny_outlined
                                : Icons.nights_stay_outlined,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Clima en ${climate.location}',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            tooltip: 'Actualizar clima',
                            onPressed: _retry,
                            icon: const Icon(Icons.refresh),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${climate.temperatureCelsius.round()} °C · ${climate.description}',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Sensación ${climate.apparentTemperatureCelsius.round()} °C · '
                        'Humedad ${climate.relativeHumidity}% · '
                        'Viento ${climate.windSpeedKmh.round()} km/h',
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Dato actual de Open-Meteo · ${_formatTime(climate.time)}',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  );
                },
              ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final local = time.toLocal();
    return '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
  }
}

class _WeatherMessage extends StatelessWidget {
  const _WeatherMessage({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(icon),
      const SizedBox(width: 12),
      Expanded(child: Text(text)),
    ],
  );
}
