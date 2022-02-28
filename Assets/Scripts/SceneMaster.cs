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
    private bool isPlayingAlarm;
    private OscMaster master;

    public void GoToScene(string sceneName)
    {
        SceneManager.LoadScene(sceneName);
    }

    private void Start()
    {
        audioData = GetComponent<AudioSource>();

        if (SceneManager.GetActiveScene().name == "SpaceHub") isInHub = true;
        else isInHub = false;

        if (isInHub)
        {
            timer = Random.Range(12, 16);
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

                timer -= Time.deltaTime;
                if (timer < 6f)
                {
                    if (!audioData.isPlaying) audioData.Play();

                    _img.color = Mathf.Abs(Mathf.Sin(timer * _blinkSpeed)) * _color;
                    for (int i = 0; i < _mat.Length; i++)
                    {
                        anim[i].SetBool("isBreaking", true);
                        if (_mat[i].GetFloat("_isStuttering") == 0)
                            _mat[i].SetFloat("_isStuttering", 1);
                        
                    }
                    if (!isPlayingAlarm)
                        AudioManager.instance.Play("Alarm"); isPlayingAlarm = true;

                }
                else { isPlayingAlarm = false; }
            }
            else
            {
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
