import 'package:flutter/material.dart';
import '../services/environmental_api_service.dart';

class EnvironmentalAlertsScreen extends StatefulWidget {
  const EnvironmentalAlertsScreen({required this.api, super.key});
  final EnvironmentalApiService api;

  @override
  State<EnvironmentalAlertsScreen> createState() =>
      _EnvironmentalAlertsScreenState();
}

class _EnvironmentalAlertsScreenState extends State<EnvironmentalAlertsScreen> {
  List<Map<String, dynamic>> _alerts = [];
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchAlerts();
  }

  Future<void> _fetchAlerts() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final alerts = await widget.api.getEnvironmentalAlerts();
      setState(() {
        _alerts = List<Map<String, dynamic>>.from(
          alerts.map((a) => Map<String, dynamic>.from(a as Map)),
        );
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(title: const Text('Alertas Ambientais')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : ListView.builder(
                  itemCount: _alerts.length,
                  itemBuilder: (context, idx) {
                    final a = _alerts[idx];
                    return ListTile(
                      leading: Icon(Icons.warning,
                          color: _getColor(a['level']?.toString())),
                      title: Text(a['type']?.toString() ?? ''),
                      subtitle: Text(
                          '${a['region']?.toString() ?? ''} - ${a['message']?.toString() ?? ''}'),
                    );
                  },
                ),
    );

  Color _getColor(String? level) {
    switch (level) {
      case 'alto':
        return Colors.red;
      case 'médio':
        return Colors.orange;
      case 'baixo':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
