using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;
using UnityEngine.UI;

public class PlayerNameMaster : MonoBehaviour
{
    [SerializeField] private TextMeshProUGUI[] players;

    private OscMaster _master;
    // Start is called before the first frame update
    void Start()
    {
        _master = GameObject.FindWithTag("Master")?.GetComponent<OscMaster>();
        if (_master != null)
        {
            for (int i = 0; i < players.Length; i++)
            {
                players[i].text = _master.GetNames()[i];
            }
        }
    }
}
