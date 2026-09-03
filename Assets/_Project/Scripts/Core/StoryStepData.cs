using System;
using System.Collections;
using UnityEngine;

/// <summary>
/// Abstract base for every step in a story.
/// Subclasses define their data in the Inspector and implement Play().
/// Play() must call onDone exactly once when finished.
/// </summary>
[Serializable]
public abstract class StoryStepData
{
    [Tooltip("Shown for debugging in the StoryManager inspector")]
    public string stepLabel;

    public abstract IEnumerator Play(Action onDone);
}
