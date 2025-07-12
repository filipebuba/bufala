# 🎨 Bu Fala Icon Generator

Gerador automático de ícones para o aplicativo **Bu Fala** - Sistema de IA para comunidades da Guiné-Bissau.

## 🌟 Características

- ✅ Gera ícones para **todas as plataformas** (Android, iOS, Web, Microsoft)
- ✅ **Otimização automática** para diferentes densidades
- ✅ **Integração com Flutter** - arquivos prontos para uso
- ✅ **Gráficos promocionais** para lojas de aplicativos
- ✅ **Press kit completo** com variações do logo
- ✅ **Validação automática** de tamanhos e formatos

## 🚀 Instalação Rápida

```bash
# Clone o repositório
git clone https://github.com/bufala/icon-generator.git
cd icon-generator

# Execute o setup automático
chmod +x setup.sh
./setup.sh

# Ou instale manualmente
npm install
npm run build
```

## 📱 Uso

### Gerar Todos os Ícones
```bash
npm run generate-icons
```

### Gerar por Plataforma
```bash
# Android/Google Play
npm run generate-android

# iOS/App Store  
npm run generate-ios

# Web/PWA
npm run generate-web

# Microsoft Store
npm run generate-microsoft
```

### Uso Programático
```typescript
import { BuFalaIconGenerator } from './src/icon-generator';

const generator = new BuFalaIconGenerator();
await generator.generateAppIcon('./output');
```

## 📁 Estrutura de Saída

```
store_assets/
├── play_store/           # Google Play Store
│   ├── ic_launcher_512.png
│   ├── feature_graphic.png
│   └── tv_banner.png
├── app_store/            # Apple App Store
│   ├── app_icon_1024x1024.png
│   ├── Contents.json
│   └── ...
├── web/                  # Web/PWA
│   ├── manifest.json
│   ├── favicon-32x32.png
│   └── pwa-icon-512x512.png
├── microsoft_store/      # Microsoft Store
│   ├── StoreLogo_50x50.png
│   └── Square150x150Logo_150x150.png
└── promotional/          # Materiais promocionais
    ├── social_media_post.png
    ├── press_kit/
    └── screenshots/
```

## 🎨 Design System

### Cores Principais
- **Verde Primário**: `#2E7D32` 🟢
- **Verde Escuro**: `#1B5E20` 🟢
- **Azul Accent**: `#4FC3F7` 🔵

### Funcionalidades
- 🏥 **Medicina**: `#F44336` (Vermelho)
- 🎓 **Educação**: `#2196F3` (Azul)
- 🌱 **Agricultura**: `#4CAF50` (Verde)
- 💚 **Wellness**: `#9C27B0` (Roxo)
- 🌍 **Ambiental**: `#009688` (Teal)

## 🔧 Integração com Flutter

### 1. Copiar Assets
```bash
# Copiar ícones gerados para o projeto Flutter
cp -r store_assets/flutter_assets/* ../android_app/assets/
```

### 2. Atualizar pubspec.yaml
```yaml
flutter:
  assets:
    - assets/icons/
    - assets/icons/medical_icon.png
    - assets/icons/education_icon.png
    - assets/icons/agriculture_icon.png
    - assets/icons/wellness_icon.png
    - assets/icons/environmental_icon.png
```

### 3. Usar no Código
```dart
// Usando constantes geradas
import '../constants/bufala_icons.dart';

// Widget simples
BuFalaIcon(
  iconName: 'medical',
  size: BuFalaIconSizes.large,
  color: Colors.red,
)

// Widget com texto
BuFalaIconWithLabel(
  iconName: 'education',
  label: 'Educação',
  iconColor: Colors.blue,
)

// Usando extensão
'medical'.toBuFalaIcon(
  size: 32,
  color: Colors.red,
)
```

## 📱 Configuração por Plataforma

### Android
```bash
# Copiar ícones para projeto Android
cp store_assets/play_store/mipmap-*/* android_app/android/app/src/main/res/
```

### iOS
```bash
# Copiar para Xcode
cp store_assets/app_store/* android_app/ios/Runner/Assets.xcassets/AppIcon.appiconset/
```

### Web/PWA
```bash
# Copiar para web
cp store_assets/web/* android_app/web/
```

## 🎯 Funcionalidades Avançadas

### Geração de Mockups
```bash
# Gerar mockups de screenshots
npm run generate-mockups
```

### Validação de Ícones
```bash
# Validar todos os ícones gerados
npm run validate store_assets/
```

### Preview Rápido
```bash
# Gerar apenas preview dos ícones principais
npm run preview
```

## 🛠️ Desenvolvimento

### Estrutura do Projeto
```
src/
├── icon-generator.ts      # Gerador principal
├── flutter-integration.ts # Integração Flutter
├── generate-icons.ts      # CLI
└── __tests__/            # Testes
```

### Executar Testes
```bash
npm test
npm run test:watch
npm run test:coverage
```

### Linting e Formatação
```bash
npm run lint
npm run format
```

## 📋 Checklist de Publicação

### Google Play Store
- [x] Ícone 512x512 ✓
- [x] Gráfico de destaque 1024x500 ✓
- [x] Banner TV 1280x720 ✓
- [ ] Screenshots da aplicação
- [ ] Descrição em português/crioulo

### Apple App Store
- [x] Todos os tamanhos de ícone ✓
- [x] Contents.json configurado ✓
- [ ] Screenshots iPhone/iPad
- [ ] Descrição da aplicação

### Microsoft Store
- [x] Todos os logos necessários ✓
- [ ] Screenshots da aplicação
- [ ] Descrição detalhada

### Web/PWA
- [x] Manifest.json ✓
- [x] Favicons ✓
- [x] Ícones PWA ✓
- [ ] Service Worker
- [ ] Teste de instalação

## 🎨 Customização

### Modificar Cores
```typescript
// Editar em src/icon-generator.ts
const colors = {
  primary: '#2E7D32',      // Verde principal
  primaryDark: '#1B5E20',  // Verde escuro
  accent: '#4FC3F7',       // Azul accent
  // ...
};
```

### Adicionar Novos Ícones
```typescript
// Adicionar em createFeatureIconSvg()
const newFeatures = [
  { name: 'transport', icon: '🚗', color: '#FF5722' },
  { name: 'finance', icon: '💰', color: '#795548' },
];
```

### Modificar Tamanhos
```typescript
// Editar iconSets em BuFalaIconGenerator
android: {
  mipmap: {
    'mipmap-mdpi': [48, 64],    // Adicionar tamanho 64
    // ...
  }
}
```

## 🔍 Troubleshooting

### Erro com Sharp
```bash
# Reinstalar Sharp
npm rebuild sharp

# Ou instalar versão específica
npm install sharp@0.32.6
```

### Erro de Permissão
```bash
# Dar permissão ao script
chmod +x setup.sh

# Ou executar com sudo
sudo npm run generate-icons
```

### Canvas não Funciona
```bash
# Instalar dependências do sistema (Ubuntu/Debian)
sudo apt-get install build-essential libcairo2-dev libpango1.0-dev libjpeg-dev libgif-dev librsvg2-dev

# macOS
brew install pkg-config cairo pango libpng jpeg giflib librsvg
```

## 📊 Métricas de Performance

### Tamanhos Gerados
- **Total de ícones**: ~150 arquivos
- **Tamanho total**: ~15MB
- **Tempo de geração**: ~30 segundos
- **Formatos suportados**: PNG, SVG, ICO

### Otimizações
- ✅ Compressão PNG otimizada
- ✅ SVG minificado
- ✅ Geração paralela
- ✅ Cache de assets

## 🌍 Suporte a Idiomas

O gerador suporta textos em:
- 🇵🇹 **Português** (padrão)
- 🇬🇼 **Crioulo da Guiné-Bissau**
- 🇬🇧 **Inglês** (documentação)

## 📞 Suporte

### Documentação
- [Wiki do Projeto](https://github.com/bufala/icon-generator/wiki)
- [Guia de Contribuição](CONTRIBUTING.md)
- [Changelog](CHANGELOG.md)

### Contato
- **Email**: suporte@bufala.app
- **GitHub Issues**: [Reportar Bug](https://github.com/bufala/icon-generator/issues)
- **Discussions**: [Discussões](https://github.com/bufala/icon-generator/discussions)

## 🤝 Contribuição

1. **Fork** o projeto
2. **Crie** uma branch para sua feature (`git checkout -b feature/nova-funcionalidade`)
3. **Commit** suas mudanças (`git commit -am 'Adiciona nova funcionalidade'`)
4. **Push** para a branch (`git push origin feature/nova-funcionalidade`)
5. **Abra** um Pull Request

### Diretrizes
- Siga o padrão de código existente
- Adicione testes para novas funcionalidades
- Atualize a documentação
- Use commits semânticos

## 📄 Licença

Este projeto está licenciado sob a **MIT License** - veja o arquivo [LICENSE](LICENSE) para detalhes.

## 🙏 Agradecimentos

- **Comunidades da Guiné-Bissau** - Inspiração do projeto
- **Flutter Team** - Framework incrível
- **Sharp** - Processamento de imagens
- **Canvas** - Geração de gráficos

## 📈 Roadmap

### v1.1.0
- [ ] Suporte a ícones animados
- [ ] Geração de splash screens
- [ ] Integração com Figma
- [ ] Templates personalizáveis

### v1.2.0
- [ ] Interface web para geração
- [ ] API REST
- [ ] Integração com CI/CD
- [ ] Suporte a temas escuros

### v2.0.0
- [ ] Geração baseada em IA
- [ ] Otimização automática
- [ ] Análise de acessibilidade
- [ ] Suporte multi-idioma completo

---

**Feito com ❤️ para as comunidades da Guiné-Bissau**

Bu Fala - Conectando tecnologia com pessoas
```

Agora vou criar um arquivo de contribuição:

```markdown:CONTRIBUTING.md
# 🤝 Guia de Contribuição - Bu Fala Icon Generator

Obrigado por considerar contribuir com o Bu Fala Icon Generator! Este documento fornece diretrizes para contribuições.

## 🌟 Como Contribuir

### 1. Reportar Bugs
- Use o [template de bug report](https://github.com/bufala/icon-generator/issues/new?template=bug_report.md)
- Inclua informações do sistema (OS, Node.js, npm)
- Forneça passos para reproduzir o problema
- Adicione screenshots se aplicável

### 2. Sugerir Funcionalidades
- Use o [template de feature request](https://github.com/bufala/icon-generator/issues/new?template=feature_request.md)
- Explique o problema que a funcionalidade resolve
- Descreva a solução proposta
- Considere alternativas

### 3. Contribuir com Código

#### Setup do Ambiente
```bash
# Fork e clone o repositório
git clone https://github.com/SEU_USUARIO/icon-generator.git
cd icon-generator

# Instalar dependências
npm install

# Executar testes
npm test

# Executar em modo desenvolvimento
npm run dev
```

#### Padrões de Código
- Use **TypeScript** para todo código novo
- Siga o **ESLint** configurado
- Use **Prettier** para formatação
- Escreva **testes** para novas funcionalidades
- Documente **APIs públicas**

#### Commits Semânticos
```bash
# Formato
tipo(escopo): descrição

# Exemplos
feat(icons): adiciona suporte a ícones animados
fix(generator): corrige erro na geração de PNG
docs(readme): atualiza instruções de instalação
test(icons): adiciona testes para validação
refactor(core): melhora performance da geração
```

#### Pull Request
1. Crie uma branch descritiva
2. Faça commits pequenos e focados
3. Adicione/atualize testes
4. Atualize documentação
5. Execute `npm run lint` e `npm test`
6. Abra PR com descrição detalhada

## 🎨 Diretrizes de Design

### Cores
- Mantenha a paleta oficial do Bu Fala
- Use cores acessíveis (contraste adequado)
- Teste em diferentes temas (claro/escuro)

### Ícones
- Siga as diretrizes de Material Design
- Mantenha consistência visual
- Teste em diferentes tamanhos
- Considere acessibilidade

### Tipografia
- Use fontes do sistema quando possível
- Mantenha hierarquia clara
- Teste legibilidade em diferentes tamanhos

## 🧪 Testes

### Executar Testes
```bash
# Todos os testes
npm test

# Testes em modo watch
npm run test:watch

# Coverage
npm run test:coverage

# Testes específicos
npm test -- --testNamePattern="IconGenerator"
```

### Escrever Testes
```typescript
// Exemplo de teste
describe('IconGenerator', () => {
  test('should generate valid SVG', () => {
    const generator = new IconGenerator();
    const svg = generator.createIcon();
    
    expect(svg).toContain('<svg');
    expect(svg).toContain('</svg>');
  });
});
```

## 📚 Documentação

### Atualizar README
- Mantenha exemplos atualizados
- Adicione novas funcionalidades
- Verifique links quebrados

### Comentários no Código
```typescript
/**
 * Gera ícone para plataforma específica
 * @param platform - Plataforma alvo (android, ios, web)
 * @param size - Tamanho do ícone em pixels
 * @returns Buffer com dados da imagem
 */
async generateIcon(platform: string, size: number): Promise<Buffer> {
  // Implementação...
}
```

### JSDoc
- Use JSDoc para APIs públicas
- Inclua exemplos de uso
- Documente parâmetros e retornos

## 🔧 Ferramentas de Desenvolvimento

### Scripts Úteis
```bash
# Desenvolvimento
npm run dev          # Executa em modo desenvolvimento
npm run build        # Compila TypeScript
npm run clean        # Limpa arquivos gerados

# Qualidade
npm run lint         # Executa ESLint
npm run format       # Formata código com Prettier
npm run type-check   # Verifica tipos TypeScript

# Testes
npm test             # Executa testes
npm run test:watch   # Testes em modo watch
npm run test:coverage # Gera relatório de coverage
```

### Extensões VS Code Recomendadas
- TypeScript and JavaScript Language Features
- ESLint
- Prettier
- Jest
- GitLens

## 🌍 Internacionalização

### Adicionar Novo Idioma
1. Crie arquivo de tradução em `src/i18n/`
2. Adicione ao sistema de carregamento
3. Teste com diferentes locales
4. Atualize documentação

### Diretrizes de Tradução
- Mantenha contexto cultural
- Use termos técnicos apropriados
- Teste com falantes nativos
- Considere diferenças regionais

## 🚀 Release Process

### Versionamento
Seguimos [Semantic Versioning](https://semver.org/):
- **MAJOR**: Mudanças incompatíveis
- **MINOR**: Novas funcionalidades compatíveis
- **PATCH**: Correções de bugs

### Checklist de Release
- [ ] Todos os testes passando
- [ ] Documentação atualizada
- [ ] CHANGELOG.md atualizado
- [ ] Versão bumped em package.json
- [ ] Tag criada no Git
- [ ] Release notes escritas

## 🎯 Áreas que Precisam de Ajuda

### Alta Prioridade
- 🐛 Correção de bugs reportados
- 📱 Suporte a novas plataformas
- 🎨 Melhorias de design
- 📚 Documentação

### Média Prioridade
- ⚡ Otimizações de performance
- 🧪 Mais testes
- 🌍 Traduções
- 🔧 Ferramentas de desenvolvimento

### Baixa Prioridade
- 🎉 Funcionalidades experimentais
- 📊 Métricas e analytics
- 🎨 Temas personalizáveis
- 🤖 Automações

