import 'package:flutter/material.dart';
import 'clima_service.dart';

class ClimaCard extends StatefulWidget {
  const ClimaCard({super.key, required this.latitud, required this.longitud, required this.lugar});
  final double latitud, longitud;
  final String lugar;
  @override
  State<ClimaCard> createState() => _ClimaCardState();
}
class _ClimaCardState extends State<ClimaCard> {
  final _service = ClimaService();
  late Future<Clima> _clima;
  @override
  void initState() { super.initState(); _cargar(); }
  void _cargar() { _clima = _service.obtener(widget.latitud, widget.longitud); }
  @override
  void didUpdateWidget(covariant ClimaCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.latitud != widget.latitud || oldWidget.longitud != widget.longitud) _cargar();
  }
  @override
  void dispose() { _service.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => Card(child: Padding(
    padding: const EdgeInsets.all(16),
    child: FutureBuilder<Clima>(future: _clima, builder: (context, snapshot) {
      if (snapshot.connectionState != ConnectionState.done) {
        return const ListTile(leading: CircularProgressIndicator(), title: Text('Consultando el clima...'));
      }
      if (snapshot.hasError) {
        final error = snapshot.error;
        final mensaje = error is ClimaException ? error.mensaje : 'No se pudo consultar el clima. Revisa tu conexión.';
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(mensaje), TextButton.icon(onPressed: () => setState(_cargar),
              icon: const Icon(Icons.refresh), label: const Text('Reintentar')),
        ]);
      }
      final clima = snapshot.data!;
      return ListTile(contentPadding: EdgeInsets.zero, leading: const Icon(Icons.wb_cloudy_outlined),
        title: Text('Clima: ${widget.lugar}'),
        subtitle: Text('${clima.temperatura.toStringAsFixed(1)} °C · ${clima.descripcion}\nFuente: Open-Meteo'));
    }),
  ));
}
