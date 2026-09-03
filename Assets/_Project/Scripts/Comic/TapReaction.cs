using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.UI;
using DG.Tweening;

/// <summary>
/// Attached to characters in comic panels.
/// When tapped: swaps to reaction sprite briefly + plays SFX + squash-stretch bounce.
/// </summary>
 class TapReaction : MonoBehaviour, IPointerClickHandler
{
    private Image image;
    private Sprite originalSprite;
    private Sprite reactionSprite;
    private string sfxId;
    private bool reacting;

    public void Setup(Image img, Sprite reaction, string sfx)
    {
        image = img;
        originalSprite = img.sprite;
        reactionSprite = reaction;
        sfxId = sfx;
    }

    public void OnPointerClick(PointerEventData eventData)
    {
        if (reacting) return;
        reacting = true;

        if (!string.IsNullOrEmpty(sfxId))
            AudioManager.Instance.PlaySFX(sfxId);

        if (reactionSprite != null)
            image.sprite = reactionSprite;

        // playful squash & stretch
        var rt = image.rectTransform;
        rt.DOScale(new Vector3(1.15f, 0.9f, 1f), 0.1f)
          .OnComplete(() =>
              rt.DOScale(Vector3.one, 0.25f).SetEase(Ease.OutBack));

        // revert sprite after 1s
        DOVirtual.DelayedCall(1.0f, () =>
        {
            if (image != null && originalSprite != null)
                image.sprite = originalSprite;
            reacting = false;
        });
    }
}
