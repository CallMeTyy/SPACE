using System.Collections;
using System.Collections.Generic;
using extOSC;
using UnityEngine;

public class PhoneRotation : MonoBehaviour
{
    private OSCReceiver _receiver;
    // Start is called before the first frame update
    void Start()
    {
        _receiver = gameObject.AddComponent<OSCReceiver>();
        _receiver.LocalPort = 7204;
        _receiver.Bind("/player/*/gyro", MessageRecieved); 
    }

    void MessageRecieved(OSCMessage msg)
    {
        print(msg);
        transform.rotation = new Quaternion(msg.Values[1].FloatValue, msg.Values[3].FloatValue,
            msg.Values[2].FloatValue, msg.Values[4].FloatValue);
    }
}
