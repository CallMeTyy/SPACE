using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using extOSC;
using Unity.Mathematics;
using UnityEngine.SceneManagement;
using UnityEngine.UI;
using UnityEngine.VFX;
using Random = UnityEngine.Random;

public class Valve : MonoBehaviour
{
    [SerializeField] private Transform _valve;
    [SerializeField] private Text _text;
    private OSCReceiver _receiver;
    private ScoreMaster _master;
    [SerializeField] private Light _light;
    [SerializeField] private VisualEffect _vfx;
    [SerializeField] private GameObject _wrongText;

    private int ID = -1;
    private float angle = 0;
    private float targetAngle;

    private float timeCheck;
    private int CPUInput;
    
    
    // Start is called before the first frame update
    void Start()
    {
        _master = GameObject.FindWithTag("Score")?.GetComponent<ScoreMaster>();
        _receiver = gameObject.AddComponent<OSCReceiver>();
        _receiver.LocalPort = 7204;
        _receiver.Bind("/player/*/valve", RotateValve);

        AudioSource audioSource = GetComponents<AudioSource>()[1];
        audioSource.pitch = Random.Range(0.9f, 1.1f);
        audioSource.Play();

        for (int i = 0; i < 5; i++)
        {
            if (gameObject.name.Contains(i.ToString())) ID = i;
        }
    }

    private void FixedUpdate()
    {
        if (!_master.countReady) return;
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
                    if (CPUInput >= 4)
                    {
                        targetAngle += Random.Range(0, 4.0f);
                    }
                }
            }
        }
        else
        {
            if (ID > 1)
            {
                timeCheck += Time.deltaTime;
                if (timeCheck > 0.1f)
                {
                    timeCheck = 0;
                    CPUInput = Random.Range(1,11);
                }
                if (CPUInput >= 4)
                {
                    targetAngle += Random.Range(0, 4.0f);
                }
            }
        }
        UpdateValve();
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
        if (!_master.countReady) return;
        if (message.Values[0].IntValue == ID)
        {
            //_valve.localRotation = Quaternion.Euler(0,0,new Quaternion(message.Values[1].FloatValue,
            //    message.Values[2].FloatValue,message.Values[3].FloatValue,message.Values[4].FloatValue).eulerAngles.z);
            //_valve.Rotate(0,0,message.Values[1].FloatValue * 4 / (Mathf.Pow(angle, 2) / 20000 + 1));
            targetAngle += -message.Values[1].FloatValue * 4;// / (Mathf.Pow(angle, 2) / 20000 + 1);
        }
    }

    void UpdateValve()
    {
        if (targetAngle < angle) _wrongText.SetActive(true);
        else _wrongText.SetActive(false);
        angle = 0.7f * angle + 0.3f * targetAngle;
        if (angle % 360 < 2 && angle >= 180)
        {
            AudioSource audioSource = GetComponents<AudioSource>()[0];
            audioSource.pitch = Random.Range(0.7f, 0.9f);
            audioSource.Play();
        }

        _vfx.SetFloat("SpawnRate", angle);
        if (angle < 1800)
        {
           
            _valve.localRotation = quaternion.Euler(-angle / 45,0,0);
        }
        else
        {
            GetComponents<AudioSource>()[1].Stop();
            _light.color = Color.green;
        }
        
        if (_text != null) _text.text = "Angle: " + angle + "/420";
    }
}
