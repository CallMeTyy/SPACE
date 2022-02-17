using System;
using System.Collections;
using System.Collections.Generic;
using extOSC;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.SceneManagement;
using UnityEngine.VFX;
using Random = UnityEngine.Random;

public class SceneMaster : MonoBehaviour
{
    private bool isInHub;
    private float timer;
    private int index;
    [SerializeField] private Image _img;
    [SerializeField] private Color _color;
    [SerializeField] private float _blinkSpeed;
    [SerializeField] private Material[] _mat;
    [SerializeField] private Animator[] anim;
    private int a;
    float index2;
    float amplitudeX = 10.0f;
    float omegaX = 1.0f;
    private OscMaster master;
    public void GoToScene(string sceneName)
    {
        SceneManager.LoadScene(sceneName);
    }

    private void Start()
    {
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
                timer -= Time.deltaTime;
                if (timer < 3.14f)
                {
                    
                    _img.color = Mathf.Abs(Mathf.Sin(timer * _blinkSpeed)) * _color;
                    for (int i = 0; i < _mat.Length; i++)
                    {
                        anim[i].SetBool("isBreaking", true);
                        if (_mat[i].GetFloat("_isStuttering") == 0)
                            _mat[i].SetFloat("_isStuttering", 1);
            
                    }
                }
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
                        timer = Random.Range(8, 12);
                        break;
                }
                master.GetSceneIndex++;
            }
                

            
        }
    }
}
