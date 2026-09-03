using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

/// <summary>
/// A story step that shows a sequence of comic panels.
/// </summary>
[CreateAssetMenu(fileName = "ComicStep_", menuName = "KathaQuest/Steps/Comic Step")]
public class ComicStepData : StoryStepData
{
    public List<ComicPanelData> panels = new List<ComicPanelData>();

    public override IEnumerator Play(Action onDone)
    {
        yield return ComicReader.Instance.Show(panels, onDone);
   }
