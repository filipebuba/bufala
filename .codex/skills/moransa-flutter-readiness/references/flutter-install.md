# Flutter Install (Linux/WSL)

## Option A: Snap (if available)
```bash
sudo snap install flutter --classic
```

## Option B: Official SDK
```bash
cd ~
git clone https://github.com/flutter/flutter.git -b stable
export PATH="$PATH:$HOME/flutter/bin"
flutter --version
```

Add to shell profile (`~/.zshrc`):
```bash
export PATH="$PATH:$HOME/flutter/bin"
```
