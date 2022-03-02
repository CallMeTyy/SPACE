using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Random = UnityEngine.Random;

public class RandomRadio : MonoBehaviour
{
    [SerializeField] private Transform pointerthing;

    private float targetX;
    private float angle;

    private float defY;
    private float timer;
    private float defZ;

    private void Start()
    {
        defY = pointerthing.localRotation.eulerAngles.y;
        defZ = pointerthing.localRotation.eulerAngles.z;
    }

    // Update is called once per frame
    void FixedUpdate()
    {
        if (timer > 0) return;
        if (Mathf.Abs(targetX - angle) < 2f)
        {
            targetX = Random.Range(-19, 136);
            timer = 2;
        }
        else
        {
            angle = 0.85f * angle + 0.15f * targetX;
        }
    }

    private void Update()
    {
        timer -= Time.deltaTime;
        pointerthing.localRotation = Quaternion.Euler(angle, defY, defZ);
    }
}
