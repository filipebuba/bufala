import { promises as fs } from 'fs';
import path from 'path';

interface PreviewOptions {
  title?: string;
  theme?: 'light' | 'dark';
  showCode?: boolean;
  responsive?: boolean;
}

class HTMLPreviewGenerator {
  private createPreviewHTML(options: PreviewOptions = {}): string {
    const {
      title = 'Bu Fala - Preview de Ícones',
      theme = 'light',
      showCode = true,
      responsive = true
    } = options;

    return `<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${title}</title>
    <link rel="stylesheet" href="css/style.css">
</head>
<body class="theme-${theme}">
    <header class="header">
        <div class="container">
            <h1>🌍 Bu Fala - Ícones</h1>
            <p>Sistema de IA para Comunidades da Guiné-Bissau</p>
        </div>
    </header>

    <main class="main">
        <div class="container">
            <section class="icon-grid">
                <div class="icon-card">
                    <img src="assets/medical_icon.svg" alt="Medical" class="icon">
                    <h3>Primeiros Socorros</h3>
                    <p>Assistência médica de emergência</p>
                </div>
                
                <div class="icon-card">
                    <img src="assets/education_icon.svg" alt="Education" class="icon">
                    <h3>Educação</h3>
                    <p>Experiências interativas</p>
                </div>
                
                <div class="icon-card">
                    <img src="assets/agriculture_icon.svg" alt="Agriculture" class="icon">
                    <h3>Agricultura</h3>
                    <p>Proteção de culturas</p>
                </div>
                
                <div class="icon-card">
                    <img src="assets/wellness_icon.svg" alt="Wellness" class="icon">
                    <h3>Bem-estar</h3>
                    <p>Coaching personalizado</p>
                </div>
            </section>
        </div>
    </main>

    <script src="js/script.js"></script>
</body>
</html>`;
  }

  private createPreviewCSS(options: PreviewOptions = {}): string {
    return `
/* Bu Fala Icons Preview CSS */
* {
    margin: 0;
    padding: 0;
    box-sizing: border-box;
}

body {
    font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
    line-height: 1.6;
    color: #333;
    background: #f5f5f5;
}

.container {
    max-width: 1200px;
    margin: 0 auto;
    padding: 0 20px;
}

.header {
    background: linear-gradient(135deg, #2E7D32, #1B5E20);
    color: white;
    padding: 2rem 0;
    text-align: center;
}

.header h1 {
    font-size: 2.5rem;
    margin-bottom: 0.5rem;
}

.main {
    padding: 2rem 0;
}

.icon-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
    gap: 2rem;
    margin-top: 2rem;
}

.icon-card {
    background: white;
    border-radius: 12px;
    padding: 2rem;
    text-align: center;
    box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
    transition: transform 0.3s ease;
}

.icon-card:hover {
    transform: translateY(-5px);
}

.icon {
    width: 64px;
    height: 64px;
    margin-bottom: 1rem;
}

.icon-card h3 {
    color: #2E7D32;
    margin-bottom: 0.5rem;
}

.icon-card p {
    color: #666;
    font-size: 0.9rem;
}
`;
  }

  private createPreviewJS(): string {
    return `
// Bu Fala Icons Preview JavaScript
document.addEventListener('DOMContentLoaded', function() {
    console.log('Bu Fala Icons Preview carregado');
    
    // Adicionar interatividade aos cards
    const cards = document.querySelectorAll('.icon-card');
    cards.forEach(card => {
        card.addEventListener('click', function() {
            const iconName = this.querySelector('h3').textContent;
            console.log('Ícone clicado:', iconName);
        });
    });
});
`;
  }

  async generateCompletePreview(outputDir: string = './preview'): Promise<void> {
    console.log('🎨 Gerando preview completo dos ícones Bu Fala...\n');
    
    try {
      // Criar estrutura de diretórios
      await fs.mkdir(outputDir, { recursive: true });
      await fs.mkdir(path.join(outputDir, 'assets'), { recursive: true });
      await fs.mkdir(path.join(outputDir, 'css'), { recursive: true });
      await fs.mkdir(path.join(outputDir, 'js'), { recursive: true });
      
      // Gerar arquivos
      const html = this.createPreviewHTML();
      await fs.writeFile(path.join(outputDir, 'index.html'), html);
      
      const css = this.createPreviewCSS();
      await fs.writeFile(path.join(outputDir, 'css', 'style.css'), css);
      
      const js = this.createPreviewJS();
      await fs.writeFile(path.join(outputDir, 'js', 'script.js'), js);
      
      console.log('✅ Preview gerado com sucesso!');
      
    } catch (error) {
      console.error('❌ Erro ao gerar preview:', error);
      throw error;
    }
  }
}

export { HTMLPreviewGenerator };
