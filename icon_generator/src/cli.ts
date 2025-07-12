import { program } from 'commander';
import { generateBuFalaIcons } from './icon-generator.js';
import { FlutterIntegration } from './flutter-integration.js';

interface CLIOptions {
  output?: string;
  project?: string;
  animated?: boolean;
  variations?: boolean;
  preview?: boolean;
}

program
  .name('bufala-icons')
  .description('Gerador de ícones para o sistema Bu Fala')
  .version('1.0.0');

program
  .command('generate')
  .description('Gera ícones básicos')
  .option('-o, --output <dir>', 'Diretório de saída', './bu_fala_icons')
  .option('--no-animated', 'Não gerar ícones animados')
  .option('--no-variations', 'Não gerar variações de estilo')
  .option('--no-preview', 'Não gerar preview HTML')
  .action(async (options: CLIOptions) => {
    try {
      const opts: any = {};
      if (options.output !== undefined) opts.outputDir = options.output;
      if (options.animated !== undefined) opts.includeAnimated = options.animated;
      opts.includeVariations = false;
      if (options.preview !== undefined) opts.generatePreview = options.preview;
      await generateBuFalaIcons(opts);
      console.log('✅ Ícones básicos gerados com sucesso!');
    } catch (error) {
      console.error('❌ Erro:', error);
      process.exit(1);
    }
  });

program
  .command('generate-all')
  .description('Gera pacote completo de ícones')
  .option('-o, --output <dir>', 'Diretório de saída', './bu_fala_icons')
  .option('--no-animated', 'Não gerar ícones animados')
  .option('--no-variations', 'Não gerar variações de estilo')
  .option('--no-preview', 'Não gerar preview HTML')
  .action(async (options: CLIOptions) => {
    try {
      const opts: any = {};
      if (options.output !== undefined) opts.outputDir = options.output;
      if (options.animated !== undefined) opts.includeAnimated = options.animated;
      if (options.variations !== undefined) opts.includeVariations = options.variations;
      if (options.preview !== undefined) opts.generatePreview = options.preview;
      await generateBuFalaIcons(opts);
      console.log('✅ Pacote completo gerado com sucesso!');
    } catch (error) {
      console.error('❌ Erro:', error);
      process.exit(1);
    }
  });

// Comando store-icons removido pois generateBuFalaStoreIcons não existe mais

program
  .command('flutter-setup')
  .description('Configura integração com projeto Flutter')
  .option('-p, --project <path>', 'Caminho do projeto Flutter', '../android_app')
  .action(async (options: CLIOptions) => {
    try {
      const integration = new FlutterIntegration(options.project);
      await integration.integrateIcons();
      await integration.generateUsageExamples();
      console.log('✅ Integração Flutter configurada com sucesso!');
    } catch (error) {
      console.error('❌ Erro:', error);
      process.exit(1);
    }
  });

program.parse();
