# 📚 KathaQuest (कथाक्वेस्ट)

> **Interactive Bilingual Storytelling & Learning Adventure for Children**  
> *Built with Flutter for high performance, smooth 60–120 FPS, and minimal hardware overhead.*

---

## 🌟 Why Flutter instead of Unity?

Unity projects often require massive GPU power, 4GB+ RAM, and long loading times, causing laptops with integrated graphics to lag or freeze. 

By completely migrating KathaQuest to **Flutter**:
- 🚀 **Ultra-lightweight**: Runs smoothly even on budget laptops, netbooks, or tablets.
- ⚡ **Instant load times**: No waiting minutes for scenes to load.
- 🌐 **Multiplatform**: Runs as a Native Linux Desktop app, in any Web Browser (Chrome/Firefox), or as an Android APK.
- 🎨 **Declarative & Responsive**: Crisp typography, high-DPI scaling, bouncy kid-friendly animations, and silky 60 FPS transitions.

---

## 🎮 Game Architecture & Story Flow

KathaQuest transforms passive reading into an interactive learning quest:

1. **Splash Screen**: Bouncing mascots (Timo the Tortoise 🐢 & Chipper the Hare 🐰), language toggle (English/Hindi), and audio controls.
2. **Story Library**: Story shelf with unlockable storybooks, star ratings, and reading stats.
3. **Interactive Comic Engine**:
   - Touch hot-spots on characters (tap Hare to see him boast and zoom; tap Tortoise to munch leaves).
   - Dynamic dialogue bubbles.
   - Narration read-aloud with sentence highlighting.
4. **4 Interactive Mini-Games**:
   - 🌲 **Forest Trail Walk**: Hand-eye coordination trail collecting stars ⭐ and clover 🍀 while avoiding mud 🟫.
   - ⏱️ **Steady Pace Meter**: Rhythmic pacing game keeping Tortoise in the green "Steady" zone.
   - 🎵 **Rhythm Steps**: Musical beat-matching tapper as Tortoise marches past the snoring hare.
   - 🏁 **The Final Sprint**: High-energy cheering button dash to break the finish line ribbon!
5. **Comprehension Quiz & Moral Check**: 3 interactive multiple-choice questions with instant celebratory feedback and moral explanation.
6. **Reward Screen**: Confetti burst, 1–3 star evaluation, and "Steady Champion" badge unlock.
7. **Parent Corner**: Math-gate verification, screen-time monitor, reading analytics, language defaults, and narration speed slider.

---

## 🛠️ How to Run

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install/linux) (version 3.10+)

### Quick Start
Run the included setup helper:
```bash
./setup_flutter.sh
```

Or run manually:
```bash
# 1. Install dependencies
flutter pub get

# 2. Run automated test suite
flutter test

# 3. Launch the app!
# Option A: In Google Chrome / Web browser (Zero build overhead, ideal for low-spec laptops)
flutter run -d chrome

# Option B: Native Linux Desktop app
flutter run -d linux
```

---

## 📂 Project Structure

```
KathaQuest/
├── pubspec.yaml                 # Flutter package & asset configuration
├── setup_flutter.sh             # Linux helper setup script
├── Docs/
│   ├── GDD.md                   # Game Design Document & pedagogical rationale
│   ├── Story1_Script.md         # Full bilingual story script & audio cues
│   ├── Quiz_Content.md          # Question bank & scoring rubrics
│   └── Playtest_Notes.md        # Child-computer interaction & accessibility guidelines
├── test/
│   └── story_flow_test.dart     # Unit & state transition test suite
├── web/
│   ├── index.html               # Web launcher with kid-friendly loading splash
│   └── manifest.json            # PWA manifest
└── lib/
    ├── main.dart                # Application entry point with MultiProvider
    ├── core/
    │   ├── app_theme.dart       # Vibrant kid-friendly design system & gradients
    │   ├── audio_manager.dart   # Sound effects & narration synchronization
    │   ├── save_manager.dart    # Offline progress persistence
    │   └── models/
    │       ├── story_model.dart # Story, ComicPanel, MiniGame, Quiz & Reward models
    │       └── save_data.dart   # Profile, stats, badges, and settings
    ├── data/
    │   └── sample_stories.dart  # Story 1 ("The Hare and the Tortoise") + upcoming stories
    ├── state/
    │   └── game_state.dart      # Global reactive state (story progress, stars, settings)
    ├── features/
    │   ├── comic/               # Comic reader, speech bubbles, interactive touch targets
    │   ├── minigames/           # 4 interactive mini-games (Forest Walk, Pacing, Rhythm, Sprint)
    │   └── quiz/                # Interactive comprehension quiz with instant feedback
    ├── screens/                 # Splash, Library, Story, Reward & Parent Corner screens
    └── widgets/                 # Custom AppBar, PauseDialog, SteadyMeter, ConfettiOverlay
```

---

## 🏆 Smart India Hackathon (SIH) Highlights
- **Bilingual Education**: Immediate English ⇄ Hindi switching promotes regional literacy and dual-language fluency.
- **Value-Based Learning**: Fables from the Panchatantra instill virtues like perseverance, humility, and critical thinking.
- **Parental Wellness**: Screen-time analytics and parent controls ensure healthy digital habits for young children.
