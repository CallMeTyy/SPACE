using System;
using System.Collections;
using System.Collections.Generic;
using extOSC;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.SceneManagement;
using UnityEngine.VFX;
using UnityEngine.Audio;
using Random = UnityEngine.Random;

[RequireComponent(typeof(AudioSource))]
public class SceneMaster : MonoBehaviour
{
    AudioSource audioData;

    private bool isInHub;
    private float timer;
    private int index;
    [SerializeField] private Image _img;
    [SerializeField] private Color _color;
    [SerializeField] private float _blinkSpeed;
    [SerializeField] private Material[] _mat;
    [SerializeField] private Animator[] anim;
    [SerializeField] private Text _clock;
    [SerializeField] private GameObject _warnin;
    [SerializeField] private Sprite[] icons;
    [SerializeField] private Image inputIcon;
    [SerializeField] private Text _gameText;
    [SerializeField] private AudioSource _jet;
    [SerializeField] private AudioSource _jetStarting;
    private OscMaster master;
    bool isPlayingAlarm;
    public void GoToScene(string sceneName)
    {
        SceneManager.LoadScene(sceneName);
    }
    public void ClickSound()
    {
        GetComponents<AudioSource>()[1].Play();
    }
    public void Hover()
    {
        GetComponents<AudioSource>()[2].Play();
    }

    private void Start()
    {
        audioData = GetComponents<AudioSource>()[0];

        if (SceneManager.GetActiveScene().name == "SpaceHub") isInHub = true;
        else isInHub = false;

        if (isInHub)
        {
            timer = Random.Range(8, 12);
        }
        for (int i = 0; i < _mat.Length; i++)
        {
            _mat[i].SetFloat("_isStuttering", 0);

        }
        master = GameObject.FindWithTag("Master").GetComponent<OscMaster>();
    }

    public void Update()
    {
        if (isInHub)
        {

            if (timer > 0)
            {
                if (timer > 3.14f)
                {
                    if (!_jet.isPlaying)
                    {
                        _jet.Play();
                    }
                }
                timer -= Time.deltaTime;
                if (timer < 3.14f && index != 5)
                {
                    if (_jet.isPlaying)
                        _jet.Stop();
                    if (!audioData.isPlaying) audioData.Play();

                    if (Mathf.Abs(Mathf.Sin(timer * (_blinkSpeed * 4))) > 0.5f)
                    {
                       
                        _jetStarting.Play();
                      
                    }
                    
                    print(Mathf.Abs(Mathf.Sin(timer * (_blinkSpeed * 2))));

                    _img.color = Mathf.Abs(Mathf.Sin(timer * _blinkSpeed)) * _color;
                    for (int i = 0; i < _mat.Length; i++)
                    {
                        anim[i].SetBool("isBreaking", true);
                        if (_mat[i].GetFloat("_isStuttering") == 0)
                            _mat[i].SetFloat("_isStuttering", 1);
                        float stutterSpeed = _mat[i].GetFloat("_StutterSpeed");
                        
                    }

                    if (!isPlayingAlarm)
                    {
                        AudioManager.instance.Play("Alarm");
                        AudioManager.instance.playTime = AudioManager.instance.GetComponents<AudioSource>()[7].time;
                        AudioManager.instance.StopPlaying("SpaceHub");
                        isPlayingAlarm = true;
                    }
                }

            }
            else
            {
                AudioManager.instance.StopPlaying("Alarm");
                switch (master.GetSceneIndex)
                {
                    case 0:
                        GoToScene("Fire");
                        break;
                    case 1:
                        GoToScene("MiniValve");
                        break;
                    case 2:
                        GoToScene("Lazer");
                        break;
                    case 3:
                        GoToScene("Window");
                        break;
                    case 4:
                        GoToScene("Volcano");
                        break;
                    case 5:
                        GoToScene("WaterPlanet");
                        break;
                    case 6:
                        GoToScene("Win");
                        break;
                    default:
                        timer = Random.Range(12, 16);
                        break;
                }
                master.GetSceneIndex++;
            }
        }
    }
}
