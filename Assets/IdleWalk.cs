using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class IdleWalk : MonoBehaviour
{
    private float targetX;
    private float timer;
    private float scale;
    private Animator _animator;
    
    // Start is called before the first frame update
    void Start()
    {
        targetX = Random.Range(-5, 3);
        scale = transform.localScale.x;
        _animator = GetComponent<Animator>();
    }

    // Update is called once per frame
    void Update()
    {
        if (Mathf.Abs(transform.position.x - targetX) > 0.1f && targetX != 10)
        {
            _animator.SetBool("walking", true);
            float dir;
            if (targetX > transform.position.x) dir = 1;
            else dir = -1;
            transform.Translate( dir * Time.deltaTime, 0, 0);
            transform.localScale = new Vector3(scale * dir, scale, 1);
        }
            
        else if (targetX != 10)
        {
            _animator.SetBool("walking", false);
            targetX = 10;
            timer = Random.Range(2.0f, 7.0f);
        }
        else if (timer > 0) timer -= Time.deltaTime;
        else targetX = Random.Range(-5.0f, 3.0f);
    }
}
