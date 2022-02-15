using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

public class Flicker : MonoBehaviour
{
    Light light;
    float flickerTime = 0.08f;
    private float timer;

    // Start is called before the first frame update
    void Start()
    {
        light = GetComponent<Light>();
    }

    // Update is called once per frame
    void Update()
    {
        timer += Time.deltaTime;
        if (timer > flickerTime)
        {
            timer = 0;
            light.intensity = Random.Range(80, 145);
        }
    }
}
