using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;
using UnityEngine.UI;

public class Countdown : MonoBehaviour
{

    ScoreMaster _master;

    [SerializeField] private Text _text;
    [SerializeField] private Text _gameText;

    [SerializeField] private Image _iconimg;

    [SerializeField] private Sprite[] icons;

    private string scene;

    private float timer;
    // Start is called before the first frame update
    void Start()
    {
        _master = GameObject.FindWithTag("Score")?.GetComponent<ScoreMaster>();
        if (_master == null) gameObject.SetActive(false);
        else
        {
            foreach (Transform t in transform)
            {
                t.gameObject.SetActive(true);
            }
        }
        scene = SceneManager.GetActiveScene().name;
        timer = 3;
        _master.countReady = false;

        switch (scene)
        {
            case "Fire":
                _iconimg.sprite = icons[0];
                _gameText.text = "Blow out the Fire!";
                break;
            case "MiniValve":
                _iconimg.sprite = icons[1];
                _gameText.text = "Rotate your phone to close the valve!";
                break;
            case "Lazer":
                _iconimg.sprite = icons[2];
                _gameText.text = "Shake to power up the laser!";
                break;
            case "Window":
                _iconimg.sprite = icons[3];
                _gameText.text = "Clean the window with touch input!";
                break;
            case "Volcano":
                _iconimg.sprite = icons[1];
                _gameText.text = "Use phone rotation to avoid falling!";
                break;
            case "WaterPlanet":
                _iconimg.sprite = icons[2];
                _gameText.text = "Dodge waves by shaking and jumping!";
                break;
            default:
                _gameText.text = "";
                break;
        }
    }

    // Update is called once per frame
    void Update()
    {
        timer -= Time.deltaTime;
        if (_master != null)
        {
            _text.text = "" + Mathf.Ceil(timer);
            if (timer <= 0){
                _master.countReady = true;
                gameObject.SetActive(false);
            }
        }
    }
}
