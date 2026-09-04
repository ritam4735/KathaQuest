# 📚 KathaQuest (कथाक्वेस्ट)

<div align="center">

![Flutter](https://img.shields.io/badge/Flutter-3.10+-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.0+-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Platform](https://img.shields.io/badge/Platform-Web%20%7C%20Linux%20%7C%20Android%20%7C%20iOS%20%7C%20Windows%20%7C%20macOS-4CAF50?style=for-the-badge)
![License](https://img.shields.io/badge/License-MIT-orange?style=for-the-badge)
![Smart India Hackathon](https://img.shields.io/badge/SIH-Finalist%20Project-FF9933?style=for-the-badge)

**An Interactive Bilingual Storytelling & Moral Learning Adventure for Children (Ages 4–9)**  
*Engineered from the ground up with Flutter for 60 FPS performance, lightweight resource usage, and zero GPU overhead.*

[Tech Stack](#-technology-stack) • [Key Features](#-key-features) • [Quick Start](#-quick-start) • [Project Structure](#-project-structure) • [Testing](#-testing)

</div>

---

## 🛠️ Technology Stack

| Layer | Technology | Key Capabilities |
| :--- | :--- | :--- |
| **Framework & Core** | **Flutter (Dart 3.x)** | Cross-platform runtime targeting Web (Chrome/Edge), Linux desktop, Android, iOS, Windows, and macOS with a unified single codebase. |
| **State Management** | **Provider** | Reactive, unidirectional data flow via `ChangeNotifier`. Manages session flow, bilingual state, pause/resume flags, and step revisions cleanly without unnecessary rebuilds. |
| **Database & Storage** | **LocalDatabase & SaveManager** | Lightweight, offline-first document database with typed collections (`UserProfile`, `StoryProgressRecord`, `AnalyticsRecord`). Features schema versioning, debounced write batching, and automated corruption recovery across Web (`localStorage`) and native platforms. |
| **Narration & Speech** | **Web Speech API & Audio Ducking** | Native TTS synthesis with `SpeechSynthesisUtterance`. Captures word boundary events (`onboundary`) for real-time word-by-word visual highlighting. Automatically ducks background music (BGM) while narration is active. |
| **Audio Engine** | **Web Audio & AudioElement** | Low-latency audio playback with asset preloading for chimes, footsteps, cheers, and fanfares across multi-platform audio services. |
| **Animation System** | **Flutter Ticker & CustomPainter** | 60 FPS hardware-accelerated animations using `AnimationController`. Multi-layer parallax background engine, physics-driven particle systems, and sprite sheets via `AnimatedSpriteWidget` with seamless pause-freezing. |
| **Typography & Fonts** | **Noto Serif & Noto Sans Devanagari** | Bundled bilingual typography supporting complex conjuncts and ligatures for English and Hindi (`NotoSerifDevanagari`, `NotoSansDevanagari`). |
| **Haptics & Tactile** | **HapticFeedback** | Tactile confirmation for button taps, quiz option selections, minigame item collections, and celebratory milestones. |

---

## ✨ Key Features

### 🎬 Layered Parallax Hero Splash
- **9 Independent Transparent PNG Layers**: Foreground flora, curious children, glowing scripture book, celestial constellations, and ascending epic characters.
- **Cinematic Timeline**: Multi-plane drift, horizontal cloud floating, soaring birds, 3D fluttering butterflies, volumetric god-rays, and an ambient breathing loop.
- **Interactive "Tap to Begin"**: Asset precaching with camera push-in and light burst unlock.

### 📖 Bilingual Comic Reader & "Read to Me"
- **Synchronized Narration**: Spoken sentences and words highlight in real-time as speech synthesis progresses.
- **Playback Controls**: Play, Pause, Resume, and Replay controls with double-tap prevention.
- **Instant Language Toggle**: One-tap switch between **English** and **Hindi** (`EN` ⇄ `हिन्दी`).
- **Interactive Tap Targets**: Characters react with custom speech bubbles, animations, and sound effects on tap.

### 🎮 4 Pedagogy-Backed Mini-Games
1. 🌲 **Forest Trail Walk (MG1)**: Hand-eye coordination minigame requiring physical tortoise steering (no direct tapping bypass) to collect stars and clovers.
2. ⏱️ **Steady Pace Meter (MG2)**: Rhythmic cadence pacing to keep Timo inside the calm green "Steady Zone".
3. 🎵 **Rhythm Steps (MG3)**: Musical two-lane beat-matching tapper with floating note hit detection.
4. 🏁 **The Final Sprint (MG4)**: High-energy cheering dash to cross the finish line ribbon.
- **Calm Breathing Timer**: Warm gold/amber breathing pulses replace stressful red countdown alarms.
- **3-Tier Encouraging Celebrations**: Performance-based positive feedback (*Amazing!*, *Great job!*, *Wonderful effort!*).
- **HUD Pause Button**: Accessible top-right pause button that completely freezes timers, physics, and animations.

### 🎓 Comprehension Quizzes & Explanations
- **Educational Explanation Cards**: Slide-up + fade cards explaining *"Why is this correct?"* (*"यह सही क्यों है?"*) after answering.
- **Dynamic Content**: Active story title and question progress dots update automatically per story.

### 🔒 Parent Corner & Learning Analytics
- **Randomized Parent Gate**: Arithmetic verification challenge with dynamic numbers preventing child memorization.
- **Learning Analytics**: Screen time tracking, total reading minutes, and story achievement metrics.

---

## 🚀 Quick Start

### 1. Clone & Fetch Dependencies
```bash
git clone https://github.com/ritam4735/KathaQuest.git
cd KathaQuest
flutter pub get
```

### 2. Run in Web Browser (Recommended)
```bash
flutter run -d chrome
```

### 3. Run on Desktop (Optional)
```bash
# Linux
flutter run -d linux

# Windows
flutter run -d windows

# macOS
flutter run -d macos
```

---

## 📂 Project Structure

```
KathaQuest/
├── pubspec.yaml                 # Dependencies, assets, & font registrations
├── setup_flutter.sh             # Linux setup helper script
├── README.md                    # Project documentation
├── test/
│   └── story_flow_test.dart     # Comprehensive unit and flow tests
├── assets/
│   ├── audio/                   # WAV SFX and chimes
│   ├── fonts/                   # NotoSans & NotoSerif Devanagari fonts
│   ├── images/                  # Hero splash layers & story backgrounds
│   └── spritesheets/            # Character sprite animation frames
└── lib/
    ├── main.dart                # App entry point with MultiProvider
    ├── core/
    │   ├── app_theme.dart       # Design system, palettes, and tactile styles
    │   ├── audio_manager.dart   # Audio manager & ducking controller
    │   ├── audio_service/       # Cross-platform Web & IO audio implementations
    │   ├── database/
    │   │   └── local_database.dart # Offline document database & typed DAOs
    │   ├── haptic_feedback_helper.dart # Tactile feedback helper
    │   ├── narration/
    │   │   ├── narration_service.dart     # Narration service abstraction
    │   │   └── narration_service_web.dart # Web Speech API boundary engine
    │   ├── save_manager.dart    # High-level save manager & debouncer
    │   └── models/              # StoryModel, SaveData, UserProfile
    ├── data/
    │   └── sample_stories.dart  # Story definitions (The Hare and the Tortoise, Rama's Exile)
    ├── state/
    │   └── game_state.dart      # Reactive Provider game state
    ├── screens/
    │   ├── splash_screen.dart   # Hero splash screen orchestrator
    │   ├── home_dashboard_screen.dart # Story map & daily quest hub
    │   ├── library_screen.dart  # Storybook collection & ratings
    │   ├── adventure_map_screen.dart  # Chapter map progression nodes
    │   ├── parent_corner_screen.dart  # Randomized math gate & analytics
    │   ├── story_screen.dart    # Story orchestrator (Comic, MiniGame, Quiz)
    │   └── reward_screen.dart   # Confetti celebration & badge unlock
    ├── features/
    │   ├── comic/               # ComicReaderView, speech bubbles, tap reactions
    │   ├── minigames/           # 4 minigames, MiniGameContainer, celebration dialog
    │   └── quiz/                # QuizView with animated explanations
    └── widgets/
        ├── animated_sprite_widget.dart # 60 FPS vsync sprite animation engine
        ├── custom_app_bar.dart         # Custom story app bar
        ├── pause_dialog.dart           # Pause dialog & step reset
        └── tactile_pill_button.dart    # 3D tactile buttons with spring physics
```

---

## 🧪 Testing

Run the automated test suite verifying story progression, pause mechanics, quiz explanations, and state transitions:

```bash
flutter test
```

---

<div align="center">
Made with ❤️ for young learners by Team KathaQuest.
</div>
