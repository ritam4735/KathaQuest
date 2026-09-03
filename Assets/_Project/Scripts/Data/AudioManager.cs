using System.Collections;
using System.Collections.Generic;
using UnityEngine;

/// <summary>
/// Singleton. Plays music, SFX, and narration.
/// All audio is referenced by string ID via an AudioManagerAsset
/// (ScriptableObject) so designers can swap sounds without code.
/// </summary>
public class AudioManager : MonoBehaviour
{
    public static AudioManager Instance { get; private set; }

    [Header("Audio Banks")]
    [SerializeField] private List<AudioEntry> musicEntries;
    [SerializeField] private List<AudioEntry> sfxEntries;
    [SerializeField] private List<AudioEntry> narrationEntries;

    [Header("Sources")]
    [SerializeField] private AudioSource musicSource;
    [SerializeField] private AudioSource narrationSource;

    [Range(0f, 1f)]
    [SerializeField] private float musicVolume = 0.6f;
    [Range(0f, 1f)]
    [SerializeField] private float sfxVolume = 1f;
    [Range(0f, 1f)]
    [SerializeField] private float narrationVolume = 1f;

    private Dictionary<string, AudioClip> musicBank;
    private Dictionary<string, AudioClip> sfxBank;
    private Dictionary<string, AudioClip> narrationBank;
    private Coroutine musicFadeRoutine;

    private void Awake()
    {
        if (Instance != null && Instance != this)
        {
            Destroy(gameObject);
            return;
        }
        Instance = this;
        DontDestroyOnLoad(gameObject);

        musicBank = BuildBank(musicEntries);
        sfxBank = BuildBank(sfxEntries);
        narrationBank = BuildBank(narrationEntries);
    }

    private Dictionary<string, AudioClip> BuildBank(List<AudioEntry> entries)
    {
        var bank = new Dictionary<string, AudioClip>();
        foreach (var e in entries)
        {
            if (!string.IsNullOrEmpty(e.id) && e.clip != null)
                bank[e.id] = e.clip;
        }
        return bank;
    }

    // ---------------- MUSIC ----------------

    public void PlayMusic(string id, float fadeDuration = 0.5f)
    {
        if (musicBank == null || !musicBank.TryGetValue(id, out var clip)) 
        {
            Debug.LogWarning($"[AudioManager] Music id not found: {id}");
            return;
        }
        if (musicSource.clip == clip && musicSource.isPlaying) return;

        if (musicFadeRoutine != null) StopCoroutine(musicFadeRoutine);
        musicFadeRoutine = StartCoroutine(FadeToMusic(clip, fadeDuration));
    }

    private IEnumerator FadeToMusic(AudioClip clip, float duration)
    {
        // fade out
        float startVol = musicSource.volume;
        for (float t = 0; t < duration; t += Time.unscaledDeltaTime)
        {
            musicSource.volume = Mathf.Lerp(startVol, 0, t / duration);
            yield return null;
        }
        musicSource.clip = clip;
        musicSource.loop = true;
        musicSource.Play();
        // fade in
        for (float t = 0; t < duration; t += Time.unscaledDeltaTime)
        {
            musicSource.volume Mathf.Lerp(0, musicVolume, t / duration);
            yield return null;
        }
        musicSource.volume = musicVolume;
    }

    // ---------------- SFX ----------------

    public void PlaySFX(string id)
    {
        if (sfxBank != null && sfxBank.TryGetValue(id, out var clip))
        {
            // pooled one-shot source so overlapping sounds work
            var tempSource = gameObject.AddComponent<AudioSource>();
            tempSource.clip = clip;
            tempSource.volume = sfxVolume;
            tempSource.Play();
            Destroy(tempSource, clip.length + 0.1f);
        }
        else Debug.LogWarning($"[AudioManager] SFX id not found: {id}");
    }

    // ---------------- NARRATION ----------------

    /// <summary>Plays narration; returns clip length in seconds (0 if not found).</summary>
    public float PlayNarration(string id)
    {
        if (narrationBank != null && narrationBank.TryGetValue(id, out var clip))
        {
            narrationSource.Stop();
            narrationSource.clip = clip;
            narrationSource.volume = narrationVolume;
            narrationSource.Play();
            return clip.length;
        }
        Debug.LogWarning($"[AudioManager] Narration id not found: {id}");
        return 0f;
    }

    public void StopNarration() => narrationSource.Stop();
    public bool IsNarrationPlaying => narrationSource != null && narrationSource.isPlaying;

    public void StopAllAudio()
    {
        StopNarration();
        musicSource.Stop();
    }

    [System.Serializable]
    public class AudioEntry
    {
        public string id;
        public AudioClip clip;
    }
}
