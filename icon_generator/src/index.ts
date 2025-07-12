import { BuFalaIconGenerator } from './icon-generator';
import { FlutterIntegration } from './flutter-integration';
import { HTMLPreviewGenerator } from './html-generator';

async function main() {
  console.log('🎨 Iniciando geração completa de ícones Bu Fala...\n');
  
  const generator = new BuFalaIconGenerator();
  const flutterIntegration = new FlutterIntegration();
  const htmlGenerator = new HTMLPreviewGenerator();
  
  try {
    // 1. Gerar todos os ícones para lojas
    console.log('📱 Gerando ícones para lojas de aplicativos...');
    await generator.generateAllStoreAssets('./store_assets');
    
    // 2. Gerar ícones básicos para o projeto
    console.log('\n🎯 Gerando ícones básicos do projeto...');
    await generator.generateIconPack();
    
    // 3. Integrar com Flutter
    console.log('\n🔗 Integrando com projeto Flutter...');
    await flutterIntegration.integrateIcons();
    await flutterIntegration.generateUsageExamples();
    
    // 4. Gerar preview HTML
    console.log('\n🌐 Gerando preview HTML...');
    await htmlGenerator.generateCompletePreview('./preview');
    
    console.log('\n✅ Todos os ícones foram gerados com sucesso!');
    console.log('\n📋 Resumo dos arquivos gerados:');
    console.log('  📁 ./store_assets/ - Ícones para lojas');
    console.log('  📁 ./assets/ - Ícones SVG principais');
    console.log('  📁 ./output/ - Documentação');
    console.log('  📁 ../android_app/assets/icons/ - Ícones Flutter');
    console.log('  📁 ./preview/ - Preview HTML');
    
  } catch (error) {
    console.error('❌ Erro ao gerar ícones:', error);
    process.exit(1);
  }
}

// Esta é a única verificação que mantemos
main().catch(console.error);
