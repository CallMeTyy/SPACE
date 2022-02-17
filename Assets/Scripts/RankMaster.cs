using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class RankMaster : MonoBehaviour
{
    private OscMaster _master;
    [SerializeField] private Text _text;
    private List<string> winners;

    // Start is called before the first frame update
    void Start()
    {
        winners = new List<string>();
        _master = GameObject.FindWithTag("Master")?.GetComponent<OscMaster>();
        if (_master != null)
        {
            List<int> scores = _master.GetScores();
            for (int i = 0; i < scores.Count; i++)
            {
                winners.Add("Player " + (i+1) + "     " + scores[i]);
            }
        }
        string winnings = "Rankings\n\n";
        foreach (string w in winners)
        {
            winnings += w + "\n";
        }
        
    }
}
