import sharp from 'sharp';
import * as fs from 'fs/promises';
import * as path from 'path';

interface FeatureIcon {
  name: string;
  symbol: string;
  color: string;
  description: string;
}

interface AppIconSet {
  android: {
    mipmap: { [key: string]: number[] };
    drawable: { [key: string]: number[] };
  };
  ios: {
    appIcon: { [key: string]: number };
  };
  web: {
    favicon: number[];
    pwa: number[];
  };
}

class BuFalaIconGenerator {
  private readonly iconSets: AppIconSet = {
    android: {
      mipmap: {
        'mipmap-mdpi': [48],
        'mipmap-hdpi': [72],
        'mipmap-xhdpi': [96],
        'mipmap-xxhdpi': [144],
        'mipmap-xxxhdpi': [192]
      },
      drawable: {
        'drawable-mdpi': [24, 32],
        'drawable-hdpi': [36, 48],
        'drawable-xhdpi': [48, 64],
        'drawable-xxhdpi': [72, 96],
        'drawable-xxxhdpi': [96, 128]
      }
    },
    ios: {
      appIcon: {
        'icon-20': 20,
        'icon-29': 29,
        'icon-40': 40,
        'icon-58': 58,
        'icon-60': 60,
        'icon-80': 80,
        'icon-87': 87,
        'icon-120': 120,
        'icon-180': 180,
        'icon-1024': 1024
      }
    },
    web: {
      favicon: [16, 32, 48],
      pwa: [72, 96, 128, 144, 152, 192, 384, 512]
    }
  };

  private readonly featureIcons: FeatureIcon[] = [
    { name: 'medical', symbol: '🏥', color: '#F44336', description: 'Primeiros Socorros' },
    { name: 'education', symbol: '📚', color: '#2196F3', description: 'Educação' },
    { name: 'agriculture', symbol: '🌱', color: '#4CAF50', description: 'Agricultura' },
    { name: 'wellness', symbol: '🧘', color: '#9C27B0', description: 'Bem-estar' },
    { name: 'environmental', symbol: '🌍', color: '#009688', description: 'Meio Ambiente' },
    { name: 'emergency', symbol: '🚨', color: '#FF5722', description: 'Emergência' },
    { name: 'translate', symbol: '🗣️', color: '#FF9800', description: 'Tradução' },
    { name: 'camera', symbol: '📷', color: '#607D8B', description: 'Câmera' }
  ];

  // ========================================
  // MÉTODOS PRINCIPAIS
  // ========================================

  async generateAppIcon(outputDir: string = './bu_fala_icons'): Promise<void> {
    console.log('🎨 Gerando ícones do Bu Fala...');
    try {
      await this.ensureDirectories();
      
      const mainIconSvg = this.createMainIconSvg();
      await fs.writeFile(path.join(outputDir, 'app_icon.svg'), mainIconSvg);
      
      // Gerar versão PNG
      const pngBuffer = await sharp(Buffer.from(mainIconSvg))
        .resize(512, 512)
        .png({ quality: 100 })
        .toBuffer();
      
      await fs.writeFile(path.join(outputDir, 'app_icon.png'), pngBuffer);
      
      await this.generateAndroidIcons();
      await this.generateIOSIcons();
      await this.generateFeatureIcons();
      await this.generateWebIcons();
      
      console.log('✅ Ícones gerados com sucesso!');
    } catch (error) {
      console.error('❌ Erro ao gerar ícones:', error);
      throw error;
    }
  }

  async generateIconPack(): Promise<void> {
    console.log('📦 Criando pacote completo de ícones...');
    
    try {
      await this.ensureDirectories();
      await this.generateAppIcon();
      await this.generateStoreAssets();
      
      const readme = this.createIconReadme();
      await fs.writeFile('output/README.md', readme);
      
      const flutterAssets = this.createFlutterAssetsConfig();
      await fs.writeFile('output/flutter_assets.yaml', flutterAssets);
      
      console.log('🎉 Pacote de ícones completo gerado!');
    } catch (error) {
      console.error('❌ Erro ao gerar pacote:', error);
      throw error;
    }
  }

  // ========================================
  // GERADO DE LOJAS
  // ========================================

    async generateAllStoreAssets(outputDir: string = './store_assets'): Promise<void> {
    console.log('🏪 Gerando todos os assets para lojas...\n');
    
    try {
      await fs.mkdir(outputDir, { recursive: true });
      
      // Gerar ícones básicos
      await this.generateIconPack();
      
      // Gerar ícones para lojas
      await this.generateStoreIcons(outputDir);
      
      console.log('✅ Todos os assets foram gerados com sucesso!');
      
    } catch (error) {
      console.error('❌ Erro ao gerar assets:', error);
      throw error;
    }
  }

  private async generateStoreIcons(outputDir: string): Promise<void> {
    console.log('📱 Gerando ícones para lojas...');
    
    const mainIconSvg = this.createMainIconSvg();
    
    // Play Store
    const playStoreDir = path.join(outputDir, 'play_store');
    await fs.mkdir(playStoreDir, { recursive: true });
    
    const playStoreIcon = await sharp(Buffer.from(mainIconSvg))
      .resize(512, 512)
      .png()
      .toBuffer();
    
    await fs.writeFile(path.join(playStoreDir, 'ic_launcher_512.png'), playStoreIcon);
    
    // App Store
    const appStoreDir = path.join(outputDir, 'app_store');
    await fs.mkdir(appStoreDir, { recursive: true });
    
    const appStoreIcon = await sharp(Buffer.from(mainIconSvg))
      .resize(1024, 1024)
      .png()
      .toBuffer();
    
    await fs.writeFile(path.join(appStoreDir, 'app_icon_1024.png'), appStoreIcon);
    
    console.log('✓ Ícones para lojas gerados');
  }

  // ========================================
  // UTILITÁRIOS
  // ========================================

  private async ensureDirectories(): Promise<void> {
    const directories = [
      'assets',
      'assets/icons',
      'output',
      'store_assets',
      'store_assets/android',
      'store_assets/android/app',
      'store_assets/android/app/src',
      'store_assets/android/app/src/main',
      'store_assets/android/app/src/main/res',
      'store_assets/ios',
      'store_assets/web',
      'store_assets/flutter',
      'store_assets/flutter/assets',
      'store_assets/flutter/assets/icons'
    ];
    
    for (const dir of directories) {
      await fs.mkdir(dir, { recursive: true });
    }
  }

  // ========================================
  // CRIAÇÃO DE SVGs
  // ========================================

  private createMainIconSvg(): string {
    return `
<svg width="512" height="512" viewBox="0 0 512 512" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <linearGradient id="bgGradient" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" style="stop-color:#2E7D32;stop-opacity:1" />
      <stop offset="50%" style="stop-color:#388E3C;stop-opacity:1" />
      <stop offset="100%" style="stop-color:#1B5E20;stop-opacity:1" />
    </linearGradient>
    <linearGradient id="globeGradient" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" style="stop-color:#4FC3F7;stop-opacity:1" />
      <stop offset="100%" style="stop-color:#0277BD;stop-opacity:1" />
    </linearGradient>
    <filter id="dropShadow">
      <feDropShadow dx="2" dy="4" stdDeviation="4" flood-color="#000000" flood-opacity="0.3"/>
    </filter>
  </defs>
  
  <!-- Background Circle -->
  <circle cx="256" cy="256" r="240" fill="url(#bgGradient)" stroke="#1B5E20" stroke-width="8" filter="url(#dropShadow)"/>
  
  <!-- Globe/Earth -->
  <circle cx="256" cy="200" r="80" fill="url(#globeGradient)" stroke="#0277BD" stroke-width="3"/>
  
  <!-- Continents on Globe -->
  <path d="M200 180 Q220 160 240 180 Q260 170 280 190 Q270 210 250 200 Q230 220 210 200 Z" fill="#2E7D32" opacity="0.8"/>
  <path d="M220 200 Q240 190 260 200 Q280 195 300 210 Q290 230 270 220 Q250 240 230 220 Z" fill="#2E7D32" opacity="0.8"/>
  
  <!-- Medical Cross -->
  <g transform="translate(180, 300)">
    <circle cx="26" cy="26" r="22" fill="#FF5252" opacity="0.2"/>
    <rect x="20" y="10" width="12" height="32" fill="#FF5252" rx="2"/>
    <rect x="10" y="20" width="32" height="12" fill="#FF5252" rx="2"/>
  </g>
  
  <!-- Education Book -->
  <g transform="translate(280, 300)">
    <circle cx="22" cy="22" r="22" fill="#1976D2" opacity="0.2"/>
    <rect x="8" y="12" width="28" height="20" fill="#1976D2" rx="3"/>
    <rect x="10" y="14" width="24" height="16" fill="#FFFFFF" rx="1"/>
    <line x1="12" y1="18" x2="30" y2="18" stroke="#1976D2" stroke-width="1.5"/>
    <line x1="12" y1="22" x2="26" y2="22" stroke="#1976D2" stroke-width="1.5"/>
    <line x1="12" y1="26" x2="28" y2="26" stroke="#1976D2" stroke-width="1.5"/>
  </g>
  
  <!-- Agriculture Plant -->
  <g transform="translate(220, 350)">
    <circle cx="25" cy="20" r="22" fill="#4CAF50" opacity="0.2"/>
    <path d="M25 25 Q15 15 10 5 Q20 10 25 15 Q30 10 40 5 Q35 15 25 25" fill="#4CAF50"/>
    <path d="M25 25 Q20 20 15 10 Q25 15 25 20 Q25 15 35 10 Q30 20 25 25" fill="#66BB6A"/>
    <rect x="23" y="25" width="4" height="12" fill="#8BC34A"/>
  </g>
  
  <!-- Speech Bubble for "Bu Fala" -->
  <g transform="translate(300, 120)">
    <ellipse cx="40" cy="20" rx="38" ry="20" fill="#FFFFFF" stroke="#2E7D32" stroke-width="2" filter="url(#dropShadow)"/>
    <path d="M15 32 L25 27 L30 37 Z" fill="#FFFFFF" stroke="#2E7D32" stroke-width="2"/>
    <text x="40" y="26" text-anchor="middle" font-family="Arial, sans-serif" font-size="14" font-weight="bold" fill="#2E7D32">Bu Fala</text>
  </g>
  
  <!-- Bottom text -->
  <text x="256" y="450" text-anchor="middle" font-family="Arial, sans-serif" font-size="16" font-weight="500" fill="#FFFFFF" opacity="0.9">
    IA para Comunidades
  </text>
</svg>`;
  }

  private createFeatureIconSvg(feature: FeatureIcon): string {
    return `
<svg width="64" height="64" viewBox="0 0 64 64" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <linearGradient id="grad_${feature.name}" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" style="stop-color:${feature.color};stop-opacity:0.8" />
      <stop offset="100%" style="stop-color:${feature.color};stop-opacity:1" />
    </linearGradient>
    <filter id="shadow_${feature.name}">
      <feDropShadow dx="1" dy="2" stdDeviation="2" flood-color="#000000" flood-opacity="0.2"/>
    </filter>
  </defs>
  <circle cx="32" cy="32" r="28" fill="url(#grad_${feature.name})" stroke="${feature.color}" stroke-width="2" filter="url(#shadow_${feature.name})"/>
  <circle cx="32" cy="32" r="20" fill="${feature.color}" opacity="0.1"/>
  <text x="32" y="40" text-anchor="middle" font-size="18" fill="#FFFFFF" font-weight="bold">${feature.symbol}</text>
</svg>`;
  }

  // ========================================
  // GERAÇÃO DE ÍCONES ANDROID
  // ========================================

  private async generateAndroidIcons(): Promise<void> {
    console.log('📱 Gerando ícones Android...');
    
    const svgBuffer = Buffer.from(this.createMainIconSvg());
    
    for (const [folder, sizes] of Object.entries(this.iconSets.android.mipmap)) {
      const dir = path.join('store_assets', 'android', 'app', 'src', 'main', 'res', folder);
      await fs.mkdir(dir, { recursive: true });
      
      for (const size of sizes) {
        const pngBuffer = await sharp(svgBuffer)
          .resize(size, size)
          .png({ quality: 100 })
          .toBuffer();
        
        await fs.writeFile(path.join(dir, 'ic_launcher.png'), pngBuffer);
        console.log(`✓ ${folder}/ic_launcher.png (${size}x${size})`);
      }
    }
    
    await this.generateAdaptiveIcons();
  }

  private async generateAdaptiveIcons(): Promise<void> {
    const drawableDir = path.join('store_assets', 'android', 'app', 'src', 'main', 'res', 'drawable');
    await fs.mkdir(drawableDir, { recursive: true });
    
    const foregroundXml = `<?xml version="1.0" encoding="utf-8"?>
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="108dp"
    android:height="108dp"
    android:viewportWidth="108"
    android:viewportHeight="108">
    <group android:scaleX="0.6" android:scaleY="0.6" android:pivotX="54" android:pivotY="54">
        <path android:fillColor="#4FC3F7" 
              android:pathData="M54,30 C66,30 76,40 76,52 C76,64 66,74 54,74 C42,74 32,64 32,52 C32,40 42,30 54,30 Z"/>
        <path android:fillColor="#2E7D32" 
              android:pathData="M45,45 Q50,40 55,45 Q60,42 65,48 Q60,54 55,52 Q50,58 45,54 Q40,50 45,45 Z"/>
        <path android:fillColor="#FF5252"
              android:pathData="M40,65 L44,65 L44,75 L40,75 Z M38,67 L46,67 L46,71 L38,71 Z"/>
    </group>
</vector>`;

    const backgroundXml = `<?xml version="1.0" encoding="utf-8"?>
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="108dp"
    android:height="108dp"
    android:viewportWidth="108"
    android:viewportHeight="108">
    <path android:fillColor="#2E7D32"
          android:pathData="M0,0h108v108h-108z"/>
    <path android:fillColor="#388E3C"
          android:pathData="M54,54m-50,0a50,50 0,1 1,100 0a50,50 0,1 1,-100 0"/>
</vector>`;

    await fs.writeFile(path.join(drawableDir, 'ic_launcher_foreground.xml'), foregroundXml);
    await fs.writeFile(path.join(drawableDir, 'ic_launcher_background.xml'), backgroundXml);
    console.log('✓ Adaptive icons gerados');
  }

  // ========================================
  // GERAÇÃO DE ÍCONES iOS
  // ========================================

  private async generateIOSIcons(): Promise<void> {
    console.log('🍎 Gerando ícones iOS...');
    
    const iosDir = path.join('store_assets', 'ios');
    await fs.mkdir(iosDir, { recursive: true });
    
    const svgBuffer = Buffer.from(this.createMainIconSvg());
    
    for (const [name, size] of Object.entries(this.iconSets.ios.appIcon)) {
      const pngBuffer = await sharp(svgBuffer)
        .resize(size, size)
        .png({ quality: 100 })
        .toBuffer();
      
      await fs.writeFile(path.join(iosDir, `${name}.png`), pngBuffer);
      console.log(`✓ ${name}.png (${size}x${size})`);
    }
  }

  // ========================================
  // GERAÇÃO DE ÍCONES WEB
  // ========================================

  private async generateWebIcons(): Promise<void> {
    console.log('🌐 Gerando ícones web...');
    
    const webDir = path.join('store_assets', 'web');
    await fs.mkdir(webDir, { recursive: true });
    
    const svgBuffer = Buffer.from(this.createMainIconSvg());

    // Favicons
    for (const size of this.iconSets.web.favicon) {
      const pngBuffer = await sharp(svgBuffer)
        .resize(size, size)
        .png({ quality: 100 })
        .toBuffer();
      
      await fs.writeFile(path.join(webDir, `favicon-${size}x${size}.png`), pngBuffer);
      console.log(`✓ favicon-${size}x${size}.png`);
    }

    // PWA icons
    for (const size of this.iconSets.web.pwa) {
      const pngBuffer = await sharp(svgBuffer)
        .resize(size, size)
        .png({ quality: 100 })
        .toBuffer();
      
      await fs.writeFile(path.join(webDir, `pwa-icon-${size}x${size}.png`), pngBuffer);
      console.log(`✓ pwa-icon-${size}x${size}.png`);
    }

    // Web manifest
    const manifest = this.generateWebManifest();
    await fs.writeFile(path.join(webDir, 'manifest.json'), JSON.stringify(manifest, null, 2));
    console.log('✓ Web manifest gerado');
  }

  // ========================================
  // GERAÇÃO DE ÍCONES DE FUNCIONALIDADES
  // ========================================

  private async generateFeatureIcons(): Promise<void> {
    console.log('🎯 Gerando ícones de funcionalidades...');
    
    const assetsDir = path.join('store_assets', 'flutter', 'assets', 'icons');
    await fs.mkdir(assetsDir, { recursive: true });

    for (const feature of this.featureIcons) {
      const svg = this.createFeatureIconSvg(feature);
      await fs.writeFile(path.join(assetsDir, `${feature.name}_icon.svg`), svg);
      
      // Generate PNG versions
      const pngBuffer = await sharp(Buffer.from(svg))
        .resize(64, 64)
        .png({ quality: 100 })
        .toBuffer();
      
      await fs.writeFile(path.join(assetsDir, `${feature.name}_icon.png`), pngBuffer);
      console.log(`✓ ${feature.name}_icon.png`);
    }
  }

  // ========================================
  // GERAÇÃO DE ASSETS PARA LOJAS
  // ========================================

  private async generateStoreAssets(): Promise<void> {
    console.log('🏪 Gerando assets para lojas...');
    
    await this.generatePlayStoreAssets();
    await this.generateAppStoreAssets();
  }

  private async generatePlayStoreAssets(): Promise<void> {
    const playStoreDir = path.join('store_assets', 'play_store');
    await fs.mkdir(playStoreDir, { recursive: true });
    
    const mainIconSvg = this.createMainIconSvg();
    
    // App icon 512x512
    const appIconBuffer = await sharp(Buffer.from(mainIconSvg))
      .resize(512, 512)
      .png({ quality: 100 })
      .toBuffer();
    
    await fs.writeFile(path.join(playStoreDir, 'ic_launcher_512.png'), appIconBuffer);
    
    // Feature graphic 1024x500
    const featureGraphicSvg = this.createFeatureGraphicSvg();
    const featureGraphicBuffer = await sharp(Buffer.from(featureGraphicSvg))
      .resize(1024, 500)
      .png({ quality: 100 })
      .toBuffer();
    
    await fs.writeFile(path.join(playStoreDir, 'feature_graphic.png'), featureGraphicBuffer);
    
    console.log('✓ Play Store assets gerados');
  }

  private async generateAppStoreAssets(): Promise<void> {
    const appStoreDir = path.join('store_assets', 'app_store');
    await fs.mkdir(appStoreDir, { recursive: true });
    
    // App Store icon 1024x1024
    const mainIconSvg = this.createMainIconSvg();
    const appStoreIconBuffer = await sharp(Buffer.from(mainIconSvg))
      .resize(1024, 1024)
      .png({ quality: 100 })
      .toBuffer();
    
    await fs.writeFile(path.join(appStoreDir, 'app_store_icon_1024.png'), appStoreIconBuffer);
    
    console.log('✓ App Store assets gerados');
  }

  // ========================================
  // CRIAÇÃO DE SVGs ESPECIAIS
  // ========================================

  private createFeatureGraphicSvg(): string {
    return `
<svg width="1024" height="500" viewBox="0 0 1024 500" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <linearGradient id="bgGradient" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" style="stop-color:#2E7D32;stop-opacity:1" />
      <stop offset="100%" style="stop-color:#1B5E20;stop-opacity:1" />
    </linearGradient>
  </defs>
  
  <!-- Background -->
  <rect width="1024" height="500" fill="url(#bgGradient)"/>
  
  <!-- App Icon -->
  <g transform="translate(50, 150)">
    <circle cx="100" cy="100" r="80" fill="#4FC3F7"/>
    <path d="M70 80 Q85 65 100 80 Q115 75 130 90 Q115 105 100 100 Q85 115 70 100 Q55 90 70 80" fill="#2E7D32"/>
  </g>
  
  <!-- Title -->
  <text x="250" y="200" font-family="Arial, sans-serif" font-size="48" font-weight="bold" fill="#FFFFFF">
    Bu Fala
  </text>
  
  <!-- Subtitle -->
  <text x="250" y="240" font-family="Arial, sans-serif" font-size="24" fill="#FFFFFF" opacity="0.9">
    Sistema de IA para Comunidades da Guiné-Bissau
  </text>
  
  <!-- Features -->
  <g transform="translate(250, 280)">
    <text x="0" y="0" font-family="Arial, sans-serif" font-size="18" fill="#FFFFFF">
      🏥 Primeiros Socorros  •  🎓 Educação  •  🌱 Agricultura  •  💚 Bem-estar
    </text>
  </g>
  
  <!-- Right side illustration -->
  <g transform="translate(700, 100)">
    <circle cx="100" cy="100" r="80" fill="#4FC3F7" opacity="0.3"/>
    <circle cx="50" cy="50" r="20" fill="#FF5252"/>
    <circle cx="150" cy="50" r="20" fill="#2196F3"/>
    <circle cx="50" cy="150" r="20" fill="#4CAF50"/>
    <circle cx="150" cy="150" r="20" fill="#9C27B0"/>
  </g>
</svg>`;
  }

  // ========================================
  // UTILITÁRIOS DE CONFIGURAÇÃO
  // ========================================

  private generateWebManifest(): any {
    return {
      name: "Bu Fala - IA para Comunidades",
      short_name: "Bu Fala",
      description: "Sistema de IA para comunidades da Guiné-Bissau",
      start_url: "/",
      display: "standalone",
      background_color: "#2E7D32",
      theme_color: "#1B5E20",
      icons: this.iconSets.web.pwa.map(size => ({
        src: `pwa-icon-${size}x${size}.png`,
        sizes: `${size}x${size}`,
        type: "image/png"
      }))
    };
  }

  private createIconReadme(): string {
    return `# Bu Fala - Pacote de Ícones

## 📱 Ícones Gerados

### Android
- **Mipmap Icons**: Ícones principais da aplicação
- **Adaptive Icons**: Suporte para Android 8+

### iOS
- **App Icons**: Todos os tamanhos necessários para iOS

### Web/PWA
- **Favicons**: 16x16, 32x32, 48x48
- **PWA Icons**: 72x72 até 512x512
- **Manifest**: Configuração completa para PWA

### Funcionalidades
${this.featureIcons.map(icon => `- ${icon.symbol} **${icon.name}**: ${icon.description}`).join('\n')}

## 🎨 Design

### Cores Principais
- **Verde Primário**: #2E7D32
- **Verde Escuro**: #1B5E20
- **Azul**: #0277BD

## 📋 Como Usar

### Flutter
\`\`\`yaml
flutter:
  assets:
    - assets/icons/
\`\`\`

### Android
Copie os arquivos para:
- \`android/app/src/main/res/mipmap-*/\`

### iOS
Adicione ao \`ios/Runner/Assets.xcassets/AppIcon.appiconset/\`

### Web
Copie para \`web/\` e referencie no \`index.html\`
`;
  }

  private createFlutterAssetsConfig(): string {
    return `# Adicione ao seu pubspec.yaml

flutter:
  assets:
    - assets/icons/
    ${this.featureIcons.map(icon => `- assets/icons/${icon.name}_icon.png`).join('\n    ')}

# Exemplo de uso:
# Image.asset('assets/icons/medical_icon.png', width: 24, height: 24)
`;
  }
}

// ========================================
// FUNÇÕES DE EXPORTAÇÃO
// ========================================

export async function generateBuFalaIcons(options: {
  outputDir?: string;
  includeAnimated?: boolean;
  includeVariations?: boolean;
  generatePreview?: boolean;
} = {}): Promise<void> {
  const generator = new BuFalaIconGenerator();
  
  console.log('🚀 Iniciando geração de ícones Bu Fala...');
  console.log(`📁 Diretório: ${options.outputDir || './bu_fala_icons'}`);
  
  try {
    await generator.generateAppIcon(options.outputDir);
    await generator.generateIconPack();
    console.log('\n✅ Geração concluída com sucesso!');
  } catch (error) {
    console.error('❌ Erro durante a geração:', error);
    throw error;
  }
}

export async function generateBuFalaStoreIcons(outputDir?: string): Promise<void> {
  const generator = new BuFalaIconGenerator();
  
  console.log('🏪 Gerando ícones para lojas...');
  console.log(`📁 Diretório: ${outputDir || './store_assets'}`);
  
  try {
    await generator.generateIconPack();
    console.log('\n✅ Ícones para lojas gerados com sucesso!');
  } catch (error) {
    console.error('❌ Erro durante a geração:', error);
    throw error;
  }
}

export { BuFalaIconGenerator };


