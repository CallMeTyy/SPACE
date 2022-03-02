using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class rotateEngine : MonoBehaviour
{
    [SerializeField] private GameObject[] _obj;
    [SerializeField] private float _speed;
    void FixedUpdate()
    {
        for(int i = 0; i < _obj.Length; i++)
        {
            _obj[i].transform.Rotate(_speed,0,0);
        }
    }
}
