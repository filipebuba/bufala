import 'package:hive/hive.dart';

class EmergencyService {
  static const String _boxName = 'emergency_data';

  // Dados de primeiros socorros em múltiplas linguagens
  static final Map<String, Map<String, dynamic>> emergencyData = {
    'childbirth': {
      'pt': {
        'title': 'Parto de Emergência',
        'symptoms': [
          'Contrações regulares e fortes',
          'Ruptura da bolsa d\'água',
          'Pressão para empurrar',
          'Cabeça do bebê visível'
        ],
        'steps': [
          '1. Mantenha a calma e chame ajuda',
          '2. Lave as mãos com água e sabão',
          '3. Prepare um local limpo e seguro',
          '4. Não tente parar o parto se a cabeça estiver visível',
          '5. Apoie a cabeça do bebê gentilmente',
          '6. Limpe o nariz e boca do bebê',
          '7. Mantenha o bebê aquecido',
          '8. Não corte o cordão umbilical sem instrumentos estéreis',
          '9. Procure ajuda médica imediatamente'
        ],
        'warnings': [
          'NUNCA puxe o bebê',
          'NUNCA corte o cordão sem esterilização',
          'Mantenha mãe e bebê aquecidos'
        ]
      },
      'crioulo': {
        'title': 'Parto di Emergência',
        'symptoms': [
          'Dor na barriga ku ta bai i ta bin',
          'Agu ta sai',
          'Vontadi pa puxa',
          'Kabesa di mininu ta parsi'
        ],
        'steps': [
          '1. Fica kalmu i chama ajuda',
          '2. Laba mon ku agu i sabon',
          '3. Prepara un lokal limpu i siguru',
          '4. Ka tenta para parto si kabesa ta parsi',
          '5. Ajuda kabesa di mininu ku jeitu',
          '6. Limpa nariz i boka di mininu',
          '7. Mantén mininu na kalor',
          '8. Ka korta korda sin instrumentu limpu',
          '9. Buska ajuda médiku na pressa'
        ],
        'warnings': [
          'NUNKA puxa mininu',
          'NUNKA korta korda sin limpeza',
          'Mantén mai i mininu na kalor'
        ]
      }
    },
    'fever': {
      'pt': {
        'title': 'Febre Alta',
        'symptoms': [
          'Temperatura acima de 38°C',
          'Calafrios',
          'Suor excessivo',
          'Dor de cabeça',
          'Fraqueza'
        ],
        'steps': [
          '1. Meça a temperatura',
          '2. Remova roupas em excesso',
          '3. Aplique compressas frias na testa',
          '4. Dê bastante líquido',
          '5. Mantenha em repouso',
          '6. Procure ajuda se febre persistir'
        ],
        'warnings': [
          'Procure ajuda urgente se temperatura > 40°C',
          'Atenção especial para crianças e idosos'
        ]
      },
      'crioulo': {
        'title': 'Febre Altu',
        'symptoms': [
          'Temperatura mas altu di 38°C',
          'Friu na korpu',
          'Suor dimais',
          'Dor na kabesa',
          'Frakezu'
        ],
        'steps': [
          '1. Medi temperatura',
          '2. Tira roupa dimais',
          '3. Pon panu friu na kabesa',
          '4. Da agu bastanti',
          '5. Dexa na diskansu',
          '6. Buska ajuda si febre ka para'
        ],
        'warnings': [
          'Buska ajuda urgenti si temperatura > 40°C',
          'Atensaun spesial pa mininus i velus'
        ]
      }
    },
    'wound': {
      'pt': {
        'title': 'Ferimentos e Cortes',
        'symptoms': [
          'Sangramento',
          'Corte na pele',
          'Dor no local',
          'Possível infecção'
        ],
        'steps': [
          '1. Lave as mãos',
          '2. Pare o sangramento com pressão',
          '3. Limpe o ferimento com água limpa',
          '4. Aplique curativo limpo',
          '5. Mantenha elevado se possível',
          '6. Troque o curativo regularmente'
        ],
        'warnings': [
          'Procure ajuda para cortes profundos',
          'Atenção para sinais de infecção'
        ]
      },
      'crioulo': {
        'title': 'Ferida i Korte',
        'symptoms': [
          'Sangi ta sai',
          'Korte na peli',
          'Dor na lokal',
          'Podi infeta'
        ],
        'steps': [
          '1. Laba mon',
          '2. Para sangi ku presaun',
          '3. Limpa ferida ku agu limpu',
          '4. Pon kurativu limpu',
          '5. Mantén altu si podi',
          '6. Muda kurativu sempri'
        ],
        'warnings': [
          'Buska ajuda pa korte fundu',
          'Atensaun pa sinal di infesaun'
        ]
      }
    }
  };

  // Dados educacionais básicos
  static final Map<String, Map<String, dynamic>> educationData = {
    'basic_math': {
      'pt': {
        'title': 'Matemática Básica',
        'topics': [
          'Números de 1 a 100',
          'Adição e Subtração',
          'Multiplicação Simples',
          'Divisão Básica',
          'Frações Simples'
        ],
        'exercises': ['2 + 3 = ?', '10 - 4 = ?', '5 × 2 = ?', '8 ÷ 2 = ?']
      },
      'crioulo': {
        'title': 'Matematika Basiku',
        'topics': [
          'Numeru di 1 te 100',
          'Suma i Tira',
          'Multiplika Simplis',
          'Dividi Basiku',
          'Frasaun Simplis'
        ],
        'exercises': ['2 + 3 = ?', '10 - 4 = ?', '5 × 2 = ?', '8 ÷ 2 = ?']
      }
    },
    'portuguese': {
      'pt': {
        'title': 'Português Básico',
        'topics': [
          'Alfabeto',
          'Palavras Simples',
          'Frases Básicas',
          'Cumprimentos',
          'Números'
        ],
        'examples': [
          'Olá = Cumprimento',
          'Casa = Local onde moramos',
          'Água = Líquido essencial',
          'Comida = Alimento'
        ]
      },
      'crioulo': {
        'title': 'Portugues Basiku',
        'topics': [
          'Alfabetu',
          'Palavra Simplis',
          'Frazi Basiku',
          'Kumprimientu',
          'Numeru'
        ],
        'examples': [
          'Olá = Kumprimientu',
          'Kasa = Lokal undi no mora',
          'Agu = Likidu importanti',
          'Kumida = Alimentu'
        ]
      }
    }
  };

  // Dados agrícolas
  static final Map<String, Map<String, dynamic>> agricultureData = {
    'crop_protection': {
      'pt': {
        'title': 'Proteção de Culturas',
        'problems': [
          'Pragas de insetos',
          'Doenças das plantas',
          'Ervas daninhas',
          'Falta de água',
          'Solo pobre'
        ],
        'solutions': [
          'Use plantas repelentes naturais',
          'Rotação de culturas',
          'Compostagem orgânica',
          'Irrigação por gotejamento',
          'Cobertura do solo'
        ],
        'natural_remedies': [
          'Nim para controle de pragas',
          'Cinzas para fortalecer plantas',
          'Água com sabão para pulgões',
          'Plantas companheiras'
        ]
      },
      'crioulo': {
        'title': 'Protesaun di Kultura',
        'problems': [
          'Praga di insetu',
          'Duensa di planta',
          'Erva ruim',
          'Falta di agu',
          'Tera fraku'
        ],
        'solutions': [
          'Uza planta natural pa afasta praga',
          'Muda kultura na lokal',
          'Kompostu organiku',
          'Rega gota-gota',
          'Kubri tera'
        ],
        'natural_remedies': [
          'Nim pa kontrola praga',
          'Sinza pa fortalesi planta',
          'Agu ku sabon pa pulgaun',
          'Planta kompanheru'
        ]
      }
    },
    'planting_calendar': {
      'pt': {
        'title': 'Calendário de Plantio',
        'rainy_season': [
          'Arroz (Maio-Junho)',
          'Milho (Maio-Julho)',
          'Feijão (Junho-Agosto)',
          'Amendoim (Maio-Junho)'
        ],
        'dry_season': [
          'Hortaliças (Novembro-Março)',
          'Tomate (Dezembro-Fevereiro)',
          'Cebola (Outubro-Dezembro)',
          'Alface (Todo ano com irrigação)'
        ]
      },
      'crioulo': {
        'title': 'Kalendario di Planta',
        'rainy_season': [
          'Aroz (Maiu-Junhu)',
          'Milhu (Maiu-Julhu)',
          'Feijaun (Junhu-Agostu)',
          'Amendoim (Maiu-Junhu)'
        ],
        'dry_season': [
          'Hortalis (Novembru-Marsu)',
          'Tomat (Dezembru-Fevereru)',
          'Sebola (Outubru-Dezembru)',
          'Alfas (Tudu anu ku rega)'
        ]
      }
    }
  };

  static Future<void> initializeData() async {
    await Hive.openBox(_boxName);
    final box = Hive.box(_boxName);

    // Salvar dados offline se não existirem
    if (box.isEmpty) {
      await box.put('emergency', emergencyData);
      await box.put('education', educationData);
      await box.put('agriculture', agricultureData);
    }
  }

  static Map<String, dynamic>? getEmergencyInfo(String type, String language) {
    final box = Hive.box<Map<String, dynamic>>(_boxName);
    final data = box.get('emergency', defaultValue: emergencyData);
    final result = data?[type]?[language];
    return result is Map<String, dynamic> ? result : null;
  }

  static Map<String, dynamic>? getEducationInfo(String type, String language) {
    final box = Hive.box<Map<String, dynamic>>(_boxName);
    final data = box.get('education', defaultValue: educationData);
    final result = data?[type]?[language];
    return result is Map<String, dynamic> ? result : null;
  }

  static Map<String, dynamic>? getAgricultureInfo(
      String type, String language) {
    final box = Hive.box<Map<String, dynamic>>(_boxName);
    final data = box.get('agriculture', defaultValue: agricultureData);
    final result = data?[type]?[language];
    return result is Map<String, dynamic> ? result : null;
  }

  static List<String> getEmergencyTypes() => emergencyData.keys.toList();

  static List<String> getEducationTypes() => educationData.keys.toList();

  static List<String> getAgricultureTypes() => agricultureData.keys.toList();
}
