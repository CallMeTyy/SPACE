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
        else if (scene == "Window")
        {
            int pdone = 0;
            for (int i = 0; i < _windowPlayers.Length; i++)
            {
                if (_windowPlayers[i].win && scores[i].x == 0) scores[i] = new Vector2(_windowPlayers[i].GetID(),Time.time);
                if (scores[i].x != 0) pdone++;
            }

            if (_master != null && pdone >= 3)
            {
                scores.Sort((p1,p2)=>p1.y.CompareTo(p2.y));
                _master.AddScore((int) scores[0].x, (int) scores[1].x, (int) scores[2].x, (int) scores[3].x);
                SceneManager.LoadScene("SpaceHub");
            }
        }
        else if (scene == "Volcano")
        {
            int pdone = 0;
            for (int i = 0; i < _lavas.Length; i++)
            {
                if (!_lavas[i].gameObject.activeSelf) pdone++;
                if (scores[i].x == 0 && !_lavas[i].gameObject.activeSelf)
                {
                    GetComponent<AudioSource>().Play();
                    scores[i] = new Vector2(_lavas[i].GetComponent<LavaPlayerController>().GetID(), Time.time);
                }
            }
            
            if (_master != null && pdone >= 3)
            {
                scores.Sort((p1,p2)=>p1.y.CompareTo(p2.y));
                for (int i = 0; i < _lavas.Length; i++)
                {
                    if (_lavas[i].gameObject.activeSelf)
                        scores[0] = new Vector2(_lavas[i].GetComponent<LavaPlayerController>().GetID(), 0);
                }
                _master.AddScore((int) scores[0].x, (int) scores[3].x, (int) scores[2].x, (int) scores[1].x);
                SceneManager.LoadScene("SpaceHub");
            }
        }
        else if (scene == "WaterPlanet")
        {
            int pdone = 0;
            for (int i = 0; i < _water.Length; i++)
            {
                if (_water[i].dead && scores[i].x == 0) scores[i] = new Vector2(_water[i].GetID(),Time.time);
                if (scores[i].x != 0) pdone++;
            }

            if (_master != null && pdone >= 3)
            {
                scores.Sort((p1,p2)=>p1.y.CompareTo(p2.y));
                _master.AddScore((int) scores[3].x, (int) scores[0].x, (int) scores[1].x, (int) scores[2].x);
                SceneManager.LoadScene("SpaceHub");
            }
        }
    }
}
