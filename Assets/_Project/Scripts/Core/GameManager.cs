using UnityEngine;
using UnityEngine.SceneManagement;

/// <summary>
/// Global singleton: scene transitions + shared constants.
/// Created automatically via RuntimeInitializeOnLoadMethod — no setup needed in scenes.
/// </summary>
public class GameManager : MonoBehaviour
{
    public static GameManager Instance { get; private set; }

    // Scene names — match files in Assets/_Project/Scenes/
    public const string SCENE_SPLASH  = "00_Splash";
    public const string SCENE_LIBRARY = "01_Library";
    public const string SCENE_STORY1  = "02_Story1_HareTortoise";

    // Story IDs used by SaveManager
    public const string STORY1_ID = "Story1_HareTortoise";

    private void Awake()
    {
        if (Instance != null && Instance != this) { Destroy(gameObject); return }
        Instance = this;
        DontDestroyOnLoad(gameObject);

        Application.targetFrameRate = 60;
        Screen.sleepTimeout = SleepTimeout.NeverSleep;
    }

    public void LoadScene(string sceneName)
    {
        Time.timeScale = f;
        SceneManager.LoadScene(sceneName);
    }

    public void GoToLibrary() => LoadScene(SCENE_LIBRARY);

    public void StartStory1() => LoadScene(SCENE_STORY1);

    public void QuitGame()
    {
        SaveManager.Instance.Save();
        Application.Quit();
    }
}
