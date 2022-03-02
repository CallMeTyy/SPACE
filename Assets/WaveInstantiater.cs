using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class WaveInstantiater : MonoBehaviour
{
    [SerializeField] private GameObject _wave;
    [SerializeField] private float _waveSpeed;

    private float timer;
    [SerializeField] private float timeBetween = 4;
    [SerializeField] private float speedUpSpeed = 20;
    private float initTBetween;
    private int wavesSent;
    // Start is called before the first frame update
    void Start()
    {
        initTBetween = timeBetween;
    }

    // Update is called once per frame
    void Update()
    {
        timer += Time.deltaTime;
        if (timer > timeBetween)
        {
            timer = 0;
            wavesSent++;
            if (timeBetween > 0.5f) timeBetween = initTBetween - wavesSent / speedUpSpeed;
            var prefab = Instantiate(_wave, new Vector3(-5, 3.8f, 160),Quaternion.identity);
            prefab.GetComponent<waveHandler>().waveSpeed = _waveSpeed;
        }
        if (Input.GetKeyUp("space"))
        {
            var prefab = Instantiate(_wave, new Vector3(-5, 3.79f, 160),Quaternion.identity);
            prefab.GetComponent<waveHandler>().waveSpeed = _waveSpeed;
        }
    }
}
