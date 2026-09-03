# KathaQuest - Game Design Document (GDD)

**Project Name:** KathaQuest (कथाक्वेस्ट)  
**Target Audience:** Children aged 4–9 years, parents, and educators  
**Target Event / Track:** Smart India Hackathon (SIH) - Interactive Learning & Storytelling  
**Tech Stack:** Flutter 3.x (Dart) • Linux Desktop, Web, Android, iOS  
**Core USP:** An interactive, bilingual storybook adventure merging comic narrative panels, mini-game challenges, and comprehension quizzes to instill positive morals and cognitive skills.

---

## 1. Executive Summary

Traditional storybooks are passive, while modern video games often lack educational rigor and moral grounding. **KathaQuest** bridges this gap by creating an interactive, game-infused storytelling experience rooted in Indian fables (Panchatantra, Jataka tales, and classic folklore).

Instead of passively turning pages, young children become active participants:
- They interact directly with characters via playful touch hot-spots.
- They guide characters through narrative-driven mini-games that embody the story's core moral lesson (e.g., maintaining a calm, steady rhythm rather than rushing).
- They answer engaging comprehension quizzes that reinforce moral reflection and vocabulary.
- Parents track reading time, completed stories, and comprehension metrics in a dedicated **Parent Corner**.

---

## 2. Core Game Loop

```
┌────────────────────────────────────────────────────────┐
│                   SPLASH SCREEN                        │
│   (Vibrant branding, Mascots, Language & Audio Setup)  │
└───────────────────────────┬────────────────────────────┘
                            │
                            ▼
┌────────────────────────────────────────────────────────┐
│                   STORY LIBRARY                        │
│    (Story cards, Star tallies, Profile, Parent Corner)  │
└───────────────────────────┬────────────────────────────┘
                            │ Select Story 1: Hare & Tortoise
                            ▼
┌────────────────────────────────────────────────────────┐
│                   STORY SESSION                        │
│                                                        │
│  Step 1: Comic Scene - The Boastful Challenge          │
│  Step 2: Mini-Game 1 - Forest Trail Collectibles       │
│  Step 3: Comic Scene - The Race Begins!                │
│  Step 4: Mini-Game 2 - Steady Pace Meter               │
│  Step 5: Comic Scene - The Hare's Careless Nap         │
│  Step 6: Mini-Game 3 - Rhythm Footsteps                │
│  Step 7: Comic Scene - Approaching the Finish Line     │
│  Step 8: Mini-Game 4 - Final Sprint Dash!              │
│  Step 9: Comprehension Quiz & Moral Reinforcement     │
│  Step 10: Reward Celebration & Badge Unlock            │
└───────────────────────────┬────────────────────────────┘
                            │
                            ▼
┌────────────────────────────────────────────────────────┐
│               PARENT CORNER & ANALYTICS                │
│   (Screen-time monitoring, Reading logs, Audio config) │
└────────────────────────────────────────────────────────┘
```

---

## 3. Flagship Story: "The Hare & the Tortoise" (कछुआ और खरगोश)

### Educational Objective
Teach children the value of **persistence, patience, and consistency** ("Slow and steady wins the race") over arrogance and hasty overconfidence.

### Narrative & Game Mechanics Progression

| Step # | Type | Name | Mechanic / Focus | Learning Goal |
|---|---|---|---|---|
| **1** | Comic | The Great Forest Challenge | Interactive tap targets: Hare zooms with dust clouds; Tortoise gently munches clover. | Character introduction & vocabulary. |
| **2** | Mini-Game | Forest Trail Walk | Drag Tortoise to collect stars ⭐ (+15) and leaves 🍃 (+10) while dodging mud 🟫. | Hand-eye coordination and spatial awareness. |
| **3** | Comic | Ready, Steady, GO! | Owl referee gives countdown; Hare shoots off like a rocket. | Narrative pacing & anticipation. |
| **4** | Mini-Game | Steady Pace Meter | Tap in rhythm to keep the gauge needle in the green "STEADY" zone. | Self-regulation, impulse control, and pacing. |
| **5** | Comic | The Boastful Nap | Hare eats apples and falls asleep snoring under the tree ("Zzz..."). | Cause-and-effect understanding. |
| **6** | Mini-Game | Rhythm Steps | Musical stepping stones scroll down; tap on beat as Timo marches past Hare. | Rhythm recognition, auditory-motor coordination. |
| **7** | Comic | The Wake-Up Call! | Animals erupt into cheers as Timo nears the ribbon; Hare awakens in panic! | Climax & narrative tension. |
| **8** | Mini-Game | The Winning Step! | Rapid cheering button taps to guide Tortoise across the ribbon. | Energetic climax and emotional satisfaction. |
| **9** | Quiz | Comprehension & Moral Check | 3 multiple-choice questions with immediate cheerful feedback & explanations. | Reading comprehension, ethical reflection. |
| **10** | Reward | Victory Celebration! | Confetti particle explosion, 1–3 star reveal, "Steady Champion" badge. | Positive reinforcement and achievement. |

---

## 4. Hardware Optimization & Low-Spec Architecture

Unity projects require significant GPU shaders, 4GB+ RAM, and heavy scene loaders that struggle on low-spec student/hackathon laptops.

By switching KathaQuest to **Flutter**:
1. **Lightweight Execution**: Uses Skia/Impeller rendering pipeline, running at 60–120 FPS on integrated Intel HD graphics and 2GB RAM.
2. **Instant Hot Reload**: Changes to UI and logic update in under 1 second without lengthy Unity recompile pauses.
3. **No Bloat Dependencies**: Mini-games use Flutter's built-in `CustomPainter`, `TickerProviderStateMixin`, and `GestureDetector` instead of heavy external engines.
4. **Universal Deployment**: Same codebase compiles to Linux Desktop (Fedora/Ubuntu), Web (Chrome/Firefox), and Mobile (Android/iOS).

---

## 5. Parent Corner & Child Safety

- **Parent Gate**: Simple verification equation (e.g. `5 + 4 = 9`) prevents accidental tampering by young kids.
- **Screen-Time Monitor**: Real-time counter of reading minutes with recommended limits.
- **Language Switcher**: Seamless toggle between Hindi (हिंदी) and English for bilingual language acquisition.
- **Accessibility**: Adjustable narration speed (0.8x to 1.5x) for early readers or children with learning differences.
