using System.Collections;
using System.Collections.Generic;
using UnityEngine;


public class PlayerAnimation : MonoBehaviour
{
    [SerializeField]private Animator anim;
    // Start is called before the first frame update
    void Start()
    {
        anim.speed = Random.Range(0.9f,1.6f);
    }

    // Update is called once per frame
    void Update()
    {
        
    }
}
