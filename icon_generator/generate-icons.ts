#!/usr/bin/env node

import { BuFalaStoreIconGenerator } from './icon-generator';
import { program } from 'commander';
import path from 'path';

program
  .name('bu-fala-icon-generator')
  .description('Gerador de ícones para lojas do Bu Fala')
  .version('1.0.0');

program
  .command('generate')
  .description('Gera todos os ícones para lojas')
  .option('-o, --output <dir>', 'Diretório de saída', './store_assets')
  .option('-p, --platform <platform>', 'Plataforma específica (play-store, app-store, web, microsoft)')
  .option('--high-quality', 'Gera ícones em alta qualidade (mais lento)')
  .action(async (options) => {
    console.log('🎨 Bu Fala Icon Generator v1.0.0\n');
    
    const generator = new BuFalaStoreIconGenerator();
    const outputDir = path.resolve(options.output);
    
    try {
      if (options.platform) {
        console.log(`📱 Gerando ícones para: ${options.platform}`);
        
        switch (options.platform.toLowerCase()) {
          case 'play-store':
          case 'android':
            await generator['generatePlayStoreIcons'](outputDir);
            break;
          case 'app-store':
          case 'ios':
            await generator['generateAppStoreIcons'](outputDir);
            break;
          case 'web':
          case 'pwa':
            await generator['generateWebStoreIcons'](outputDir);
            break;
          case 'microsoft':
          case 'windows':
            await generator['generateMicrosoftStoreIcons'](outputDir);
            break;
          default:
            console.error(`❌ Plataforma não suportada: ${options.platform}`);
            process.exit(1);
        }
      } else {
        await generator.generateAllStoreAssets(outputDir);
      }
      
    } catch (error) {
      console.error('❌ Erro durante a geração:', error);
      process.exit(1);
    }
  });

program
  .command('preview')
  .description('Gera preview dos ícones principais')
  .option('-o, --output <dir>', 'Diretório de saída', './preview')
  .action(async (options) => {
    console.log('👀 Gerando preview dos ícones...\n');
    
    // Implementar preview simples
    const generator = new BuFalaStoreIconGenerator();
    // Gerar apenas os ícones principais para preview rápido
    console.log('Preview não implementado ainda. Use "generate" para ver todos os ícones.');
  });

program
  .command('validate')
  .description('Valida os ícones gerados')
  .argument('<dir>', 'Diretório com os ícones')
  .action(async (dir) => {
    console.log(`🔍 Validando ícones em: ${dir}\n`);
    
    // Implementar validação
    console.log('Validação não implementada ainda.');
  });

// Parse dos argumentos
program.parse();
