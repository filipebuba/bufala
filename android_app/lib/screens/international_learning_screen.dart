import 'package:flutter/material.dart';
import '../models/international_learning_models.dart';
import '../services/international_learning_service.dart';
import '../widgets/loading_overlay.dart';

/// Tela principal do Sistema Internacional "Bu Fala Professor para ONGs"
class InternationalLearningScreen extends StatefulWidget {
  const InternationalLearningScreen({super.key});

  @override
  State<InternationalLearningScreen> createState() => _InternationalLearningScreenState();
}

class _InternationalLearningScreenState extends State<InternationalLearningScreen> {
  final InternationalLearningService _service = InternationalLearningService();
  bool _isLoading = false;
  List<InternationalOrganization> _organizations = [];
  InternationalOrganization? _selectedOrg;
  final int _currentStep = 0;

  // Controladores do formulário
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  String _selectedProfession = 'doctor';
  String _selectedNativeLanguage = 'pt';
  final List<String> _selectedSpokenLanguages = ['pt'];
  String _selectedLocation = 'bissau';
  List<String> _selectedTargetLanguages = ['pt-GW'];

  @override
  void initState() {
    super.initState();
    _loadOrganizations();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _loadOrganizations() async {
    setState(() => _isLoading = true);
    
    try {
      final response = await _service.getOrganizations();
      if (response.success && response.data != null) {
        setState(() {
          _organizations = response.data!;
          if (_organizations.isNotEmpty) {
            _selectedOrg = _organizations.first;
          }
        });
      } else {
        _showErrorSnackBar('Erro ao carregar organizações: ${response.error}');
      }
    } catch (e) {
      _showErrorSnackBar('Erro de conexão: $e');
    }
    
    setState(() => _isLoading = false);
  }

  Future<void> _registerProfessional() async {
    if (!_validateForm()) return;

    setState(() => _isLoading = true);

    try {
      final response = await _service.registerProfessional(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        profession: _selectedProfession,
        nativeLanguage: _selectedNativeLanguage,
        spokenLanguages: _selectedSpokenLanguages,
        organizationId: _selectedOrg!.id,
        assignmentLocation: _selectedLocation,
        arrivalDate: DateTime.now(),
        targetLanguages: _selectedTargetLanguages,
      );

      if (response.success && response.data != null) {
        _showSuccessDialog(response.data!);
      } else {
        _showErrorSnackBar('Erro ao registrar: ${response.error}');
      }
    } catch (e) {
      _showErrorSnackBar('Erro de conexão: $e');
    }

    setState(() => _isLoading = false);
  }

  bool _validateForm() {
    if (_nameController.text.trim().isEmpty) {
      _showErrorSnackBar('Nome é obrigatório');
      return false;
    }
    if (_emailController.text.trim().isEmpty) {
      _showErrorSnackBar('Email é obrigatório');
      return false;
    }
    if (_selectedOrg == null) {
      _showErrorSnackBar('Selecione uma organização');
      return false;
    }
    return true;
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccessDialog(InternationalProfessional professional) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('Registrado com Sucesso!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Bem-vindo, ${professional.name}!'),
            const SizedBox(height: 8),
            Text('Organização: ${professional.organizationName}'),
            Text('Profissão: ${professional.profession}'),
            Text('Localização: ${professional.assignmentLocation}'),
            const SizedBox(height: 16),
            const Text(
              '🎓 Seu plano de estudos personalizado está sendo preparado...',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _navigateToLearningDashboard(professional);
            },
            child: const Text('Começar Aprendizado'),
          ),
        ],
      ),
    );
  }

  void _navigateToLearningDashboard(InternationalProfessional professional) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InternationalDashboardScreen(professional: professional),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.language, color: Colors.white),
            SizedBox(width: 8),
            Flexible(
              child: Text(
                '🌍 Bu Fala Professor Internacional',
                style: TextStyle(fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF2E7D32),
      ),
      body: LoadingOverlay(
        isLoading: _isLoading,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcomeHeader(),
              const SizedBox(height: 24),
              _buildOrganizationInfo(),
              const SizedBox(height: 24),
              _buildRegistrationForm(),
            ],
          ),
        ),
      ),
    );

  Widget _buildWelcomeHeader() => Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🌍 Bu Fala Professor Internacional',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Sistema especializado de ensino de idiomas locais para profissionais de organizações internacionais',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.medical_services, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text('Médicos Sem Fronteiras', style: TextStyle(color: Colors.white, fontSize: 14)),
            ],
          ),
          SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.school, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text('UNICEF • Banco Mundial', style: TextStyle(color: Colors.white, fontSize: 14)),
            ],
          ),
          SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.emergency, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text('Módulos de Emergência', style: TextStyle(color: Colors.white, fontSize: 14)),
            ],
          ),
        ],
      ),
    );

  Widget _buildOrganizationInfo() {
    if (_organizations.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Carregando organizações...'),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '🏢 Organizações Parceiras',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...(_organizations.map(_buildOrganizationCard)),
          ],
        ),
      ),
    );
  }

  Widget _buildOrganizationCard(InternationalOrganization org) {
    final isSelected = _selectedOrg?.id == org.id;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: isSelected ? const Color(0xFFE8F5E8) : null,
      child: ListTile(
        leading: Text(org.logoUrl, style: const TextStyle(fontSize: 24)),
        title: Text(
          org.name,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tipo: ${_getTypeDisplayName(org.type)}'),
            Text('Idiomas: ${org.languagesNeeded.join(', ')}'),
            Text('Urgência: ${_getUrgencyDisplayName(org.urgencyLevel)}'),
          ],
        ),
        trailing: isSelected
            ? const Icon(Icons.check_circle, color: Color(0xFF4CAF50))
            : null,
        onTap: () {
          setState(() {
            _selectedOrg = org;
            // Atualizar idiomas alvo baseado na organização
            _selectedTargetLanguages = List.from(org.languagesNeeded);
          });
        },
      ),
    );
  }

  Widget _buildRegistrationForm() => Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '📝 Registro de Profissional',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildFormFields(),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _selectedOrg != null ? _registerProfessional : null,
                icon: const Icon(Icons.person_add),
                label: const Text('Registrar e Começar Aprendizado'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(16),
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );

  Widget _buildFormFields() => Column(
      children: [
        // Nome
        TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Nome Completo',
            prefixIcon: Icon(Icons.person),
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        
        // Email
        TextFormField(
          controller: _emailController,
          decoration: const InputDecoration(
            labelText: 'Email',
            prefixIcon: Icon(Icons.email),
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        
        // Profissão
        DropdownButtonFormField<String>(
          initialValue: _selectedProfession,
          decoration: const InputDecoration(
            labelText: 'Profissão',
            prefixIcon: Icon(Icons.work),
            border: OutlineInputBorder(),
          ),
          items: const [
            DropdownMenuItem(value: 'doctor', child: Text('👨‍⚕️ Médico')),
            DropdownMenuItem(value: 'nurse', child: Text('👩‍⚕️ Enfermeiro')),
            DropdownMenuItem(value: 'teacher', child: Text('👨‍🏫 Professor')),
            DropdownMenuItem(value: 'engineer', child: Text('👨‍🔧 Engenheiro')),
            DropdownMenuItem(value: 'agronomist', child: Text('👨‍🌾 Agrônomo')),
            DropdownMenuItem(value: 'social_worker', child: Text('👥 Assistente Social')),
            DropdownMenuItem(value: 'diplomat', child: Text('🤝 Diplomata')),
          ],
          onChanged: (value) {
            setState(() => _selectedProfession = value!);
          },
        ),
        const SizedBox(height: 16),
        
        // Idioma nativo
        DropdownButtonFormField<String>(
          initialValue: _selectedNativeLanguage,
          decoration: const InputDecoration(
            labelText: 'Idioma Nativo',
            prefixIcon: Icon(Icons.language),
            border: OutlineInputBorder(),
          ),
          items: const [
            DropdownMenuItem(value: 'pt', child: Text('🇵🇹 Português')),
            DropdownMenuItem(value: 'en', child: Text('🇺🇸 English')),
            DropdownMenuItem(value: 'fr', child: Text('🇫🇷 Français')),
            DropdownMenuItem(value: 'es', child: Text('🇪🇸 Español')),
            DropdownMenuItem(value: 'de', child: Text('🇩🇪 Deutsch')),
            DropdownMenuItem(value: 'ar', child: Text('🇸🇦 العربية')),
          ],
          onChanged: (value) {
            setState(() => _selectedNativeLanguage = value!);
          },
        ),
        const SizedBox(height: 16),
        
        // Localização
        DropdownButtonFormField<String>(
          initialValue: _selectedLocation,
          decoration: const InputDecoration(
            labelText: 'Localização de Trabalho',
            prefixIcon: Icon(Icons.location_on),
            border: OutlineInputBorder(),
          ),
          items: const [
            DropdownMenuItem(value: 'bissau', child: Text('🏙️ Bissau (Capital)')),
            DropdownMenuItem(value: 'gabu', child: Text('🌾 Gabú (Interior)')),
            DropdownMenuItem(value: 'bafata', child: Text('🏘️ Bafatá')),
            DropdownMenuItem(value: 'cacheu', child: Text('🌊 Cacheu (Litoral)')),
            DropdownMenuItem(value: 'bolama', child: Text('🏝️ Bolama (Ilhas)')),
          ],
          onChanged: (value) {
            setState(() => _selectedLocation = value!);
          },
        ),
        
        if (_selectedOrg != null) ...[
          const SizedBox(height: 16),
          _buildTargetLanguagesSection(),
        ],
      ],
    );

  Widget _buildTargetLanguagesSection() => Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E8),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF4CAF50)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🎯 Idiomas para Aprender (${_selectedOrg!.name})',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ...(_selectedOrg!.languagesNeeded.map((lang) => CheckboxListTile(
            title: Text(_getLanguageDisplayName(lang)),
            value: _selectedTargetLanguages.contains(lang),
            onChanged: (checked) {
              setState(() {
                if (checked == true) {
                  _selectedTargetLanguages.add(lang);
                } else {
                  _selectedTargetLanguages.remove(lang);
                }
              });
            },
            activeColor: const Color(0xFF4CAF50),
          ))),
        ],
      ),
    );

  String _getTypeDisplayName(String type) {
    switch (type) {
      case 'medical_humanitarian':
        return 'Humanitária Médica';
      case 'education_humanitarian':
        return 'Educação Humanitária';
      case 'development_economic':
        return 'Desenvolvimento Econômico';
      default:
        return type;
    }
  }

  String _getUrgencyDisplayName(String urgency) {
    switch (urgency) {
      case 'high':
        return '🔴 Alta';
      case 'medium':
        return '🟡 Média';
      case 'low':
        return '🟢 Baixa';
      default:
        return urgency;
    }
  }

  String _getLanguageDisplayName(String lang) {
    switch (lang) {
      case 'pt-GW':
        return '🇬🇼 Crioulo da Guiné-Bissau';
      case 'ff':
        return '🗣️ Fula';
      case 'mnk':
        return '🗣️ Mandinka';
      case 'bsc':
        return '🗣️ Balanta';
      default:
        return lang;
    }
  }
}

/// Tela de Dashboard para profissionais internacionais
class InternationalDashboardScreen extends StatefulWidget {

  const InternationalDashboardScreen({
    required this.professional, super.key,
  });
  final InternationalProfessional professional;

  @override
  State<InternationalDashboardScreen> createState() => _InternationalDashboardScreenState();
}

class _InternationalDashboardScreenState extends State<InternationalDashboardScreen> {
  final InternationalLearningService _service = InternationalLearningService();
  bool _isLoading = false;
  List<SpecializedModule> _availableModules = [];
  final List<SpecializedModule> _emergencyModules = [];

  @override
  void initState() {
    super.initState();
    _loadModules();
  }

  Future<void> _loadModules() async {
    setState(() => _isLoading = true);

    try {
      // Carregar módulos regulares
      final response = await _service.getModules(
        profession: widget.professional.profession,
        targetLanguage: widget.professional.targetLanguages.isNotEmpty 
            ? widget.professional.targetLanguages.first 
            : 'pt-GW',
      );

      if (response.success && response.data != null) {
        setState(() {
          _availableModules = response.data!;
        });
      }

      // Carregar módulos de emergência
      await _loadEmergencyModules();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar módulos: $e')),
      );
    }

    setState(() => _isLoading = false);
  }

  Future<void> _loadEmergencyModules() async {
    for (final targetLang in widget.professional.targetLanguages) {
      final emergencyResponse = await _service.generateEmergencyModule(
        professionalId: widget.professional.id,
        profession: widget.professional.profession,
        targetLanguage: targetLang,
        emergencyType: 'medical',
        hoursUntilDeployment: 2,
      );

      if (emergencyResponse.success && emergencyResponse.data != null) {
        setState(() {
          _emergencyModules.add(emergencyResponse.data!);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        title: Text('${widget.professional.name} - Dashboard'),
        backgroundColor: const Color(0xFF2E7D32),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildWelcomeCard(),
                  const SizedBox(height: 16),
                  _buildEmergencySection(),
                  const SizedBox(height: 16),
                  _buildRegularModulesSection(),
                ],
              ),
            ),
    );

  Widget _buildWelcomeCard() => Card(
      color: const Color(0xFFE8F5E8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: const Color(0xFF4CAF50),
                  child: Text(
                    widget.professional.name.substring(0, 1).toUpperCase(),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bem-vindo, ${widget.professional.name}!',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(widget.professional.organizationName),
                      Text('📍 ${widget.professional.assignmentLocation}'),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              '🎯 Seu plano de estudos personalizado está pronto!',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Idiomas alvo: ${widget.professional.targetLanguages.join(', ')}'),
          ],
        ),
      ),
    );

  Widget _buildEmergencySection() => Card(
      color: const Color(0xFFFFEBEE),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.emergency, color: Colors.red),
                SizedBox(width: 8),
                Text(
                  '🚨 Módulos de Emergência',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text('Aprenda o essencial em 2 horas ou menos'),
            const SizedBox(height: 12),
            if (_emergencyModules.isEmpty)
              const Center(child: CircularProgressIndicator())
            else
              ...(_emergencyModules.map((module) => _buildModuleCard(module, isEmergency: true))),
          ],
        ),
      ),
    );

  Widget _buildRegularModulesSection() => Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '📚 Módulos Especializados',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('Aprendizado progressivo para sua profissão'),
            const SizedBox(height: 12),
            if (_availableModules.isEmpty)
              const Text('Nenhum módulo disponível')
            else
              ...(_availableModules.map(_buildModuleCard)),
          ],
        ),
      ),
    );

  Widget _buildModuleCard(SpecializedModule module, {bool isEmergency = false}) => Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isEmergency ? Colors.red : const Color(0xFF4CAF50),
          child: Text(
            module.iconUrl.isNotEmpty ? module.iconUrl : '📚',
            style: const TextStyle(fontSize: 20),
          ),
        ),
        title: Text(
          module.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(module.description),
            Text('⏱️ ${module.estimatedDuration.inMinutes} min'),
            Text('🎯 ${module.difficultyLevel}'),
          ],
        ),
        trailing: ElevatedButton(
          onPressed: () => _startModule(module),
          style: ElevatedButton.styleFrom(
            backgroundColor: isEmergency ? Colors.red : const Color(0xFF4CAF50),
            foregroundColor: Colors.white,
          ),
          child: Text(isEmergency ? 'COMEÇAR' : 'Estudar'),
        ),
      ),
    );

  void _startModule(SpecializedModule module) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ModuleLearningScreen(
          professional: widget.professional,
          module: module,
        ),
      ),
    );
  }
}

/// Tela de aprendizado de módulo
class ModuleLearningScreen extends StatelessWidget {

  const ModuleLearningScreen({
    required this.professional, required this.module, super.key,
  });
  final InternationalProfessional professional;
  final SpecializedModule module;

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        title: Text(module.name),
        backgroundColor: const Color(0xFF2E7D32),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              module.description,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            const Text(
              'Lições:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: module.lessons.length,
                itemBuilder: (context, index) {
                  final lesson = module.lessons[index];
                  return Card(
                    child: ListTile(
                      title: Text(lesson.title),
                      subtitle: Text(lesson.description),
                      trailing: const Icon(Icons.play_arrow),
                      onTap: () {
                        // Implementar navegação para lição específica
                      },
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
