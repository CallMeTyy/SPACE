using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class bullet : MonoBehaviour
{
    public Transform player;
    Quaternion dir;
    // Start is called before the first frame update
    void Start()
    {
        if (player != null) dir = player.transform.rotation;
        //dir *= Quaternion.Euler(0, 0, 180);
    }

    // Update is called once per frame
    void FixedUpdate()
    {
        transform.position += dir * Vector3.forward * Time.deltaTime * 20;
        
    }
}
