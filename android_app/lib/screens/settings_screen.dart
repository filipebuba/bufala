import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../providers/app_provider.dart';
import '../services/language_service.dart';
import '../services/storage_service.dart';
import '../services/api_service.dart';
import '../config/app_config.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final LanguageService _languageService = LanguageService();
  final OfflineService _offlineService = OfflineService();
  final StorageService _storageService = StorageService();
  final ApiService _apiService = ApiService();
  
  Map<String, int> _storageStats = {};
  Map<String, dynamic> _storageInfo = {};
  Map<String, dynamic> _backendConfig = {};
  Map<String, dynamic> _revolutionaryConfig = {};
  bool _isLoading = false;
  bool _isConnected = false;

  @override
  void initState() {
    super.initState();
    _loadStorageStats();
    _loadStorageInfo();
    _loadBackendConfig();
    _checkConnection();
  }

  Future<void> _loadStorageStats() async {
    try {
      final stats = await _offlineService.getStorageStats();
      setState(() {
        _storageStats = stats;
      });
    } catch (e) {
      print('Erro ao carregar estatísticas de armazenamento: $e');
    }
  }

  Future<void> _loadStorageInfo() async {
    try {
      final info = await _storageService.getStorageInfo();
      setState(() {
        _storageInfo = info;
      });
    } catch (e) {
      print('Erro ao carregar informações de armazenamento: $e');
    }
  }

  Future<void> _loadBackendConfig() async {
    try {
      final response = await http.get(
        Uri.parse('${AppConfig.apiBaseUrl}/config/backend'),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        final config = json.decode(response.body);
        setState(() {
          _backendConfig = config;
          _revolutionaryConfig = config['revolutionary_features'] ?? {};
        });
      }
    } catch (e) {
      print('Erro ao carregar configurações do backend: $e');
    }
  }

  Future<void> _checkConnection() async {
    try {
      final response = await http.get(
        Uri.parse('${AppConfig.apiBaseUrl}/health'),
        timeout: const Duration(seconds: 5),
      );
      
      setState(() {
        _isConnected = response.statusCode == 200;
      });
    } catch (e) {
      setState(() {
        _isConnected = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _languageService.translate('settings', appProvider.currentLanguage),
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              _isConnected ? Icons.cloud_done : Icons.cloud_off,
              color: _isConnected ? Colors.green : Colors.red,
            ),
            onPressed: _checkConnection,
            tooltip: _isConnected ? 'Conectado' : 'Desconectado',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.wait([
            _loadStorageInfo(),
            _loadBackendConfig(),
            _checkConnection(),
          ]);
        },
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Status do Sistema
            _buildSystemStatusCard(context),
            const SizedBox(height: 16),
            
            // Configurações de Idioma e Região
            _buildLanguageSection(context, appProvider),
            const SizedBox(height: 16),
            
            // Configurações de Aparência
            _buildAppearanceSection(context, appProvider),
            const SizedBox(height: 16),
            
            // Funcionalidades Revolucionárias
            _buildRevolutionaryFeaturesSection(context),
            const SizedBox(height: 16),
            
            // Configurações de Backend
            _buildBackendSection(context),
            const SizedBox(height: 16),
            
            // Conectividade e Sincronização
            _buildConnectivitySection(context, appProvider),
            const SizedBox(height: 16),
            
            // Armazenamento e Dados
            _buildStorageSection(context),
            const SizedBox(height: 16),
            
            // Configurações Regionais da Guiné-Bissau
            _buildGuineaBissauSection(context),
            const SizedBox(height: 16),
            
            // Informações do App
            _buildInfoSection(context),
          ],
        ),
      ),
    );
  }

  // Card de Status do Sistema
  Widget _buildSystemStatusCard(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.health_and_safety,
                  color: colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Status do Sistema',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatusIndicator(
                    'Conexão',
                    _isConnected ? 'Online' : 'Offline',
                    _isConnected ? Colors.green : Colors.red,
                    _isConnected ? Icons.cloud_done : Icons.cloud_off,
                  ),
                ),
                Expanded(
                  child: _buildStatusIndicator(
                    'IA',
                    _backendConfig.isNotEmpty ? 'Ativa' : 'Inativa',
                    _backendConfig.isNotEmpty ? Colors.green : Colors.orange,
                    _backendConfig.isNotEmpty ? Icons.psychology : Icons.psychology_outlined,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatusIndicator(String label, String status, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
          Text(
            status,
            style: TextStyle(
              fontSize: 10,
              color: color.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) => Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(
            icon,
            color: Theme.of(context).colorScheme.primary,
            size: 24,
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );

  // Seção de Funcionalidades Revolucionárias
  Widget _buildRevolutionaryFeaturesSection(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.auto_awesome,
                  color: colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Funcionalidades Revolucionárias',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildRevolutionaryFeatureTile(
              'Tradução Contextual',
              'IA avançada que entende contexto cultural',
              Icons.translate,
              _revolutionaryConfig['contextual_translation']?['enabled'] ?? false,
              (value) => _updateRevolutionaryFeature('contextual_translation', 'enabled', value),
            ),
            _buildRevolutionaryFeatureTile(
              'Análise Emocional',
              'Detecta emoções e tom na comunicação',
              Icons.sentiment_satisfied,
              _revolutionaryConfig['emotional_analysis']?['enabled'] ?? false,
              (value) => _updateRevolutionaryFeature('emotional_analysis', 'enabled', value),
            ),
            _buildRevolutionaryFeatureTile(
              'Ponte Cultural',
              'Facilita comunicação entre culturas',
              Icons.diversity_3,
              _revolutionaryConfig['cultural_bridge']?['enabled'] ?? false,
              (value) => _updateRevolutionaryFeature('cultural_bridge', 'enabled', value),
            ),
            _buildRevolutionaryFeatureTile(
              'Aprendizado Adaptativo',
              'Sistema aprende com suas interações',
              Icons.psychology,
              _revolutionaryConfig['adaptive_learning']?['enabled'] ?? false,
              (value) => _updateRevolutionaryFeature('adaptive_learning', 'enabled', value),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildRevolutionaryFeatureTile(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    Function(bool) onChanged,
  ) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(subtitle),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
      ),
    );
  }
  
  // Seção de Configurações de Backend
  Widget _buildBackendSection(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.settings_applications,
                  color: colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Configurações de Backend',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_backendConfig.isNotEmpty) ..[
              _buildBackendConfigTile(
                'Modelo de IA',
                _backendConfig['model_name'] ?? 'Não configurado',
                Icons.memory,
              ),
              _buildBackendConfigTile(
                'Temperatura',
                '${_backendConfig['temperature'] ?? 0.7}',
                Icons.thermostat,
              ),
              _buildBackendConfigTile(
                'Tokens Máximos',
                '${_backendConfig['max_tokens'] ?? 512}',
                Icons.token,
              ),
              _buildBackendConfigTile(
                'Timeout',
                '${_backendConfig['timeout'] ?? 30}s',
                Icons.timer,
              ),
            ] else
              const Center(
                child: Text(
                  'Configurações não disponíveis offline',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildBackendConfigTile(String title, String value, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(title),
      trailing: Text(
        value,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildLanguageSelector(AppProvider appProvider) => Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Selecionar Idioma',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: LanguageService.supportedLanguages.entries.map((entry) {
                final isSelected = appProvider.currentLanguage == entry.key;
                return FilterChip(
                  label: Text(entry.value),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      appProvider.setLanguage(entry.key);
                    }
                  },
                  selectedColor: Theme.of(context).colorScheme.primaryContainer,
                  checkmarkColor: Theme.of(context).colorScheme.primary,
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );

  Future<void> _updateRevolutionaryFeature(String feature, String key, bool value) async {
    try {
      final response = await http.put(
        Uri.parse('${AppConfig.apiBaseUrl}/config/revolutionary/$feature'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({key: value}),
      );
      
      if (response.statusCode == 200) {
        setState(() {
          _revolutionaryConfig[feature] = _revolutionaryConfig[feature] ?? {};
          _revolutionaryConfig[feature][key] = value;
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Configuração atualizada: $feature'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao atualizar configuração: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required IconData icon,
  }) => Card(
      child: SwitchListTile(
        title: Text(title),
        subtitle: Text(subtitle),
        value: value,
        onChanged: onChanged,
        secondary: Icon(icon),
      ),
    );

  // Seção de Idioma e Região
  Widget _buildLanguageSection(BuildContext context, AppProvider appProvider) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.language,
                  color: colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Idioma e Região',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Selecionar Idioma',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: LanguageService.supportedLanguages.entries.map((entry) {
                final isSelected = appProvider.currentLanguage == entry.key;
                return FilterChip(
                  label: Text(entry.value),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      appProvider.setLanguage(entry.key);
                    }
                  },
                  selectedColor: colorScheme.primaryContainer,
                  checkmarkColor: colorScheme.primary,
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  // Seção de Aparência
  Widget _buildAppearanceSection(BuildContext context, AppProvider appProvider) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.palette,
                  color: colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Aparência',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Modo Escuro'),
              subtitle: const Text('Ativar tema escuro'),
              value: appProvider.isDarkMode,
              onChanged: (value) => appProvider.setDarkMode(value),
              secondary: Icon(
                appProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                color: colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Seção de Conectividade
  Widget _buildConnectivitySection(BuildContext context, AppProvider appProvider) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.sync,
                  color: colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Conectividade e Sincronização',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Sincronização Automática'),
              subtitle: const Text('Sincronizar quando conectado'),
              value: appProvider.autoSync,
              onChanged: (value) => appProvider.setAutoSync(value),
              secondary: Icon(
                Icons.sync,
                color: colorScheme.primary,
              ),
            ),
            ListTile(
              leading: Icon(
                Icons.cloud_sync,
                color: colorScheme.primary,
              ),
              title: const Text('Sincronizar Agora'),
              subtitle: Text(
                '${_storageStats['sync_queue_items'] ?? 0} itens na fila',
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: _syncData,
            ),
          ],
        ),
      ),
    );
  }

  // Seção de Armazenamento
  Widget _buildStorageSection(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.storage,
                  color: colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Armazenamento e Dados',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildStorageInfo(),
            const SizedBox(height: 12),
            ListTile(
              leading: Icon(
                Icons.cleaning_services,
                color: colorScheme.primary,
              ),
              title: const Text('Limpar Cache'),
              subtitle: const Text('Remove dados antigos offline'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: _clearOldOfflineData,
            ),
          ],
        ),
      ),
    );
  }

  // Seção Específica da Guiné-Bissau
  Widget _buildGuineaBissauSection(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.flag,
                  color: colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Configurações Regionais - Guiné-Bissau',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildGuineaBissauTile(
              'Idiomas Locais',
              'Crioulo, Balanta, Fula, Mandinga',
              Icons.language,
              () => _showLanguageDialog(),
            ),
            _buildGuineaBissauTile(
              'Regiões',
              'Bissau, Bafatá, Gabú, Cacheu...',
              Icons.location_on,
              () => _showRegionDialog(),
            ),
            _buildGuineaBissauTile(
              'Culturas Locais',
              'Arroz, Castanha de Caju, Mandioca',
              Icons.agriculture,
              () => _showCropsDialog(),
            ),
            _buildGuineaBissauTile(
              'Medicina Tradicional',
              'Plantas medicinais locais',
              Icons.local_pharmacy,
              () => _showMedicineDialog(),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildGuineaBissauTile(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  // Seção de Informações
  Widget _buildInfoSection(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info,
                  color: colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Informações do App',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: Icon(
                Icons.info_outline,
                color: colorScheme.primary,
              ),
              title: const Text('Sobre o Bu Fala'),
              subtitle: const Text('Versão 1.0.0'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: _showAboutDialog,
            ),
            ListTile(
              leading: Icon(
                Icons.privacy_tip,
                color: colorScheme.primary,
              ),
              title: const Text('Política de Privacidade'),
              subtitle: const Text('Como protegemos seus dados'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => _showPrivacyDialog(),
            ),
            ListTile(
              leading: Icon(
                Icons.help,
                color: colorScheme.primary,
              ),
              title: const Text('Ajuda e Suporte'),
              subtitle: const Text('Como usar o aplicativo'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => _showHelpDialog(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStorageInfo() => Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Uso de Armazenamento',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Dados Offline:'),
                Text('${_storageStats['offline_items'] ?? 0} itens'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Fila de Sincronização:'),
                Text('${_storageStats['sync_queue_items'] ?? 0} itens'),
              ],
            ),
          ],
        ),
      ),
    );

  // Métodos para diálogos específicos da Guiné-Bissau
  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Idiomas Locais'),
        content: const Text(
          'Configurações para idiomas locais da Guiné-Bissau:\n\n'
          '• Crioulo Guineense\n'
          '• Balanta\n'
          '• Fula\n'
          '• Mandinga\n'
          '• Papel\n'
          '• Manjaco',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  void _showRegionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Regiões da Guiné-Bissau'),
        content: const Text(
          'Regiões administrativas:\n\n'
          '• Bissau (capital)\n'
          '• Bafatá\n'
          '• Biombo\n'
          '• Bolama\n'
          '• Cacheu\n'
          '• Gabú\n'
          '• Oio\n'
          '• Quinara\n'
          '• Tombali',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  void _showCropsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Culturas Locais'),
        content: const Text(
          'Principais culturas da Guiné-Bissau:\n\n'
          '• Arroz (principal alimento)\n'
          '• Castanha de Caju\n'
          '• Mandioca\n'
          '• Milho\n'
          '• Amendoim\n'
          '• Feijão\n'
          '• Batata-doce\n'
          '• Coco',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  void _showMedicineDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Medicina Tradicional'),
        content: const Text(
          'Plantas medicinais comuns na Guiné-Bissau:\n\n'
          '• Neem (para malária)\n'
          '• Moringa (nutritiva)\n'
          '• Baobá (vitamina C)\n'
          '• Cajueiro (anti-inflamatório)\n'
          '• Papaia (digestivo)\n\n'
          'Sempre consulte um profissional de saúde.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Política de Privacidade'),
        content: const Text(
          'O Bu Fala respeita sua privacidade:\n\n'
          '• Dados armazenados localmente\n'
          '• Sincronização opcional\n'
          '• Sem coleta de dados pessoais\n'
          '• Código aberto e transparente',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ajuda e Suporte'),
        content: const Text(
          'Como usar o Bu Fala:\n\n'
          '• Funciona offline\n'
          '• Faça perguntas sobre saúde\n'
          '• Consulte informações agrícolas\n'
          '• Sincronize quando possível\n\n'
          'Para suporte, visite nossa comunidade.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) => Card(
      child: ListTile(
        title: Text(title),
        subtitle: Text(subtitle),
        leading: Icon(icon),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );

  Widget _buildInfoTile({
    required String title,
    required String subtitle,
    required IconData icon,
    VoidCallback? onTap,
  }) => Card(
      child: ListTile(
        title: Text(title),
        subtitle: Text(subtitle),
        leading: Icon(icon),
        trailing: onTap != null ? const Icon(Icons.arrow_forward_ios) : null,
        onTap: onTap,
      ),
    );

  Future<void> _clearOldOfflineData() async {
    try {
      await _offlineService.clearOldOfflineData();
      _loadStorageStats();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cache offline limpo com sucesso'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao limpar cache: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _syncData() async {
    try {
      await _offlineService.processSyncQueue();
      _loadStorageStats();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sincronização concluída'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro na sincronização: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: 'Bu Fala',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(
        Icons.health_and_safety,
        size: 48,
        color: Colors.blue,
      ),
      children: [
        const Text(
          'Bu Fala é um sistema de IA desenvolvido para ajudar comunidades '
          'da Guiné-Bissau com primeiros socorros, educação e agricultura '
          'em áreas com acesso limitado à internet.',
        ),
        const SizedBox(height: 16),
        const Text(
          'O aplicativo funciona offline e sincroniza dados quando '
          'uma conexão está disponível.',
        ),
      ],
    );
  }
}

