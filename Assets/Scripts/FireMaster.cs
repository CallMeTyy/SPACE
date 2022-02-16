using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using extOSC;
using UnityEngine.SceneManagement;
using UnityEngine.UI;
using Random = UnityEngine.Random;

public class FireMaster : MonoBehaviour
{
    private OSCReceiver _receiver;
    private int ID = -1;
    [SerializeField] private Material _mat;
    [SerializeField] private Emergency[] _eLights;
    private float fireValue = 1.0f;
    private OscMaster _master;
    private float CPUInput = 0f;
    private float timeCheck;


    // Start is called before the first frame update
    void Start()
    {
        _master = GameObject.FindWithTag("Master")?.GetComponent<OscMaster>();
        _receiver = gameObject.AddComponent<OSCReceiver>();
        _receiver.LocalPort = 7204;
        _receiver.Bind("/player/*/mic", Fire);

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
                        CPUInput = Random.Range(1,11);
                    }
                }
            }
        }
        else
        {
            if (ID > 1)
            {
                timeCheck += Time.deltaTime;
                if (timeCheck > 0.05f)
                {
                    CPUInput = Random.Range(1,11);
                }

                if (CPUInput >= 2)
                {
                    fireValue -= 0.025f;
                    if (fireValue < 0) fireValue = 0;
                }
            }
        }
        
        
    }

    public float GetScore()
    {
        return fireValue;
    }

    public int getID()
    {
        return ID;
    }

    void Fire(OSCMessage message)
    {
        if (message.Values[1].FloatValue > 0.1f && message.Values[0].IntValue == ID && fireValue > 0) fireValue -= 0.025f;
        if (fireValue < 0) fireValue = 0;
        _mat.SetFloat("_FlameAmount", fireValue - 1);
        if (fireValue <= 0)
        {
            foreach (Emergency _l in _eLights)
            {
                _l.StopEmergency();
            }
        }
    }
}