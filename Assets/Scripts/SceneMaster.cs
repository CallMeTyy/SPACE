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
    [SerializeField] private AudioSource[] _jetStarting;
    [SerializeField] private List<string> scenes;
    [SerializeField] private string overrideScene = "";
    [SerializeField] private bool or;
    private OscMaster master;
    float[] rtime = new float[4];
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
        for (int j = 0; j < _jetStarting.Length; j++)
        {
            rtime[j] = 3.14f - Random.Range(0.1f, 0.2f);
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
                if (timer < 3.14f && scenes.Count != 0)
                {
                    if (_jet.isPlaying)
                        _jet.Stop();
                    if (!audioData.isPlaying) audioData.Play();

                    for (int i = 0; i < _jetStarting.Length; i++) {
                        if (!_jetStarting[i].isPlaying)
                        {                            
                            if (timer < rtime[i])
                            {
                                _jetStarting[i].Play();
                                rtime[i] -= Random.Range(0.24f, 0.5f);
                            }
                        }
                            
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
                if (or)
                {
                    GoToScene(overrideScene);
                    return;
                }

                if (scenes.Count == 0)
                {
                    GoToScene("Win");
                    return;
                }
                int iii = Random.Range(0, scenes.Count);
                string sceneN = scenes[iii];
                GoToScene(sceneN);
                scenes.RemoveAt(iii);
                master.GetSceneIndex++;
            }
        }
    }
}
