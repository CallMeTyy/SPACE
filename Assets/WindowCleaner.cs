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
    private ScoreMaster _master;
    private float CPUInput = 0f;
    private float timeCheck;
    private float time;

    
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
        
        for (int i = 0; i < 5; i++)
        {
            if (gameObject.name.Contains(i.ToString())) ID = i;
        }
        
    }
    
    void Clean(OSCMessage message)
    {
        //print(message);
        if (message.Values[0].IntValue == ID)
        {
            targetPos.x = message.Values[1].FloatValue;
            targetPos.y = message.Values[2].FloatValue;
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
        if (win) return;
        currentPos = currentPos * 0.8f + targetPos * 0.2f;
        Brush(currentPos.x, currentPos.y);
    }

    private void Update()
    {
        CPU();
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
        }
    }
    
    public float Map(float x, float in_min, float in_max, float out_min, float out_max, bool clamp = true)
    {
        if (clamp) x = Math.Max(in_min, Math.Min(x, in_max));
        return (x - in_min) * (out_max - out_min) / (in_max - in_min) + out_min;
    }
}
