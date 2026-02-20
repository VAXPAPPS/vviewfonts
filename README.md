# VViewFonts

**VViewFonts** is a professional Linux desktop application for browsing, previewing, and managing system fonts. Built with Flutter and powered by direct FFI calls to `libfontconfig` for maximum performance.

---

## ✨ Features

| Feature | Description |
|---|---|
| 🔍 **Font Discovery** | Instantly lists all installed system fonts via native FFI — no subprocess overhead |
| 🔎 **Real-time Search** | Filter fonts by name as you type |
| 🏷️ **Category Filtering** | Filter by Sans-Serif, Serif, Monospace, or Other |
| 👁️ **Live Preview** | Preview any font with custom text and adjustable size (8–120px) |
| 📋 **Compare Mode** | Compare up to 4 fonts side-by-side with the same preview text |
| ⭐ **Favorites** | Save your favorite fonts locally for quick access |
| 📄 **Font Details** | View detailed metadata: family, style, weight, slant, category, format, file path |
| 📎 **Copy Font Name** | One-click copy of any font family name to clipboard |
| 🔀 **List / Grid View** | Toggle between compact list and visual grid display |

---

## 🏗️ Architecture

```
Clean Architecture + BLoC State Management
├── domain/       # Entities & repository interfaces
├── data/         # FFI datasource, SharedPreferences, repository impl
├── application/  # BLoCs (FontList, FontPreview, Favorites)
└── presentation/ # Pages & widgets
```

**FFI Pipeline:**
```
libfontconfig (C) → fontconfig_helper.c → libfontconfig_helper.so → Dart FFI (Isolate) → BLoC → UI
```

---

## 📦 Build Dependencies

### System Libraries (Required)

Install on **Debian/Ubuntu**:

```bash
sudo apt install libfontconfig1-dev pkg-config clutter-1.0 cmake ninja-build libgtk-3-dev
```

Install on **Fedora**:

```bash
sudo dnf install fontconfig-devel pkg-config cmake ninja-build gtk3-devel
```

Install on **Arch Linux**:

```bash
sudo pacman -S fontconfig pkgconf cmake ninja gtk3
```

| Library | Package | Purpose |
|---|---|---|
| `libfontconfig` | `libfontconfig1-dev` | Font discovery via FFI |
| `pkg-config` | `pkg-config` | Build system dependency resolution |
| `GTK 3` | `libgtk-3-dev` | Flutter Linux embedding |
| `CMake` | `cmake` | Native build system |
| `Ninja` | `ninja-build` | Build backend |

### Flutter Dependencies

| Package | Version | Purpose |
|---|---|---|
| `flutter_bloc` | ^9.1.0 | BLoC state management |
| `equatable` | ^2.0.7 | Value equality for states/events |
| `shared_preferences` | ^2.5.3 | Local favorites persistence |
| `window_manager` | ^0.5.1 | Desktop window controls |
| `venom_config` | ^0.0.1 | VAXP configuration system |

---

## 🚀 Build & Run

```bash
# Install dependencies
flutter pub get

# Run in debug mode
flutter run -d linux

# Build release
flutter build linux
```

The release binary will be at:
```
build/linux/x64/release/bundle/vviewfonts
```

---

## 📜 License

VAXP Organization — Private Project.
# vviewfonts
