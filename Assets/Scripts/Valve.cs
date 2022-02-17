using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using extOSC;
using Unity.Mathematics;
using UnityEngine.SceneManagement;
using UnityEngine.UI;
using Random = UnityEngine.Random;

public class Valve : MonoBehaviour
{
    [SerializeField] private Transform _valve;
    [SerializeField] private Text _text;
    private OSCReceiver _receiver;
    private OscMaster _master;
    [SerializeField] private Light _light;

    private int ID = -1;
    private float angle = 0;
    private float targetAngle;

    private float timeCheck;
    private int CPUInput;
    
    
    // Start is called before the first frame update
    void Start()
    {
        _master = GameObject.FindWithTag("Master")?.GetComponent<OscMaster>();
        _receiver = gameObject.AddComponent<OSCReceiver>();
        _receiver.LocalPort = 7204;
        _receiver.Bind("/player/*/valve", RotateValve);

        for (int i = 0; i < 5; i++)
        {
            if (gameObject.name.Contains(i.ToString())) ID = i;
        }
    }

    private void Update()
    {
        if (_master != null)
        {
            if (_master.GetPlayerCount() < 4)
            {
                if (ID > _master.GetPlayerCount())
                {
                    timeCheck += Time.deltaTime;
                    if (timeCheck > 0.1f)
                    {
                        timeCheck = 0;
                        CPUInput = Random.Range(1,11);
                    }
                    if (CPUInput >= 2)
                    {
                        targetAngle += Random.Range(0, 4.0f);
                    }
                    UpdateValve();
                }
            }
        }
        else
        {
            if (ID > 3)
            {
                timeCheck += Time.deltaTime;
                if (timeCheck > 0.1f)
                {
                    timeCheck = 0;
                    CPUInput = Random.Range(1,11);
                }
                if (CPUInput >= 2)
                {
                    targetAngle += Random.Range(0, 4.0f);
                }
                UpdateValve();
            }
        }
    }

    public int GetID()
    {
        return ID;
    }

    public int GetAngle()
    {
        return (int) angle;
    }

    void RotateValve(OSCMessage message)
    {
        if (message.Values[0].IntValue == ID)
        {
            //_valve.localRotation = Quaternion.Euler(0,0,new Quaternion(message.Values[1].FloatValue,
            //    message.Values[2].FloatValue,message.Values[3].FloatValue,message.Values[4].FloatValue).eulerAngles.z);
            //_valve.Rotate(0,0,message.Values[1].FloatValue * 4 / (Mathf.Pow(angle, 2) / 20000 + 1));
            targetAngle += -message.Values[1].FloatValue * 2;// / (Mathf.Pow(angle, 2) / 20000 + 1);
            UpdateValve();
        } 
    }

    void UpdateValve()
    {
        angle = 0.7f * angle + 0.3f * targetAngle;
        if (angle < 1800)
        {
            _valve.localRotation = quaternion.Euler(-angle / 45,0,0);
        }
        else
        {
            _light.color = Color.green;
        }
        
        if (_text != null) _text.text = "Angle: " + angle + "/420";
    }
}
