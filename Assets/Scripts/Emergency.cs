using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Emergency : MonoBehaviour
{
    private Light light;
    private SpriteRenderer _render;
    private float speed = 2;
    private Color defC;
    private bool _emergency = true;
    
    // Start is called before the first frame update
    void Start()
    {
        light = GetComponent<Light>();
        if (light == null)
        {
            _render = GetComponent<SpriteRenderer>();
            defC = _render.color;
        }
        else
        {
            defC = light.color;
        }
        
    }

    public void StopEmergency()
    {
        _emergency = false;
        if (light != null) light.color = defC;
        else _render.color = defC;
    }

    // Update is called once per frame
    void Update()
    {
        if (_emergency && light != null)
        {
            Color c = Color.red;
            c.r *= Mathf.Abs(Mathf.Sin(Time.time * 2));
            light.color = c;
        } else if (_emergency)
        {
            Color c = Color.red;
            c.r *= Mathf.Abs(Mathf.Sin(Time.time * 2));
            if (c.r < 0.5f) c.r = 0.5f;
            c.g = 0.5f;
            c.b = 0.5f;
            _render.color = c;
        }
        
    }
}
