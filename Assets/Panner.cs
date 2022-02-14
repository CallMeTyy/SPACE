using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class Panner : MonoBehaviour
{
    [SerializeField] private RectTransform space;
    [SerializeField] private RectTransform spaceR;
    private List<RectTransform> images;

    private Vector2 rightOffset;
    private Vector2 rightOffsetMax;
    private Vector2 midOffset;

    public float speed = 1;

    private void Start()
    {
        images = new List<RectTransform>();
        
        rightOffset = new Vector2(spaceR.rect.width, 0);
        rightOffsetMax = new Vector2(spaceR.rect.width, 0);
        spaceR.offsetMax = rightOffsetMax;
        spaceR.offsetMin = rightOffset;
        midOffset = space.offsetMin;
        images.Add(space);
        images.Add(spaceR);
    }

    void Update()
    {
        foreach (RectTransform rect in images)
        {
            if (rect.offsetMin.x < -rect.rect.width)
            {
                rect.offsetMin = rightOffset;
                rect.offsetMax = rightOffsetMax;
            }
            rect.offsetMin += Vector2.left * speed * Time.deltaTime;
            rect.offsetMax += Vector2.left * speed * Time.deltaTime;
        }
    }
}
