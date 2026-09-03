import '../core/models/story_model.dart';

class SampleStories {
  // Flagship Story: Rama's Exile from The Ramayana
  static final Story ramasExile = Story(
    id: 'story_rama_exile',
    titleEn: "Rama's Exile",
    titleRegional: 'राम का वनवास',
    synopsisEn:
        'Embark with Lord Rama, Sita, and Lakshmana into the Dandaka forest, encountering mythical sages, divine trials, and the mystery of the Golden Deer.',
    synopsisRegional:
        'भगवान राम, सीता और लक्ष्मण के साथ दंडक वन की यात्रा पर चलें, जहाँ उनका सामना ऋषियों, दिव्य परीक्षाओं और सोने के हिरण से होता है।',
    moralEn: 'Duty, devotion, and righteousness triumph over deception.',
    moralRegional: 'कर्तव्य, समर्पण और धर्म हमेशा छल पर विजय पाते हैं।',
    coverEmoji: '🏹👑🌲',
    category: 'The Ramayana',
    estimatedMinutes: 6,
    targetAgeMin: 5,
    targetAgeMax: 12,
    steps: [
      // STEP 1: Comic Intro
      ComicStep(
        id: 'rama_step_1_forest',
        title: 'Journey into Dandakaranya',
        panels: [
          ComicPanel(
            panelId: 'rama_panel_1',
            backgroundTheme: 'sunny_forest',
            narrationEn:
                'Accompanied by Sita and Lakshmana, Rama walked serenely through the flowering groves of the Dandaka forest.',
            narrationRegional:
                'सीता और लक्ष्मण के साथ, श्री राम दंडकारण्य के सुरम्य वनों में शांत भाव से आगे बढ़ रहे थे।',
            dialogues: [
              ComicDialogue(
                speaker: 'Lord Rama',
                avatar: '🏹',
                textEn: 'The forest whispers with the blessings of ancient sages. Stay vigilant, brother.',
                textRegional: 'यह पावन वन ऋषियों की तपस्या से गुंजित है। सावधान रहना, भ्राता लक्ष्मण।',
                isLeftAligned: true,
              ),
              ComicDialogue(
                speaker: 'Devi Sita',
                avatar: '🌸',
                textEn: 'Look at the golden light filtering through the sacred banyan trees!',
                textRegional: 'देखिए इन बरगद के वृक्षों से कैसी सुनहरी दिव्य किरणें छनकर आ रही हैं!',
                isLeftAligned: false,
              ),
            ],
            interactiveTargets: [
              ComicCharacterTarget(
                characterId: 'rama',
                name: 'Lord Rama',
                emoji: '🏹',
                posX: 0.30,
                posY: 0.55,
                tapReactionType: 'boast_zoom',
                soundEffect: 'victory_fanfare',
                speechBubbleOnTap: 'Dharma is my guide. 🌟',
              ),
              ComicCharacterTarget(
                characterId: 'sita',
                name: 'Devi Sita',
                emoji: '🌸',
                posX: 0.70,
                posY: 0.58,
                tapReactionType: 'munch_leaf',
                soundEffect: 'star_twinkle',
                speechBubbleOnTap: 'Such divine peace in the woods! 🪷',
              ),
            ],
          ),
        ],
      ),

      // STEP 2: Mini-Game (Forest Walk / Hermitage Trail)
      const MiniGameStep(
        id: 'rama_step_2_minigame',
        title: 'Mini-Game: Hermitage Trail Walk',
        gameType: MiniGameType.forestWalk,
        instructionsEn:
            'Guide the path through the forest! Collect sacred lotus flowers 🪷 and golden stars ⭐ while dodging brambles!',
        instructionsRegional:
            'वन के रास्ते पर आगे बढ़ें! पवित्र कमल 🪷 और चमकते सितारे ⭐ इकट्ठा करें और कांटों से बचें!',
        targetScore: 50,
        durationSeconds: 25,
      ),

      // STEP 3: Comic - Appearance of the Golden Deer
      ComicStep(
        id: 'rama_step_3_deer_comic',
        title: 'The Enigmatic Golden Deer',
        panels: [
          ComicPanel(
            panelId: 'rama_panel_2',
            backgroundTheme: 'apple_tree_meadow',
            narrationEn:
                'Suddenly, an extraordinary deer with golden fur and sapphire horns skipped into the sunlit clearing.',
            narrationRegional:
                'अचानक, सोने जैसी चमकती त्वचा और नीलम जैसे सींगों वाला एक अलौकिक हिरण घास के मैदान में उछलने लगा।',
            dialogues: [
              ComicDialogue(
                speaker: 'Devi Sita',
                avatar: '🌸',
                textEn: 'O Rama, what a wondrous creature! Its skin glistens like spun gold!',
                textRegional: 'हे राम, कितना अद्भुत और मनमोहक मृग है! इसकी चमक शुद्ध स्वर्ण जैसी है!',
                isLeftAligned: true,
              ),
              ComicDialogue(
                speaker: 'Lakshmana',
                avatar: '🛡️',
                textEn: 'Be cautious! Such a creature has never existed. It could be demon Maricha in disguise!',
                textRegional: 'सावधान भ्राता! ऐसा मृग संसार में संभव नहीं। यह मायावी राक्षस मारीच का छल हो सकता है!',
                isLeftAligned: false,
              ),
            ],
            interactiveTargets: [
              ComicCharacterTarget(
                characterId: 'deer',
                name: 'Golden Deer',
                emoji: '🦌✨',
                posX: 0.50,
                posY: 0.45,
                tapReactionType: 'cheer_jump',
                soundEffect: 'star_twinkle',
                speechBubbleOnTap: 'Leap and glitter! ✨',
              ),
            ],
          ),
        ],
      ),

      // STEP 4: Mini-Game - The Chase (Steady Pacing)
      const MiniGameStep(
        id: 'rama_step_4_steady_chase',
        title: 'Mini-Game: Steady Tracking',
        gameType: MiniGameType.raceBegins,
        instructionsEn:
            'Track the illusionary deer! Keep Rama’s spiritual focus in the green STEADY zone to see through the illusion!',
        instructionsRegional:
            'मायावी हिरण की खोज करें! राम की दृष्टि को हरी पट्टी में संतुलित रखें ताकि सच प्रकट हो सके!',
        targetScore: 60,
        durationSeconds: 20,
      ),

      // STEP 5: Comprehension Quiz (Matches Screenshot 4 EXACTLY)
      const QuizStep(
        id: 'rama_step_5_quiz',
        title: 'The Ramayana Quiz',
        questions: [
          QuizQuestion(
            id: 'q_golden_deer',
            questionEn: 'What did the golden deer represent to Sita?',
            questionRegional: 'सीता जी के लिए स्वर्ण मृग क्या था?',
            optionsEn: [
              'A Divine Gift',
              'A Magician’s Illusion',
              'A Demon’s Trap',
              'A Prophecy',
            ],
            optionsRegional: [
              'एक दिव्य उपहार',
              'एक जादुई भ्रम',
              'राक्षस का एक मायावी जाल',
              'एक भविष्यवाणी',
            ],
            correctOptionIndex: 2, // "A Demon's Trap"
            explanationEn:
                'The golden deer was the demon Maricha transformed by Ravana’s cunning plan to lure Rama away from the hermitage!',
            explanationRegional:
                'सोने का हिरण वास्तव में मायावी राक्षस मारीच था, जिसे रावण ने षड्यंत्र रचकर भेजा था!',
          ),
          QuizQuestion(
            id: 'q_lakshmana_warning',
            questionEn: 'Who cautioned that the deer might be an illusion?',
            questionRegional: 'किसने चेतावनी दी थी कि यह हिरण एक छल हो सकता है?',
            optionsEn: [
              'Sage Agastya',
              'Lakshmana',
              'Jatayu',
              'King Janaka',
            ],
            optionsRegional: [
              'ऋषि अगस्त्य',
              'लक्ष्मण जी',
              'जटायु',
              'राजा जनक',
            ],
            correctOptionIndex: 1,
            explanationEn:
                'Lakshmana was perceptive and warned that demons use illusions in the Dandaka forest.',
            explanationRegional:
                'लक्ष्मण जी ने तुरंत भांप लिया था कि दंडकारण्य में राक्षस ऐसे रूप धारण करते हैं।',
          ),
        ],
      ),

      // STEP 6: Reward Screen
      const RewardStep(
        id: 'rama_step_6_rewards',
        title: 'Chapter Completed!',
        badgeName: 'Mythology Master',
        badgeIcon: '🏹🏆',
        badgeDescriptionEn:
            'You mastered the sacred wisdom of the Ramayana and uncovered the mystery of the Golden Deer!',
        badgeDescriptionRegional:
            'आपने रामायण के इस गूढ़ प्रसंग को समझकर स्वर्ण पदक प्राप्त किया!',
        baseStars: 3,
      ),
    ],
  );

  // Flagship Story: The Hare and the Tortoise
  static final Story hareAndTortoise = Story(
    id: 'story_hare_tortoise',
    titleEn: 'The Hare and the Tortoise',
    titleRegional: 'कछुआ और खरगोश',
    synopsisEn:
        'The boastful hare mocks the slow tortoise and challenges him to a race. A timeless tale of perseverance, focus, and humility!',
    synopsisRegional:
        'घमंडी खरगोश ने धीमे कछुए का मजाक उड़ाकर उसे दौड़ की चुनौती दी। धैर्य, निरंतरता और विनम्रता की अमर शिक्षाप्रद कथा!',
    moralEn:
        'Slow and steady wins the race. Hard work, perseverance, and consistency are more valuable than overconfidence.',
    moralRegional:
        'धीमी और निरंतर गति ही दौड़ जीतती है। कठिन परिश्रम और धैर्य अति-आत्मविश्वास से कहीं अधिक मूल्यवान हैं।',
    coverEmoji: '🐢⚡🐰',
    category: 'Panchatantra & Aesop',
    estimatedMinutes: 6,
    targetAgeMin: 4,
    targetAgeMax: 10,
    steps: [
      // STEP 1: Comic Scene 1 - The Forest Boast & Challenge
      ComicStep(
        id: 'ht_step_1_intro',
        title: 'The Forest Clearing Challenge',
        panels: [
          ComicPanel(
            panelId: 'ht_panel_1',
            backgroundTheme: 'sunny_forest',
            backgroundImage:
                'assets/images/backgrounds_for_hare_tortoise_story/1.png',
            narrationEn:
                'Once upon a time, a hare and a tortoise lived in the same forest. The hare was very fast and loved to boast about his speed. He often laughed at the slow-moving tortoise.\n\nOne day, the tortoise grew tired of being mocked and calmly said, "I may be slow, but I challenge you to a race." The hare burst into laughter. "A race? Against you? I\'ll win without even trying!"',
            narrationRegional:
                'एक समय की बात है, एक घने जंगल में एक खरगोश और एक कछुआ रहते थे। खरगोश बहुत तेज दौड़ता था और सदा अपनी गति का घमंड करता था। वह अक्सर कछुए की धीमी चाल का मजाक उड़ाता रहता था।\n\nएक दिन, कछुए ने शांत भाव से कहा, "मैं धीमा जरूर हूँ, पर मैं तुम्हें दौड़ की चुनौती देता हूँ।" खरगोश जोर से हंसा, "दौड़? वो भी तुम्हारे साथ? मैं तो बिना मेहनत किए ही जीत जाऊंगा!"',
            dialogues: [
              ComicDialogue(
                speaker: 'Boastful Hare',
                avatar: '🐰',
                textEn:
                    'Haha! Look at you crawling! No one in this entire forest can match my lightning speed! 💨',
                textRegional:
                    'हाहाहा! जरा अपनी चाल तो देखो! पूरे जंगल में कोई भी मेरी बिजली जैसी गति की बराबरी नहीं कर सकता! 💨',
                isLeftAligned: true,
              ),
              ComicDialogue(
                speaker: 'Timo Tortoise',
                avatar: '🐢',
                textEn:
                    'Speed is not everything, friend Hare. Slow and steady footsteps reach the goal. Let us race!',
                textRegional:
                    'सब कुछ गति ही नहीं होती, मित्र खरगोश। निरंतर और धैर्यवान कदम भी लक्ष्य तक पहुँचते हैं। आओ दौड़ लगाएं!',
                isLeftAligned: false,
              ),
            ],
            interactiveTargets: [
              ComicCharacterTarget(
                characterId: 'hare',
                name: 'Boastful Hare',
                emoji: '🐰',
                posX: 0.30,
                posY: 0.52,
                spriteAnimation: 'hare_idle',
                tapReactionType: 'boast_zoom',
                soundEffect: 'victory_fanfare',
                speechBubbleOnTap: 'I am the fastest animal in the woods! 🐰💨',
              ),
              ComicCharacterTarget(
                characterId: 'tortoise',
                name: 'Timo Tortoise',
                emoji: '🐢',
                posX: 0.72,
                posY: 0.55,
                spriteAnimation: 'tortoise_idle',
                tapReactionType: 'cheer_jump',
                soundEffect: 'star_twinkle',
                speechBubbleOnTap: 'Calm mind, steady footsteps. 🐢🌿',
              ),
            ],
          ),
        ],
      ),

      // STEP 2: Mini-Game 1 - Forest Walk Warm-up
      const MiniGameStep(
        id: 'ht_step_2_forest_walk',
        title: 'Mini-Game: Forest Warm-Up Trail',
        gameType: MiniGameType.forestWalk,
        instructionsEn:
            'Guide Timo along the woodland trail! Collect clovers 🍀 and bright stars ⭐ while dodging muddy brambles to warm up for the big race!',
        instructionsRegional:
            'टीमो को जंगल के रास्ते पर आगे बढ़ाएं! स्वादिष्ट पत्तियां 🍀 और चमकीले सितारे ⭐ इकट्ठा करें और कीचड़ से बचें!',
        targetScore: 50,
        durationSeconds: 20,
      ),

      // STEP 3: Comic Scene 2 - The Race Begins!
      ComicStep(
        id: 'ht_step_3_race_start',
        title: 'The Starting Line',
        panels: [
          ComicPanel(
            panelId: 'ht_panel_2',
            backgroundTheme: 'race_track',
            backgroundImage:
                'assets/images/backgrounds_for_hare_tortoise_story/2.png',
            narrationEn:
                'The other animals gathered to watch. They marked the starting point and the finish line, and the race began!\n\nThe hare leaped forward in a flash of dust, laughing triumphantly as the forest cheered!',
            narrationRegional:
                'जंगल के तमाम पशु-पक्षी यह अनोखी दौड़ देखने उमड़ पड़े। उन्होंने प्रारंभिक रेखा और पहाड़ी पर अंतिम बिंदु तय किया, और सीटी बजते ही दौड़ शुरू हो गई!\n\nखरगोश धूल उड़ाता हुआ पलक झपकते ही आगे निकल गया, जबकि दर्शक तालियां बजा रहे थे!',
            dialogues: [
              ComicDialogue(
                speaker: 'Forest Animals',
                avatar: '🦉',
                textEn: 'Ready... steady... On your mark, get set, GO! 🚩🐾',
                textRegional: 'तैयार... सावधान... अपनी जगह लो, और GO! 🚩🐾',
                isLeftAligned: true,
              ),
              ComicDialogue(
                speaker: 'Boastful Hare',
                avatar: '🐰',
                textEn: 'See you at the finish line, Timo! If you ever reach it! 💨⚡',
                textRegional: 'अंतिम रेखा पर मिलते हैं, कछुआ जी! अगर तुम वहाँ कभी पहुँच पाए तो! 💨⚡',
                isLeftAligned: false,
              ),
            ],
            interactiveTargets: [
              ComicCharacterTarget(
                characterId: 'hare',
                name: 'Sprinting Hare',
                emoji: '🐰💨',
                posX: 0.32,
                posY: 0.50,
                spriteAnimation: 'hare_run',
                tapReactionType: 'boast_zoom',
                soundEffect: 'victory_fanfare',
                speechBubbleOnTap: 'Zoom! Catch my dust! 💨',
              ),
              ComicCharacterTarget(
                characterId: 'tortoise',
                name: 'Timo Tortoise',
                emoji: '🐢',
                posX: 0.68,
                posY: 0.54,
                spriteAnimation: 'tortoise_walk',
                tapReactionType: 'cheer_jump',
                soundEffect: 'footstep_wood',
                speechBubbleOnTap: 'Step by step, straight ahead! 🐾',
              ),
            ],
          ),
        ],
      ),

      // STEP 4: Mini-Game 2 - Steady Pace Racing
      const MiniGameStep(
        id: 'ht_step_4_steady_race',
        title: 'Mini-Game: Steady Pace Challenge',
        gameType: MiniGameType.raceBegins,
        instructionsEn:
            'Tap steadily to keep Timo in the green STEADY zone! Maintain balanced focus while the hare zooms ahead!',
        instructionsRegional:
            'टीमो को हरी पट्टी में संतुलित रखने के लिए स्थिर गति से टैप करें! जब खरगोश आगे भागे, तब अपना ध्यान स्थिर रखें!',
        targetScore: 60,
        durationSeconds: 20,
      ),

      // STEP 5: Comic Scene 3 - The Overconfident Nap
      ComicStep(
        id: 'ht_step_5_shady_nap',
        title: 'The Shady Tree Overlook',
        panels: [
          ComicPanel(
            panelId: 'ht_panel_3',
            backgroundTheme: 'sunny_forest',
            backgroundImage:
                'assets/images/backgrounds_for_hare_tortoise_story/4.png',
            narrationEn:
                'The hare sprinted ahead so quickly that he soon disappeared from sight. Looking back, he saw the tortoise crawling slowly along the path. Feeling overconfident, the hare thought, "The tortoise is so far behind. I have plenty of time to rest."\n\nHe lay down under a shady tree and soon fell fast asleep. Meanwhile, the tortoise kept moving at a slow but steady pace. He never stopped, never looked back, and never gave up.',
            narrationRegional:
                'खरगोश इतनी तेजी से दौड़ा कि कुछ ही पलों में आंखों से ओझल हो गया। पीछे मुड़कर देखने पर उसे कछुआ बहुत दूर, नन्हा सा रेंगता हुआ दिखाई दिया। अति-आत्मविश्वास में भरकर खरगोश ने सोचा, "कछुआ तो मीलों पीछे है। मेरे पास आराम करने का बहुत समय है।"\n\nवह एक घने छायादार पेड़ के नीचे लेट गया और ठंडी हवा में उसे गहरी नींद आ गई। उधर कछुआ बिना रुके, धीमी और दृढ़ गति से लगातार आगे बढ़ता रहा। उसने न पीछे देखा, न आराम किया, और कभी हार नहीं मानी।',
            dialogues: [
              ComicDialogue(
                speaker: 'Sleeping Hare',
                avatar: '🐰',
                textEn: 'Zzz... The breeze is so cool... I can easily sleep for an hour... Zzz... 😴',
                textRegional: 'खर्राटे... यहाँ कितनी ठंडी छांव है... मैं आधा घंटा सो भी लूँ तो भी जीत जाऊंगा... 😴',
                isLeftAligned: true,
              ),
              ComicDialogue(
                speaker: 'Timo Tortoise',
                avatar: '🐢',
                textEn: 'Keep walking... Step by step... The goal gets closer every second! 🐢🌿',
                textRegional: 'चलते रहो... एक-एक कदम... हर पल मंजिल पास आ रही है! 🐢🌿',
                isLeftAligned: false,
              ),
            ],
            interactiveTargets: [
              ComicCharacterTarget(
                characterId: 'sleeping_hare',
                name: 'Sleeping Hare',
                emoji: '🐰💤',
                posX: 0.28,
                posY: 0.54,
                spriteAnimation: 'hare_sleep',
                tapReactionType: 'boast_zoom',
                soundEffect: 'star_twinkle',
                speechBubbleOnTap: 'Zzz... snoring away peacefully... 😴',
              ),
              ComicCharacterTarget(
                characterId: 'tortoise',
                name: 'Determined Timo',
                emoji: '🐢✨',
                posX: 0.72,
                posY: 0.52,
                spriteAnimation: 'tortoise_climb',
                tapReactionType: 'cheer_jump',
                soundEffect: 'footstep_wood',
                speechBubbleOnTap: 'Never give up! Onward to the hill! 🐢🏔️',
              ),
            ],
          ),
        ],
      ),

      // STEP 6: Mini-Game 3 - Rhythm March
      const MiniGameStep(
        id: 'ht_step_6_rhythm_steps',
        title: 'Mini-Game: Steady March Rhythm',
        gameType: MiniGameType.rhythmSteps,
        instructionsEn:
            'While the hare snores, keep Timo’s steady marching cadence! Tap the falling left and right footsteps right as they hit the green target line!',
        instructionsRegional:
            'जब तक खरगोश सो रहा है, कछुए के कदमों की ताल बनाए रखें! बीट लाइन पर आते ही बाएँ और दाएँ कदमों पर सटीक टैप करें!',
        targetScore: 60,
        durationSeconds: 20,
      ),

      // STEP 7: Comic Scene 4 - The Frantic Awakening
      ComicStep(
        id: 'ht_step_7_awakening',
        title: 'The Sunset Awakening',
        panels: [
          ComicPanel(
            panelId: 'ht_panel_4',
            backgroundTheme: 'finish_line',
            backgroundImage:
                'assets/images/backgrounds_for_hare_tortoise_story/5.png',
            narrationEn:
                'After a long nap, the hare suddenly woke up! He noticed the golden evening sun and gasped in horror. He raced toward the finish line as fast as his legs could carry him.\n\nBut it was too late! Timo was already just inches away from the red victory ribbon!',
            narrationRegional:
                'एक लंबी नींद के बाद खरगोश अचानक चौंककर उठा! ढलते सूरज की सुनहरी किरणों को देखकर उसके होश उड़ गए। वह अपने पूरे बल से अंतिम रेखा की ओर बेतहाशा भागा।\n\nपरन्तु अब बहुत देर हो चुकी थी! टीमो कछुआ विजय-फीते से बस कुछ ही इंच दूर पहुँच चुका था!',
            dialogues: [
              ComicDialogue(
                speaker: 'Panicked Hare',
                avatar: '🐰',
                textEn: 'NO! It cannot be! I must run faster than the wind! 😱⚡🏃',
                textRegional: 'नहीं! ऐसा नहीं हो सकता! मुझे आंधी से भी तेज भागना होगा! 😱⚡🏃',
                isLeftAligned: true,
              ),
              ComicDialogue(
                speaker: 'Timo Tortoise',
                avatar: '🐢',
                textEn: 'Just one final push across the red ribbon! 🚩✨',
                textRegional: 'बस एक अंतिम कदम और लाल फीता पार! 🚩✨',
                isLeftAligned: false,
              ),
            ],
            interactiveTargets: [
              ComicCharacterTarget(
                characterId: 'surprised_hare',
                name: 'Shocked Hare',
                emoji: '🐰❗',
                posX: 0.28,
                posY: 0.48,
                spriteAnimation: 'hare_surprised',
                tapReactionType: 'boast_zoom',
                soundEffect: 'victory_fanfare',
                speechBubbleOnTap: 'Oh no! The finish ribbon is right there! 😱',
              ),
              ComicCharacterTarget(
                characterId: 'tortoise',
                name: 'Sprinting Timo',
                emoji: '🐢💨',
                posX: 0.70,
                posY: 0.52,
                spriteAnimation: 'tortoise_run',
                tapReactionType: 'cheer_jump',
                soundEffect: 'footstep_wood',
                speechBubbleOnTap: 'Victory is in reach! 🏁✨',
              ),
            ],
          ),
        ],
      ),

      // STEP 8: Mini-Game 4 - Final Sprint
      const MiniGameStep(
        id: 'ht_step_8_final_sprint',
        title: 'Mini-Game: Final Sprint to the Ribbon!',
        gameType: MiniGameType.finalSprint,
        instructionsEn:
            'Tap as fast as you can to cheer Timo across the hilltop finish line before the hare catches up! Break the red ribbon!',
        instructionsRegional:
            'जितनी जल्दी हो सके टैप करें ताकि कछुआ खरगोश के पहुँचने से पहले लाल फीता काटकर जीत जाए!',
        targetScore: 50,
        durationSeconds: 20,
      ),

      // STEP 9: Comic Scene 5 - Victory & The Timeless Moral
      ComicStep(
        id: 'ht_step_9_moral',
        title: 'Slow and Steady Wins the Race',
        panels: [
          ComicPanel(
            panelId: 'ht_panel_5',
            backgroundTheme: 'finish_line',
            backgroundImage:
                'assets/images/backgrounds_for_hare_tortoise_story/5.png',
            narrationEn:
                'The tortoise had already crossed the finish line, and all the animals were cheering! The red victory ribbon fluttered proudly in the breeze.\n\nThe hare realized that his overconfidence had cost him the race. He congratulated the tortoise and learned an important lesson.\n\n⭐ Moral: Slow and steady wins the race. Hard work, perseverance, and consistency are more valuable than overconfidence.',
            narrationRegional:
                'कछुआ पहले ही विजय-रेखा पार कर चुका था, और पूरा जंगल तालियों की गड़गड़ाहट से गूंज उठा! लाल विजय-फीता गर्व से लहरा रहा था।\n\nखरगोश समझ गया कि उसके अहंकार और अति-आत्मविश्वास ने उसे हरा दिया। उसने सिर झुकाकर कछुए को बधाई दी और जीवन का सबसे अनमोल सबक सीखा।\n\n⭐ नैतिक शिक्षा: धीमी और स्थिर गति ही दौड़ जीतती है। कठिन परिश्रम, धैर्य और निरंतरता अति-आत्मविश्वास से कहीं अधिक श्रेष्ठ हैं।',
            dialogues: [
              ComicDialogue(
                speaker: 'Timo Tortoise',
                avatar: '🐢',
                textEn:
                    'Thank you, dear forest friends! Consistency and perseverance made this victory possible! 🏆🎉',
                textRegional:
                    'धन्यवाद प्यारे मित्रों! कभी न रुकने के संकल्प और धैर्य ने ही आज मुझे विजयी बनाया है! 🏆🎉',
                isLeftAligned: true,
              ),
              ComicDialogue(
                speaker: 'Humbled Hare',
                avatar: '🐰',
                textEn:
                    'You taught me a great truth today, Timo. I will never boast or mock anyone again. Congratulations! 🤝',
                textRegional:
                    'तुमने मुझे आज जीवन का सबसे बड़ा सच सिखाया, टीमो। मैं अब कभी घमंड नहीं करूँगा। तुम्हें बधाई! 🤝',
                isLeftAligned: false,
              ),
            ],
            interactiveTargets: [
              ComicCharacterTarget(
                characterId: 'champion_tortoise',
                name: 'Champion Timo',
                emoji: '🐢🏆',
                posX: 0.35,
                posY: 0.52,
                spriteAnimation: 'tortoise_win',
                tapReactionType: 'cheer_jump',
                soundEffect: 'victory_fanfare',
                speechBubbleOnTap: 'Slow and steady won the race! 🏆✨',
              ),
              ComicCharacterTarget(
                characterId: 'cheering_hare',
                name: 'Humbled Hare',
                emoji: '🐰🤝',
                posX: 0.70,
                posY: 0.52,
                spriteAnimation: 'hare_cheer',
                tapReactionType: 'boast_zoom',
                soundEffect: 'star_twinkle',
                speechBubbleOnTap: 'Congratulations Timo! Great job! 👏',
              ),
            ],
          ),
        ],
      ),

      // STEP 10: Comprehension Quiz
      const QuizStep(
        id: 'ht_step_10_quiz',
        title: 'The Hare & Tortoise Wisdom Quiz',
        questions: [
          QuizQuestion(
            id: 'ht_q1_challenge',
            questionEn: 'Why did Timo the Tortoise challenge the Hare to a race?',
            questionRegional: 'कछुए ने खरगोश को दौड़ की चुनौती क्यों दी?',
            optionsEn: [
              'To win a prize of gold',
              'He was tired of being mocked and wanted to prove perseverance',
              'Because he thought he was faster than the hare',
              'The forest king ordered them to race',
            ],
            optionsRegional: [
              'सोने का पुरस्कार जीतने के लिए',
              'वह उपहास से तंग आ गया था और धैर्य की शक्ति सिद्ध करना चाहता था',
              'क्योंकि उसे लगा वह खरगोश से तेज है',
              'जंगल के राजा ने उन्हें आदेश दिया था',
            ],
            correctOptionIndex: 1,
            explanationEn:
                'Timo stayed calm despite being mocked and proved that steady perseverance triumphs over boasts!',
            explanationRegional:
                'कछुए ने शांत रहकर यह सिद्ध किया कि निरंतर धैर्य और कठिन परिश्रम घमंडी बातों से बड़ा होता है!',
          ),
          QuizQuestion(
            id: 'ht_q2_nap',
            questionEn: 'Why did the Hare stop to sleep under the shady tree?',
            questionRegional: 'खरगोश घने पेड़ के नीचे सोने क्यों रुक गया?',
            optionsEn: [
              'He got hurt during the race',
              'He became overconfident seeing the tortoise far behind',
              'Night had already fallen',
              'He forgot that a race was going on',
            ],
            optionsRegional: [
              'दौड़ते समय उसे चोट लग गई थी',
              'कछुए को बहुत पीछे देखकर वह अति-आत्मविश्वासी हो गया था',
              'अचानक रात हो गई थी',
              'वह भूल गया था कि कोई दौड़ चल रही है',
            ],
            correctOptionIndex: 1,
            explanationEn:
                'The hare was overconfident and assumed he had so much time that he could sleep and still easily win.',
            explanationRegional:
                'खरगोश अति-आत्मविश्वास में था और उसे लगा कि सोने के बाद भी वह आसानी से जीत जाएगा।',
          ),
          QuizQuestion(
            id: 'ht_q3_moral',
            questionEn: 'What is the timeless moral of this story?',
            questionRegional: 'इस अमर कथा की मुख्य नैतिक शिक्षा क्या है?',
            optionsEn: [
              'Speed is all that matters in life',
              'Slow and steady wins the race; perseverance beats overconfidence',
              'Never race near trees',
              'It is better to take long naps during contests',
            ],
            optionsRegional: [
              'जीवन में केवल गति ही मायने रखती है',
              'धीमी और निरंतर गति ही जीतती है; धैर्य अति-आत्मविश्वास को हरा देता है',
              'पेड़ों के पास कभी दौड़ नहीं लगानी चाहिए',
              'प्रतियोगिता के दौरान लंबी नींद लेना अच्छा होता है',
            ],
            correctOptionIndex: 1,
            explanationEn:
                'Consistency, hard work, and determination will always overcome arrogant overconfidence!',
            explanationRegional:
                'निरंतरता, परिश्रम और दृढ़ संकल्प सदा घमंडी अति-आत्मविश्वास पर विजय प्राप्त करते हैं!',
          ),
        ],
      ),

      // STEP 11: Reward Screen
      const RewardStep(
        id: 'ht_step_11_reward',
        title: 'Forest Champion!',
        badgeName: 'Emerald Green Badge',
        badgeIcon: '🐢🏆✨',
        badgeDescriptionEn:
            'You completed The Hare and the Tortoise fable! Slow and steady wins the race!',
        badgeDescriptionRegional:
            'आपने कछुआ और खरगोश की अमर कहानी पूरी कर विजय पदक प्राप्त किया!',
        baseStars: 3,
      ),
    ],
  );

  // Panchatantra Tales
  static final Story panchatantraTales = Story(
    id: 'story_panchatantra',
    titleEn: 'Panchatantra Tales',
    titleRegional: 'पंचतंत्र की कहानियां',
    synopsisEn:
        'Timeless fables of the animal kingdom taught by sage Vishnu Sharma to impart wisdom, strategy, and virtue.',
    synopsisRegional:
        'विष्णु शर्मा द्वारा रचित नीति और बुद्धिमत्ता की अमर कथाएं जो जीवन की सच्ची राह दिखाती हैं।',
    moralEn: 'Wisdom is greater than strength.',
    moralRegional: 'बुद्धि बल से सदैव श्रेष्ठ होती है।',
    coverEmoji: '🌳📖🐒',
    category: 'Panchatantra',
    estimatedMinutes: 5,
    targetAgeMin: 4,
    targetAgeMax: 10,
    steps: [
      const RewardStep(
        id: 'pancha_step',
        title: 'The Wise Monkey',
        badgeName: 'Emerald Green',
        badgeIcon: '🐒🍃',
        badgeDescriptionEn: 'The monkey outsmarted the crocodile with quick wit!',
        badgeDescriptionRegional: 'चतुर बंदर ने अपनी बुद्धि से मगरमच्छ को परास्त किया!',
        baseStars: 3,
      ),
    ],
  );

  // Vikram Betaal
  static final Story vikramBetaal = Story(
    id: 'story_vikram_betaal',
    titleEn: 'Vikram Betaal',
    titleRegional: 'विक्रम और बेताल',
    synopsisEn:
        'King Vikramaditya answers philosophical riddles presented by the wily Betaal during midnight walks through the cremation grounds.',
    synopsisRegional:
        'राजा विक्रमादित्य और चतुर बेताल के गूढ़ दार्शनिक प्रश्न और न्याय के निर्णय।',
    moralEn: 'True justice requires discernment and courage.',
    moralRegional: 'सच्चे न्याय के लिए विवेक और साहस आवश्यक है।',
    coverEmoji: '👑👻🌙',
    category: 'Folklore & Legends',
    estimatedMinutes: 5,
    targetAgeMin: 6,
    targetAgeMax: 12,
    steps: [
      const RewardStep(
        id: 'vikram_step',
        title: "The King's Justice",
        badgeName: 'Saffron Master',
        badgeIcon: '👑⚖️',
        badgeDescriptionEn: 'Mastered the riddles of King Vikramaditya!',
        badgeDescriptionRegional: 'राजा विक्रमादित्य के जटिल न्याय को सिद्ध किया!',
        baseStars: 3,
      ),
    ],
  );

  static List<Story> getAllStories() => [
        hareAndTortoise,
        ramasExile,
        panchatantraTales,
        vikramBetaal,
      ];
}
