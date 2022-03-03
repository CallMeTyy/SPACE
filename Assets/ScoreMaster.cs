using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;
using UnityEngine.SceneManagement;

public class ScoreMaster : MonoBehaviour
{
    private OscMaster _master;
    [SerializeField] FireMaster[] _firePlayers;
    [SerializeField] private Valve[] _valvePlayers;
    [SerializeField] private WindowCleaner[] _windowPlayers;
    [SerializeField] private GameObject[] _lavas;
    [SerializeField] private WaterPlayer[] _water;
    [SerializeField] private LazerMaster _lazerMaster;
    [SerializeField] List<Vector2> scores;
    public bool countReady;
    private string scene;
    private bool lavaReady = false;
    [SerializeField] private GameObject countdown;
    bool initialized;
    bool finalReady;
    float timer;


    // Start is called before the first frame update
    void Start()
    {
        _master = GameObject.FindWithTag("Master")?.GetComponent<OscMaster>();
        scene = SceneManager.GetActiveScene().name;
    }

    public int GetPlayerCount()
    {
        if (_master != null) return _master.GetPlayerCount();
        else return 0;
    }

    public bool isReady()
    {
        if (finalReady) return false;
        if (lavaReady) return true;
        bool ready = true;
        foreach (GameObject p in _lavas)
        {
            if (!p.GetComponent<LavaPlayerController>().ready) ready = false;
        }
        if (ready) lavaReady = true;
        if (countdown != null && ready) countdown.SetActive(true);
        return ready;
    }


    void FinishTime()
    {
        timer += Time.deltaTime;
        if (timer > 1)
        {
            SceneManager.LoadScene("SpaceHub");
        }
    }

    // Update is called once per frame
    void Update()
    {
        if (!initialized)
        {
            _master = GameObject.FindWithTag("Master")?.GetComponent<OscMaster>();
            initialized = true;
        }
        else if (_master == null) return;
        if (scene == "Fire")
        {
            int pdone = 0;
            for (int i = 0; i < _firePlayers.Length; i++)
            {
                scores[i] = new Vector2(_firePlayers[i].getID(), _firePlayers[i].winTime);
                if (_firePlayers[i].winTime != float.MaxValue) pdone++;
            }
            scores.Sort((p1, p2) => p1.y.CompareTo(p2.y));
            if (_master != null && pdone >= 3)
            {
                if (!finalReady)
                {
                    scores.Sort((p1, p2) => p1.y.CompareTo(p2.y));
                    finalReady = true;
                    _master.AddScore((int)scores[0].x, (int)scores[1].x, (int)scores[2].x, (int)scores[3].x);
                }
                FinishTime();
            }
        }
        else if (scene == "MiniValve")
        {
            int pdone = 0;
            for (int i = 0; i < _valvePlayers.Length; i++)
            {
                scores[i] = new Vector2(_valvePlayers[i].GetID(), _valvePlayers[i].winTime);
                if (_valvePlayers[i].winTime != float.MaxValue) pdone++;
            }
            scores.Sort((p1, p2) => p1.y.CompareTo(p2.y));
            if (_master != null && pdone >= 3)
            {
                if (!finalReady)
                {
                    scores.Sort((p1, p2) => p1.y.CompareTo(p2.y));
                    finalReady = true;
                    _master.AddScore((int)scores[0].x, (int)scores[1].x, (int)scores[2].x, (int)scores[3].x);
                }
                FinishTime();
            }
        }
        else if (scene == "Lazer")
        {
            if (_lazerMaster.GetScore().x > 0.95f)
            {
                if (!finalReady)
                {
                    finalReady = true;
                    _master.AddScore(1, 3);
                }
                FinishTime();
            }
            else if (_lazerMaster.GetScore().y > 0.95f)
            {
                if (!finalReady)
                {
                    finalReady = true;
                    _master.AddScore(2, 4);
                }
                FinishTime();
            }
        }
        else if (scene == "Window")
        {
            int pdone = 0;
            for (int i = 0; i < _windowPlayers.Length; i++)
            {
                scores[i] = new Vector2(_windowPlayers[i].GetID(), _windowPlayers[i].timeofwin);
                if (_windowPlayers[i].win) pdone++;
            }
            scores.Sort((p1, p2) => p1.y.CompareTo(p2.y));
            if (_master != null && pdone >= 3)
            {
                if (!finalReady)
                {
                    finalReady = true;
                    _master.AddScore((int)scores[1].x, (int)scores[2].x, (int)scores[3].x, (int)scores[0].x);
                }
                FinishTime();
            }
        }
        else if (scene == "Volcano")
        {
            int pdone = 0;
            for (int i = 0; i < _lavas.Length; i++)
            {
                if (!_lavas[i].gameObject.activeSelf) pdone++;
                scores[i] = new Vector2(_lavas[i].GetComponent<LavaPlayerController>().GetID(), _lavas[i].GetComponent<LavaPlayerController>().timeOfDeath);
            }
            scores.Sort((p1, p2) => p1.y.CompareTo(p2.y));
            if (_master != null && pdone >= 3)
            {
                if (!finalReady)
                {
                    finalReady = true;
                    scores.Sort((p1, p2) => p1.y.CompareTo(p2.y));
                    _master.AddScore((int)scores[0].x, (int)scores[3].x, (int)scores[2].x, (int)scores[1].x);
                }
                FinishTime();
            }
        }
        else if (scene == "WaterPlanet")
        {
            int pdone = 0;
            for (int i = 0; i < _water.Length; i++)
            {
                scores[i] = new Vector2(_water[i].GetID(), _water[i].timeofdeath);
                if (_water[i].timeofdeath != float.MaxValue) pdone++;                
            }
            scores.Sort((p1, p2) => p1.y.CompareTo(p2.y));
            if (_master != null && pdone >= 3)
            {
                if (!finalReady)
                {
                    scores.Sort((p1, p2) => p1.y.CompareTo(p2.y));
                    finalReady = true;
                    _master.AddScore((int)scores[3].x, (int)scores[2].x, (int)scores[1].x, (int)scores[0].x);
                }

                FinishTime();
            }
        }
    }
}
