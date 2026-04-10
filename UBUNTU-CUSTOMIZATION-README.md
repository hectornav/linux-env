# 🍎 Ubuntu macOS Developer Customization

> Personalización completa de Ubuntu 24.04 → estilo macOS Developer Dark Mode
> 
> **Versión:** 2.0  
> **Fecha:** 2026-04-08  
> **Sistema:** Ubuntu 22.04+ / 24.04 LTS / GNOME 42+  
> **Script:** `setup-macos-ubuntu.sh` (100% reproducible en cualquier PC nueva)

---

## 📋 Resumen de Cambios

| Componente | Antes | Después |
|---|---|---|
| Tema GTK | Yaru-blue | **WhiteSur-Dark** (Monterey style) |
| Iconos | Yaru-blue | **WhiteSur-dark** |
| Cursor | Yaru | **macOS** (Apple Cursor) |
| Fuente Sistema | Ubuntu Sans 11 | **SF Pro Display 11** |
| Fuente Mono | Default | **JetBrains Mono Nerd Font 11** |
| Fuente Títulos | Ubuntu Sans | **SF Pro Display Bold 11** |
| Dock | Lateral izquierdo | **Bottom, autohide instant, transparente** |
| Botones ventana | Derecha | **Izquierda (WM + GTK3 + GTK4)** |
| Prompt ZSH | fino-time | **Starship (Tokyo Night)** |
| Color Scheme | Auto | **Dark Mode** |
| Wallpaper | Default | **Tux stomping Microsoft / Dark gradient** |
| Shell Theme | Default | **WhiteSur-Dark + Blur My Shell (glass)** |
| Terminal | GNOME Terminal | **Terminator (Tokyo Night + Nerd Font)** |
| VS Code | Default | **Tokyo Night + JetBrains Mono** |
| Boot Screen | Default GRUB | **Tela macOS-style** |

---

## 🎨 Tema Visual

### GTK Theme: WhiteSur-Dark
- Tema inspirado en macOS Monterey
- Bordes redondeados, blur, transparencias
- **Fuente**: [vinceliuice/WhiteSur-gtk-theme](https://github.com/vinceliuice/WhiteSur-gtk-theme)
- **Ubicación**: `~/.themes/WhiteSur-Dark*`

### Icon Theme: WhiteSur-dark
- Iconos estilo macOS (Finder, Settings, etc.)
- **Fuente**: [vinceliuice/WhiteSur-icon-theme](https://github.com/vinceliuice/WhiteSur-icon-theme)

### Cursor: macOS
- Cursor fiel al de macOS (24px)
- **Fuente**: [ful1e5/apple_cursor](https://github.com/ful1e5/apple_cursor)

---

## 🔤 Fuentes

| Fuente | Uso | Ubicación |
|---|---|---|
| SF Pro Display | Sistema, UI, títulos | `~/.local/share/fonts/SFPro/` |
| JetBrains Mono Nerd Font | Terminal, código, iconos | `~/.local/share/fonts/JetBrainsMono/` |

- Antialiasing: RGBA (subpixel)
- Hinting: Slight

---

## ⚓ Dock (Dash-to-Dock)

| Setting | Valor |
|---|---|
| Posición | Bottom (abajo) |
| Autohide | ✅ Instant (show: 0s, hide: 0.1s) |
| dock-fixed | ❌ (no reserva espacio = no gap) |
| Transparencia | Dinámica (60%) |
| Tamaño iconos | 48px |
| Indicador apps | Dots (puntos) |
| Click action | Minimize |
| Pressure required | ❌ (reacciona al instante) |

---

## 🖥️ Terminal: Terminator

### Configuración
- **Font**: JetBrains Mono Nerd Font 12
- **Colores**: Tokyo Night palette
- **Background**: Semi-transparente (92%)
- **Titlebar**: Oculto (más limpio)
- **Default terminal**: ✅ (sistema + GNOME + dock)
- **Config**: `~/.config/terminator/config`

### Starship Prompt
- Prompt moderno escrito en Rust
- Tema: **Tokyo Night** (`#7aa2f7`, `#9ece6a`, `#f7768e`, `#bb9af7`)
- Muestra: git, Python, Node, Rust, Go, Docker, duración
- **Config**: `~/.config/starship.toml`

---

## 🛠️ Herramientas CLI

| Herramienta | Reemplaza | Alias | Descripción |
|---|---|---|---|
| `eza` | `ls` | `ls`, `ll`, `lt` | Listado con iconos, colores, git |
| `batcat` | `cat` | `cat` | Syntax highlighting + line numbers |
| `btop` | `htop` | `top` | Monitor gráfico de sistema |
| `fastfetch` | `neofetch` | `fetch` | Info del sistema (se muestra al abrir terminal) |
| `fzf` | — | `Ctrl+R` | Fuzzy finder para historial y archivos |
| `zoxide` | `cd` | `z <dir>` | cd inteligente (aprende tus dirs) |
| `ripgrep` | `grep` | `rg` | Grep ultra-rápido |
| `fd-find` | `find` | `fd` | Find ultra-rápido |
| `tldr` | `man` | `help` | Man pages simplificadas |
| `starship` | theme | — | Prompt cross-shell moderno |

---

## 🧩 GNOME Extensions

| Extensión | UUID | Función |
|---|---|---|
| **Blur My Shell** | `blur-my-shell@aunetx` | Blur glassmorphism en panel, dock, overview |
| **Clipboard Indicator** | `clipboard-indicator@tudmotu.com` | Historial de clipboard en el panel |
| **Caffeine** | `caffeine@patapon.info` | Prevenir sleep/screensaver |
| **User Themes** | `user-theme@gnome-shell-ext...` | Permitir temas de shell personalizados |

---

## ⌨️ Aliases

### Archivos y Navegación
```bash
ls      → eza --icons --group-directories-first
ll      → eza -la --icons --git
lt      → eza --tree --icons --level=2
cat     → batcat --style=auto
top     → btop
fd      → fdfind
rg      → rg --smart-case
help    → tldr
z       → zoxide (smart cd)
```

### Git
```bash
gs      → git status          git st  → status
ga      → git add             git co  → checkout
gc      → git commit          git lg  → log --graph --all
gp      → git push            git wip → add all + commit WIP
gl      → log --graph         git amend → amend last commit
```

### Sistema
```bash
fetch   → fastfetch           Super+E → Files
myip    → curl ifconfig.me    Super+T → Terminator
update  → apt update+upgrade  Ctrl+R  → FZF history search
```

---

## 💻 VS Code

- **Theme**: Tokyo Night
- **Font**: JetBrains Mono Nerd Font 14
- **Terminal Font**: JetBrains Mono Nerd Font 13
- **Extension**: `enkia.tokyo-night`

---

## 🔧 Git Global Config

```bash
init.defaultBranch = main
core.editor = code --wait
push.autoSetupRemote = true
credential.helper = store
```

**Aliases**: `st`, `co`, `br`, `ci`, `lg`, `last`, `unstage`, `amend`, `wip`

---

## 🖼️ Wallpaper

- **Opción 1**: Tux cyberpunk pisoteando Microsoft (AI-generated)
- **Opción 2**: Dark gradient generado con ImageMagick (auto en script)
- **Ubicación**: `~/Pictures/tux-developer-wallpaper.png`
- **Modo**: zoom

---

## 🥾 GRUB Boot Theme

- **Tema**: Tela (mismo autor que WhiteSur)
- **Estilo**: macOS-inspired boot screen
- **Fuente**: [vinceliuice/grub2-themes](https://github.com/vinceliuice/grub2-themes)

---

## ⚙️ Configuración GNOME

| Setting | Valor |
|---|---|
| Botones ventana | Izquierda (WM + GTK3 + GTK4 settings.ini) |
| Reloj | Fecha + día de la semana |
| Hot corners | Desactivados |
| Animaciones | Activadas |
| Batería | Porcentaje visible |
| Touchpad | Natural scroll + tap-to-click |
| Color scheme | prefer-dark |

---

## 🔄 Cómo Revertir

### Revertir .zshrc
```bash
cp ~/.zshrc.backup.* ~/.zshrc  # restore more recent backup
source ~/.zshrc
```

### Revertir tema a Yaru
```bash
gsettings set org.gnome.desktop.interface gtk-theme 'Yaru-blue'
gsettings set org.gnome.desktop.interface icon-theme 'Yaru-blue'
gsettings set org.gnome.desktop.interface cursor-theme 'Yaru'
gsettings set org.gnome.desktop.wm.preferences button-layout ':minimize,maximize,close'
```

### Revertir dock
```bash
gsettings set org.gnome.shell.extensions.dash-to-dock dock-position 'LEFT'
gsettings set org.gnome.shell.extensions.dash-to-dock dock-fixed true
gsettings set org.gnome.shell.extensions.dash-to-dock extend-height true
```

### Desinstalar todo
```bash
rm -rf ~/.themes/WhiteSur* ~/.local/share/icons/WhiteSur* ~/.icons/macOS*
rm -rf ~/.local/share/fonts/SFPro/ ~/.local/share/fonts/JetBrainsMono/
rm -rf ~/.config/terminator/config ~/.config/starship.toml
```

---

## 📝 Notas

- El script es **100% reproducible** en cualquier PC nueva con Ubuntu + GNOME
- Para la fuente Nerd en VS Code: ya configurado automáticamente
- Fastfetch se muestra al abrir Terminator (no en VS Code terminal)
- `Ctrl+R` en terminal = búsqueda fuzzy del historial (FZF)
- `z projects` = salta a la carpeta "projects" más usada (Zoxide)
- `help tar` = muestra uso simplificado del comando tar (TLDR)

---

> 🎯 **Tip**: Cierra sesión y vuelve a entrar para que todos los cambios se apliquen completamente.
