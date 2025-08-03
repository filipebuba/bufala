import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'config/app_config.dart';
import 'constants/app_colors.dart';
import 'constants/app_strings.dart';
import 'providers/app_provider.dart';
import 'screens/agriculture_navigation_screen.dart';
import 'screens/collaborative_validation_screen.dart';
import 'screens/education_screen.dart';
import 'screens/home_screen.dart';
import 'screens/settings_screen.dart';
import 'services/gemma3_backend_service.dart';
import 'services/integrated_api_service.dart';
import 'services/language_service.dart';
import 'services/offline_service.dart';
import 'services/wellness_coaching_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar configurações do app
  await AppConfig.initialize();

  // Inicializar Hive para armazenamento offline
  await Hive.initFlutter();
  await Hive.openBox<dynamic>('bu_fala_cache');
  await Hive.openBox<dynamic>('user_preferences');

  // Inicializar serviço Gemma-3
  final gemmaService = Gemma3BackendService();
  final gemmaConnected = await gemmaService.initialize();
  print(gemmaConnected
      ? '🟢 Backend Gemma-3 conectado!'
      : '🟡 Backend Gemma-3 indisponível - usando modo offline');

  // Inicializar serviço de wellness coaching
  final wellnessService = WellnessCoachingService();
  final wellnessInitialized = await wellnessService.initialize();
  print(wellnessInitialized
      ? '🟢 Serviço de wellness inicializado!'
      : '🟡 Serviço de wellness em modo offline');

  runApp(const MoranaApp());
}

class MoranaApp extends StatelessWidget {
  const MoranaApp({super.key});

  @override
  Widget build(BuildContext context) => MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AppProvider()),
          Provider(create: (_) => IntegratedApiService()),
          Provider(create: (_) => LanguageService()),
          Provider(create: (_) => OfflineService()),
        ],
        child: Consumer<AppProvider>(
          builder: (context, appProvider, child) => MaterialApp(
            title: 'Moransa',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              primarySwatch: AppColors.primarySwatch,
              primaryColor: AppColors.primary,
              colorScheme: ColorScheme.fromSeed(
                seedColor: AppColors.primary,
              ),
              fontFamily: 'Roboto',
              appBarTheme: const AppBarTheme(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 2,
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              cardTheme: CardThemeData(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            darkTheme: ThemeData(
              primarySwatch: AppColors.primarySwatch,
              primaryColor: AppColors.primary,
              colorScheme: ColorScheme.fromSeed(
                seedColor: AppColors.primary,
                brightness: Brightness.dark,
              ),
              fontFamily: 'Roboto',
              appBarTheme: AppBarTheme(
                backgroundColor: Colors.grey[900],
                foregroundColor: Colors.white,
                elevation: 2,
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              cardTheme: CardThemeData(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            themeMode:
                appProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('pt', 'BR'), // Português
              Locale('en', 'US'), // Inglês
            ],
            locale: Locale(appProvider.currentLanguage, ''),
            home: const MainNavigationScreen(),
          ),
        ),
      );
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const EducationScreen(),
    const AgricultureNavigationScreen(), // Navegação de agricultura unificada
    const CollaborativeValidationScreen(), // Sistema de Validação Comunitária Unificado
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: _screens,
        ),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          selectedItemColor: AppColors.primary,
          unselectedItemColor: Colors.grey,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: AppStrings.home,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.school),
              label: AppStrings.education,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.agriculture),
              label: 'Agricultura',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.translate),
              label: 'Colaboração',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: AppStrings.settings,
            ),
          ],
        ),
      );
}
