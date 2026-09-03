# KathaQuest - Playtest & UX Guidelines (Ages 4–9)

## 1. Ergonomics & Touch Target Sizing
- Young children have developing fine-motor skills.
- All interactive buttons must have a **minimum hit target of 56x56 dp** with prominent tactile drop shadows so children intuitively perceive them as clickable.
- Avoid cluttered screens; keep key actions centered with generous padding.

## 2. Audio-Visual Feedback & Haptics
- Every tap must produce instant multi-sensory feedback:
  - Visual bounce or scale pop (10–25% elastic scale).
  - Cheerful sound effect (pop, chime, or giggle).
- Immediate feedback prevents repeated accidental taps and frustration.

## 3. Accessibility & Low-Spec Performance
- Use clean vector graphics and `CustomPainter` rendering rather than heavy video files or uncompressed 3D assets.
- Ensure the app stays above 60 FPS on low-power dual-core laptops and budget Android tablets.
- Keep background music gentle and duck audio during dialogue narration so voices remain crystal clear.

## 4. Bilingual Language Scaffolding
- Providing instant one-tap toggles between English and Hindi allows kids to hear regional phrasing and build dual-language vocabulary naturally.
- Highlight narration sentences dynamically to support early literacy.
