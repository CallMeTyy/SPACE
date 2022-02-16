using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Emergency : MonoBehaviour
{
    private Light light;
    private float speed = 2;
    private Color defC;
    private bool _emergency = true;
    
    // Start is called before the first frame update
    void Start()
    {
        light = GetComponent<Light>();
        defC = light.color;
    }

    public void StopEmergency()
    {
        _emergency = false;
        light.color = defC;
    }

    // Update is called once per frame
    void Update()
    {
        if (_emergency)
        {
            Color c = Color.red;
            c.r *= Mathf.Abs(Mathf.Sin(Time.time * 2));
            light.color = c;
        }
        
    }
}
