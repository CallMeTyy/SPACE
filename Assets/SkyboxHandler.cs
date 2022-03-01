using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class SkyboxHandler : MonoBehaviour
{
    [SerializeField] private Material _skybox;
    [SerializeField] private float rotation;

    float timer;
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    /*void Update()
    {
        if (timer < 0.5f) timer += Time.deltaTime;
        else
        {
            timer = 0;
            rotation++;
            //rotation += rotation + 5;
            _skybox.SetFloat("_Rotation", rotation);
        }
        
    }*/
    private void FixedUpdate()
    {   
        rotation += 0.04f;
        _skybox.SetFloat("_Rotation", rotation);
    }
}
