using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Emergency : MonoBehaviour
{
    private Light light;
    private float speed = 2;
    
    // Start is called before the first frame update
    void Start()
    {
        light = GetComponent<Light>();
    }

    // Update is called once per frame
    void Update()
    {
        Color c = Color.red;
        c.r *= Mathf.Abs(Mathf.Sin(Time.time * 2));
        light.color = c;
    }
}
