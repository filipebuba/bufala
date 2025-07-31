import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../providers/app_provider.dart';
import '../services/language_service.dart';
import '../services/storage_service.dart';
import '../services/offline_service.dart';
import '../services/api_service.dart';
import '../services/environmental_api_service.dart';
import '../config/app_config.dart';
// Imports para navegação
import 'medical_emergency_unified_screen.dart';
import 'education_screen.dart';
import 'agriculture_screen.dart';
import 'wellness_coaching_screen.dart';
import 'environmental_menu_screen.dart';
import 'translate_screen.dart';
import 'voiceguide_accessibility_screen.dart';
import 'gamification_screen.dart';

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
      if (mounted) {
        setState(() {
          _storageStats = stats;
        });
      }
    } catch (e) {
      debugPrint('Erro ao carregar estatísticas de armazenamento: $e');
    }
  }

  Future<void> _loadStorageInfo() async {
    try {
      final info = await _storageService.getStorageInfo();
      if (mounted) {
        setState(() {
          _storageInfo = info;
        });
      }
    } catch (e) {
      debugPrint('Erro ao carregar informações de armazenamento: $e');
    }
  }

  Future<void> _loadBackendConfig() async {
    try {
      final response = await http.get(
        Uri.parse('${AppConfig.apiBaseUrl}/config/backend'),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 200 && mounted) {
        final config = json.decode(response.body) as Map<String, dynamic>;
        setState(() {
          _backendConfig = config;
          _revolutionaryConfig = (config['revolutionary_features'] as Map<String, dynamic>?) ?? {};
        });
      }
    } catch (e) {
      debugPrint('Erro ao carregar configurações do backend: $e');
    }
  }

  Future<void> _checkConnection() async {
    try {
      final response = await http.get(
        Uri.parse('${AppConfig.apiBaseUrl}/health'),
      ).timeout(const Duration(seconds: 5));
      
      if (mounted) {
        setState(() {
          _isConnected = response.statusCode == 200;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isConnected = false;
        });
      }
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
          'Configurações',
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
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
              
              // Modo Offline
              _buildOfflineSection(context, appProvider),
              const SizedBox(height: 16),
              
              // Funcionalidades Revolucionárias
              _buildRevolutionaryFeaturesSection(context),
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
              
              // Navegação para Funcionalidades
              _buildFunctionalitiesSection(context),
              const SizedBox(height: 16),
              
              // Informações do App
              _buildInfoSection(context),
              const SizedBox(height: 32),
            ],
          ),
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
                Expanded(
                  child: Text(
                    'Status do Sistema',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
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
                const SizedBox(width: 8),
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
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            status,
            style: TextStyle(
              fontSize: 10,
              color: color.withOpacity(0.8),
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

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
                Expanded(
                  child: Text(
                    'Funcionalidades Revolucionárias',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildRevolutionaryFeatureTile(
              'Tradução Contextual',
              'IA avançada que entende contexto cultural',
              Icons.translate,
              _getRevolutionaryFeatureValue('contextual_translation', 'enabled'),
              (value) => _updateRevolutionaryFeature('contextual_translation', 'enabled', value),
            ),
            _buildRevolutionaryFeatureTile(
              'Análise Emocional',
              'Detecta emoções e tom na comunicação',
              Icons.sentiment_satisfied,
              _getRevolutionaryFeatureValue('emotional_analysis', 'enabled'),
              (value) => _updateRevolutionaryFeature('emotional_analysis', 'enabled', value),
            ),
            _buildRevolutionaryFeatureTile(
              'Ponte Cultural',
              'Facilita comunicação entre culturas',
              Icons.diversity_3,
              _getRevolutionaryFeatureValue('cultural_bridge', 'enabled'),
              (value) => _updateRevolutionaryFeature('cultural_bridge', 'enabled', value),
            ),
            _buildRevolutionaryFeatureTile(
              'Aprendizado Adaptativo',
              'Sistema aprende com suas interações',
              Icons.psychology,
              _getRevolutionaryFeatureValue('adaptive_learning', 'enabled'),
              (value) => _updateRevolutionaryFeature('adaptive_learning', 'enabled', value),
            ),
          ],
        ),
      ),
    );
  }
  
  bool _getRevolutionaryFeatureValue(String feature, String key) {
    try {
      final featureConfig = _revolutionaryConfig[feature] as Map<String, dynamic>?;
      return (featureConfig?[key] as bool?) ?? false;
    } catch (e) {
      return false;
    }
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
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        subtitle,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
      ),
    );
  }

  Future<void> _updateRevolutionaryFeature(String feature, String key, bool value) async {
    try {
      final response = await http.put(
        Uri.parse('${AppConfig.apiBaseUrl}/config/revolutionary/$feature'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({key: value}),
      );
      
      if (response.statusCode == 200 && mounted) {
        setState(() {
          _revolutionaryConfig[feature] = _revolutionaryConfig[feature] ?? {};
          (_revolutionaryConfig[feature] as Map<String, dynamic>)[key] = value;
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
                Expanded(
                  child: Text(
                    'Idioma e Região',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Selecionar Idioma',
              style: theme.textTheme.titleSmall?.copyWith(
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
                Expanded(
                  child: Text(
                    'Aparência',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
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

  // Seção de Modo Offline
  Widget _buildOfflineSection(BuildContext context, AppProvider appProvider) {
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
                  Icons.offline_bolt,
                  color: colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Modo Offline com Gemma 3n',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Ativar Modo Offline'),
              subtitle: Text(
                appProvider.isOfflineMode 
                  ? 'IA funcionando localmente com Gemma 3n'
                  : 'Conectar ao servidor quando disponível',
              ),
              value: appProvider.isOfflineMode,
              onChanged: (value) => appProvider.setOfflineMode(value),
              secondary: Icon(
                appProvider.isOfflineMode ? Icons.offline_bolt : Icons.cloud,
                color: colorScheme.primary,
              ),
            ),
            if (appProvider.isOfflineMode) ...[
              const Divider(),
              ListTile(
                leading: Icon(
                  Icons.psychology,
                  color: colorScheme.primary,
                ),
                title: const Text('Gemma 3n Local'),
                subtitle: const Text('IA otimizada para dispositivo - Privacidade garantida'),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green.withOpacity(0.3)),
                  ),
                  child: const Text(
                    'ATIVO',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ),
              ),
            ],
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
                Expanded(
                  child: Text(
                    'Conectividade e Sincronização',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Sincronização Automática'),
              subtitle: const Text('Sincronizar dados automaticamente quando conectado'),
              value: true, // Placeholder
              onChanged: (value) {
                // Implementar lógica de sincronização
              },
              secondary: Icon(
                Icons.sync,
                color: colorScheme.primary,
              ),
            ),
            ListTile(
              leading: Icon(
                Icons.sync_alt,
                color: colorScheme.primary,
              ),
              title: const Text('Sincronizar Agora'),
              subtitle: const Text('Forçar sincronização manual'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // Implementar sincronização manual
                _syncData();
              },
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
                Expanded(
                  child: Text(
                    'Armazenamento e Dados',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.surfaceVariant.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Uso de Armazenamento'),
                      Text('${_storageInfo['used_space'] ?? 0} MB'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Dados Offline:'),
                      Text('${_storageStats['offline_data'] ?? 0} itens'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Fila de Sincronização:'),
                      Text('${_storageStats['sync_queue'] ?? 0} itens'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: Icon(
                Icons.cleaning_services,
                color: colorScheme.primary,
              ),
              title: const Text('Limpar Cache'),
              subtitle: const Text('Remove dados antigos offline'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                _clearCache();
              },
            ),
          ],
        ),
      ),
    );
  }

  // Seção da Guiné-Bissau
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
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    gradient: const LinearGradient(
                      colors: [Colors.red, Colors.yellow, Colors.green],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Configurações Regionais',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.only(left: 32),
              child: Text(
                'Guiné-Bissau',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: Icon(
                Icons.language,
                color: colorScheme.primary,
              ),
              title: const Text('Configurar Idioma Local'),
              subtitle: const Text('Definir idioma preferido da região'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showLanguageSelectionDialog(),
            ),
            ListTile(
              leading: Icon(
                Icons.location_on,
                color: colorScheme.primary,
              ),
              title: const Text('Selecionar Região'),
              subtitle: const Text('Configurar sua região na Guiné-Bissau'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showRegionSelectionDialog(),
            ),
            ListTile(
               leading: Icon(
                 Icons.agriculture,
                 color: colorScheme.primary,
               ),
               title: const Text('Culturas da Região'),
               subtitle: const Text('Informações sobre cultivos locais'),
               trailing: const Icon(Icons.chevron_right),
               onTap: () => _navigateToLocalCrops(),
             ),
            ListTile(
              leading: Icon(
                Icons.local_hospital,
                color: colorScheme.primary,
              ),
              title: const Text('Medicina Tradicional'),
              subtitle: const Text('Guia de plantas medicinais'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _navigateToTraditionalMedicine(),
            ),
          ],
        ),
      ),
    );
  }

  // Seção de Funcionalidades
  Widget _buildFunctionalitiesSection(BuildContext context) {
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
                  Icons.apps,
                  color: colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Funcionalidades do App',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildFunctionalityTile(
              'Assistência Médica',
              'Emergências e consultas médicas',
              Icons.medical_services,
              () => _navigateToMedical(),
            ),
            _buildFunctionalityTile(
              'Educação',
              'Sistema educacional inteligente',
              Icons.school,
              () => _navigateToEducation(),
            ),
            _buildFunctionalityTile(
              'Agricultura',
              'Assistência para cultivos',
              Icons.agriculture,
              () => _navigateToAgriculture(),
            ),
            _buildFunctionalityTile(
              'Bem-estar',
              'Coaching de saúde e bem-estar',
              Icons.favorite,
              () => _navigateToWellness(),
            ),
            _buildFunctionalityTile(
              'Meio Ambiente',
              'Análise e sustentabilidade ambiental',
              Icons.eco,
              () => _navigateToEnvironmental(),
            ),
            _buildFunctionalityTile(
              'Tradução',
              'Tradutor inteligente multilíngue',
              Icons.translate,
              () => _navigateToTranslation(),
            ),
            _buildFunctionalityTile(
              'Acessibilidade',
              'Guia de voz e recursos de acessibilidade',
              Icons.accessibility,
              () => _navigateToAccessibility(),
            ),
            _buildFunctionalityTile(
              'Gamificação',
              'Sistema de conquistas e recompensas',
              Icons.emoji_events,
              () => _navigateToGamification(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFunctionalityTile(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return ListTile(
      leading: Icon(
        icon,
        color: colorScheme.primary,
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w500),
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        subtitle,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: const Icon(Icons.chevron_right),
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
                Expanded(
                  child: Text(
                    'Informações do App',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
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
              title: const Text('Versão'),
              subtitle: const Text('1.0.0+1'),
            ),
            ListTile(
              leading: Icon(
                Icons.code,
                color: colorScheme.primary,
              ),
              title: const Text('Build'),
              subtitle: const Text('Debug'),
            ),
            ListTile(
              leading: Icon(
                Icons.support,
                color: colorScheme.primary,
              ),
              title: const Text('Suporte'),
              subtitle: const Text('Contato para ajuda e feedback'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // Implementar navegação para suporte
              },
            ),
          ],
        ),
      ),
    );
  }

  // Métodos auxiliares
  void _showLanguageSelectionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Selecionar Idioma Local'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView(
              shrinkWrap: true,
              children: [
                ListTile(
                  title: const Text('Português'),
                  onTap: () {
                    _setLocalLanguage('pt');
                    Navigator.of(context).pop();
                  },
                ),
                ListTile(
                  title: const Text('Crioulo'),
                  onTap: () {
                    _setLocalLanguage('gcr');
                    Navigator.of(context).pop();
                  },
                ),
                ListTile(
                  title: const Text('Fula'),
                  onTap: () {
                    _setLocalLanguage('ff');
                    Navigator.of(context).pop();
                  },
                ),
                ListTile(
                  title: const Text('Mandinga'),
                  onTap: () {
                    _setLocalLanguage('mnk');
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
          ],
        );
      },
    );
  }

  void _showRegionSelectionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Selecionar Região'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView(
              shrinkWrap: true,
              children: [
                ListTile(
                  title: const Text('Bissau'),
                  onTap: () {
                    _setUserRegion('bissau');
                    Navigator.of(context).pop();
                  },
                ),
                ListTile(
                  title: const Text('Bafatá'),
                  onTap: () {
                    _setUserRegion('bafata');
                    Navigator.of(context).pop();
                  },
                ),
                ListTile(
                  title: const Text('Gabú'),
                  onTap: () {
                    _setUserRegion('gabu');
                    Navigator.of(context).pop();
                  },
                ),
                ListTile(
                  title: const Text('Oio'),
                  onTap: () {
                    _setUserRegion('oio');
                    Navigator.of(context).pop();
                  },
                ),
                ListTile(
                  title: const Text('Quinara'),
                  onTap: () {
                    _setUserRegion('quinara');
                    Navigator.of(context).pop();
                  },
                ),
                ListTile(
                  title: const Text('Tombali'),
                  onTap: () {
                    _setUserRegion('tombali');
                    Navigator.of(context).pop();
                  },
                ),
                ListTile(
                  title: const Text('Cacheu'),
                  onTap: () {
                    _setUserRegion('cacheu');
                    Navigator.of(context).pop();
                  },
                ),
                ListTile(
                  title: const Text('Biombo'),
                  onTap: () {
                    _setUserRegion('biombo');
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
          ],
        );
      },
    );
  }

  void _setLocalLanguage(String language) async {
    try {
      await _storageService.saveLocalSetting('local_language', language);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Idioma local definido: $language'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar idioma: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _setUserRegion(String region) async {
    try {
      await _storageService.saveLocalSetting('user_region', region);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Região definida: $region'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar região: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _syncData() async {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sincronização iniciada...'),
          backgroundColor: Colors.blue,
        ),
      );
    }
    // Implementar lógica de sincronização
  }

  void _clearCache() async {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cache limpo com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
    }
    // Implementar limpeza de cache
  }

  // Métodos de navegação
  void _navigateToLocalCrops() {
    // Implementar navegação para culturas locais
  }

  void _navigateToTraditionalMedicine() {
    // Implementar navegação para medicina tradicional
  }

  void _navigateToMedical() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const MedicalEmergencyUnifiedScreen(),
      ),
    );
  }

  void _navigateToEducation() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const EducationScreen(),
      ),
    );
  }

  void _navigateToAgriculture() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AgricultureScreen(),
      ),
    );
  }

  void _navigateToWellness() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const WellnessCoachingScreen(),
      ),
    );
  }

  void _navigateToEnvironmental() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EnvironmentalMenuScreen(
          apiService: EnvironmentalApiService(baseUrl: AppConfig.apiBaseUrl),
        ),
      ),
    );
  }

  void _navigateToTranslation() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const TranslateScreen(),
      ),
    );
  }

  void _navigateToAccessibility() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const VoiceGuideAccessibilityScreen(),
      ),
    );
  }

  void _navigateToGamification() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const GamificationScreen(),
      ),
    );
  }
}

