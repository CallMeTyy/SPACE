using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class WaveInstantiater : MonoBehaviour
{
    [SerializeField] private GameObject _wave;
    [SerializeField] private float _waveSpeed;
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        if (Input.GetKeyUp("space"))
        {
            var prefab = Instantiate(_wave, new Vector3(-5, 3.8f, 160),Quaternion.identity);
            prefab.GetComponent<waveHandler>().waveSpeed = _waveSpeed;
        }
    }
}
