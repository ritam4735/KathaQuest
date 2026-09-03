using System;
using System.IO;
using UnityEngine;

/// <summary>
/// Singleton. Persists SaveData as JSON in persistentDataPath.
/// </summary>
public class SaveManager : MonoBehaviour
{
    public static SaveManager Instance { get; private set; }

    private SaveData data;
    private string SavePath => Path.Combine(Application.persistentDataPath, "kathaquest_save.json");

    private void Awake()
    {
        if (Instance != null && Instance != this) { Destroy(gameObject); return; }
        Instance = this;
        DontDestroyOnLoad(gameObject);
        Load();
    }

    public SaveData Data => data;

    public void Load()
    {
        try
        {
            if (File.Exists(SavePath))
            {
                string json = File.ReadAllText(SavePath);
                data = JsonUtility.FromJson<SaveData>(json) ?? new SaveData();
            }
            else data = new SaveData();
        }
        catch (Exception e)
        {
            Debug.LogError($"[SaveManager] Load failed: {e.Message}");
            data = new SaveData();
        }
    }

    public void Save()
    {
        try
        {
            string json = JsonUtility.ToJson(data, true);
            File.WriteAllText(SavePath, json);
        }
        catch (Exception e)
        {
            Debug.LogError($"[SaveManager] Save failed: {e.Message}");
        }
    }

    // ---------- Convenience methods ----------

    public void RecordStepCompleted(string storyId, int stepIndex)
    {
        var p = data.GetOrCreateStory(storyId);
        if (stepIndex > p.lastStepIndex) p.lastStepIndex = stepIndex;
        Save();
    }

    public void AddStars(string storyId, int stars)
    {
        var p = data.GetOrCreateStory(storyId);
        p.starsEarned += stars;
        Save();
    }

    public void CompleteStory(string storyId, string badgeId, string stickerId)
    {
        var p = data.GetOrCreateStory(storyId);
        p.completed = true;
        if (!string.IsNullOrEmpty(badgeId) && !p.badges.Contains(badgeId))
            p.badges.Add(badgeId);
        if (!string.IsNullOrEmpty(stickerId) && !data.stickers.Contains(stickerId))
            data.stickers.Add(stickerId);
        Save();
    }

    public void ResetAll()
    {
        data = new SaveData();
        Save();
    }

    private void OnApplicationPause(bool paused)
    {
        if (paused) Save();  // mobile safety
    }
}
