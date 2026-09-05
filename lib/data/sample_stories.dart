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
    coverImage: 'assets/images/story_rama_exile.jpg',
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
          ComicPanel(
            panelId: 'rama_panel_1_hermitage',
            backgroundTheme: 'apple_tree_meadow',
            narrationEn:
                'Soon they reached the serene hermitage of the revered sages, where wild deer rested beside burning holy fires in peace.',
            narrationRegional:
                'शीघ्र ही वे ऋषि-मुनियों के शांत आश्रम में पहुँचे, जहाँ हवन कुंड के निकट हिरण निर्भय होकर विचरण कर रहे थे।',
            dialogues: [
              ComicDialogue(
                speaker: 'Lakshmana',
                avatar: '🛡️',
                textEn: 'Brother, the hermitage is near. The sages offer their sacred blessings for our journey.',
                textRegional: 'भ्राता, आश्रम निकट ही है। ऋषिगण हमारी रक्षा के लिए आशीर्वाद दे रहे हैं।',
                isLeftAligned: true,
              ),
              ComicDialogue(
                speaker: 'Lord Rama',
                avatar: '🏹',
                textEn: 'Let us step forward with reverence and gather sacred herbs for our path.',
                textRegional: 'आओ श्रद्धा से आगे बढ़ें और वन के मार्ग पर पवित्र जड़ी-बूटियां एकत्र करें।',
                isLeftAligned: false,
              ),
            ],
            interactiveTargets: [
              ComicCharacterTarget(
                characterId: 'lakshmana',
                name: 'Lakshmana',
                emoji: '🛡️',
                posX: 0.35,
                posY: 0.55,
                tapReactionType: 'boast_zoom',
                soundEffect: 'victory_fanfare',
                speechBubbleOnTap: 'Ever watchful, ever loyal! 🛡️',
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
          ComicPanel(
            panelId: 'rama_panel_2_chase_start',
            backgroundTheme: 'race_track',
            narrationEn:
                'Entranced by its golden splendor, Sita pleaded for the wondrous deer. Rama drew his bow, promising to uncover the truth.',
            narrationRegional:
                'इस स्वर्ण मृग की सुंदरता से मुग्ध होकर सीता जी ने उसे लाने का आग्रह किया। श्री राम ने अपना धनुष उठाया और सत्य की खोज में निकल पड़े।',
            dialogues: [
              ComicDialogue(
                speaker: 'Lord Rama',
                avatar: '🏹',
                textEn: 'Fear not. If it is divine, I will bring it gently. If it is demon illusion, dharma will strike it down.',
                textRegional: 'भय मत करो। यदि यह निर्दोष है तो मैं इसे ले आऊंगा, यदि यह कोई माया है तो धर्म इसका नाश करेगा।',
                isLeftAligned: true,
              ),
            ],
            interactiveTargets: [
              ComicCharacterTarget(
                characterId: 'rama_chase',
                name: 'Rama on Alert',
                emoji: '🏹⭐',
                posX: 0.40,
                posY: 0.55,
                tapReactionType: 'boast_zoom',
                soundEffect: 'victory_fanfare',
                speechBubbleOnTap: 'Truth will prevail! 🏹',
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
    coverImage: 'assets/images/backgrounds_for_hare_tortoise_story/1.png',
    steps: [
      // STEP 1: Comic Scene 1 - The Forest Boast & Challenge (2 Panels)
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
                posX: 0.28,
                posY: 0.68,
                spriteAnimation: 'hare_idle',
                flipX: true,
                tapReactionType: 'boast_zoom',
                soundEffect: 'victory_fanfare',
                speechBubbleOnTap: 'I am the fastest animal in the woods! 🐰💨',
              ),
              ComicCharacterTarget(
                characterId: 'tortoise',
                name: 'Timo Tortoise',
                emoji: '🐢',
                posX: 0.72,
                posY: 0.70,
                spriteAnimation: 'tortoise_idle',
                flipX: false,
                tapReactionType: 'cheer_jump',
                soundEffect: 'star_twinkle',
                speechBubbleOnTap: 'Calm mind, steady footsteps. 🐢🌿',
              ),
            ],
          ),
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
                characterId: 'hare_run',
                name: 'Sprinting Hare',
                emoji: '🐰💨',
                posX: 0.62,
                posY: 0.68,
                spriteAnimation: 'hare_run',
                flipX: true,
                tapReactionType: 'boast_zoom',
                soundEffect: 'victory_fanfare',
                speechBubbleOnTap: 'Zoom! Catch my dust! 💨',
              ),
              ComicCharacterTarget(
                characterId: 'tortoise_walk',
                name: 'Timo Tortoise',
                emoji: '🐢',
                posX: 0.22,
                posY: 0.70,
                spriteAnimation: 'tortoise_walk',
                flipX: true,
                tapReactionType: 'cheer_jump',
                soundEffect: 'footstep_wood',
                speechBubbleOnTap: 'Step by step, straight ahead! 🐾',
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

      // STEP 3: Comic Scene 2 - The Overconfident Nap & Frantic Awakening (2 Panels)
      ComicStep(
        id: 'ht_step_3_mid_race',
        title: 'The Twist in the Race',
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
                posY: 0.76,
                spriteAnimation: 'hare_sleep',
                flipX: true,
                tapReactionType: 'boast_zoom',
                soundEffect: 'star_twinkle',
                speechBubbleOnTap: 'Zzz... snoring away peacefully on the grass... 😴',
              ),
              ComicCharacterTarget(
                characterId: 'tortoise_climb',
                name: 'Determined Timo',
                emoji: '🐢✨',
                posX: 0.72,
                posY: 0.70,
                spriteAnimation: 'tortoise_climb',
                flipX: true,
                tapReactionType: 'cheer_jump',
                soundEffect: 'footstep_wood',
                speechBubbleOnTap: 'Never give up! Onward to the hill! 🐢🏔️',
              ),
            ],
          ),
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
                posX: 0.25,
                posY: 0.70,
                spriteAnimation: 'hare_surprised',
                flipX: true,
                tapReactionType: 'boast_zoom',
                soundEffect: 'victory_fanfare',
                speechBubbleOnTap: 'Oh no! The finish ribbon is right there! 😱',
              ),
              ComicCharacterTarget(
                characterId: 'tortoise_sprint',
                name: 'Sprinting Timo',
                emoji: '🐢💨',
                posX: 0.75,
                posY: 0.70,
                spriteAnimation: 'tortoise_run',
                flipX: true,
                tapReactionType: 'cheer_jump',
                soundEffect: 'footstep_wood',
                speechBubbleOnTap: 'Victory is in reach! 🏁✨',
              ),
            ],
          ),
        ],
      ),

      // STEP 4: Mini-Game 2 - Final Sprint
      const MiniGameStep(
        id: 'ht_step_4_final_sprint',
        title: 'Mini-Game: Final Sprint to the Ribbon!',
        gameType: MiniGameType.finalSprint,
        instructionsEn:
            'Tap as fast as you can to cheer Timo across the hilltop finish line before the hare catches up! Break the red ribbon!',
        instructionsRegional:
            'जितनी जल्दी हो सके टैप करें ताकि कछुआ खरगोश के पहुँचने से पहले लाल फीता काटकर जीत जाए!',
        targetScore: 50,
        durationSeconds: 20,
      ),

      // STEP 5: Comprehension Quiz
      const QuizStep(
        id: 'ht_step_5_quiz',
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

      // STEP 6: Reward Screen
      const RewardStep(
        id: 'ht_step_6_reward',
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
    coverImage: 'assets/images/story_panchatantra.jpg',
    steps: [
      // STEP 1: Comic Intro - The Sweet Jamun Tree
      ComicStep(
        id: 'pancha_step_1_intro',
        title: 'The Sweet Jamun Tree',
        panels: [
          ComicPanel(
            panelId: 'pancha_panel_1',
            backgroundTheme: 'sunny_forest',
            backgroundImage: 'assets/images/backgrounds_for_hare_tortoise_story/1.png',
            narrationEn:
                'High upon a lush rose-apple tree by the sacred river Ganga lived Kapi, a clever and generous monkey.',
            narrationRegional:
                'पवित्र गंगा नदी के तट पर लगे विशाल जामुन के वृक्ष पर कपी नाम का एक बुद्धिमान और दयालु बंदर रहता था।',
            dialogues: [
              ComicDialogue(
                speaker: 'Kapi (Monkey)',
                avatar: '🐒',
                textEn: 'Welcome, Makara! Feast on these ruby-red sweet jamun fruits fresh from my tree!',
                textRegional: 'स्वागत है मकर! इन मीठे और रसीले जामुन का आनंद लो जो मैंने तुम्हारे लिए तोड़े हैं!',
                isLeftAligned: true,
              ),
              ComicDialogue(
                speaker: 'Makara (Crocodile)',
                avatar: '🐊',
                textEn: 'Thank you, kind brother! You are the most generous friend in the whole forest.',
                textRegional: 'धन्यवाद भ्राता! तुम इस वन के सबसे उदार और सच्चे मित्र हो।',
                isLeftAligned: false,
              ),
            ],
            interactiveTargets: [
              ComicCharacterTarget(
                characterId: 'kapi_monkey',
                name: 'Kapi',
                emoji: '🐒',
                posX: 0.32,
                posY: 0.50,
                tapReactionType: 'boast_zoom',
                soundEffect: 'tap_pop',
                speechBubbleOnTap: 'Sweet fruits make true friends! 🍃',
              ),
              ComicCharacterTarget(
                characterId: 'makara_croc',
                name: 'Makara',
                emoji: '🐊',
                posX: 0.68,
                posY: 0.62,
                tapReactionType: 'nod_agree',
                soundEffect: 'tortoise_step',
                speechBubbleOnTap: 'Mmm, delicious jamuns! 🌊',
              ),
            ],
          ),
        ],
      ),

      // STEP 2: Mini-Game 1 - Gathering the Forest Harvest
      const MiniGameStep(
        id: 'pancha_step_2_game',
        title: 'Jamun Harvest Trail',
        gameType: MiniGameType.forestWalk,
        instructionsEn:
            'Slide Kapi left and right to harvest sweet jamuns and golden stars while dodging thorns and river mud!',
        instructionsRegional:
            'मीठे जामुन और सुनहरे तारे एकत्र करने के लिए बाएं और दाएं स्लाइड करें!',
        targetScore: 100,
        durationSeconds: 30,
      ),

      // STEP 3: Comic Scene 2 - The River Treachery & Quick Wit
      ComicStep(
        id: 'pancha_step_3_comic',
        title: 'The Clever Heart Trick',
        panels: [
          ComicPanel(
            panelId: 'pancha_panel_2',
            backgroundTheme: 'race_track',
            backgroundImage: 'assets/images/backgrounds_for_hare_tortoise_story/3.png',
            narrationEn:
                'Midway across the river, Makara confessed his secret: his wife demanded the monkey’s heart! But Kapi did not panic.',
            narrationRegional:
                'नदी के बीचों-बीच पहुंचकर मगरमच्छ ने सच बताया कि उसकी पत्नी बंदर का दिल खाना चाहती है! लेकिन कपी तनिक भी घबराया नहीं।',
            dialogues: [
              ComicDialogue(
                speaker: 'Makara',
                avatar: '🐊',
                textEn: 'Alas friend, my wife says the heart of one who eats such sweet fruit must be sweet as nectar!',
                textRegional: 'मित्र क्षमा करना, मेरी पत्नी का मानना है कि मीठे फल खाने वाले का दिल भी अमृत समान होगा!',
                isLeftAligned: false,
              ),
              ComicDialogue(
                speaker: 'Kapi',
                avatar: '🐒',
                textEn: 'Oh brother, why didn’t you tell me? I keep my heart safely stored in the hollow of the jamun tree! Turn back so I can fetch it!',
                textRegional: 'अरे भ्राता, पहले क्यों नहीं बताया? मैं अपना दिल जामुन के खोखल में सुरक्षित रखता हूँ! मुझे वापस ले चलो!',
                isLeftAligned: true,
              ),
            ],
            interactiveTargets: [
              ComicCharacterTarget(
                characterId: 'kapi_quick_wit',
                name: 'Clever Kapi',
                emoji: '🐒',
                posX: 0.35,
                posY: 0.52,
                tapReactionType: 'boast_zoom',
                soundEffect: 'quiz_correct',
                speechBubbleOnTap: 'Presence of mind conquers danger! 💡',
              ),
            ],
          ),
        ],
      ),

      // STEP 4: Mini-Game 2 - River Animal Memory Match
      const MiniGameStep(
        id: 'pancha_step_4_game',
        title: 'River Creatures Memory Match',
        gameType: MiniGameType.memoryMatch,
        instructionsEn:
            'Flip cards and match pairs of sacred river creatures to help Kapi leap safely back onto the high branch!',
        instructionsRegional:
            'कपी को सुरक्षित किनारे तक पहुँचाने के लिए पवित्र नदी के जीवों के जोड़े खोजें!',
        targetScore: 120,
        durationSeconds: 45,
      ),

      // STEP 5: Educational Quiz
      const QuizStep(
        id: 'pancha_step_5_quiz',
        title: 'Panchatantra Wisdom Quiz',
        questions: [
          QuizQuestion(
            id: 'pq_1',
            questionEn: 'Where did Kapi the clever monkey claim his heart was kept?',
            questionRegional: 'चतुर बंदर कपी ने अपना दिल कहाँ सुरक्षित रखने की बात कही?',
            optionsEn: [
              'Safely in the hollow of the jamun tree',
              'Deep beneath the river sands',
              'Inside a golden chest',
              'Carried by the forest owl',
            ],
            optionsRegional: [
              'जामुन के पेड़ के सुरक्षित खोखल में',
              'नदी की गहरी रेत के नीचे',
              'एक सुनहरे संदूक के भीतर',
              'जंगल के उल्लू के पास',
            ],
            correctOptionIndex: 0,
            explanationEn: 'Kapi used his quick wit to convince the crocodile to swim back to the tree!',
            explanationRegional: 'कपी ने अपनी तीव्र बुद्धि से मगरमच्छ को वापस पेड़ की ओर ले जाने पर मना लिया!',
          ),
          QuizQuestion(
            id: 'pq_2',
            questionEn: 'What is the timeless moral of this Panchatantra fable?',
            questionRegional: 'पंचतंत्र की इस प्रसिद्ध कथा से हमें क्या मुख्य शिक्षा मिलती है?',
            optionsEn: [
              'Presence of mind and wisdom overcome grave danger',
              'Crocodiles can never swim in sweet rivers',
              'Never share fruits with anyone',
              'Trees should always grow far from rivers',
            ],
            optionsRegional: [
              'संकट के समय धैर्य और प्रत्युत्पन्नमति से प्राणों की रक्षा होती है',
              'मगरमच्छ कभी मीठी नदियों में नहीं तैर सकते',
              'अपने फल कभी किसी से साझा न करें',
              'पेड़ों को हमेशा नदी से बहुत दूर होना चाहिए',
            ],
            correctOptionIndex: 0,
            explanationEn: 'When facing unexpected peril, calm intelligence and quick thinking prevail over brute strength.',
            explanationRegional: 'अचानक आए संकट में घबराने के बजाय शांत बुद्धि और चतुराई से हर समस्या का समाधान संभव है।',
          ),
          QuizQuestion(
            id: 'pq_3',
            questionEn: 'Which Sanskrit word signifies monkey in Indian mythology?',
            questionRegional: 'भारतीय पौराणिक ग्रंथों में बंदर के लिए कौन सा संस्कृत शब्द प्रयुक्त होता है?',
            optionsEn: ['वानर (Vanar)', 'गज (Gaj)', 'मयूर (Mayur)', 'अश्व (Ashwa)'],
            optionsRegional: ['वानर (Vanar)', 'गज (Gaj)', 'मयूर (Mayur)', 'अश्व (Ashwa)'],
            correctOptionIndex: 0,
            explanationEn: 'Vanara is the revered monkey hero archetype celebrated throughout the Ramayana and Panchatantra.',
            explanationRegional: 'वानर शब्द रामायण और पंचतंत्र में आदरणीय वानर वीरों के लिए प्रयुक्त होता है।',
          ),
        ],
      ),

      // STEP 6: Victory Reward Celebration
      const RewardStep(
        id: 'pancha_step_6_reward',
        title: 'The Clever Heart Victory',
        badgeName: 'Emerald Green',
        badgeIcon: '🐒🍃',
        badgeDescriptionEn: 'Kapi outsmarted danger with wisdom and presence of mind!',
        badgeDescriptionRegional: 'कपी ने संकट में अपनी अद्भुत चतुराई और सूझबूझ से विजय पाई!',
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
    coverImage: 'assets/images/story_vikram_betaal.jpg',
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
