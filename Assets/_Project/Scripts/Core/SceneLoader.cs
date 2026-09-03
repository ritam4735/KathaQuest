using UnityEngine;
using UnityEngine.SceneManagement;

/// <summary>
/// Simple helper for UI buttons in the Library/Splash scenes.
/// Attach to a GameObject and wire buttons to its public methods.
/// </summary>
public class SceneLoader : MonoBehaviour
{
    public void LoadSplash()  => GameManager.Instance.LoadSceneManager.SCENE_SPLASH);
    public void LoadLibrary() => GameManager.Instance.LoadScene(GameManager.SCENE_LIBRARY);
    public void LoadStory1()  => GameManager.Instance.LoadScene(GameManager.SCENE_STORY1);
}
