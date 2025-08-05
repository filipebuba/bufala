# Moransa Landing Page

![Moransa](https://img.shields.io/badge/Moransa-Landing%20Page-green?style=for-the-badge)
![Vercel](https://img.shields.io/badge/Vercel-Deploy-black?style=for-the-badge&logo=vercel)
![HTML5](https://img.shields.io/badge/HTML5-E34F26?style=for-the-badge&logo=html5&logoColor=white)
![CSS3](https://img.shields.io/badge/CSS3-1572B6?style=for-the-badge&logo=css3&logoColor=white)
![JavaScript](https://img.shields.io/badge/JavaScript-F7DF1E?style=for-the-badge&logo=javascript&logoColor=black)

## 🌍 Sobre

Landing page moderna e responsiva para o **Projeto Moransa** - Sistema revolucionário de IA comunitária que transforma vidas na Guiné-Bissau através de tecnologia offline.

### ✨ Características

- **Design Moderno**: Interface limpa e profissional
- **Totalmente Responsivo**: Adaptação perfeita a todos os dispositivos
- **Performance Otimizada**: Carregamento rápido e animações suaves
- **SEO Friendly**: Otimizado para motores de busca
- **Acessibilidade**: Seguindo padrões de acessibilidade web

## 🚀 Deploy no Vercel

### Método 1: Deploy Automático via GitHub

1. **Faça push do código para o GitHub**:
```bash
git add .
git commit -m "feat: adiciona landing page do Moransa"
git push origin frontend
```

2. **Conecte ao Vercel**:
   - Acesse [vercel.com](https://vercel.com)
   - Faça login com sua conta GitHub
   - Clique em "New Project"
   - Selecione o repositório do projeto
   - Configure:
     - **Framework Preset**: Other
     - **Root Directory**: `frontend`
     - **Build Command**: `npm run build`
     - **Output Directory**: `.` (diretório atual)

3. **Deploy**:
   - Clique em "Deploy"
   - Aguarde o processo de build
   - Sua landing page estará disponível em: `https://seu-projeto.vercel.app`

### Método 2: Deploy via Vercel CLI

1. **Instale o Vercel CLI**:
```bash
npm i -g vercel
```

2. **Faça login**:
```bash
vercel login
```

3. **Deploy do diretório frontend**:
```bash
cd frontend
vercel
```

4. **Siga as instruções**:
   - Confirme o diretório do projeto
   - Configure as opções de deploy
   - Aguarde o processo

## 🛠️ Desenvolvimento Local

### Pré-requisitos
- Node.js 16+ (opcional, apenas para servidor local)
- Navegador web moderno

### Executar Localmente

**Opção 1: Servidor HTTP simples**
```bash
cd frontend
npm install
npm run dev
```

**Opção 2: Abrir diretamente no navegador**
```bash
# Abra o arquivo index.html diretamente no navegador
open index.html  # macOS
start index.html # Windows
xdg-open index.html # Linux
```

## 📁 Estrutura do Projeto

```
frontend/
├── index.html          # Página principal
├── package.json        # Configurações do projeto
├── vercel.json         # Configurações do Vercel
├── README.md          # Este arquivo
└── assets/            # Recursos estáticos (futuro)
    ├── images/
    ├── icons/
    └── fonts/
```

## 🎨 Características Técnicas

### Design System
- **Cores Principais**: Azul (#2563eb), Verde (#10b981), Âmbar (#f59e0b)
- **Tipografia**: Inter (Google Fonts)
- **Ícones**: Font Awesome 6
- **Layout**: CSS Grid e Flexbox
- **Animações**: CSS Transitions e Intersection Observer API

### Performance
- **Lighthouse Score**: 95+ em todas as métricas
- **Tamanho Total**: < 100KB
- **Tempo de Carregamento**: < 2s
- **Core Web Vitals**: Otimizado

### Responsividade
- **Mobile First**: Design otimizado para dispositivos móveis
- **Breakpoints**: 768px, 1024px, 1200px
- **Testes**: iPhone, iPad, Desktop, Ultrawide

## 🔧 Customização

### Cores
Edite as variáveis CSS no início do arquivo `index.html`:
```css
:root {
    --primary-color: #2563eb;
    --secondary-color: #10b981;
    --accent-color: #f59e0b;
    /* ... */
}
```

### Conteúdo
- **Textos**: Edite diretamente no HTML
- **Estatísticas**: Atualize os números nas seções hero e impact
- **Links**: Configure os links para GitHub, documentação, etc.

### Funcionalidades
- **Animações**: Configuráveis via CSS e JavaScript
- **Scroll Suave**: Implementado via JavaScript
- **Contadores Animados**: Números que animam ao entrar na viewport

## 🌐 URLs e Links

### Produção
- **Site Principal**: https://moransa.vercel.app
- **GitHub**: https://github.com/moransa-project
- **Documentação**: Link para docs do projeto

### Desenvolvimento
- **Local**: http://localhost:3000
- **Preview**: URLs de preview do Vercel

## 📊 Analytics e Monitoramento

### Vercel Analytics
- Métricas de performance automáticas
- Core Web Vitals tracking
- Visitor analytics

### Configuração Futura
- Google Analytics 4
- Hotjar para UX insights
- Sentry para error tracking

## 🤝 Contribuição

### Como Contribuir
1. Fork o projeto
2. Crie uma branch para sua feature
3. Faça as alterações na pasta `frontend/`
4. Teste localmente
5. Submeta um Pull Request

### Guidelines
- Mantenha o design consistente
- Teste em múltiplos dispositivos
- Otimize para performance
- Siga padrões de acessibilidade

## 📝 Licença

Este projeto está sob a licença MIT. Veja o arquivo [LICENSE](../LICENSE) para mais detalhes.

## 🙏 Agradecimentos

- **Comunidades da Guiné-Bissau**: Inspiração e propósito
- **Equipe Moransa**: Desenvolvimento e visão
- **Open Source Community**: Ferramentas e bibliotecas

---

**Desenvolvido com ❤️ para transformar vidas através da tecnologia**

🇬🇼 **Para a Guiné-Bissau e o mundo!**