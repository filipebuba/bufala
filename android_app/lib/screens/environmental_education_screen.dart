import 'package:flutter/material.dart';
import '../services/environmental_api_service.dart';

class EnvironmentalEducationScreen extends StatefulWidget {
  const EnvironmentalEducationScreen({required this.api, super.key});
  final EnvironmentalApiService api;

  @override
  State<EnvironmentalEducationScreen> createState() =>
      _EnvironmentalEducationScreenState();
}

class _EnvironmentalEducationScreenState
    extends State<EnvironmentalEducationScreen> {
  List<Map<String, dynamic>> _modules = [];
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchModules();
  }

  Future<void> _fetchModules() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final modules = await widget.api.getEducationModules();
      setState(() {
        _modules = List<Map<String, dynamic>>.from(
          modules.map((m) => Map<String, dynamic>.from(m as Map)),
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
      appBar: AppBar(title: const Text('Educação Ambiental')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : ListView.builder(
                  itemCount: _modules.length,
                  itemBuilder: (context, idx) {
                    final m = _modules[idx];
                    return ListTile(
                      title: Text(m['title']?.toString() ?? ''),
                      subtitle: Text(m['description']?.toString() ?? ''),
                    );
                  },
                ),
    );
}
