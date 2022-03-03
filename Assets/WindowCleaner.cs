using System;
using System.Collections;
using System.Collections.Generic;
using extOSC;
using UnityEngine;
using UnityEngine.UI;
using Random = UnityEngine.Random;

public class WindowCleaner : MonoBehaviour
{
    private OSCReceiver _receiver;
    private int ID = -1;
    Texture2D img;
    [SerializeField] private Material mat;
    public int brushSize = 20;
    private Vector2 targetPos;
    private Vector2 currentPos;
    public bool win;
    [SerializeField] Light _light;
    [SerializeField] private Transform _sponge;
    private ScoreMaster _master;
    private float CPUInput = 0f;
    private float timeCheck;
    private float time;
    private bool initialized;

    public float timeofwin;

    
    // Start is called before the first frame update
    void Start()
    {
        time = Random.value;
        _master = GameObject.FindWithTag("Score")?.GetComponent<ScoreMaster>();
        _receiver = gameObject.AddComponent<OSCReceiver>();
        _receiver.LocalPort = 7204;
        _receiver.Bind("/player/*/touch", Clean);
        img = new Texture2D(512, 512);
        for (int x = 0; x < 512; x++)
        {
            for (int y = 0; y < 512; y++)
            {
                img.SetPixel(x,y,Color.green);
            }
        }
        img.Apply();
        mat.SetTexture("_splat", img);
        targetPos = new Vector2(0.975f, 0.025f);
        currentPos = new Vector2(0.975f, 0.025f);
        
        for (int i = 0; i < 5; i++)
        {
            if (gameObject.name.Contains(i.ToString())) ID = i;
        }
        
    }
    
    void Clean(OSCMessage message)
    {
        if (!_master.countReady) return;
        //print(message);
        if (message.Values[0].IntValue == ID)
        {
            targetPos.x = message.Values[1].FloatValue;
            targetPos.y = message.Values[2].FloatValue;

            if (Random.Range(0, 2000) > 1500)
            {
                AudioSource audioSource = GetComponent<AudioSource>();
                audioSource.pitch = Random.Range(0.8f, 1.2f); ;
                audioSource.Play();
                print("Playing sound");
            }
        }
    }

    bool CheckWin()
    {
        int pixDone = 0;
        for (int x = 16; x < 512; x += 32)
        {
            for (int y = 16; y < 512; y += 32)
            {
                if (img.GetPixel(x, y).g < 1) pixDone++;
            }
        }
        if (pixDone >= 225) return true;
        return false;
        
    }

    private void FixedUpdate()
    {
        if (!_master.countReady) return;
        if (win) return;
        currentPos = currentPos * 0.8f + targetPos * 0.2f;
        Brush(currentPos.x, currentPos.y);
    }

    private void Update()
    {
        if (!_master.countReady) return;
        CPU();
        if (_sponge != null) _sponge.localPosition = new Vector3(Map(currentPos.x, 0, 1, 0.545f, 0.885f),
            Map(currentPos.y, 0, 1, -0.125f,0.11f ), -6.8342f);
    }
    public int GetID()
    {
        return ID;
    }


    void CPU()
    {
        if (_master != null)
        {
            if (_master.GetPlayerCount() < 4)
            {
                if (ID > _master.GetPlayerCount())
                {
                    timeCheck += Time.deltaTime;
                    if (timeCheck > time)
                    {
                        AudioSource audioSource = GetComponent<AudioSource>();
                        if (!audioSource.isPlaying && Random.Range(0,2) < 1)
                        {
                            audioSource.pitch = Random.Range(0.8f, 1.2f); ;
                            audioSource.Play();
                        }
                        time = Random.value;
                        timeCheck = 0;
                        targetPos = new Vector2(Random.value, Random.value);
                        win = CheckWin();
                        if (win)
                        {
                            _light.color = Color.green;
                        }
                    }
                }
            }
        }
        else
        {
            if (ID > 1)
            {
                timeCheck += Time.deltaTime;
                if (timeCheck > time)
                {
                    time = Random.value;
                    timeCheck = 0;
                    targetPos = new Vector2(Random.value, Random.value);
                    win = CheckWin();
                    if (win)
                    {
                        _light.color = Color.green;
                    }
                    else { /*if (Random.Range(0, 2000) > 1900) 
                        {
                            AudioSource audioSource = GetComponent<AudioSource>();
                            audioSource.pitch = Random.Range(0.9f,1.1f); ;
                            audioSource.Play();
                        } */
                    }
                }
            }
        }
    }

    private void Brush(float inputX, float inputY)
    {
        int mouseX = (int) Map(inputX, 0, 1, 0, 512);
        int mouseY = (int) Map(inputY, 0, 1, 0, 512);
        for (int x = mouseX - brushSize; x <= mouseX + brushSize; x++)
        {
            for (int y = mouseY - brushSize; y <= mouseY + brushSize; y++)
            {
                img.SetPixel(x, y, Color.red);
            }
        }
        img.Apply();
        win = CheckWin();
        if (win)
        {
            _light.color = Color.green;
            timeofwin = Time.time;
        }
    }
    
    public float Map(float x, float in_min, float in_max, float out_min, float out_max, bool clamp = true)
    {
        if (clamp) x = Math.Max(in_min, Math.Min(x, in_max));
        return (x - in_min) * (out_max - out_min) / (in_max - in_min) + out_min;
    }
}
