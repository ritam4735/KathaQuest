using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using TMPro;
using DG.Tweening;

/// <summary>
/// Displays comic panels with tap-to-advance, narration playback,
/// character entrance animations, and tap reactions.
/// Singleton placed once in the story scene.
/// </summary>
public class ComicReader : MonoBehaviour
{
    public static ComicReader Instance { get; private set; }

    [Header("Panel UI")]
    [SerializeField] private Image backgroundImage;
    [SerializeField] private Image largeArtImage;      // optional big illustration
    [SerializeField] private TextMeshProUGUI dialogueText;
    [SerializeField] private TextMeshProUGUI speakerNameText;
    [SerializeField] private GameObject speakerNameBox;
    [SerializeField] private GameObject dialogueBox;
    [SerializeField] private Image tapIndicator;       // blinking "tap to continue" arrow

    [Header("Character Slots")]
    [Tooltip("Empty child Transforms in the panel area. 0=left, 1=center, 2=right.")]
    [SerializeField] private Transform[] characterSlots;

    [Header("Typewriter")]
    [SerializeField] private float charsPerSecond = 30f;
    [SerializeField] private bool useTypewriter = true;

    [Header("Narration Sync (karaoke highlight)")]
    [SerializeField] private bool highlightWhileNarrating = true;
    [SerializeField] private Color highlightColor = new Color(1f, 0.85f, 0.2f);

    private List<ComicPanelData> currentPanels;
    private int panelIndex;
    private Action onSequenceDone;
    private bool acceptingTaps;
    private bool canAdvance;
    private Coroutine activePanelRoutine;
    private readonly List<GameObject> spawnedCharacters = new List<GameObject>();
    private Color normalTextColor;

    private void Awake()
    {
        Instance = this;
        normalTextColor = dialogueText.color;
        gameObject.SetActive(false);
    }

    /// <summary>Shows a sequence of panels. Calls onDone after the last one.</summary>
    public IEnumerator Show(List<ComicPanelData> panels, Action onDone)
    {
        currentPanels = panels;
        panelIndex = -1;
        onSequenceDone = onDone;
        gameObject.SetActive);

        yield return ShowNextPanel();
    }

    private IEnumerator ShowNextPanel()
    {
        panelIndex++;
        if (panelIndex >= currentPanels.Count)
        {
            FinishSequence();
            yield break;
        }

        acceptingTaps = false;
        canAdvance = false;

        var panel = currentPanels[panelIndex];
        activePanelRoutine = StartCoroutine(PlayPanel(panel));
    }

    private IEnumerator PlayPanel(ComicPanelData panel)
    {
        // ----- 1. Background crossfade -----
        if (panel.backgroundImage != null)
        {
            backgroundImage.sprite = panel.backgroundImage;
            backgroundImage.color = new Color(1, 1, 1, 0);
            backgroundImage.DOFade(1f, 0.4f);
        }

        // ----- 2. Optional large art pop-in -----
        if (panel.largeArt != null)
        {
            largeArt.sprite = panel.largeArt;
            largeArtImage.gameObject.SetActive(true);
            largeArtImage.transform.localScale = Vector3.one * 0.85f;
            largeArt.transform.DOScale(Vector3.one, 0.35f).SetEasease.OutBack);
        }
        else largeArtImage.gameObject.SetActive(false);

        // ----- 3. Spawn characters at slots with entrance bounce -----
        ClearCharacters();
        foreach (var pc in panel.characters)
        {
            if (pc.sprite == null || pc.slotIndex < 0 || pc.slotIndex >= characterSlots.Length) continue;

            var go = new GameObject($"Char_{pc.slotIndex}", typeof(Image));
            var img = go.GetComponent<Image>();
            img.sprite = pc.sprite;
            img.rectTransform.sizeDelta = GetSpriteSize(pc.sprite);
            go.transform.SetParent(characterSlots[pc.slotIndex], false);
            go.transform.localPosition = Vector3.zero;

            if (pc.flipX) img.rectTransform.localRotation = Quaternion.Euler(0, 180, 0);

            // attach tap reaction
            var reaction = go.AddComponent<TapReaction>();
            reaction.Setup(img, pc.reactionSprite, pc.tapSfxId);

            // entrance animation: pop in from small
            go.transform.localScale = Vector3.zero;
            go.transform.DOScale(Vector3.one, 0.4f).SetEase(Ease.OutBack)
                .SetDelay(0.15f * pc.slotIndex);

            spawnedCharacters.Add(go);
        }

        // ----- 4. Dialogue: speaker name + typewriter text -----
        dialogueBox.SetActive(!string.IsNullOrEmpty(panel.dialogueText));
        if (!string.IsNullOrEmpty(panel.dialogueText))
        {
            bool hasSpeaker = !string.IsNullOrEmpty(panel.speakerName);
            speakerNameBox.SetActive(hasSpeaker);
            speakerNameText.text = hasSpeaker ? panel.speakerName : "";

            dialogueText.color = normalTextColor;
            dialogueText.text = panel.dialogueText;

            if (useTypewriter) yield return Typewriter(panel.dialogueText);
        }

        // ----- 5. Narration -----
        float narrationLength = 0f;
        if (!string.IsNullOrEmpty(panel.narrationId))
        {
            narrationLength = AudioManager.Instance.PlayNarration(panel.narrationId);
            if (highlightWhileNarrating && !string.IsNullOrEmpty(panel.dialogueText))
                StartCoroutine(NarrationHighlight(narrationLength, panel.dialogueText));
        }

        // ----- 6. Wait: minimum time + narration, then enable advance -----
        float wait = Mathf.Max(panel.minPanelTime, 0f);
        if (!panel.waitForTap)
            wait = Mathf.Max(wait, narrationLength + panel.autoAdvanceDelay);

        yield return new WaitForSeconds(wait);
        while (AudioManager.Instance.IsNarrationPlaying && !panel.waitForTap)
            yield return null;

        if (panel.waitForTap)
        {
            canAdvance = true;
            tapIndicator.gameObject.SetActive(true);
            // blink the indicator
            tapIndicator.DOFade(0.3f, 0.5f).SetLoops(-1, LoopType.Yoyo);
        }
        else
        {
            yield return new WaitForSeconds(panel.autoAdvanceDelay);
            ShowNextPanel();
        }
    }

    private IEnumerator Typewriter(string fullText)
    {
        dialogueText.maxVisibleCharacters = 0;
        dialogueText.text = fullText;
        int total = fullText.Length;
        float delay = 1f / charsPerSecond;

        // tap skips typewriter
        while (dialogueText.maxVisibleCharacters < total)
        {
            if (acceptingTapThisPanel && Input.GetMouseButtonDown(0))
            {
                dialogueText.maxVisibleCharacters = total;
                break;
            }
            dialogueText.maxVisibleCharacters++;
            yield return new WaitForSeconds(delay);
        }
    }

    private IEnumerator NarrationHighlight(float duration, string text)
    {
        // Simple karaoke: reveal highlight by increasing maxVisibleCharacters
        // in sync with narration while text is fully displayed.
        // (For v1, we highlight the whole text softly pulsing instead of per-word.)
        float t = 0f;
        while (t < duration && AudioManager.Instance.IsNarrationPlaying)
        {
            t += Time.deltaTime;
            float pulse = 0.5f + 0.5f * Mathf.Sin(t * 4f);
            dialogueText.color = Color.Lerp(normalTextColor, highlightColor, pulse * 0.6f);
            yield return null;
        }
        dialogueText.color = normalTextColor;
    }

    // ---------- Input ----------

    private bool acceptingTapThisPanel;

    private void Update()
    {
        if (!acceptingTaps || !canAdvance) return;
        if (Input.GetMouseButtonDown(0) || (Input.touchCount > 0 && Input.GetTouch(0).phase == TouchPhase.Began))
        {
            AudioManager.Instance.PlaySFX("SFX_UI_Click");
            Advance();
        }
    }

    private void Advance()
    {
        acceptingTaps = false;
        canAdvance = false;
        tapIndicator.DOKill();
        tapIndicator.gameObject.SetActive(false);

        AudioManager.Instance.StopNarration();
        ShowNextPanel();
    }

    // ---------- Helpers ----------

    private void FinishSequence()
    {
        ClearCharacters();
        gameObject.SetActive(false);
        onSequenceDone?.Invoke();
        onSequenceDone = null;
    }

    private void ClearCharacters()
    {
        foreach (var go in spawnedCharacters)
            if (go != null) Destroy(go);
        spawnedCharacters.Clear();
    }

    private Vector2 GetSpriteSize(Sprite s)
    {
        // scale sprite to fit ~40% of screen height
        float targetHeight = Screen.height * 0.4f;
        float scale = targetHeight / s.bounds.size.y;
        return s.bounds.size * scale;
    }

    private void OnEnable() => acceptingTaps = true;
    private void OnDisable()
    {
        acceptingTaps = false;
        DOTween.Kill(dialogueText);
        DOTween.Kill(tapIndicator);
    }
}
