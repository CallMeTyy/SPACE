using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class Panner : MonoBehaviour
{
    [SerializeField] private RectTransform space;
    [SerializeField] private RectTransform spaceL;
    [SerializeField] private RectTransform spaceR;
    private List<RectTransform> images;

    private Vector2 rightOffset;
    private Vector2 rightOffsetMax;
    private Vector2 midOffset;

    public float speed = 1;

    private void Start()
    {
        images = new List<RectTransform>();
        rightOffset = spaceR.offsetMin;
        rightOffsetMax = spaceR.offsetMax;
        midOffset = space.offsetMin;
        images.Add(space);
        images.Add(spaceL);
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
            rect.offsetMin += Vector2.left * speed;
            rect.offsetMax += Vector2.left * speed;
        }
    }
}
