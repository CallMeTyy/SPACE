using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using extOSC;
using UnityEngine.SceneManagement;
using UnityEngine.VFX;

public class LazerMaster : MonoBehaviour
{
    [SerializeField] private Transform _t13;
    [SerializeField] private Transform _t24;
    public float T1Score;
    public float T2Score;
    private OSCReceiver _receiver;

    private ScoreMaster _master;

    private float speed = 0.0025f;
    private float timeCheck;
    private int CPUInput;
    private bool intersect;
    private bool finishSound;

    [SerializeField] private VisualEffect[] _vfx;
    [SerializeField] private AudioSource[] audios;

    // Start is called before the first frame update
    void Start()
    {
        _master = GameObject.FindWithTag("Score")?.GetComponent<ScoreMaster>();
        _receiver = gameObject.AddComponent<OSCReceiver>();
        _receiver.LocalPort = 7204;
        _receiver.Bind("/player/*/laser", accelInput);
    }

    // Update is called once per frame
    void Update()
    {
        CPU();
        _t13.localScale = new Vector3(map(T1Score, 0, 1, 0.008f, 0.12f), 0.2f, 0.1f);
        _t24.localScale = new Vector3(map(T2Score, 0, 1, 0.008f, 0.12f), 0.2f, 0.1f);
        if (Mathf.Max(T1Score, T2Score) > 0.94f && !finishSound)
        {
            audios[5].Play();
            finishSound = true;
        }
    }
    
    public float map(float x, float in_min, float in_max, float out_min, float out_max)
    {
        return (x - in_min) * (out_max - out_min) / (in_max - in_min) + out_min;
    }

    void CPU()
    {
        if (_master != null)
        {
            //print(_master.GetPlayerCount());
            if (_master.GetPlayerCount() < 4)
            {
                timeCheck += Time.deltaTime;
                if (timeCheck > 0.05f)
                {
                    timeCheck = 0;
                    for (int i = _master.GetPlayerCount() + 1; i <= 4; i++)
                    {
                        CPUInput = Random.Range(1, 11);
                        if (i == 1) CPUInput = Random.Range(1, 3);
                        if (CPUInput >= 2)
                        {
                            CPUStuff(i);
                        }
                        
                    }
                    
                }
            }
        }
        else
        {
            timeCheck += Time.deltaTime;
            if (timeCheck > 0.05f)
            {
                timeCheck = 0;
                for (int i = 2; i <= 4; i++)
                {
                    CPUInput = Random.Range(1, 11);
                    if (CPUInput >= 2)
                    {
                        CPUStuff(i);
                    }
                }
            }
        }
    }

    void CPUStuff(int ID)
    {
        if (ID <= _master.GetPlayerCount()) return;
        OSCMessage msg = new OSCMessage("CPU");
        msg.AddValue(OSCValue.Int(ID));
        msg.AddValue(OSCValue.Float(Random.Range(1,8)));
        msg.AddValue(OSCValue.Float(Random.Range(1, 8)));
        msg.AddValue(OSCValue.Float(Random.Range(1, 8)));
        accelInput(msg);
    }

    public Vector2 GetScore()
    {
        return new Vector2(T1Score, T2Score);
    }

    void accelInput(OSCMessage message)
    {
        if (!_master.countReady) return;
        else if (audios[0].isPlaying)
        {
            audios[0].Stop();
            audios[1].Stop();
        }
        if (!audios[2].isPlaying) audios[2].Play();
        if (message.Values[0].IntValue == 1 || message.Values[0].IntValue == 3)
        {
            if (new Vector3(message.Values[1].FloatValue, message.Values[2].FloatValue, message.Values[3].FloatValue)
                .magnitude > 4)
                T1Score += speed;
            if (T1Score + T2Score >= 1)
            {
                T2Score -= speed;
                if (!audios[3].isPlaying)
                {
                    audios[3].Play();
                    audios[3].panStereo = map(T1Score, 0, 1, -0.5f, 0.5f);
                }
            } else if (T1Score + T2Score > 0.9f)
            {
                if (!audios[4].isPlaying)
                {
                    audios[4].Play();
                    intersect = true;
                }
            }
        }

        if (message.Values[0].IntValue == 2 || message.Values[0].IntValue == 4)
        {
            if (new Vector3(message.Values[1].FloatValue, message.Values[2].FloatValue, message.Values[3].FloatValue)
                .magnitude > 4)
                T2Score += speed;
            if (T1Score + T2Score >= 1)
            {
                T1Score -= speed;
            }
        }
        if (message.Values[0].IntValue == 1)
        {
            if (new Vector3(message.Values[1].FloatValue, message.Values[2].FloatValue, message.Values[3].FloatValue).magnitude > 4)
                _vfx[0].SetFloat("SpawnRate", 0);
            else { _vfx[0].SetFloat("SpawnRate", -1); }
        }

        if (message.Values[0].IntValue == 2)
        {
            if (new Vector3(message.Values[1].FloatValue, message.Values[2].FloatValue, message.Values[3].FloatValue).magnitude > 4)
                _vfx[1].SetFloat("SpawnRate", 0);
            else { _vfx[1].SetFloat("SpawnRate", -1); }
        }

        if (message.Values[0].IntValue == 3)
        {
            if (new Vector3(message.Values[1].FloatValue, message.Values[2].FloatValue, message.Values[3].FloatValue).magnitude > 4)
                _vfx[2].SetFloat("SpawnRate", 0);
            else { _vfx[2].SetFloat("SpawnRate", -1); }
        }

        if (message.Values[0].IntValue == 4)
        {
            if (new Vector3(message.Values[1].FloatValue, message.Values[2].FloatValue, message.Values[3].FloatValue).magnitude > 4)
                _vfx[3].SetFloat("SpawnRate", 0);
            else { _vfx[3].SetFloat("SpawnRate", -1); }
        }


    }
}