using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class ScoreMaster : MonoBehaviour
{
    private OscMaster _master;
    [SerializeField] FireMaster[] _firePlayers;
    [SerializeField] private Valve[] _valvePlayers;
    [SerializeField] private LazerMaster _lazerMaster;
    [SerializeField] List<Vector2> scores;

    private string scene;

    // Start is called before the first frame update
    void Start()
    {
        _master = GameObject.FindWithTag("Master")?.GetComponent<OscMaster>();
        scene = SceneManager.GetActiveScene().name;
    }

    public int GetPlayerCount()
    {
        return _master.GetPlayerCount();
    }

    // Update is called once per frame
    void Update()
    {
        if (_master == null) return;
        if (scene == "Fire")
        {
            for (int i = 0; i < _firePlayers.Length; i++)
            {
                scores[i] = new Vector2(_firePlayers[i].getID(),_firePlayers[i].GetScore());
            }
            scores.Sort((p1,p2)=>p1.y.CompareTo(p2.y));
            if (_master != null && scores[2].y < 0.05f)
            {
                _master.AddScore((int) scores[0].x, (int) scores[1].x, (int) scores[2].x, (int) scores[3].x);
                SceneManager.LoadScene("SpaceHub");
            }
        } else if (scene == "MiniValve")
        {
            for (int i = 0; i < _valvePlayers.Length; i++)
            {
                scores[i] = new Vector2(_valvePlayers[i].GetID(),_valvePlayers[i].GetAngle());
            }
            scores.Sort((p1,p2)=>p1.y.CompareTo(p2.y));
            if (_master != null && scores[1].y > 1800)
            {
                _master.AddScore((int) scores[3].x, (int) scores[2].x, (int) scores[1].x, (int) scores[0].x);
                SceneManager.LoadScene("SpaceHub");
            }
        } else if (scene == "Lazer")
        {
            if (_lazerMaster.GetScore().x > 0.95f)
            { 
                _master.AddScore(1,3);
                SceneManager.LoadScene("SpaceHub");
            } else if (_lazerMaster.GetScore().y > 0.95f)
            {
                _master.AddScore(2,4);
                SceneManager.LoadScene("SpaceHub");
            }
        }
    }
}
