using System.Collections;
using System.Collections.Generic;
using UnityEngine;
public class rotatePlanet : MonoBehaviour
{
    public float speed;
    // Start is called before the first frame update
    void Start()
    {
        transform.Rotate(new Vector3(0,0,Random.Range(0,360)));
    }

    // Update is called once per frame
    void Update()
    {
        transform.Rotate(new Vector3(0,0,speed * Time.deltaTime));
    }
}
