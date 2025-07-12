import { BuFalaIconGenerator } from '../icon-generator';
import fs from 'fs/promises';
import path from 'path';

describe('BuFalaIconGenerator', () => {
  let generator: BuFalaIconGenerator;
  const testOutputDir = './test_output';

  beforeEach(() => {
    generator = new BuFalaIconGenerator();
  });

  afterEach(async () => {
    // Limpar arquivos de teste
    try {
      await fs.rmdir(testOutputDir, { recursive: true });
    } catch (error) {
      // Ignorar erro se diretório não existir
    }
  });

  describe('SVG Generation', () => {
    test('should create main app icon SVG', () => {
      const svg = generator['createMainAppIconSvg']();
      
      expect(svg).toContain('<svg');
      expect(svg).toContain('</svg>');
      expect(svg).toContain('Bu Fala');
      expect(svg).toContain('#2E7D32'); // Primary color
    });

    test('should create feature icon SVG', () => {
      const svg = generator['createFeatureIconSvg']('🏥', '#F44336');
      
      expect(svg).toContain('<svg');
      expect(svg).toContain('🏥');
      expect(svg).toContain('#F44336');
    });
  });

  describe('Icon Generation', () => {
    test('should generate app icon without errors', async () => {
      await expect(generator.generateAppIcon(testOutputDir)).resolves.not.toThrow();
    });

    test('should create output directory', async () => {
      await generator.generateAppIcon(testOutputDir);
      
      const stats = await fs.stat(testOutputDir);
      expect(stats.isDirectory()).toBe(true);
    });
  });

  describe('Store Icons', () => {
    test('should generate store icons without errors', async () => {
      const storeGenerator = new (require('../icon-generator').BuFalaStoreIconGenerator)();
      
      await expect(
        storeGenerator.generateAllStoreAssets(testOutputDir)
      ).resolves.not.toThrow();
    });
  });

  describe('Flutter Integration', () => {
    test('should create valid pubspec configuration', () => {
      const config = generator['createFlutterAssetsConfig']();
      
      expect(config).toContain('flutter:');
      expect(config).toContain('assets:');
      expect(config).toContain('medical_icon.png');
    });
  });
});
