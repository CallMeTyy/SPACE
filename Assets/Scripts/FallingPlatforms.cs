using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.VFX;

public class FallingPlatforms : MonoBehaviour
{
    public float timer;
    private GameObject[] platforms;
    public float timeBetweenFalls = 5;

    private int targetPlat;
    private int fallen;
    private bool done;
    public ScoreMaster _master;
    [SerializeField] private VisualEffect[] _vfx;
    
    // Start is called before the first frame update
    void Start()
    {
        _master = GameObject.FindWithTag("Score")?.GetComponent<ScoreMaster>();
        platforms = GameObject.FindGameObjectsWithTag("Platform");
        targetPlat = Random.Range(0, platforms.Length);
        timer = timeBetweenFalls;
        foreach (var plat in platforms)
        {
            Rigidbody r = plat.AddComponent<Rigidbody>();
            r.isKinematic = true;
        }
    }

    // Update is called once per frame
    void Update()
    {
        if (_master != null)
            if (!_master.isReady() || !_master.countReady)
                return;

        if (done) return;

        if (timer > 0)
        {
            timer -= Time.deltaTime;
            platforms[targetPlat].GetComponent<Animator>().enabled = true;
            _vfx[targetPlat].SetFloat("SpawnRate", 1);
        }
        else
        {
            timer = timeBetweenFalls;
            platforms[targetPlat].GetComponent<Rigidbody>().isKinematic = false;
            _vfx[targetPlat].SetFloat("SpawnRate", 0);
            GetNewPlat();
            fallen++;
        }
    }

    void GetNewPlat()
    {
        if (fallen > 15)
        {
            done = true;
            return;
        }
        targetPlat = Random.Range(0, platforms.Length);
        if (!platforms[targetPlat].activeSelf) GetNewPlat();
    }
}
