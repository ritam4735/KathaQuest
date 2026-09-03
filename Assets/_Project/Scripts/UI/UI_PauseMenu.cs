using UnityEngine;
using UnityEngine.UI;

/// <summary>
/// Simple pause overlay. Place the prefab in the story scene.
/// </summary>
public class UI_PauseMenu : MonoBehaviour
{
    public static UI_PauseMenu Instance { get; private set; }

    [SerializeField] private GameObject panel;
    [SerializeField] private Button resumeButton;
    [SerializeField] private Button restartButton;
    [SerializeField] private Button homeButton;

    private void Awake()
    {
        Instance = this;
        panel.SetActive(false);

        resumeButton.onClick.AddListener(Hide);
        restartButton.onClick.AddListener(() =>
        {
            Hide();
            GameManager.Instance.LoadScene(GameManager.SCENE_STORY1);
        });
        homeButton.onClick.AddListener(() => GameManager.Instance.GoToLibrary());
    }

    public void Show()
    {
        panel.SetActive(true);
        StoryManager.Instance.SetPaused(true);
    }

    public void Hide()
    {
        panel.SetActive(false);
        StoryManager.Instance.SetPaused(false);
   }
