using System.Collections;
using System.Collections.Generic;
using System.Threading;
using UnityEngine;

public class Alpaca : MonoBehaviour
{
    private Vector3 target;
    private Vector2 start;

    private RectTransform _transform;

    private Animator _animator;
    private float time;
    
    void Start()
    {
        time = Random.value;
        _animator = GetComponent<Animator>();
        _animator.speed = 0.9f + Random.value / 10;
        _animator.enabled = false;
        _transform = GetComponent<RectTransform>();
        start = _transform.position;
        target = new Vector3(Random.Range(start.x - 10, start.x + 10),
            Random.Range(_transform.rect.height, Screen.height - _transform.rect.height),0);
    }

    void Update()
    {
        if (time > 0 && !_animator.enabled) time -= Time.deltaTime;
        else _animator.enabled = true;
        
        if (target != null)
        {
            MoveToTarget();
        }
    }

    void MoveToTarget()
    {
        _transform.position = 0.995f * _transform.position + target * 0.005f;
        if (Vector3.Distance(_transform.position, target) < 5) 
            target = new Vector3(Random.Range(start.x - 10, start.x + 10),
                Random.Range(_transform.rect.height, Screen.height - _transform.rect.height),0);
    }
}
