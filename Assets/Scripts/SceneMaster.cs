using System;
using System.Collections;
using System.Collections.Generic;
using extOSC;
using UnityEngine;
using UnityEngine.SceneManagement;
using Random = UnityEngine.Random;

public class SceneMaster : MonoBehaviour
{
    private bool isInHub;
    private float timer;
    private int index;

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
            timer = Random.Range(2, 5);
        }

        master = GameObject.FindWithTag("Master").GetComponent<OscMaster>();
    }

    public void Update()
    {
        if (isInHub)
        {
            if (timer > 0) timer -= Time.deltaTime;
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
                        GoToScene("2V2Fight");
                        break;
                    default:
                        timer = Random.Range(2, 5);
                        break;
                }
                master.GetSceneIndex++;
            }
                

            
        }
    }
}