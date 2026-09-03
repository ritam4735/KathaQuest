#!/usr/bin/env python3
"""
KathaQuest - Text to Speech (TTS) Audio Asset Generator
Generates narration and dialogue MP3 files from Tools/narration.csv using gTTS.
"""

import csv
import os
import sys

def main():
    try:
        from gtts import gTTS
    except ImportError:
        print("gTTS is not installed. Install with: pip install gTTS")
        print("Dry run mode: Reading narration manifest...")
        gTTS = None

    csv_path = os.path.join(os.path.dirname(__file__), 'narration.csv')
    output_dir = os.path.join(os.path.dirname(__file__), '..', 'assets', 'audio')
    os.makedirs(output_dir, exist_ok=True)

    if not os.path.exists(csv_path):
        print(f"Error: Could not find {csv_path}")
        sys.exit(1)

    with open(csv_path, 'r', encoding='utf-8') as f:
        reader = csv.DictReader(f)
        count = 0
        for row in reader:
            audio_file = row['AudioFile']
            text_en = row['TextEn']
            text_hi = row['TextRegional']
            out_file_en = os.path.join(output_dir, f"en_{audio_file}")
            out_file_hi = os.path.join(output_dir, f"hi_{audio_file}")

            print(f"Processing: {audio_file} -> {row['Speaker']}")
            if gTTS:
                # English
                tts_en = gTTS(text=text_en, lang='en', slow=False)
                tts_en.save(out_file_en)
                # Hindi
                tts_hi = gTTS(text=text_hi, lang='hi', slow=False)
                tts_hi.save(out_file_hi)

            count += 1

        print(f"Processed {count} narration items successfully.")

if __name__ == '__main__':
    main()
