#!/usr/bin/env node

import { BuFalaIconGenerator, generateBuFalaIcons } from './icon-generator.js';
import { FlutterIntegration } from './flutter-integration.js';
import { generateBuFalaStoreIcons } from './icon-generator.js';

interface CLIOptions {
  command: string;
  outputDir?: string;
  projectPath?: string;
  includeAnimated?: boolean;
  includeVariations?: boolean;
  generatePreview?: boolean;
  help?: boolean;
}

class BuFalaCLI {
  private parseArgs(args: string[]): CLIOptions {
    const options: CLIOptions = {
      command: args[0] || 'help',
      includeAnimated: true,
      includeVariations: true,
      generatePreview: true
    };

    for (let i = 1; i < args.length; i++) {
      const arg = args[i];
      
      if (arg.startsWith('--output=')) {
        options.outputDir = arg.split('=')[1];
      } else if (arg.startsWith('--project=')) {
        options.projectPath = arg.split('=')[1];
      } else if (arg === '--no-animated') {
        options.includeAnimated = false;
      } else if (arg === '--no-variations') {
        options.includeVariations = false;
      } else if (arg === '--no-preview') {
        options.generatePreview = false;
      } else if (arg === '--help' || arg === '-h') {
        options.help = true
      }
    }

    return options;
  }

  private showHelp(): void {
    console.log(`
🌍 Bu Fala Icon Generator CLI

COMANDOS:
  generate        Gera todos os ícones básicos
  generate-all    Gera ícones completos com variações
  store-icons     Gera ícones para lojas de aplicativos
  flutter-setup   Configura integração com projeto Flutter
  help           Mostra esta ajuda

OPÇÕES:
  --output=DIR          Diretório de saída (padrão: ./bu_fala_icons)
  --project=PATH        Caminho do projeto Flutter (padrão: ../android_app)
  --no-animated         Não gerar ícones animados
  --no-variations       Não gerar variações de estilo
  --no-preview          Não gerar arquivos de preview
  --help, -h            Mostra esta ajuda

EXEMPLOS:
  # Gerar ícones básicos
  npm run cli generate

  # Gerar ícones completos em diretório específico
  npm run cli generate-all --output=./meus_icones

  # Gerar apenas ícones para lojas
  npm run cli store-icons --output=./store_assets

  # Configurar projeto Flutter
  npm run cli flutter-setup --project=../meu_projeto_flutter

  # Gerar sem animações e variações
  npm run cli generate --no-animated --no-variations

ESTRUTURA DE SAÍDA:
  📁 assets/
    ├── 📄 app_icon.svg (ícone principal)
    ├── 📁 icons/ (ícones de funcionalidades)
    ├── 📁 flat_style/ (estilo flat)
    ├── 📁 gradient_style/ (estilo gradient)
    ├── 📁 outline_style/ (estilo outline)
    ├── 📁 glass_style/ (estilo glass)
    └── 📁 animated_frames/ (frames de animação)
  
  📁 store_assets/
    ├── 📁 android/ (ícones Android)
    ├── 📁 ios/ (ícones iOS)
    ├── 📁 web/ (ícones Web/PWA)
    └── 📁 windows/ (ícones Windows)
  
  📁 output/
    ├── 📄 README.md (documentação)
    ├── 📄 preview.html (preview básico)
    ├── 📄 expanded_preview.html (preview completo)
    └── 📄 generation_report.json (relatório)

SOBRE O BU FALA:
  Bu Fala é um sistema de IA para comunidades da Guiné-Bissau,
  oferecendo primeiros socorros, educação, agricultura e bem-estar.

SUPORTE:
  📧 suporte@bufala.app
  🌐 https://docs.bufala.app
  📱 https://github.com/bufala/android_app
`);
  }

  async run(args: string[]): Promise<void> {
    const options = this.parseArgs(args);

    if (options.help || options.command === 'help') {
      this.showHelp();
      return;
    }

    console.log('🌍 Bu Fala Icon Generator CLI');
    console.log('=====================================\n');

    try {
      switch (options.command) {
        case 'generate':
          await this.generateBasicIcons(options);
          break;
        
        case 'generate-all':
          await this.generateAllIcons(options);
          break;
        
        case 'store-icons':
          await this.generateStoreIcons(options);
          break;
        
        case 'flutter-setup':
          await this.setupFlutterIntegration(options);
          break;
        
        default:
          console.error(`❌ Comando desconhecido: ${options.command}`);
          console.log('Use "help" para ver comandos disponíveis.');
          process.exit(1);
      }

      console.log('\n🎉 Operação concluída com sucesso!');
      
    } catch (error) {
      console.error('\n💥 Erro durante a execução:', error);
      process.exit(1);
    }
  }

  private async generateBasicIcons(options: CLIOptions): Promise<void> {
    console.log('📱 Gerando ícones básicos...\n');
    
    await generateBuFalaIcons({
      outputDir: options.outputDir,
      includeAnimated: options.includeAnimated,
      includeVariations: false, // Básico não inclui variações
      generatePreview: options.generatePreview
    });
  }

  private async generateAllIcons(options: CLIOptions): Promise<void> {
    console.log('🎨 Gerando pacote completo de ícones...\n');
    
    await generateBuFalaIcons({
      outputDir: options.outputDir,
      includeAnimated: options.includeAnimated,
      includeVariations: options.includeVariations,
      generatePreview: options.generatePreview
    });
  }

  private async generateStoreIcons(options: CLIOptions): Promise<void> {
    console.log('🏪 Gerando ícones para lojas de aplicativos...\n');
    
    await generateBuFalaStoreIcons(options.outputDir || './store_assets');
  }

  private async setupFlutterIntegration(options: CLIOptions): Promise<void> {
    console.log('🔗 Configurando integração com Flutter...\n');
    
    const integration = new FlutterIntegration(options.projectPath);
    
    // Primeiro gerar os ícones se não existirem
    console.log('1️⃣ Verificando ícones...');
    try {
      await generateBuFalaIcons({
        outputDir: './temp_icons',
        includeAnimated: false,
        includeVariations: false,
        generatePreview: false
      });
      console.log('✓ Ícones gerados');
    } catch (error) {
      console.log('⚠️ Usando ícones existentes');
    }

    // Integrar com Flutter
    console.log('2️⃣ Integrando com Flutter...');
    await integration.integrateIcons();
    
    // Gerar exemplos
    console.log('3️⃣ Gerando exemplos...');
    await integration.generateUsageExamples();
    
    console.log('✅ Integração Flutter concluída!');
  }
}

// Função principal
async function main(): Promise<void> {
  const cli = new BuFalaCLI();
  const args = process.argv.slice(2);
  
  if (args.length === 0) {
    args.push('help');
  }
  
  await cli.run(args);
}

// Executar se chamado diretamente
if (require.main === module) {
  main().catch((error) => {
    console.error('💥 Erro fatal:', error);
    process.exit(1);
  });
}

export { BuFalaCLI, main };
