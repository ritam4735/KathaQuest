using System;
using System.Collections;
using UnityEngine;
using UnityEngine.UI;
using TMPro;
using DG.Tweening;

/// <summary>
/// TEMPORARY steps for testing the pipeline before real minigames exist.
/// Delete or ignore once real steps are in.
/// </summary>

// Shows a colored screen with text "MINI-GAME GOES HERE" for N seconds.
[System.Serializable]
public class PlaceholderMiniGameStep : StoryStepData
{
    public string label = "Mini-Game Placeholder";
    public float duration = 3f;

    public override IEnumerator Play(Action onDone)
    {
        Debug.Log($"▶ STEP: {stepLabel} — {label} ({duration}s)");
        yield return new WaitForSeconds(duration);
        onDone?.Invoke();
    }
}
