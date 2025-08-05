# Moransa Landing Page

![Moransa](https://img.shields.io/badge/Moransa-Landing%20Page-green?style=for-the-badge)
![Vercel](https://img.shields.io/badge/Vercel-Deploy-black?style=for-the-badge&logo=vercel)
![HTML5](https://img.shields.io/badge/HTML5-E34F26?style=for-the-badge&logo=html5&logoColor=white)
![CSS3](https://img.shields.io/badge/CSS3-1572B6?style=for-the-badge&logo=css3&logoColor=white)
![JavaScript](https://img.shields.io/badge/JavaScript-F7DF1E?style=for-the-badge&logo=javascript&logoColor=black)

## 🌍 About

Modern and responsive landing page for the **Moransa Project** - Revolutionary community AI system that transforms lives in Guinea-Bissau through offline technology.

### ✨ Features

- **Modern Design**: Clean and professional interface
- **Fully Responsive**: Perfect adaptation to all devices
- **Optimized Performance**: Fast loading and smooth animations
- **SEO Friendly**: Optimized for search engines
- **Accessibility**: Following web accessibility standards

## 🚀 Deploy to Vercel

### Method 1: Automatic Deploy via GitHub

1. **Push code to GitHub**:
```bash
git add .
git commit -m "feat: add Moransa landing page"
git push origin frontend
```

2. **Connect to Vercel**:
   - Go to [vercel.com](https://vercel.com)
   - Login with your GitHub account
   - Click "New Project"
   - Select the project repository
   - Configure:
     - **Framework Preset**: Other
     - **Root Directory**: `frontend`
     - **Build Command**: `npm run build`
     - **Output Directory**: `.` (current directory)

3. **Deploy**:
   - Click "Deploy"
   - Wait for the build process
   - Your landing page will be available at: `https://your-project.vercel.app`

### Method 2: Deploy via Vercel CLI

1. **Install Vercel CLI**:
```bash
npm i -g vercel
```

2. **Login**:
```bash
vercel login
```

3. **Deploy frontend directory**:
```bash
cd frontend
vercel
```

4. **Follow instructions**:
   - Confirm project directory
   - Configure deploy options
   - Wait for the process

## 🛠️ Local Development

### Prerequisites
- Node.js 16+ (optional, only for local server)
- Modern web browser

### Run Locally

**Option 1: Simple HTTP server**
```bash
cd frontend
npm install
npm run dev
```

**Option 2: Open directly in browser**
```bash
# Open index.html file directly in browser
open index.html  # macOS
start index.html # Windows
xdg-open index.html # Linux
```

## 📁 Project Structure

```
frontend/
├── index.html          # Main page
├── package.json        # Project configuration
├── vercel.json         # Vercel configuration
├── README.md          # Portuguese documentation
├── README_EN.md       # English documentation (this file)
├── README_NAVIGATOR.html # Documentation navigator
└── assets/            # Static resources (future)
    ├── images/
    ├── icons/
    └── fonts/
```

## 🎨 Technical Features

### Design System
- **Primary Colors**: Blue (#2563eb), Green (#10b981), Amber (#f59e0b)
- **Typography**: Inter (Google Fonts)
- **Icons**: Font Awesome 6
- **Layout**: CSS Grid and Flexbox
- **Animations**: CSS Transitions and Intersection Observer API

### Performance
- **Lighthouse Score**: 95+ in all metrics
- **Total Size**: < 100KB
- **Loading Time**: < 2s
- **Core Web Vitals**: Optimized

### Responsiveness
- **Mobile First**: Design optimized for mobile devices
- **Breakpoints**: 768px, 1024px, 1200px
- **Testing**: iPhone, iPad, Desktop, Ultrawide

## 🔧 Customization

### Colors
Edit CSS variables at the beginning of `index.html` file:
```css
:root {
    --primary-color: #2563eb;
    --secondary-color: #10b981;
    --accent-color: #f59e0b;
    /* ... */
}
```

### Content
- **Texts**: Edit directly in HTML
- **Statistics**: Update numbers in hero and impact sections
- **Links**: Configure links to GitHub, documentation, etc.

### Features
- **Animations**: Configurable via CSS and JavaScript
- **Smooth Scroll**: Implemented via JavaScript
- **Animated Counters**: Numbers that animate when entering viewport

## 🌐 URLs and Links

### Production
- **Main Site**: https://moransa.vercel.app
- **GitHub**: https://github.com/moransa-project
- **Documentation**: Link to project docs

### Development
- **Local**: http://localhost:3000
- **Preview**: Vercel preview URLs

## 📊 Analytics and Monitoring

### Vercel Analytics
- Automatic performance metrics
- Core Web Vitals tracking
- Visitor analytics

### Future Configuration
- Google Analytics 4
- Hotjar for UX insights
- Sentry for error tracking

## 🤝 Contributing

### How to Contribute
1. Fork the project
2. Create a branch for your feature
3. Make changes in `frontend/` folder
4. Test locally
5. Submit a Pull Request

### Guidelines
- Maintain consistent design
- Test on multiple devices
- Optimize for performance
- Follow accessibility standards

## 📝 License

This project is under the MIT license. See the [LICENSE](../LICENSE) file for more details.

## 🙏 Acknowledgments

- **Guinea-Bissau Communities**: Inspiration and purpose
- **Moransa Team**: Development and vision
- **Open Source Community**: Tools and libraries

---

**Developed with ❤️ to transform lives through technology**

🇬🇼 **For Guinea-Bissau and the world!**