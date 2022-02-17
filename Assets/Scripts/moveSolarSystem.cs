using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class moveSolarSystem : MonoBehaviour
{
    public float speed;
    [SerializeField] private bool useX;
    [SerializeField] private bool useY;
    [SerializeField] private bool useZ;
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        if (useX)
        transform.position = new Vector3((speed * Time.deltaTime) + transform.position.x, transform.position.y,transform.position.z);

        if (useY)
            transform.position = new Vector3(transform.position.x, (speed * Time.deltaTime) + transform.position.y, transform.position.z);

        if (useZ)
            transform.position = new Vector3(transform.position.x, transform.position.y, (speed * Time.deltaTime) + transform.position.z);
    }
}
