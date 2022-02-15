using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class moveSolarSystem : MonoBehaviour
{
    public float speed;
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        transform.position = new Vector3((speed * Time.deltaTime) + transform.position.x, transform.position.y,transform.position.z);
    }
}
