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
    [SerializeField] private Slider _slider;
    

    // Start is called before the first frame update
    void Start()
    {
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
        print(message);
        if (message.Values[1].FloatValue > 0.1f && message.Values[0].IntValue == ID) _slider.value += 0.1f;
        if (_slider.value >= 1f) SceneManager.LoadScene("SpaceHub");
    }
}