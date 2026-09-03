# 📚 KathaQuest (कथाक्वेस्ट)

<div align="center">

![Flutter](https://img.shields.io/badge/Flutter-3.10+-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.0+-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Platform](https://img.shields.io/badge/Platform-Web%20%7C%20Linux%20%7C%20Windows%20%7C%20macOS%20%7C%20Android-4CAF50?style=for-the-badge)
![License](https://img.shields.io/badge/License-MIT-orange?style=for-the-badge)
![Smart India Hackathon](https://img.shields.io/badge/SIH-Finalist%20Project-FF9933?style=for-the-badge)

**An Interactive Bilingual Storytelling & Moral Learning Adventure for Children**  
*Built from the ground up with Flutter for 60–120 FPS performance, lightweight resource usage, and zero GPU overhead.*

[Features](#-key-features) • [Quick Start](#-quick-start) • [Linux Setup](#-linux-setup-guide) • [Windows Setup](#-windows-setup-guide) • [macOS Setup](#-macos-setup-guide) • [Architecture](#-project-architecture) • [Troubleshooting](#-troubleshooting--faq)

</div>

---

## 🌟 Overview

**KathaQuest** transforms traditional Indian fables and folk tales (Panchatantra, Jataka, Ramayana) into captivating, gamified learning experiences for young children. 

Unlike heavy 3D game engines that demand dedicated GPUs and gigabytes of memory, KathaQuest is built with **Flutter**. It delivers rich storybook visuals, 60 FPS multi-layer parallax animations, interactive tap micro-reactions, and tactile mini-games—running smoothly on low-spec school netbooks, Chromebooks, personal laptops, tablets, and mobile devices alike.

---

## ✨ Key Features

### 🎬 Disney-Tier Layered Hero Splash
- **9 Independent Transparent PNG Layers**: Foreground floral beds, curious children, glowing sacred scripture book, celestial constellations, and 4 ascending story heroes (Lord Rama, Sita, Royal King, and Winged Simha Lion).
- **Cinematic 4-Stage Timeline**:
  - **Stage 1 (0–1s)**: Fade from black, gentle center camera zoom, ambient landscape illumination.
  - **Stage 2 (1–4s)**: World awakens with multi-plane parallax drift, horizontal clouds, soaring silhouette birds, 3D fluttering butterflies, and swaying foliage.
  - **Stage 3 (4–7s)**: Volumetric god-rays, constellation star traces, and ascending deities with divine glowing halos.
  - **Stage 4 (Idle Loop)**: Never freezes! Infinite ambient breathing loop while waiting for user interaction.
- **Interactive "Tap to Begin"**: Screen never auto-navigates. When background asset precaching finishes, the glowing progress bar smoothly morphs into an interactive **"Tap to Begin"** prompt with golden light burst and camera push-in feedback.

### 💬 Glowing Magical Storybook Speech Bubbles
- **Luminous Golden Halo**: Dual-layer soft glowing aura shadows (`#FFD54F` / `#FFA000`) with warm parchment gradient canvas.
- **Devanagari & Latin Typography**: Deep royal ink with `NotoSerifDevanagari` and `NotoSansDevanagari` fallbacks for crisp bilingual text rendering.
- **Enchanted Mini-Game Prompts**: In-game reaction bubbles, real-time rhythm combo feedback (`Combo x4! 🌟`), and the **MagicalHintBanner** quest scroll.

### 🎮 4 Pedagogy-Backed Mini-Games
1. 🌲 **Forest Trail Walk (MG1)**: Hand-eye coordination minigame collecting falling stars (`+15 ⭐`) and clover (`+10 🍀`) while steering Timo the Tortoise.
2. ⏱️ **Steady Pace Meter (MG2)**: Rhythmic pacing game keeping Tortoise inside the green "Steady Zone" via calibrated cadence tapping.
3. 🎵 **Rhythm Steps (MG3)**: Musical beat-matching tapper as Timo marches quietly past the snoring hare with floating note feedback.
4. 🏁 **The Final Sprint (MG4)**: High-energy cheering button dash to cross the finish line ribbon and claim victory.

### 📖 Interactive Comic Engine & Quizzes
- **Tap Reactions**: Touch characters to trigger custom voice reactions, sounds, and animations.
- **Bilingual Switcher**: Instant one-tap toggle between **English** and **Hindi** (`EN` ⇄ `हिन्दी`) with native audio narration.
- **Moral Comprehension Quiz**: 3 interactive questions validating story comprehension, virtues, and vocabulary.
- **Parent Corner**: Math-gate protected parental dashboard with screen-time analytics, sound sliders, and child safety controls.

---

## 🚀 Quick Start (Browser / Web)

The fastest and lightest way to run KathaQuest on **any operating system** (Linux, Windows, macOS) without compiling native desktop binaries:

```bash
# 1. Clone the repository
git clone https://github.com/ritam4735/KathaQuest.git
cd KathaQuest

# 2. Get project dependencies
flutter pub get

# 3. Launch in Google Chrome (Instant Web App)
flutter run -d chrome
```

---

## 🐧 Linux Setup Guide

Tested on **Fedora 38/39/40**, **Ubuntu 20.04/22.04/24.04 LTS**, **Debian 11/12**, and **Arch Linux**.

### 1. Install System Dependencies

#### Fedora / RHEL:
```bash
sudo dnf groupinstall -y "Development Tools" "C Development Tools and Libraries"
sudo dnf install -y clang cmake ninja-build gtk3-devel pkg-config libstdc++-devel
```

#### Ubuntu / Debian / Linux Mint:
```bash
sudo apt update
sudo apt install -y clang cmake ninja-build pkg-config libgtk-3-dev liblzma-dev
```

#### Arch Linux / Manjaro:
```bash
sudo pacman -S --needed base-devel clang cmake ninja gtk3 pkgconf
```

### 2. Install Flutter SDK on Linux

```bash
# Create development directory
mkdir -p ~/development
cd ~/development

# Clone Flutter stable channel
git clone https://github.com/flutter/flutter.git -b stable

# Add Flutter to your shell profile (~/.bashrc or ~/.zshrc)
echo 'export PATH="$HOME/development/flutter/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc

# Verify Flutter installation
flutter doctor
```

### 3. Run KathaQuest on Linux

```bash
cd /path/to/KathaQuest

# Fetch dependencies
flutter pub get

# Option A: Run in Chrome (Zero build overhead, fast preview)
flutter run -d chrome

# Option B: Run as a Native Linux Desktop Application
flutter run -d linux
```

> **Automated Script**: You can also simply run `./setup_flutter.sh` in the project root!

---

## 🪟 Windows Setup Guide

Tested on **Windows 10** and **Windows 11** (64-bit).

### 1. Install Prerequisites

1. **Git for Windows**: Download and install from [git-scm.com](https://git-scm.com/download/win).
2. **Visual Studio 2022**:
   - Download Visual Studio Community from [visualstudio.microsoft.com](https://visualstudio.microsoft.com/).
   - In the Visual Studio Installer, check **"Desktop development with C++"** workload.
   - Ensure **MSVC v143**, **Windows 10/11 SDK**, and **C++ CMake tools for Windows** are checked.
3. **Google Chrome / Microsoft Edge**: Pre-installed or downloaded for web testing.

### 2. Install Flutter SDK on Windows

1. Download the latest Flutter SDK bundle from [docs.flutter.dev](https://docs.flutter.dev/get-started/install/windows).
2. Extract the zip file to `C:\src\flutter` (do **not** install Flutter in `C:\Program Files\` due to permission restrictions).
3. Add Flutter to your Environment Variables:
   - Press <kbd>Win</kbd> + <kbd>S</kbd>, search for **"Edit the system environment variables"**.
   - Click **Environment Variables...**
   - Under **User variables**, select `Path` and click **Edit**.
   - Click **New** and add: `C:\src\flutter\bin`
   - Click **OK** on all windows.
4. Open a **new** PowerShell or Command Prompt window and verify:
   ```powershell
   flutter doctor
   ```

### 3. Run KathaQuest on Windows

```powershell
# Navigate to project folder
cd C:\path\to\KathaQuest

# Fetch dependencies
flutter pub get

# Option A: Run in Google Chrome / Edge (Recommended)
flutter run -d chrome
# or
flutter run -d edge

# Option B: Run as a Native Windows Desktop Application
flutter run -d windows
```

---

## 🍎 macOS Setup Guide

Tested on **macOS Monterey, Ventura, Sonoma, and Sequoia** on both **Apple Silicon (M1/M2/M3/M4)** and **Intel** Macs.

### 1. Install Prerequisites

1. **Xcode Command Line Tools**:
   ```bash
   xcode-select --install
   ```
2. **Homebrew** (if not already installed):
   ```bash
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   ```
3. **CocoaPods**:
   ```bash
   sudo gem install cocoapods
   # or via brew:
   brew install cocoapods
   ```

### 2. Install Flutter SDK on macOS

```bash
# Create directory
mkdir -p ~/development
cd ~/development

# Download Flutter stable
git clone https://github.com/flutter/flutter.git -b stable

# Add to ~/.zshrc (default shell on macOS)
echo 'export PATH="$HOME/development/flutter/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc

# Verify installation
flutter doctor
```

### 3. Run KathaQuest on macOS

```bash
cd /path/to/KathaQuest

# Fetch dependencies
flutter pub get

# Option A: Run in Chrome (Fastest, zero native compile time)
flutter run -d chrome

# Option B: Run as a Native macOS Desktop Application
flutter run -d macos
```

---

## 📂 Project Architecture

```
KathaQuest/
├── pubspec.yaml                 # Dependencies, assets, fonts, & metadata
├── setup_flutter.sh             # Automated Linux helper script
├── README.md                    # Project documentation & setup guide
├── Docs/
│   ├── GDD.md                   # Game Design Document & pedagogy
│   ├── Story1_Script.md         # Full bilingual story script & audio cues
│   ├── Quiz_Content.md          # Question bank & scoring rubrics
│   └── Playtest_Notes.md        # Child-computer interaction guidelines
├── assets/
│   ├── audio/                   # High quality WAV SFX & chimes
│   │   ├── hare_snore.wav
│   │   ├── hare_whoosh.wav
│   │   ├── kids_cheer.wav
│   │   ├── quiz_correct.wav
│   │   ├── star_twinkle.wav
│   │   ├── tap_pop.wav
│   │   ├── tortoise_step.wav
│   │   └── victory_fanfare.wav
│   ├── fonts/                   # Indian Devanagari typography
│   │   ├── NotoSansDevanagari.ttf
│   │   └── NotoSerifDevanagari.ttf
│   ├── images/
│   │   ├── hero_splash/         # Layered transparent PNG assets
│   │   │   ├── background.png   # Palace, pillars, sky, distant mountains
│   │   │   ├── flowers.png      # Foreground floral border bed
│   │   │   ├── kids.png         # Curious children gazing at scripture
│   │   │   ├── book.png         # Glowing sacred scripture book
│   │   │   ├── constalations.png# Shimmering celestial constellations
│   │   │   ├── char1.png        # Royal King avatar
│   │   │   ├── char2.png        # Winged Simha (Lion) guardian
│   │   │   ├── char3.png        # Radiant Princess Sita
│   │   │   └── char4.png        # Lord Rama with Kodanda bow
│   │   └── backgrounds_for_hare_tortoise_story/ # 5 story backgrounds
│   └── spritesheets/            # Character sprite animations (walk, run, sleep, cheer)
└── lib/
    ├── main.dart                # App entry point with MultiProvider
    ├── core/
    │   ├── app_theme.dart       # Royal Indian palette & tactile button styles
    │   ├── audio_manager.dart   # Cross-platform sound effect controller
    │   ├── save_manager.dart    # Offline JSON progress persistence
    │   ├── audio_service/       # Multiplatform audio service (Web, IO, Stubs)
    │   └── models/              # StoryModel, ComicPanel, MiniGame, UserProfile
    ├── data/
    │   └── sample_stories.dart  # Story 1 ("The Hare and the Tortoise")
    ├── state/
    │   └── game_state.dart      # Global reactive state (Provider)
    ├── screens/
    │   ├── splash_screen.dart   # Main HeroSplashScreen orchestrator
    │   ├── splash/
    │   │   ├── layers/          # Modular parallax, clouds, birds, butterflies, particles
    │   │   └── ui/              # LoadingProgressBar & TapToBeginOverlay
    │   ├── home_dashboard_screen.dart # Story map & daily quest hub
    │   ├── library_screen.dart  # Book collection & star ratings
    │   ├── adventure_map_screen.dart # Interactive chapter map nodes
    │   ├── parent_corner_screen.dart # Pin-gate screen time & analytics
    │   ├── story_screen.dart    # Story orchestrator (Comic, MiniGame, Quiz)
    │   └── reward_screen.dart   # Confetti celebration & medallion unlocks
    ├── features/
    │   ├── comic/               # ComicReaderView, TapReactionWidget, SpeechBubble
    │   ├── minigames/           # ForestWalk, RaceBegins, RhythmSteps, FinalSprint
    │   └── quiz/                # Interactive comprehension quiz
    └── widgets/
        ├── magical_speech_bubble.dart # Glowing storybook bubble system
        ├── bottom_nav_bar.dart  # Custom royal bottom navigation
        ├── steady_meter.dart    # Pacing meter gauge
        └── animated_sprite_widget.dart # Frame-based character sprite engine
```

---

## 🔧 Useful Commands

| Command | Action |
| :--- | :--- |
| `flutter run -d chrome` | Run the application in Google Chrome |
| `flutter run -d linux` | Run as native Linux desktop application |
| `flutter run -d windows` | Run as native Windows desktop application |
| `flutter run -d macos` | Run as native macOS desktop application |
| `flutter run -d edge` | Run in Microsoft Edge on Windows |
| `flutter test` | Run automated unit and state test suite |
| `flutter analyze` | Run static code analysis and lint verification |
| `flutter build web --release` | Generate production web bundle in `build/web/` |

---

## ❓ Troubleshooting & FAQ

### Q: Why do I see a missing font characters warning in the browser console?
Flutter Web checks for system font fallbacks when rendering complex emoji or specific glyphs. KathaQuest includes bundled `NotoSansDevanagari` and `NotoSerifDevanagari` font assets registered in `pubspec.yaml`, ensuring all Hindi and Sanskrit characters render correctly across all platforms.

### Q: Web browser does not play audio on app launch?
Modern web browsers (Chrome, Safari, Edge) block audio autoplay until the user interacts with the page (clicks or taps). In KathaQuest:
- The intro sequence plays visual animations and sound effects.
- Once the user taps the **"Tap to Begin"** prompt, audio context is unlocked and all sounds (footsteps, fanfare, cheers, pop sounds) play with full fidelity.

### Q: Native Linux desktop build fails with missing header files?
Ensure you have installed the GTK3 development headers:
- Fedora: `sudo dnf install gtk3-devel pkg-config`
- Ubuntu/Debian: `sudo apt install libgtk-3-dev pkg-config`

### Q: Native Windows desktop build fails with Visual Studio errors?
Open Visual Studio Installer, click **Modify** on your Visual Studio 2022 installation, and ensure **"Desktop development with C++"** is checked and installed.

---

## 🏆 Smart India Hackathon (SIH) Value Proposition

1. **Bilingual Literacy & Inclusion**: Instant switching between English and Hindi addresses the NEP 2020 mandate for foundational regional language literacy.
2. **Character & Value Education**: Classic Panchatantra and regional folk narratives convey timeless lessons of perseverance, kindness, humility, and critical thinking.
3. **Child Wellness**: Built-in screen time tracking, math verification gates for parents, and non-addictive narrative milestones foster balanced digital habits.
4. **Hardware Equity**: Low-memory footprint enables deployment on affordable devices across government schools and rural learning centers.

---

<div align="center">
Made with ❤️ for young learners by Team KathaQuest.
</div>
