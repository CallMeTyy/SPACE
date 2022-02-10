using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;
using Random = UnityEngine.Random;

public class SceneMaster : MonoBehaviour
{
    private bool isInHub;
    private float timer;
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
            timer = Random.Range(5, 10);
        }
    }

    public void Update()
    {
        if (isInHub)
        {
            GoToScene("Lazer");
            if (timer > 0) timer -= Time.deltaTime;
            else
                switch (Random.Range(0, 3))
                {
                    case 0:
                        GoToScene("MiniValve");
                        break;
                    case 1:
                        GoToScene("Lazer");
                        break;
                    case 2:
                        GoToScene("2V2Fight");
                        break;
                    default:
                        timer = Random.Range(5, 10);
                        break;
                }
        }
    }
}
