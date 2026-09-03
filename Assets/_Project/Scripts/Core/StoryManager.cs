using System;
using System.Collections;
using UnityEngine;
using UnityEngine.UI;

/// <summary>
/// Runs a story: plays each step in order, calls the next when one finishes.
/// Place in the story scene; assign a StoryData asset.
/// </summary>
public class StoryManager : MonoBehaviour
{
    public static StoryManager Instance { get; private set; }

    [Header("Story Content")]
    [SerializeField] private StoryData story;

    [Header("UI")]
    [SerializeField] private CanvasGroup fadeCanvas;   // fullscreen black Image for fades (alpha=1 default)
    [SerializeField] private Button pauseButton;

    [Header("Options")]
    [SerializeField] private float fadeInDuration = 0.6f;

    public string StoryId => story != null ? story.storyId : "";
    public int CurrentStepIndex { get; private set; } = -1;

    private bool isRunning;
    public bool IsPaused { get; private set; }

    private void Awake()
    {
        Instance = this;
    }

    private void Start()
    {
        if (pauseButton != null)
            pauseButton.onClick.AddListener(() => UI_PauseMenu.Instance?.Show());

        StartCoroutine(RunStory());
    }

    private IEnumerator RunStory()
    {
        if (story == null || story.steps.Count == 0)
        {
            Debug.LogError("[StoryManager] No StoryData or no steps assigned!");
            yield break;
        }

        // fade in from black
        yield return Fade(1f, 0f, fadeInDuration);

        isRunning = true;
        CurrentStepIndex = -1;
        NextStep();
    }

    /// <summary>Called by steps when they finish. Advances to next step.</summary>
    public void NextStep()
    {
        if (!isRunning) return;

        // record progress for resume feature (v1.1; harmless now)
        if (CurrentStepIndex >= 0 && SaveManager.Instance != null)
            SaveManager.Instance.RecordStepCompleted(story.storyId, CurrentStepIndex);

        CurrentStepIndex++;

        if (CurrentStepIndex >= story.steps.Count)
        {
            isRunning = false;
            StoryCompleted();
            return;
        }

        var step = story.steps[CurrentStepIndex];
        StartCoroutine(WrapStep(step));
    }

    private IEnumerator WrapStep(StoryStepData step)
    {
        Action onDone = null;
 bool done = false;
        onDone = () => done = true;

        yield return StartCoroutine(step.Play(onDone));

        // safety: if a step forgot to call onDone, don't hang forever
        float guard = 0f;
        while (!done && guard < 30f) { guard += Time.deltaTime; yield return null; }

        if (!done) Debug.LogWarning($"[StoryManager] Step '{step.stepLabel}' never called onDone.");
        else NextStep();
    }

    private void StoryCompleted()
    {
        SaveManager.Instance.CompleteStory(story.storyId, story.badgeId, story.stickerId);
        // Reward step (last step in list) already handled UI; go home after a delay
        StartCoroutine(DelayThenLibrary(4f));
    }

    private IEnumerator DelayThenLibrary(float seconds)
    {
        yield return new WaitForSeconds(seconds);
        GameManager.Instance.GoToLibrary();
    }

    // ---------- Pause support ----------

    public void SetPaused(bool paused)
    {
        IsPaused = paused;
        Time.timeScale = paused ? 0f :1f;
        AudioListener.pause = paused;
    }

    // ---------- Fade helper (used by steps for transitions) ----------

    public IEnumerator FadeOut(float duration) => Fade(0f, 1f, duration);
    public IEnumerator FadeIn(float duration)  => Fade(1f, 0f, duration);

    private IEnumerator Fade(float from, float to, float duration)
    {
        if (fadeCanvas ==) yield break;
        float t = 0f;
        fadeCanvas.blocksRaycasts = true;
        while (t < duration)
        {
            t += Time.unscaledDeltaTime;
            fadeCanvas.alpha = Mathf.Lerp(from, to, t / duration);
            yield return null;
        }
        fadeCanvas.alpha = to;
        fadeCanvas.blocksRaycasts = to > 0.5f;
    }
}
