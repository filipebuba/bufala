# Bufala - Aplicativo Comunitário para Guiné-Bissau

## 🌍 Visão Geral

O **Bufala** é um aplicativo Android desenvolvido especificamente para atender às necessidades urgentes das comunidades rurais da Guiné-Bissau. O aplicativo funciona completamente offline e oferece suporte em português e crioulo guineense, proporcionando acesso a informações vitais sobre primeiros socorros, educação e agricultura.

## 🎯 Problema que Resolve

Nossas comunidades enfrentam desafios críticos:
- **Saúde**: Mulheres morrem durante o parto por falta de acesso médico em áreas remotas
- **Educação**: Professores qualificados sem acesso a materiais didáticos
- **Agricultura**: Perda de colheitas por falta de conhecimento sobre proteção de culturas
- **Conectividade**: Áreas sem acesso adequado à internet, apenas telefones móveis ocasionais

## ✨ Funcionalidades Principais

### 🚨 Emergências Médicas
- **Primeiros Socorros para Parto**: Instruções passo a passo para assistir partos de emergência
- **Tratamento de Febre**: Métodos de resfriamento e quando buscar ajuda
- **Cuidados com Ferimentos**: Limpeza, desinfecção e bandagem adequada
- **Suporte Bilíngue**: Todas as instruções em português e crioulo

### 📚 Educação Offline
- **Matemática Básica**: Números, operações e cálculos do dia a dia
- **Língua Portuguesa**: Alfabetização e comunicação
- **Educação em Saúde**: Higiene, prevenção e cuidados básicos
- **Educação Cívica**: Direitos, deveres e cidadania
- **Vocabulário Bilíngue**: Português ↔ Crioulo

### 🌱 Agricultura Sustentável
- **Proteção de Culturas**: Como proteger plantações de pragas e doenças
- **Calendário de Plantio**: Quando plantar cada cultura na Guiné-Bissau
- **Remédios Naturais**: Soluções orgânicas para problemas agrícolas
- **Técnicas Sazonais**: Orientações para época seca e chuvosa

## 🛠️ Tecnologias Utilizadas

- **Flutter**: Framework multiplataforma para desenvolvimento mobile
- **Dart**: Linguagem de programação
- **Hive**: Banco de dados local para armazenamento offline
- **Provider**: Gerenciamento de estado
- **Material Design**: Interface moderna e intuitiva

## 📱 Estrutura do Aplicativo

```
android_app/
├── lib/
│   ├── main.dart                 # Ponto de entrada do aplicativo
│   ├── providers/
│   │   └── app_provider.dart     # Gerenciamento de idioma e estado
│   ├── services/
│   │   └── emergency_service.dart # Dados offline em PT/Crioulo
│   ├── screens/
│   │   ├── home_screen.dart      # Tela inicial
│   │   ├── emergency_screen.dart # Emergências médicas
│   │   ├── education_screen.dart # Conteúdo educacional
│   │   ├── agriculture_screen.dart # Informações agrícolas
│   │   └── settings_screen.dart  # Configurações
│   └── utils/
│       └── app_colors.dart       # Paleta de cores
└── pubspec.yaml                  # Dependências do projeto
```

## 🚀 Como Executar

### Pré-requisitos
- Flutter SDK (versão 3.0+)
- Android Studio ou VS Code
- Dispositivo Android ou emulador

### Instalação

1. **Clone o repositório**:
   ```bash
   git clone <repository-url>
   cd bufala/android_app
   ```

2. **Instale as dependências**:
   ```bash
   flutter pub get
   ```

3. **Execute o aplicativo**:
   ```bash
   flutter run
   ```

## 🌐 Suporte a Idiomas

O aplicativo oferece suporte completo a:
- **Português**: Idioma oficial da Guiné-Bissau
- **Crioulo Guineense**: Idioma local mais falado

### Alternância de Idiomas
Os usuários podem alternar entre português e crioulo através das configurações, garantindo acessibilidade para toda a comunidade.

## 📊 Dados Offline

Todos os dados são armazenados localmente usando Hive, incluindo:
- Instruções médicas detalhadas
- Conteúdo educacional estruturado
- Informações agrícolas sazonais
- Vocabulário bilíngue
- Configurações do usuário

## 🎨 Design e UX

- **Interface Intuitiva**: Ícones claros e navegação simples
- **Cores Temáticas**: Cada seção tem sua própria identidade visual
- **Acessibilidade**: Textos grandes e contrastes adequados
- **Responsivo**: Adapta-se a diferentes tamanhos de tela

## 🔮 Funcionalidades Futuras

### Aprendizado de Máquina Local
- **Processamento de Linguagem Natural**: Para melhor compreensão do crioulo
- **Reconhecimento de Voz**: Interação por voz em crioulo
- **Tradução Automática**: Melhorias na tradução PT ↔ Crioulo
- **Adaptação Cultural**: O app aprende com o uso local

### Expansão de Conteúdo
- **Mais Idiomas Locais**: Suporte a outros dialetos regionais
- **Conteúdo Veterinário**: Cuidados com animais de criação
- **Meteorologia Local**: Previsões climáticas para agricultura
- **Marketplace Local**: Conexão entre produtores e compradores

## 🤝 Contribuição

Este projeto é desenvolvido para e pela comunidade da Guiné-Bissau. Contribuições são bem-vindas:

1. **Conteúdo Local**: Adicionar mais informações específicas da região
2. **Traduções**: Melhorar traduções para crioulo
3. **Funcionalidades**: Sugerir novas funcionalidades necessárias
4. **Testes**: Testar o aplicativo em diferentes dispositivos

## 📞 Contato e Suporte

Para sugestões, problemas ou contribuições:
- **Issues**: Use o sistema de issues do GitHub
- **Comunidade**: Participe das discussões da comunidade
- **Feedback**: Compartilhe experiências de uso

## 📄 Licença

Este projeto é desenvolvido com o objetivo de servir à comunidade da Guiné-Bissau. Consulte o arquivo LICENSE para mais detalhes.

## 🙏 Agradecimentos

Este aplicativo foi desenvolvido pensando nas necessidades reais das comunidades rurais da Guiné-Bissau, especialmente:
- Mulheres em áreas remotas que precisam de assistência médica
- Professores dedicados que trabalham sem recursos adequados
- Agricultores que lutam para proteger suas colheitas
- Toda a comunidade que preserva e valoriza o crioulo guineense

---

**Bufala** - *Tecnologia a serviço da comunidade guineense* 🇬🇼