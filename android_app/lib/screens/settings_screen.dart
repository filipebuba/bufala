import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../services/language_service.dart';
import '../services/offline_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final LanguageService _languageService = LanguageService();
  final OfflineService _offlineService = OfflineService();
  Map<String, int> _storageStats = {};

  @override
  void initState() {
    super.initState();
    _loadStorageStats();
  }

  void _loadStorageStats() {
    setState(() {
      _storageStats = _offlineService.getStorageStats();
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        title: Consumer<AppProvider>(
          builder: (context, appProvider, child) => Text(
              _languageService.translate('settings', appProvider.currentLanguage),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
        ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Consumer<AppProvider>(
        builder: (context, appProvider, child) => ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Seção de Idioma
              _buildSectionHeader(
                _languageService.translate('language', appProvider.currentLanguage),
                Icons.language,
              ),
              _buildLanguageSelector(appProvider),
              const SizedBox(height: 24),

              // Seção de Aparência
              _buildSectionHeader(
                'Aparência',
                Icons.palette,
              ),
              _buildSwitchTile(
                title: _languageService.translate('dark_mode', appProvider.currentLanguage),
                subtitle: 'Ativar tema escuro',
                value: appProvider.isDarkMode,
                onChanged: (value) => appProvider.setDarkMode(value),
                icon: Icons.dark_mode,
              ),
              const SizedBox(height: 24),

              // Seção de Conectividade
              _buildSectionHeader(
                'Conectividade',
                Icons.wifi,
              ),
              _buildSwitchTile(
                title: _languageService.translate('offline_mode', appProvider.currentLanguage),
                subtitle: 'Usar apenas conteúdo offline',
                value: appProvider.isOfflineMode,
                onChanged: (value) => appProvider.setOfflineMode(value),
                icon: Icons.offline_bolt,
              ),
              const SizedBox(height: 24),

              // Seção de Armazenamento
              _buildSectionHeader(
                'Armazenamento',
                Icons.storage,
              ),
              _buildStorageInfo(),
              const SizedBox(height: 16),
              _buildActionButton(
                title: 'Limpar Cache Offline',
                subtitle: 'Remove dados offline antigos',
                icon: Icons.cleaning_services,
                onTap: _clearOldOfflineData,
              ),
              _buildActionButton(
                title: 'Sincronizar Dados',
                subtitle: 'Sincronizar dados pendentes',
                icon: Icons.sync,
                onTap: _syncData,
              ),
              const SizedBox(height: 24),

              // Seção de Informações
              _buildSectionHeader(
                'Informações',
                Icons.info,
              ),
              _buildInfoTile(
                title: 'Versão do App',
                subtitle: '1.0.0',
                icon: Icons.app_settings_alt,
              ),
              _buildInfoTile(
                title: 'Sobre Bu Fala',
                subtitle: 'Sistema de IA para Guiné-Bissau',
                icon: Icons.help_outline,
                onTap: _showAboutDialog,
              ),
            ],
          ),
      ),
    );

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

