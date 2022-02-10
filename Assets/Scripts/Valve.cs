using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using extOSC;
using UnityEngine.UI;

public class Valve : MonoBehaviour
{
    [SerializeField] private RectTransform _valve;
    [SerializeField] private Text _text;
    private OSCReceiver _receiver;

    private int ID = -1;
    private float angle = 0;
    
    // Start is called before the first frame update
    void Start()
    {
        _receiver = gameObject.AddComponent<OSCReceiver>();
        _receiver.LocalPort = 7204;
        _receiver.Bind("/player/*/valve", RotateValve);

        for (int i = 0; i < 4; i++)
        {
            if (gameObject.name.Contains(i.ToString())) ID = i;
        }
    }

    void RotateValve(OSCMessage message)
    {
        if (message.Values[0].IntValue == ID)
        {
            //_valve.localRotation = Quaternion.Euler(0,0,new Quaternion(message.Values[1].FloatValue,
            //    message.Values[2].FloatValue,message.Values[3].FloatValue,message.Values[4].FloatValue).eulerAngles.z);
            _valve.Rotate(0,0,message.Values[1].FloatValue * 4 / (Mathf.Pow(angle, 2) / 20000 + 1));
            angle += -message.Values[1].FloatValue * 4 / (Mathf.Pow(angle, 2) / 20000 + 1);
            _valve.localScale = new Vector3(1 - angle / 9000, 1 - angle / 9000, 0);
            if (_text != null) _text.text = "Angle: " + angle;
        } 
    }
}
