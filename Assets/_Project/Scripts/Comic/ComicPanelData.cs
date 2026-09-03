using System;
using System.Collections.Generic;
using UnityEngine;

/// <summary>
/// ONE comic panel. Designers create one .asset per panel.
/// A panel = background + optional character sprites positioned on it + dialogue + narration.
/// </summary>
[CreateAssetMenu(fileName = "S1_Panel01", menuName = "KathaQuest/Comic Panel")]
public class ComicPanelData : ScriptableObject
{
    [Header("Visuals")]
    public Sprite backgroundImage;
    [Tooltip("Dialog box at bottom, large narrator-style panel — leave empty to skip")]
    public Sprite largeArt;               // optional full-width illustration above dialogue

    [Header("Characters on this panel")]
    public List<PanelCharacter> characters = new List<PanelCharacter>();

    [Header("Dialogue")]
    [TextArea(2, 4)]
    public string dialogueText;
    [Tooltip("Name displayed above dialogue (e.g., 'Hare'). Empty = narrator style (no name box).")]
    public string speakerName;

    [Header("Narration (Google TTS)")]
    [Tooltip("Audio ID in AudioManager, e.g., S1_P01. Leave empty for silent panel.")]
    public string narrationId;

    [Header("Behaviour")]
    [Tooltip("If true, player must tap to advance. If false, auto-advance after narration + delay.")]
    public bool waitForTap = true;
    public float autoAdvanceDelay = 2f;

    [Tooltip("Extra delay (seconds) after narration finishes before allowing advance — prevents too-fast tapping")]
    public float minPanelTime = 0.5f;

    [Serializable]
    public class PanelCharacter
    {
        [Tooltip("Which slot this character occupies (slots are defined per-panel in ComicReader prefab)")]
        public int slotIndex = 0;          // 0=left, 1=center, 2=right (matches ComicReader slots)
        public Sprite sprite;
        [Tooltip("Optional reaction sprite shown when this character is tapped")]
        public Sprite reactionSprite;
        [Tooltip("SFX played when tapped (AudioManager ID)")]
        public string tapSfxId;
        [Tooltip("Sprite flip?")]
        public bool flipX = false;
    }
}
