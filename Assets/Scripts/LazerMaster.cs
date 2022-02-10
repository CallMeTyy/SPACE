using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using extOSC;
using UnityEngine.SceneManagement;

public class LazerMaster : MonoBehaviour
{

    [SerializeField] private ParticleSystem _red;
    [SerializeField] private ParticleSystem _blue;
    private GradientColorKey[] colorKey;
    private GradientAlphaKey[] alphaKey;
    private GradientAlphaKey[] alphaKeyB;
    private Gradient color;
    private Gradient colorB;
    private OSCReceiver _receiver;

    private float speed = 0.01f;
    // Start is called before the first frame update
    void Start()
    {
        
        _receiver = gameObject.AddComponent<OSCReceiver>();
        _receiver.LocalPort = 7204;
        _receiver.Bind("/player/*/laser", accelInput);
        
        color = new Gradient();
        colorB = new Gradient();
        colorKey = new GradientColorKey[2];
        alphaKey = new GradientAlphaKey[2];
        alphaKeyB = new GradientAlphaKey[2];
        
        colorKey[0].color = Color.white;
        colorKey[1].color = Color.white;
        colorKey[0].time = 0;
        colorKey[1].time = 1.0f;
        
        alphaKey[0].alpha = 1.0f;
        alphaKey[1].alpha = 0.0f;
        alphaKey[0].time = 0;
        alphaKey[1].time = 0.01f;
        
        alphaKeyB[0].alpha = 1.0f;
        alphaKeyB[1].alpha = 0.0f;
        alphaKeyB[0].time = 0;
        alphaKeyB[1].time = 0.01f;
        
        color.SetKeys(colorKey,alphaKey);
    }

    // Update is called once per frame
    void Update()
    {
        color.SetKeys(colorKey,alphaKey);
        colorB.SetKeys(colorKey, alphaKeyB);
        var col = _blue.colorOverLifetime;
        col.color = color;
        var redCol = _red.colorOverLifetime;
        redCol.color = colorB;

        if (alphaKey[1].time > 0.95f || alphaKeyB[1].time > 0.95f)
        {
            SceneManager.LoadScene("SpaceHub");
        }
    }

    void accelInput(OSCMessage message)
    {
        if (message.Values[0].IntValue == 1 || message.Values[0].IntValue == 3)
        {
            if (new Vector3(message.Values[1].FloatValue, message.Values[2].FloatValue, message.Values[3].FloatValue)
                .magnitude > 4)
                alphaKey[1].time += speed;
            if (alphaKey[1].time + alphaKeyB[1].time >= 1)
            {
                alphaKeyB[1].time -= speed;
            }
        }
        
        if (message.Values[0].IntValue == 2 || message.Values[0].IntValue == 4)
        {
            if (new Vector3(message.Values[1].FloatValue, message.Values[2].FloatValue, message.Values[3].FloatValue)
                .magnitude > 4)
                alphaKeyB[1].time += speed;
            if (alphaKey[1].time + alphaKeyB[1].time >= 1)
            {
                alphaKey[1].time -= speed;
            }
        }
    }
}
