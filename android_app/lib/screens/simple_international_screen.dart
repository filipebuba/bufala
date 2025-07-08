import 'package:flutter/material.dart';
import '../models/international_learning_models.dart';
import '../services/international_learning_service.dart';

/// Tela Simples do Sistema Internacional "Bu Fala Professor para ONGs"
class SimpleInternationalScreen extends StatefulWidget {
  const SimpleInternationalScreen({super.key});

  @override
  State<SimpleInternationalScreen> createState() =>
      _SimpleInternationalScreenState();
}

class _SimpleInternationalScreenState extends State<SimpleInternationalScreen> {
  final InternationalLearningService _service = InternationalLearningService();
  bool _isLoading = false;
  List<InternationalOrganization> _organizations = [];
  String? _status;

  @override
  void initState() {
    super.initState();
    _loadOrganizations();
  }

  Future<void> _loadOrganizations() async {
    setState(() {
      _isLoading = true;
      _status = 'Carregando organizações...';
    });

    try {
      final response = await _service.getOrganizations();
      if (response.success && response.data != null) {
        setState(() {
          _organizations = response.data!;
          _status = 'Carregado ${_organizations.length} organizações';
          _isLoading = false;
        });
      } else {
        setState(() {
          _status = 'Erro ao carregar organizações: ${response.error}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _status = 'Erro: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('🌍 Bu Fala Internacional'),
          backgroundColor: Colors.blue[800],
          foregroundColor: Colors.white,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Card(
                color: Colors.blue[50],
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '🌍 Sistema Internacional para ONGs',
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue[800],
                                ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Bu Fala como professor multilíngue para profissionais internacionais',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Status
              if (_status != null)
                Card(
                  color: _isLoading ? Colors.orange[50] : Colors.green[50],
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        if (_isLoading)
                          const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        else
                          Icon(Icons.check_circle, color: Colors.green[600]),
                        const SizedBox(width: 12),
                        Expanded(child: Text(_status!)),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 20),

              // Lista de Organizações
              if (_organizations.isNotEmpty) ...[
                Text(
                  'Organizações Disponíveis:',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                ..._organizations
                    .map((InternationalOrganization org) => Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: _getOrgColor(org.type),
                              child: Text(
                                _getOrgIcon(org.type),
                                style: const TextStyle(fontSize: 20),
                              ),
                            ),
                            title: Text(
                              org.name,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Tipo: ${_getOrgTypeName(org.type)}'),
                                Text(
                                    'Idiomas: ${org.languagesNeeded.join(", ")}'),
                                Text('Urgência: ${org.urgencyLevel}'),
                              ],
                            ),
                            trailing: ElevatedButton(
                              onPressed: () => _selectOrganization(org),
                              child: const Text('Entrar'),
                            ),
                          ),
                        ))
                    ,
              ],

              // Botão para recarregar
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _loadOrganizations,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Recarregar'),
                ),
              ),
            ],
          ),
        ),
      );

  Color _getOrgColor(String type) {
    switch (type) {
      case 'medical_humanitarian':
        return Colors.red[100]!;
      case 'education_humanitarian':
        return Colors.blue[100]!;
      case 'development_economic':
        return Colors.green[100]!;
      default:
        return Colors.grey[100]!;
    }
  }

  String _getOrgIcon(String type) {
    switch (type) {
      case 'medical_humanitarian':
        return '🏥';
      case 'education_humanitarian':
        return '🎓';
      case 'development_economic':
        return '🏗️';
      default:
        return '🌍';
    }
  }

  String _getOrgTypeName(String type) {
    switch (type) {
      case 'medical_humanitarian':
        return 'Médico Humanitário';
      case 'education_humanitarian':
        return 'Educação Humanitária';
      case 'development_economic':
        return 'Desenvolvimento Econômico';
      default:
        return type;
    }
  }

  void _selectOrganization(InternationalOrganization org) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('🌍 ${org.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Você selecionou: ${org.name}'),
            const SizedBox(height: 8),
            Text('Tipo: ${_getOrgTypeName(org.type)}'),
            Text('Idiomas necessários: ${org.languagesNeeded.join(", ")}'),
            Text('Módulos prioritários: ${org.priorityModules.join(", ")}'),
            Text('Nível de urgência: ${org.urgencyLevel}'),
            Text('Ritmo de aprendizado: ${org.learningPace}'),
            const SizedBox(height: 12),
            const Text(
              'Em breve: registro de profissionais e acesso aos módulos especializados.',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showComingSoon();
            },
            child: const Text('Registrar'),
          ),
        ],
      ),
    );
  }

  void _showComingSoon() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🚀 Registro de profissionais em desenvolvimento!'),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
