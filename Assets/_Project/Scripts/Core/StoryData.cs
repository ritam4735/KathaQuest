using System.Collections.Generic;
using UnityEngine;

/// <summary>
/// One asset per story. Holds the ordered sequence of steps.
/// Designers build a whole story here without touching code.
/// </summary>
[CreateAssetMenu(fileName = "Story1_HareTortoise", menuName = "KathaQuest/Story Data")]
public class StoryData : ScriptableObject
{
    public string storyId = "Story1_HareTortoise";
    string storyTitle = "The Hare and the Tortoise";
    public string storySubtitle = "A Panchatantra Classic";

    [Tooltip("Cover image shown in the Library")]
    public Sprite coverImage;

    [Tooltip("Badge awarded on completion")]
    public string badgeId = "Badge_SteadyWinner";

    [Tooltip("Sticker awarded on completion")]
    public string stickerId = "Sticker_Tortoise";

    [Tooltip("Total collectible stars available across all mini-games")]
    public int maxStars = 9;

    [Tooltip("The ordered sequence of steps — comics, minigames, cutscenes, quiz, reward")]
    public List<StoryStepData> steps = new List<StoryStepData>();
}
