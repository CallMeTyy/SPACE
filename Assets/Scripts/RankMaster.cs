using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;
using UnityEngine.UI;

public class RankMaster : MonoBehaviour
{
    private OscMaster _master;
    [SerializeField] private TextMeshProUGUI _text;
    [SerializeField] private Sprite[] sprites;
    [SerializeField] private Image[] _heads;
    private List<Vector2> winners;

    // Start is called before the first frame update
    void Start()
    {
        winners = new List<Vector2>();
        _master = GameObject.FindWithTag("Master")?.GetComponent<OscMaster>();
        if (_master != null)
        {
            List<int> scores = _master.GetScores();
            for (int i = 0; i < scores.Count; i++)
            {
                winners.Add(new Vector2(i, scores[i]));
            }
        }
        winners.Sort((a,b)=>b.y.CompareTo(a.y));
        string winnings = "";
        for (int i = 0; i < winners.Count; i++)
        {
            winnings += (i+1) + "." + _master.GetNames()[(int)winners[i].x] + " - " + winners[i].y + "\n";
            _heads[i].sprite = sprites[(int) winners[i].x];
        }

        _text.text = winnings;
        Destroy(_master.gameObject);
    }
}
