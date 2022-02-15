using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using extOSC;
using UnityEngine.SceneManagement;
using UnityEngine.UI;

public class FireMaster : MonoBehaviour
{
    private OSCReceiver _receiver;
    private int ID = -1;
    [SerializeField] private ParticleSystem[] _systems;
    [SerializeField] private Light[] lights;

    private GradientAlphaKey[] _alphaKey;
    
    private float fireValue = 1.0f;
    [SerializeField] private Gradient color;

    // Start is called before the first frame update
    void Start()
    {
        _alphaKey = color.alphaKeys;
        _receiver = gameObject.AddComponent<OSCReceiver>();
        _receiver.LocalPort = 7204;
        _receiver.Bind("/player/*/mic", Fire);

        for (int i = 0; i < 4; i++)
        {
            if (gameObject.name.Contains(i.ToString())) ID = i;
        }
    }
    
    

    void Fire(OSCMessage message)
    {
        print(fireValue);
        if (message.Values[1].FloatValue > 0.1f && message.Values[0].IntValue == ID && fireValue > 0.05f) fireValue -= 0.025f;
        _alphaKey[1].time = fireValue;
        color.SetKeys(color.colorKeys, _alphaKey);
        foreach (ParticleSystem _s in _systems)
        {
            var col = _s.colorOverLifetime;
            col.color = color;
        }

        if (fireValue < 0.05f)
        {
            SceneManager.LoadScene("SpaceHub");
        }
        if (fireValue < 0.1f)
        {
            foreach (Light l in lights)
            {
                l.gameObject.GetComponent<Flicker>().enabled = false;
                l.intensity = 0;
            }
        }
    }
}
